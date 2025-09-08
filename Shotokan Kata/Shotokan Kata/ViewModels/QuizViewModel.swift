//
//  QuizViewModel.swift
//  Shotokan Kata
//
//  Created by Jens Lohmann on 16/08/2025.
//

import Foundation
import Combine

// MARK: - Quiz State
enum QuizState {
    case notStarted
    case inProgress
    case completed
    case paused
}

// MARK: - Quiz Result
struct QuizResult {
    let totalQuestions: Int
    let correctAnswers: Int
    let incorrectAnswers: Int
    let skippedQuestions: Int
    let timeSpent: TimeInterval
    let selectedRank: KarateRank
    let selectedCategory: QuestionCategory?
    let questions: [QuizQuestion]
    let userAnswers: [QuizAnswer] // Changed to support different answer types

    var score: Double {
        guard totalQuestions > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100.0
    }

    var isPassing: Bool {
        score >= 70.0 // 70% passing grade
    }
}

// MARK: - Quiz Answer Types
enum QuizAnswer {
    case multipleChoice(Int?)       // Index of selected answer
    case kiaiSelection(Set<Int>)    // Set of selected move indices
    case skipped
}

// MARK: - Quiz View Model
class QuizViewModel: ObservableObject {
    @Published var quizState: QuizState = .notStarted
    @Published var currentQuestionIndex = 0
    @Published var selectedAnswerIndex: Int?
    @Published var showingExplanation = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var totalTimeSpent: TimeInterval = 0
    @Published var userAnswers: [QuizAnswer] = [] // Changed to support different answer types
    @Published var showingResults = false
    @Published var errorMessage: String?

    // Quiz configuration
    @Published var selectedRank: KarateRank = .ninthKyu
    @Published var selectedCategory: QuestionCategory?
    @Published var numberOfQuestions = 10
    @Published var timeLimit: TimeInterval = 600 // 10 minutes default
    @Published var isTimedQuiz = true

    // Current quiz data
    @Published var questions: [QuizQuestion] = []
    @Published var quizResult: QuizResult?

    private let quizDataService: QuizDataService
    private var cancellables = Set<AnyCancellable>()
    private var quizTimer: Timer?
    private var startTime: Date?

    init(quizDataService: QuizDataService = QuizDataService()) {
        self.quizDataService = quizDataService
        setupBindings()
    }

