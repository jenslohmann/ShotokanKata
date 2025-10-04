//
//  Kata.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 16/08/2025.
//

import Foundation

// MARK: - Kata Model
struct Kata: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let japaneseName: String
    let hiraganaName: String?
    let numberOfMoves: Int
    let kataNumber: Int
    let beltRank: String // Raw string from JSON (e.g., "9_kyu", "1_dan")
    let description: String
    let keyTechniques: [String]
    let referenceURL: String?
    let moves: [KataMove]

    // Computed property to convert string to KarateRank enum
    var rank: KarateRank? {
        KarateRank(rawValue: beltRank)
    }

    // Computed property for belt color
    var beltColor: BeltColor {
        rank?.beltColor ?? .white
    }

    // Computed property for display name of rank
    var rankDisplayName: String {
        rank?.displayName ?? beltRank
    }

    // MARK: - Sequence Organization

    // Get moves by sequence name (nil sequenceName treated as main sequence)
    func moves(for sequenceName: String?) -> [KataMove] {
        return moves.filter { $0.sequenceName == sequenceName }.sorted { $0.sequence < $1.sequence }
    }

    // Get all unique sequence names in order of first appearance by sequence number
    var sequenceNames: [String?] {
        let sortedMoves = moves.sorted { $0.sequence < $1.sequence }
        var uniqueSequences: [String?] = []
        for move in sortedMoves {
            if !uniqueSequences.contains(move.sequenceName) {
                uniqueSequences.append(move.sequenceName)
            }
        }
        return uniqueSequences
    }

    private enum CodingKeys: String, CodingKey {
        case name, japaneseName, hiraganaName, numberOfMoves, kataNumber, beltRank, description, keyTechniques, referenceURL, moves
    }
}

// MARK: - Kata Move Model
struct KataMove: Codable, Hashable {
    let sequence: Int
    let japaneseName: String
    let direction: String
    let kiai: Bool?
    let subMoves: [KataSubMove]
    let sequenceName: String? // Optional field for sequence categorization (e.g., "preparation", "main", "conclusion")

    private enum CodingKeys: String, CodingKey {
        case sequence, japaneseName, direction, kiai, subMoves, sequenceName
    }
}

// MARK: - Kata Sub-Move Model
struct KataSubMove: Codable, Hashable {
    let order: Int
    let technique: String
    let hiragana: String?
    let stance: String
    let stanceHiragana: String?
    let description: String
    let icon: String

    private enum CodingKeys: String, CodingKey {
        case order, technique, hiragana, stance, stanceHiragana, description, icon
    }
}
