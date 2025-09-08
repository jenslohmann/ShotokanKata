//
//  QuestionCategory.swift
//  Shotokan Kata
//
//  Created by Jens Lohmann on 16/08/2025.
//

import Foundation

// MARK: - Question Category
enum QuestionCategory: String, CaseIterable, Codable {
    case history = "history"
    case techniques = "techniques"
    case sequences = "sequences"
    case applications = "applications"
    case ranks = "ranks"
    case kataOrder = "kata_order"
    case terminology = "terminology"
    case philosophy = "philosophy"

    var displayName: String {
        switch self {
        case .history:
            return NSLocalizedString("History", comment: "History question category")
        case .techniques:
            return NSLocalizedString("Techniques", comment: "Techniques question category")
        case .sequences:
            return NSLocalizedString("Sequences", comment: "Sequences question category")
        case .applications:
            return NSLocalizedString("Applications", comment: "Applications question category")
        case .ranks:
            return NSLocalizedString("Ranks", comment: "Ranks question category")
        case .kataOrder:
            return NSLocalizedString("Kata Order", comment: "Kata order question category")
        case .terminology:
            return NSLocalizedString("Terminology", comment: "Terminology question category")
        case .philosophy:
            return NSLocalizedString("Philosophy", comment: "Philosophy question category")
        }
    }

    var icon: String {
        switch self {
        case .history:
            return "book.fill"
        case .techniques:
            return "hand.raised.fill"
        case .sequences:
            return "arrow.forward.circle.fill"
        case .applications:
            return "target"
        case .ranks:
            return "medal.fill"
        case .kataOrder:
            return "list.number"
        case .terminology:
            return "character.book.closed.fill"
        case .philosophy:
            return "brain.head.profile"
        }
    }

    var description: String {
        switch self {
        case .history:
            return NSLocalizedString("Questions about the history and origins of Shotokan karate and specific kata", comment: "History category description")
        case .techniques:
            return NSLocalizedString("Questions about specific techniques, stances, and movements in kata", comment: "Techniques category description")
        case .sequences:
            return NSLocalizedString("Questions about the sequence and flow of movements within kata", comment: "Sequences category description")
        case .applications:
            return NSLocalizedString("Questions about practical applications and bunkai of kata movements", comment: "Applications category description")
        case .ranks:
            return NSLocalizedString("Questions about belt ranks, grading requirements, and progression", comment: "Ranks category description")
        case .kataOrder:
            return NSLocalizedString("Questions about the traditional order of learning kata in Shotokan", comment: "Kata order category description")
        case .terminology:
            return NSLocalizedString("Questions about Japanese terminology and names used in karate", comment: "Terminology category description")
        case .philosophy:
            return NSLocalizedString("Questions about the philosophy and principles of Shotokan karate", comment: "Philosophy category description")
        }
    }
}
