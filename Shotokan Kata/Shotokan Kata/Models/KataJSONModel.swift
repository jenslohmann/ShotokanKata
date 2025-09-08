//
//  KataJSONModel.swift
//  Shotokan Kata
//
//  Created by Jens Lohmann on 16/08/2025.
//

import Foundation

// MARK: - Legacy Kata JSON Model (for backward compatibility)
// This model supports the old kata_data.json format if needed
struct KataJSONModel: Codable {
    let kata: [LegacyKata]
}

// MARK: - Legacy Kata Model
struct LegacyKata: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let japaneseName: String
    let hiraganaName: String?
    let numberOfMoves: Int
    let kataNumber: Int
    let beltRank: String
    let description: String
    let keyTechniques: [String]
    let referenceURL: String?
    let moves: [LegacyKataMove]?

    // Convert to modern Kata model
    func toKata() -> Kata {
        let modernMoves = moves?.map { $0.toKataMove() } ?? []
        return Kata(
            name: name,
            japaneseName: japaneseName,
            hiraganaName: hiraganaName,
            numberOfMoves: numberOfMoves,
            kataNumber: kataNumber,
            beltRank: beltRank,
            description: description,
            keyTechniques: keyTechniques,
            referenceURL: referenceURL,
            moves: modernMoves
        )
    }

    private enum CodingKeys: String, CodingKey {
        case name, japaneseName, hiraganaName, numberOfMoves, kataNumber, beltRank, description, keyTechniques, referenceURL, moves
    }
}

// MARK: - Legacy Kata Move Model
struct LegacyKataMove: Identifiable, Codable, Hashable {
    let id = UUID()
    let sequence: Int
    let name: String
    let japaneseName: String
    let direction: String
    let kiai: Bool
    let subMoves: [LegacyKataSubMove]?

    // Convert to modern KataMove model
    func toKataMove() -> KataMove {
        let modernSubMoves = subMoves?.map { $0.toKataSubMove() } ?? []
        return KataMove(
            sequence: sequence,
            japaneseName: japaneseName,
            direction: direction,
            kiai: kiai,
            subMoves: modernSubMoves, sequenceName: nil
        )
    }

    private enum CodingKeys: String, CodingKey {
        case sequence, name, japaneseName, direction, kiai, subMoves
    }
}

// MARK: - Legacy Kata Sub-Move Model
struct LegacyKataSubMove: Identifiable, Codable, Hashable {
    let id = UUID()
    let order: Int
    let technique: String
    let hiragana: String?
    let japaneseName: String
    let stance: String
    let stanceHiragana: String?
    let description: String
    let icon: String
    let timing: String

    // Convert to modern KataSubMove model
    func toKataSubMove() -> KataSubMove {
        return KataSubMove(
            order: order,
            technique: technique,
            hiragana: hiragana,
            stance: stance,
            stanceHiragana: stanceHiragana,
            description: description,
            icon: icon
        )
    }

    private enum CodingKeys: String, CodingKey {
        case order, technique, hiragana, japaneseName, stance, stanceHiragana, description, icon, timing
    }
}