    // MARK: - Computed Properties
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0.0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }

    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }

    var canGoBack: Bool {
        currentQuestionIndex > 0
    }

    var canGoNext: Bool {
        currentQuestionIndex < questions.count - 1
    }

    var hasAnsweredCurrentQuestion: Bool {
        guard currentQuestionIndex < userAnswers.count else { return false }
        switch userAnswers[currentQuestionIndex] {
        case .multipleChoice(let index):
            return index != nil
        case .kiaiSelection(let moves):
            return !moves.isEmpty
        case .skipped:
            return false
        }
    }

    // MARK: - Public Methods
    func startQuiz() {
        loadQuestions()
    }

    func loadQuestions() {
        let availableQuestions = quizDataService.getQuestions(
            for: selectedRank,
            category: selectedCategory,
            limit: numberOfQuestions
        )

        guard !availableQuestions.isEmpty else {
            errorMessage = "No questions available for the selected criteria."
            return
        }

        questions = availableQuestions
        userAnswers = Array(repeating: .skipped, count: questions.count)
        currentQuestionIndex = 0
        selectedAnswerIndex = nil
        showingExplanation = false
        timeRemaining = isTimedQuiz ? timeLimit : 0
        totalTimeSpent = 0
        startTime = Date()
        quizState = .inProgress

        if isTimedQuiz {
            startTimer()
        }
    }

    func selectAnswer(_ answerIndex: Int) {
        selectedAnswerIndex = answerIndex
        if currentQuestionIndex < userAnswers.count {
            userAnswers[currentQuestionIndex] = .multipleChoice(answerIndex)
        }
    }

    func selectKiaiMoves(_ moveIndices: Set<Int>) {
        if currentQuestionIndex < userAnswers.count {
            userAnswers[currentQuestionIndex] = .kiaiSelection(moveIndices)
        }
    }

    func nextQuestion() {
        if showingExplanation {
            // Move to next question
            showingExplanation = false
            selectedAnswerIndex = nil

            if isLastQuestion {
                completeQuiz()
            } else {
                currentQuestionIndex += 1
                // Load previous answer if exists
                if currentQuestionIndex < userAnswers.count {
                    switch userAnswers[currentQuestionIndex] {
                    case .multipleChoice(let index):
                        selectedAnswerIndex = index
                    case .kiaiSelection(let moves):
                        // Handle loading of kiai selection if needed
                        break
                    case .skipped:
                        selectedAnswerIndex = nil
                    }
                }
            }
        } else {
            // Show explanation
            showingExplanation = true
        }
    }

    func previousQuestion() {
        guard canGoBack else { return }
        showingExplanation = false
        currentQuestionIndex -= 1
        switch userAnswers[currentQuestionIndex] {
        case .multipleChoice(let index):
            selectedAnswerIndex = index
        case .kiaiSelection(let moves):
            // Handle loading of kiai selection if needed
            break
        case .skipped:
            selectedAnswerIndex = nil
        }
    }

    func skipQuestion() {
        if currentQuestionIndex < userAnswers.count {
            userAnswers[currentQuestionIndex] = .skipped
        }

        if isLastQuestion {
            completeQuiz()
        } else {
            currentQuestionIndex += 1
            switch userAnswers[currentQuestionIndex] {
            case .multipleChoice(let index):
                selectedAnswerIndex = index
            case .kiaiSelection(let moves):
                // Handle loading of kiai selection if needed
                break
            case .skipped:
                selectedAnswerIndex = nil
            }
        }
    }

    func pauseQuiz() {
        quizState = .paused
        stopTimer()
    }

    func resumeQuiz() {
        quizState = .inProgress
        if isTimedQuiz && timeRemaining > 0 {
            startTimer()
        }
    }

    func completeQuiz() {
        stopTimer()
        quizState = .completed

        let endTime = Date()
        if let startTime = startTime {
            totalTimeSpent = endTime.timeIntervalSince(startTime)
        }

        generateResults()
        showingResults = true
    }

    func restartQuiz() {
        resetQuiz()
        startQuiz()
    }

    func resetQuiz() {
        stopTimer()
        quizState = .notStarted
        currentQuestionIndex = 0
        selectedAnswerIndex = nil
        showingExplanation = false
        questions = []
        userAnswers = []
        quizResult = nil
        showingResults = false
        timeRemaining = 0
        totalTimeSpent = 0
        startTime = nil
        errorMessage = nil
    }

    // MARK: - Configuration Methods
    func setRank(_ rank: KarateRank) {
        selectedRank = rank
    }

    func setCategory(_ category: QuestionCategory?) {
        selectedCategory = category
    }

    func setNumberOfQuestions(_ count: Int) {
        numberOfQuestions = max(1, min(count, 50)) // Limit between 1 and 50
    }

    func setTimeLimit(_ seconds: TimeInterval) {
        timeLimit = max(60, seconds) // Minimum 1 minute
        if isTimedQuiz {
            timeRemaining = timeLimit
        }
    }

    func toggleTimedQuiz() {
        isTimedQuiz.toggle()
        if isTimedQuiz {
            timeRemaining = timeLimit
        } else {
            timeRemaining = 0
            stopTimer()
        }
    }

    // MARK: - Private Methods
    private func setupBindings() {
        quizDataService.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let errorMessage = errorMessage {
                    self?.errorMessage = errorMessage
                }
            }
            .store(in: &cancellables)
    }

    private func startTimer() {
        stopTimer()
        quizTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
    }

    private func stopTimer() {
        quizTimer?.invalidate()
        quizTimer = nil
    }

    private func updateTimer() {
        guard timeRemaining > 0 else {
            completeQuiz()
            return
        }
        timeRemaining -= 1
    }

    private func generateResults() {
        var correctCount = 0
        var incorrectCount = 0
        var skippedCount = 0

        for (index, userAnswer) in userAnswers.enumerated() {
            guard index < questions.count else { continue }

            switch userAnswer {
            case .multipleChoice(let answer):
                if let answer = answer, answer == questions[index].correctAnswerIndex {
                    correctCount += 1
                } else if answer != nil {
                    incorrectCount += 1
                } else {
                    skippedCount += 1
                }
            case .kiaiSelection(let selectedMoves):
                if let correctIndices = questions[index].correctMoveIndices {
                    let correctMoves = Set(correctIndices)
                    if selectedMoves == correctMoves {
                        correctCount += 1
                    } else {
                        incorrectCount += 1
                    }
                } else {
                    // No correct answer defined, mark as incorrect
                    incorrectCount += 1
                }
            case .skipped:
                skippedCount += 1
            }
        }

        quizResult = QuizResult(
            totalQuestions: questions.count,
            correctAnswers: correctCount,
            incorrectAnswers: incorrectCount,
            skippedQuestions: skippedCount,
            timeSpent: totalTimeSpent,
            selectedRank: selectedRank,
            selectedCategory: selectedCategory,
            questions: questions,
            userAnswers: userAnswers
        )
    }
}

// MARK: - Quiz View Model Extensions
extension QuizViewModel {
    func getAvailableQuestionCount() -> Int {
        return quizDataService.getQuestionCount(for: selectedRank, category: selectedCategory)
    }

    func getAvailableCategories() -> [QuestionCategory] {
        return quizDataService.getAvailableCategories(for: selectedRank)
    }

    func isAnswerCorrect(_ answerIndex: Int, for questionIndex: Int) -> Bool {
        guard questionIndex < questions.count else { return false }
        return answerIndex == questions[questionIndex].correctAnswerIndex
    }

    func getScoreColor() -> String {
        guard let result = quizResult else { return "primary" }

        if result.score >= 90 { return "green" }
        if result.score >= 80 { return "blue" }
        if result.score >= 70 { return "orange" }
        return "red"
    }
}
