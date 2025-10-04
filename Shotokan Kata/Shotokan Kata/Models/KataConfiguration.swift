//
//  KataConfiguration.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 22/08/2025.
//

import Foundation

// MARK: - Kata Configuration Model
struct KataConfiguration: Codable {
    let availableKata: [KataFileInfo]
}

// MARK: - Kata File Info Model
struct KataFileInfo: Codable, Identifiable {
    let id = UUID()
    let fileName: String
    let kataNumber: Int
    let name: String
    let enabled: Bool

    private enum CodingKeys: String, CodingKey {
        case fileName, kataNumber, name, enabled
    }
}
