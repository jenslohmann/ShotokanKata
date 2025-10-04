//
//  QuizQuestion.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 16/08/2025.
//

import Foundation

// MARK: - Question Type Enum
enum QuestionType: String, CaseIterable, Codable {
    case staticQuestion = "static_question"     // Fixed questions that don't change
    case kataMovesCount = "kata_moves_count"    // Dynamic questions about number of moves in kata
    case kataKiaiSelection = "kata_kiai_selection" // Interactive kata display for kiai selection
    case kataTechniques = "kata_techniques"     // Dynamic questions about techniques in kata moves
    case kataStances = "kata_stances"          // Dynamic questions about stances in kata moves
    case kataRank = "kata_rank"                // Dynamic questions about kata rank requirements
    case kataOrder = "kata_order"              // Dynamic questions about kata order in curriculum

    var displayName: String {
        switch self {
        case .staticQuestion:
            return "Static Question"
        case .kataMovesCount:
            return "Kata Moves Count"
        case .kataKiaiSelection:
            return "Kata Kiai Selection"
        case .kataTechniques:
            return "Kata Techniques"
        case .kataStances:
            return "Kata Stances"
        case .kataRank:
            return "Kata Rank"
        case .kataOrder:
            return "Kata Order"
        }
    }
}

// MARK: - Quiz Question Model
struct QuizQuestion: Identifiable, Codable {
    let id = UUID()
    let question: String
    var options: [String] // Changed to var for kiai selection questions
    var correctAnswerIndex: Int // Changed to var for dynamic assignment
    let category: QuestionCategory
    let questionType: QuestionType
    let requiredRank: String // Raw string from JSON (e.g., "9_kyu", "1_dan")
    let explanation: String?
    let relatedKataNames: [String]?
    let kataData: Kata? // Full kata data for kiai selection questions
    let correctMoveIndices: [Int]? // Array of move sequence numbers that have kiai

    // Custom initializer for standard questions
    init(question: String, options: [String], correctAnswerIndex: Int, category: QuestionCategory, questionType: QuestionType, requiredRank: String, explanation: String? = nil, relatedKataNames: [String]? = nil, kataData: Kata? = nil, correctMoveIndices: [Int]? = nil) {
        self.question = question
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.category = category
        self.questionType = questionType
        self.requiredRank = requiredRank
        self.explanation = explanation
        self.relatedKataNames = relatedKataNames
        self.kataData = kataData
        self.correctMoveIndices = correctMoveIndices
    }

    // Computed property to convert string to KarateRank enum
    var rank: KarateRank? {
        KarateRank(rawValue: requiredRank)
    }

    // Computed property for display name of rank
    var rankDisplayName: String {
        rank?.displayName ?? requiredRank
    }

    // Computed property for difficulty level based on rank
    var difficultyLevel: DifficultyLevel {
        guard let rank = rank else { return .beginner }

        if DifficultyLevel.beginner.associatedRanks.contains(rank) {
            return .beginner
        } else if DifficultyLevel.intermediate.associatedRanks.contains(rank) {
            return .intermediate
        } else if DifficultyLevel.advanced.associatedRanks.contains(rank) {
            return .advanced
        } else {
            return .expert
        }
    }

    private enum CodingKeys: String, CodingKey {
        case question, options, correctAnswerIndex, category, questionType, requiredRank, explanation, relatedKataNames, kataData, correctMoveIndices
    }
}
