//
//  DifficultyLevel.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import Foundation

// MARK: - Rank System (Kyu and Dan ranks)
enum KarateRank: String, CaseIterable, Codable {
    // Kyu ranks (colored belts) - descending order
    case tenthKyu = "10_kyu"     // White Belt
    case ninthKyu = "9_kyu"      // Yellow Belt
    case eighthKyu = "8_kyu"     // Orange Belt
    case seventhKyu = "7_kyu"    // Green Belt
    case sixthKyu = "6_kyu"      // Purple Belt
    case fifthKyu = "5_kyu"      // Brown Belt
    case fourthKyu = "4_kyu"     // Brown Belt
    case thirdKyu = "3_kyu"      // Brown Belt
    case secondKyu = "2_kyu"     // Brown Belt
    case firstKyu = "1_kyu"      // Brown Belt

    // Dan ranks (black belts) - ascending order
    case firstDan = "1_dan"      // 1st Dan Black Belt
    case secondDan = "2_dan"     // 2nd Dan Black Belt
    case thirdDan = "3_dan"      // 3rd Dan Black Belt
    case fourthDan = "4_dan"     // 4th Dan Black Belt
    case fifthDan = "5_dan"      // 5th Dan Black Belt
    case sixthDan = "6_dan"      // 6th Dan Black Belt
    case seventhDan = "7_dan"    // 7th Dan Black Belt
    case eighthDan = "8_dan"     // 8th Dan Black Belt
    case ninthDan = "9_dan"      // 9th Dan Black Belt
    case tenthDan = "10_dan"     // 10th Dan Black Belt

    var displayName: String {
        switch self {
        case .tenthKyu: return NSLocalizedString("10th Kyū", comment: "Tenth kyu rank")
        case .ninthKyu: return NSLocalizedString("9th Kyū", comment: "Ninth kyu rank")
        case .eighthKyu: return NSLocalizedString("8th Kyū", comment: "Eighth kyu rank")
        case .seventhKyu: return NSLocalizedString("7th Kyū", comment: "Seventh kyu rank")
        case .sixthKyu: return NSLocalizedString("6th Kyū", comment: "Sixth kyu rank")
        case .fifthKyu: return NSLocalizedString("5th Kyū", comment: "Fifth kyu rank")
        case .fourthKyu: return NSLocalizedString("4th Kyū", comment: "Fourth kyu rank")
        case .thirdKyu: return NSLocalizedString("3rd Kyū", comment: "Third kyu rank")
        case .secondKyu: return NSLocalizedString("2nd Kyū", comment: "Second kyu rank")
        case .firstKyu: return NSLocalizedString("1st Kyū", comment: "First kyu rank")
        case .firstDan: return NSLocalizedString("1st Dan", comment: "First dan rank")
        case .secondDan: return NSLocalizedString("2nd Dan", comment: "Second dan rank")
        case .thirdDan: return NSLocalizedString("3rd Dan", comment: "Third dan rank")
        case .fourthDan: return NSLocalizedString("4th Dan", comment: "Fourth dan rank")
        case .fifthDan: return NSLocalizedString("5th Dan", comment: "Fifth dan rank")
        case .sixthDan: return NSLocalizedString("6th Dan", comment: "Sixth dan rank")
        case .seventhDan: return NSLocalizedString("7th Dan", comment: "Seventh dan rank")
        case .eighthDan: return NSLocalizedString("8th Dan", comment: "Eighth dan rank")
        case .ninthDan: return NSLocalizedString("9th Dan", comment: "Ninth dan rank")
        case .tenthDan: return NSLocalizedString("10th Dan", comment: "Tenth dan rank")
        }
    }

    var beltColor: BeltColor {
        switch self {
        case .tenthKyu: return .white
        case .ninthKyu: return .yellow
        case .eighthKyu: return .orange
        case .seventhKyu, .sixthKyu: return .green
        case .fifthKyu, .fourthKyu: return .purple
        case .thirdKyu, .secondKyu, .firstKyu: return .brown
        case .firstDan, .secondDan, .thirdDan, .fourthDan, .fifthDan,
             .sixthDan, .seventhDan, .eighthDan, .ninthDan, .tenthDan: return .black
        }
    }

    var sortOrder: Int {
        switch self {
        case .tenthKyu: return 1
        case .ninthKyu: return 2
        case .eighthKyu: return 3
        case .seventhKyu: return 4
        case .sixthKyu: return 5
        case .fifthKyu: return 6
        case .fourthKyu: return 7
        case .thirdKyu: return 8
        case .secondKyu: return 9
        case .firstKyu: return 10
        case .firstDan: return 11
        case .secondDan: return 12
        case .thirdDan: return 13
        case .fourthDan: return 14
        case .fifthDan: return 15
        case .sixthDan: return 16
        case .seventhDan: return 17
        case .eighthDan: return 18
        case .ninthDan: return 19
        case .tenthDan: return 20
        }
    }
}

// MARK: - Belt Color System
enum BeltColor: String, CaseIterable {
    case white = "white"
    case yellow = "yellow"
    case orange = "orange"
    case green = "green"
    case purple = "purple"
    case brown = "brown"
    case black = "black"

    var displayName: String {
        switch self {
        case .white: return NSLocalizedString("White Belt", comment: "White belt color")
        case .yellow: return NSLocalizedString("Yellow Belt", comment: "Yellow belt color")
        case .orange: return NSLocalizedString("Orange Belt", comment: "Orange belt color")
        case .green: return NSLocalizedString("Green Belt", comment: "Green belt color")
        case .purple: return NSLocalizedString("Purple Belt", comment: "Purple belt color")
        case .brown: return NSLocalizedString("Brown Belt", comment: "Brown belt color")
        case .black: return NSLocalizedString("Black Belt", comment: "Black belt color")
        }
    }
}

// MARK: - Difficulty Level (for quiz and learning progression)
enum DifficultyLevel: String, CaseIterable, Codable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    case expert = "expert"

    var displayName: String {
        switch self {
        case .beginner: return NSLocalizedString("Beginner", comment: "Beginner difficulty level")
        case .intermediate: return NSLocalizedString("Intermediate", comment: "Intermediate difficulty level")
        case .advanced: return NSLocalizedString("Advanced", comment: "Advanced difficulty level")
        case .expert: return NSLocalizedString("Expert", comment: "Expert difficulty level")
        }
    }

    var associatedRanks: [KarateRank] {
        switch self {
        case .beginner:
            return [.tenthKyu, .ninthKyu, .eighthKyu]
        case .intermediate:
            return [.seventhKyu, .sixthKyu, .fifthKyu, .fourthKyu]
        case .advanced:
            return [.thirdKyu, .secondKyu, .firstKyu, .firstDan, .secondDan]
        case .expert:
            return [.thirdDan, .fourthDan, .fifthDan, .sixthDan, .seventhDan, .eighthDan, .ninthDan, .tenthDan]
        }
    }
}
