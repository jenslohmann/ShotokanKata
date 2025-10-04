//
//  QuizDataService.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 16/08/2025.
//

import Foundation
import Combine

// MARK: - Quiz Data Service Error
enum QuizDataServiceError: Error, LocalizedError {
    case fileNotFound(fileName: String)
    case invalidData(fileName: String)
    case decodingError(fileName: String, error: Error)
    case noQuestionsAvailable(rank: KarateRank)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return "Quiz file not found: \(fileName)"
        case .invalidData(let fileName):
            return "Invalid data in quiz file: \(fileName)"
        case .decodingError(let fileName, let error):
            return "Failed to decode quiz file \(fileName): \(error.localizedDescription)"
        case .noQuestionsAvailable(let rank):
            return "No questions available for rank: \(rank.displayName)"
        }
    }
}

// MARK: - Quiz Data Service
class QuizDataService: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var allQuestions: [QuizQuestion] = []
    private let kataDataService: KataDataService

    init(kataDataService: KataDataService = KataDataService()) {
        self.kataDataService = kataDataService
        loadQuizData()
    }

    // MARK: - Public Methods
    func loadQuizData() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let loadedQuestions = try await loadAllQuestions()
                await MainActor.run {
                    self.allQuestions = loadedQuestions
                    self.questions = loadedQuestions
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("Error loading quiz data: \(error)")
                }
            }
        }
    }

    func getQuestions(for rank: KarateRank, category: QuestionCategory? = nil, limit: Int? = nil) -> [QuizQuestion] {
        var filteredQuestions = allQuestions.filter { question in
            // Check if question is appropriate for the rank or lower
            guard let questionRank = question.rank else { return false }
            return questionRank.sortOrder <= rank.sortOrder
        }

        // Filter by category if specified
        if let category = category {
            filteredQuestions = filteredQuestions.filter { $0.category == category }
        }

        // Shuffle and limit if specified
        filteredQuestions.shuffle()
        if let limit = limit {
            filteredQuestions = Array(filteredQuestions.prefix(limit))
        }

        return filteredQuestions
    }

    func getQuestions(for difficultyLevel: DifficultyLevel, category: QuestionCategory? = nil, limit: Int? = nil) -> [QuizQuestion] {
        let associatedRanks = difficultyLevel.associatedRanks
        var filteredQuestions = allQuestions.filter { question in
            guard let questionRank = question.rank else { return false }
            return associatedRanks.contains(questionRank)
        }

        // Filter by category if specified
        if let category = category {
            filteredQuestions = filteredQuestions.filter { $0.category == category }
        }

        // Shuffle and limit if specified
        filteredQuestions.shuffle()
        if let limit = limit {
            filteredQuestions = Array(filteredQuestions.prefix(limit))
        }

        return filteredQuestions
    }

    func getAvailableCategories(for rank: KarateRank) -> [QuestionCategory] {
        let availableQuestions = getQuestions(for: rank)
        let categories = Set(availableQuestions.map { $0.category })
        return Array(categories).sorted { $0.rawValue < $1.rawValue }
    }

    func getQuestionCount(for rank: KarateRank, category: QuestionCategory? = nil) -> Int {
        return getQuestions(for: rank, category: category).count
    }

    // MARK: - Private Methods
    private func loadAllQuestions() async throws -> [QuizQuestion] {
        print("Loading quiz questions...")

        // First load kata data for dynamic question generation using the proper async method
        let availableKata = try await kataDataService.loadKataDataAsync()
        print("Kata data loaded for quiz generation: \(availableKata.count) kata available")

        // Generate static questions
        var allQuestions = generateStaticQuestions()
        print("Generated \(allQuestions.count) static questions:")
        for (index, question) in allQuestions.enumerated() {
            print("  \(index + 1). [\(question.questionType.displayName)] \(question.question)")
            print("     Options: \(question.options)")

            // Handle different question types for correct answer display
            if question.questionType == .kataKiaiSelection {
                if let correctIndices = question.correctMoveIndices {
                    print("     Correct moves: \(correctIndices.map(String.init).joined(separator: ", "))")
                } else {
                    print("     Correct moves: None specified")
                }
            } else if !question.options.isEmpty && question.correctAnswerIndex < question.options.count {
                print("     Correct: \(question.options[question.correctAnswerIndex])")
            } else {
                print("     Correct: Invalid index or empty options")
            }

            print("     Rank: \(question.rankDisplayName)")
            print("     Category: \(question.category.rawValue)")
            print("")
        }

        // Generate dynamic questions based on available kata
        let dynamicQuestions = generateDynamicQuestions(with: availableKata)
        allQuestions.append(contentsOf: dynamicQuestions)

        print("Generated \(dynamicQuestions.count) dynamic questions:")
        for (index, question) in dynamicQuestions.enumerated() {
            print("  \(index + 1). [\(question.questionType.displayName)] \(question.question)")
            print("     Options: \(question.options)")

            // Handle different question types for correct answer display
            if question.questionType == .kataKiaiSelection {
                if let correctIndices = question.correctMoveIndices {
                    print("     Correct moves: \(correctIndices.map(String.init).joined(separator: ", "))")
                } else {
                    print("     Correct moves: None specified")
                }
            } else if !question.options.isEmpty && question.correctAnswerIndex < question.options.count {
                print("     Correct: \(question.options[question.correctAnswerIndex])")
            } else {
                print("     Correct: Invalid index or empty options")
            }

            print("     Rank: \(question.rankDisplayName)")
            print("     Category: \(question.category.rawValue)")
            print("")
        }

        print("Generated \(allQuestions.count) total quiz questions (\(allQuestions.filter { $0.questionType == .staticQuestion }.count) static, \(allQuestions.filter { $0.questionType != .staticQuestion }.count) dynamic)")
        return allQuestions
    }

    // MARK: - Static Questions Generation
    private func generateStaticQuestions() -> [QuizQuestion] {
        var questions: [QuizQuestion] = []

        // Basic questions for 9th Kyu (Heian Shodan level)
        questions.append(QuizQuestion(
            question: "What is the first kata learned in Shōtōkan karate?",
            options: ["Heian Shodan", "Heian Nidan", "Tekki Shodan", "Bassai Dai"],
            correctAnswerIndex: 0,
            category: .kataOrder,
            questionType: .staticQuestion,
            requiredRank: "9_kyu",
            explanation: "Heian Shodan is traditionally the first kata taught to beginners in Shōtōkan karate.",
            relatedKataNames: ["Heian Shodan"]
        ))

        questions.append(QuizQuestion(
            question: "What does 'Heian' mean in English?",
            options: ["Peace", "Strength", "Power", "Balance"],
            correctAnswerIndex: 0,
            category: .terminology,
            questionType: .staticQuestion,
            requiredRank: "9_kyu",
            explanation: "Heian means 'peaceful mind' or 'peace' in Japanese.",
            relatedKataNames: ["Heian Shodan", "Heian Nidan", "Heian Sandan", "Heian Yondan", "Heian Godan"]
        ))

        // Intermediate questions for higher kyu ranks
        questions.append(QuizQuestion(
            question: "Which kata is typically learned at 5th Kyu level?",
            options: ["Heian Godan", "Tekki Shodan", "Bassai Dai", "Kanku Dai"],
            correctAnswerIndex: 1,
            category: .ranks,
            questionType: .staticQuestion,
            requiredRank: "5_kyu",
            explanation: "Tekki Shodan is traditionally taught at 5th Kyu (Brown Belt) level.",
            relatedKataNames: ["Tekki Shodan"]
        ))

        questions.append(QuizQuestion(
            question: "What stance is predominantly used in Tekki Shodan?",
            options: ["Zenkutsu-dachi", "Kokutsu-dachi", "Kiba-dachi", "Shiko-dachi"],
            correctAnswerIndex: 2,
            category: .techniques,
            questionType: .staticQuestion,
            requiredRank: "5_kyu",
            explanation: "Tekki Shodan is performed entirely in Kiba-dachi (horse riding stance).",
            relatedKataNames: ["Tekki Shodan"]
        ))

        // Advanced questions for Dan ranks
        questions.append(QuizQuestion(
            question: "Which kata is often considered the flagship kata of Shōtōkan?",
            options: ["Heian Shodan", "Tekki Shodan", "Bassai Dai", "Empi"],
            correctAnswerIndex: 2,
            category: .philosophy,
            questionType: .staticQuestion,
            requiredRank: "1_dan",
            explanation: "Bassai Dai is often considered the flagship kata of Shōtōkan, representing the essence of the style.",
            relatedKataNames: ["Bassai Dai"]
        ))

        questions.append(QuizQuestion(
            question: "What does 'Bassai' mean?",
            options: ["To storm a fortress", "Flying swallow", "Peaceful mind", "Iron horse"],
            correctAnswerIndex: 0,
            category: .terminology,
            questionType: .staticQuestion,
            requiredRank: "1_dan",
            explanation: "Bassai means 'to storm a fortress' or 'to penetrate a fortress', reflecting the powerful nature of this kata.",
            relatedKataNames: ["Bassai Dai"]
        ))

        return questions
    }

    // MARK: - Dynamic Questions Generation
    private func generateDynamicQuestions(with availableKata: [Kata]) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []

        // Generate "number of moves" questions for all available kata
        let movesCountQuestions = generateKataMovesCountQuestions(with: availableKata)
        questions.append(contentsOf: movesCountQuestions)

        // Generate "kiai selection" questions for all available kata
        let kiaiSelectionQuestions = generateKataKiaiSelectionQuestions(with: availableKata)
        questions.append(contentsOf: kiaiSelectionQuestions)

        // Generate "technique" questions for specific moves in kata
        let techniqueQuestions = generateKataTechniqueQuestions(with: availableKata)
        questions.append(contentsOf: techniqueQuestions)

        // Generate "stance" questions for specific moves in kata
        let stanceQuestions = generateKataStanceQuestions(with: availableKata)
        questions.append(contentsOf: stanceQuestions)

        return questions
    }

    // MARK: - Kata Moves Count Questions Generation
    private func generateKataMovesCountQuestions(with availableKata: [Kata]) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []
        let allMoveCounts = Set(availableKata.map { $0.numberOfMoves })

        for kata in availableKata {
            let correctAnswer = kata.numberOfMoves
            let correctAnswerString = String(correctAnswer)

            // Generate 3 incorrect options
            var incorrectOptions: [String] = []

            // Option 1: Random close number (±1 to ±3)
            let randomOffset = [-3, -2, -1, 1, 2, 3].randomElement() ?? 1
            let closeNumber = max(1, correctAnswer + randomOffset)
            if closeNumber != correctAnswer {
                incorrectOptions.append(String(closeNumber))
            }

            // Option 2: Another kata's move count (if different)
            let otherMoveCounts = allMoveCounts.filter { $0 != correctAnswer }
            if let otherMoveCount = otherMoveCounts.randomElement() {
                incorrectOptions.append(String(otherMoveCount))
            }

            // Option 3: Generate a reasonable random number in kata range (15-30)
            let randomNumber = Int.random(in: 15...30)
            if randomNumber != correctAnswer && !incorrectOptions.contains(String(randomNumber)) {
                incorrectOptions.append(String(randomNumber))
            }

            // Ensure we have exactly 3 incorrect options
            while incorrectOptions.count < 3 {
                let randomNum = Int.random(in: max(1, correctAnswer - 5)...(correctAnswer + 5))
                let randomString = String(randomNum)
                if randomNum != correctAnswer && !incorrectOptions.contains(randomString) {
                    incorrectOptions.append(randomString)
                }
            }

            // Take only first 3 incorrect options
            incorrectOptions = Array(incorrectOptions.prefix(3))

            // Create all options and shuffle
            var allOptions = [correctAnswerString] + incorrectOptions
            allOptions.shuffle()

            // Find the correct answer index after shuffling
            guard let correctIndex = allOptions.firstIndex(of: correctAnswerString) else {
                continue // Skip this question if we can't find the correct answer
            }

            let question = QuizQuestion(
                question: "How many moves are in \(kata.name)?",
                options: allOptions,
                correctAnswerIndex: correctIndex,
                category: .sequences,
                questionType: .kataMovesCount,
                requiredRank: kata.beltRank,
                explanation: "\(kata.name) contains \(correctAnswer) moves in total.",
                relatedKataNames: [kata.name]
            )

            questions.append(question)
        }

        print("Generated \(questions.count) kata moves count questions")
        return questions
    }

    // MARK: - Kata Kiai Selection Questions Generation
    private func generateKataKiaiSelectionQuestions(with availableKata: [Kata]) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []

        for kata in availableKata {
            // Find all moves with kiai
            let kiaiMoves = kata.moves.filter { $0.kiai == true }

            // Only generate kiai selection questions for kata that have kiai moves
            guard !kiaiMoves.isEmpty else {
                continue
            }

            // Get the correct move indices (sequence numbers)
            let correctMoveIndices = kiaiMoves.map { $0.sequence }

            // Create explanation
            let kiaiMoveDescriptions = kiaiMoves.map { "move \($0.sequence)" }
            let explanationText: String
            if kiaiMoves.count == 1 {
                explanationText = "In \(kata.name), kiai is performed on \(kiaiMoveDescriptions[0])."
            } else {
                explanationText = "In \(kata.name), kiai is performed on \(kiaiMoveDescriptions.joined(separator: " and "))."
            }

            // Create the kiai selection question
            let question = QuizQuestion(
                question: "Select the moves where the karateka should say kiai in \(kata.name):",
                options: [], // Empty for interactive selection
                correctAnswerIndex: 0, // Not used for selection questions
                category: .sequences,
                questionType: .kataKiaiSelection,
                requiredRank: kata.beltRank,
                explanation: explanationText,
                relatedKataNames: [kata.name],
                kataData: kata,
                correctMoveIndices: correctMoveIndices
            )

            questions.append(question)
        }

        print("Generated \(questions.count) kata kiai selection questions")
        return questions
    }

    // MARK: - Kata Technique Questions Generation
    private func generateKataTechniqueQuestions(with availableKata: [Kata]) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []

        // Collect all unique techniques from all kata for generating distractors
        var allTechniques: Set<String> = []
        for kata in availableKata {
            for move in kata.moves {
                for subMove in move.subMoves {
                    allTechniques.insert(subMove.technique)
                }
            }
        }
        let techniqueArray = Array(allTechniques)

        // Need at least 5 techniques to generate meaningful questions (1 correct + 4 distractors)
        guard techniqueArray.count >= 5 else {
            print("Not enough unique techniques (\(techniqueArray.count)) to generate technique questions")
            return questions
        }

        for kata in availableKata {
            // Generate questions for moves that have sub-moves with techniques
            let movesWithTechniques = kata.moves.filter { !$0.subMoves.isEmpty }

            // Limit to a few questions per kata to avoid overwhelming the quiz
            let selectedMoves = Array(movesWithTechniques.shuffled().prefix(2))

            for move in selectedMoves {
                // Use the first sub-move's technique as the correct answer
                guard let firstSubMove = move.subMoves.first else { continue }
                let correctTechnique = firstSubMove.technique

                // Generate 4 incorrect options from other techniques
                let otherTechniques = techniqueArray.filter { $0 != correctTechnique }

                // Ensure we have enough techniques for distractors
                guard otherTechniques.count >= 4 else {
                    print("Not enough distractor techniques for \(correctTechnique)")
                    continue
                }

                let shuffledOtherTechniques = otherTechniques.shuffled()
                let incorrectOptions = Array(shuffledOtherTechniques.prefix(4))

                // Create all options and shuffle
                var allOptions = [correctTechnique] + incorrectOptions
                allOptions.shuffle()

                // Find the correct answer index after shuffling
                guard let correctIndex = allOptions.firstIndex(of: correctTechnique) else {
                    continue
                }

                let sequenceText = move.sequenceName ?? String(move.sequence)
                let question = QuizQuestion(
                    question: "What technique is used in \(kata.name) in step \(sequenceText)?",
                    options: allOptions,
                    correctAnswerIndex: correctIndex,
                    category: .techniques,
                    questionType: .kataTechniques,
                    requiredRank: kata.beltRank,
                    explanation: "The technique used in \(kata.name) step \(sequenceText) is \(correctTechnique).",
                    relatedKataNames: [kata.name]
                )

                questions.append(question)
            }
        }

        print("Generated \(questions.count) kata technique questions")
        return questions
    }

    // MARK: - Kata Stance Questions Generation
    private func generateKataStanceQuestions(with availableKata: [Kata]) -> [QuizQuestion] {
        var questions: [QuizQuestion] = []

        // Collect all unique stances from all kata for generating distractors
        var allStances: Set<String> = []
        for kata in availableKata {
            for move in kata.moves {
                for subMove in move.subMoves {
                    allStances.insert(subMove.stance)
                }
            }
        }
        let stanceArray = Array(allStances)

        // Need at least 5 stances to generate meaningful questions (1 correct + 4 distractors)
        guard stanceArray.count >= 5 else {
            print("Not enough unique stances (\(stanceArray.count)) to generate stance questions")
            return questions
        }

        for kata in availableKata {
            // Generate questions for moves that have sub-moves with stances
            let movesWithStances = kata.moves.filter { !$0.subMoves.isEmpty }

            // Limit to a few questions per kata to avoid overwhelming the quiz
            let selectedMoves = Array(movesWithStances.shuffled().prefix(2))

            for move in selectedMoves {
                // Use the first sub-move's stance as the correct answer
                guard let firstSubMove = move.subMoves.first else { continue }
                let correctStance = firstSubMove.stance

                // Generate 4 incorrect options from other stances
                let otherStances = stanceArray.filter { $0 != correctStance }

                // Ensure we have enough stances for distractors
                guard otherStances.count >= 4 else {
                    print("Not enough distractor stances for \(correctStance)")
                    continue
                }

                let shuffledOtherStances = otherStances.shuffled()
                let incorrectOptions = Array(shuffledOtherStances.prefix(4))

                // Create all options and shuffle
                var allOptions = [correctStance] + incorrectOptions
                allOptions.shuffle()

                // Find the correct answer index after shuffling
                guard let correctIndex = allOptions.firstIndex(of: correctStance) else {
                    continue
                }

                let sequenceText = move.sequenceName ?? String(move.sequence)
                let question = QuizQuestion(
                    question: "What stance is used in \(kata.name) in step \(sequenceText)?",
                    options: allOptions,
                    correctAnswerIndex: correctIndex,
                    category: .techniques,
                    questionType: .kataStances,
                    requiredRank: kata.beltRank,
                    explanation: "The stance used in \(kata.name) step \(sequenceText) is \(correctStance).",
                    relatedKataNames: [kata.name]
                )

                questions.append(question)
            }
        }

        print("Generated \(questions.count) kata stance questions")
        return questions
    }
}

// MARK: - Quiz Data Service Extensions
extension QuizDataService {
    func searchQuestions(searchText: String, rank: KarateRank? = nil, category: QuestionCategory? = nil) -> [QuizQuestion] {
        var filteredQuestions = allQuestions

        // Filter by rank if specified
        if let rank = rank {
            filteredQuestions = getQuestions(for: rank)
        }

        // Filter by category if specified
        if let category = category {
            filteredQuestions = filteredQuestions.filter { $0.category == category }
        }

        // Filter by search text
        if !searchText.isEmpty {
            filteredQuestions = filteredQuestions.filter { question in
                question.question.localizedCaseInsensitiveContains(searchText) ||
                question.options.joined(separator: " ").localizedCaseInsensitiveContains(searchText) ||
                (question.explanation?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                (question.relatedKataNames?.joined(separator: " ").localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }

        return filteredQuestions
    }
}
