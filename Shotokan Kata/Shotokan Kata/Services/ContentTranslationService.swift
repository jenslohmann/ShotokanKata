//
//  ContentTranslationService.swift
//  Shōtōkan Kata
//
//  Translations of the data content (kata, vocabulary and static quiz questions).
//  Files live in Resources/i18n/<lang>/ with the same names and layout as in the web app
//  (src/data/i18n/<lang>/). The i18n folder is copied into the bundle as a folder reference.
//    - kata/<kata file>.json: kata description and sub-move descriptions
//    - vocabulary.json: term texts keyed by term id
//    - quiz.json: static quiz questions keyed by "static-<n>"
//  Only prose is translated; names, techniques, stances and Japanese fields are never translated.
//  A kata or term without a complete translation is shown in English.
//

import Foundation

// MARK: - Translation Models
struct KataTranslation: Codable {
    let description: String
    /// Sub-move descriptions keyed by move sequence, then sub-move order: moves["-1"]["1"].
    let moves: [String: [String: String]]
}

struct VocabularyTermTranslation: Codable {
    let shortDescription: String?
    let definition: String?
    let componentBreakdown: String?
}

struct QuizQuestionTranslation: Codable {
    let question: String
    let options: [String]
    let explanation: String?
}

// MARK: - Content Translation Service
enum ContentTranslationService {
    /// Language of the source data.
    static let sourceLanguage = "en"

    /// The language the app UI is shown in (follows the iOS app language setting).
    static var currentLanguage: String {
        Bundle.main.preferredLocalizations.first ?? sourceLanguage
    }

    // MARK: Kata
    static func localize(_ kata: Kata, fileName: String, language: String = currentLanguage) -> Kata {
        guard language != sourceLanguage,
              let translation: KataTranslation = load(fileName, subdirectory: "i18n/\(language)/kata") else {
            return kata
        }

        var localized = kata
        localized.description = translation.description
        for (moveIndex, move) in kata.moves.enumerated() {
            for (subMoveIndex, subMove) in move.subMoves.enumerated() {
                guard let text = translation.moves[String(move.sequence)]?[String(subMove.order)], !text.isEmpty else {
                    print("⚠️ Incomplete \(language) translation for \(fileName) (move \(move.sequence).\(subMove.order)); using English")
                    return kata
                }
                localized.moves[moveIndex].subMoves[subMoveIndex].description = text
            }
        }
        return localized
    }

    // MARK: Vocabulary
    static func localize(_ terms: [VocabularyTerm], language: String = currentLanguage) -> [VocabularyTerm] {
        guard language != sourceLanguage,
              let translations: [String: VocabularyTermTranslation] = load("vocabulary", subdirectory: "i18n/\(language)") else {
            return terms
        }

        return terms.map { term in
            guard let text = translations[String(term.id)],
                  let shortDescription = text.shortDescription, !shortDescription.isEmpty,
                  let definition = text.definition, !definition.isEmpty,
                  term.componentBreakdown == nil || text.componentBreakdown?.isEmpty == false else {
                return term
            }
            var localized = term
            localized.shortDescription = shortDescription
            localized.definition = definition
            if term.componentBreakdown != nil {
                localized.componentBreakdown = text.componentBreakdown
            }
            return localized
        }
    }

    // MARK: Quiz
    /// Static quiz question translations keyed by "static-<n>" (n = 1-based position of the static question).
    static func staticQuizTranslations(language: String = currentLanguage) -> [String: QuizQuestionTranslation] {
        guard language != sourceLanguage else { return [:] }
        return load("quiz", subdirectory: "i18n/\(language)") ?? [:]
    }

    // MARK: Loading
    private static func load<T: Decodable>(_ name: String, subdirectory: String) -> T? {
        // Only look in the i18n folder: the English source files have the same names
        guard let url = Bundle.main.url(forResource: name, withExtension: "json", subdirectory: subdirectory) else {
            print("⚠️ Translation not found: \(subdirectory)/\(name).json")
            return nil
        }

        do {
            return try JSONDecoder().decode(T.self, from: Data(contentsOf: url))
        } catch {
            print("❌ Failed to load translation \(name): \(error)")
            return nil
        }
    }
}
