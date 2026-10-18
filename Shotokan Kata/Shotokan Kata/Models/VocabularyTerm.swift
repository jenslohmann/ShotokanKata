//
//  VocabularyTerm.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 07/10/2025.
//

import Foundation

// MARK: - Vocabulary Models
struct VocabularyResponse: Codable {
    let vocabularyTerms: [VocabularyTerm]
}

struct VocabularyTerm: Identifiable, Codable, Hashable {
    let id: Int
    let term: String
    let japaneseName: String
    let hiraganaName: String
    var shortDescription: String
    var definition: String
    let category: String
    var componentBreakdown: String?

    var categoryType: VocabularyCategory {
        VocabularyCategory(category: category)
    }
}

enum VocabularyCategory: String, CaseIterable, Codable {
    case general = "general"
    case etiquette = "etiquette"
    case titles = "titles"
    case techniques = "techniques"
    case stances = "stances"
    case blocks = "blocks"
    case strikesPunches = "strikes_punches" // Strikes (uchi) and punches (zuki/tsuki)
    case kicks = "kicks"
    case training = "training"
    case ranks = "ranks"
    case equipment = "equipment"

    // Category from the vocabulary data; "strikes" and "punches" share one category
    init(category: String) {
        switch category {
        case "strikes", "punches":
            self = .strikesPunches
        default:
            self = VocabularyCategory(rawValue: category) ?? .general
        }
    }

    var displayName: String {
        switch self {
        case .general:
            return NSLocalizedString("vocabulary.category.general", comment: "General")
        case .etiquette:
            return NSLocalizedString("vocabulary.category.etiquette", comment: "Etiquette")
        case .titles:
            return NSLocalizedString("vocabulary.category.titles", comment: "Titles")
        case .techniques:
            return NSLocalizedString("vocabulary.category.techniques", comment: "Techniques")
        case .stances:
            return NSLocalizedString("vocabulary.category.stances", comment: "Stances")
        case .blocks:
            return NSLocalizedString("vocabulary.category.blocks", comment: "Blocks")
        case .strikesPunches:
            return NSLocalizedString("vocabulary.category.strikes_punches", comment: "Strikes, punches")
        case .kicks:
            return NSLocalizedString("vocabulary.category.kicks", comment: "Kicks")
        case .training:
            return NSLocalizedString("vocabulary.category.training", comment: "Training")
        case .ranks:
            return NSLocalizedString("vocabulary.category.ranks", comment: "Ranks")
        case .equipment:
            return NSLocalizedString("vocabulary.category.equipment", comment: "Equipment")
        }
    }

    var systemImage: String {
        switch self {
        case .general:
            return "book.fill"
        case .etiquette:
            return "hands.sparkles.fill"
        case .titles:
            return "person.fill.badge.plus"
        case .techniques:
            return "figure.martial.arts"
        case .stances:
            return "figure.stand"
        case .blocks:
            return "shield.fill"
        case .strikesPunches:
            return "hand.raised.fill"
        case .kicks:
            return "figure.kickboxing"
        case .training:
            return "dumbbell.fill"
        case .ranks:
            return "medal.fill"
        case .equipment:
            return "gear"
        }
    }
}
