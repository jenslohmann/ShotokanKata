//
//  VocabularyDataService.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 07/10/2025.
//

import Foundation

// MARK: - Vocabulary Data Service
class VocabularyDataService: ObservableObject {
    @Published var vocabularyTerms: [VocabularyTerm] = []

    init() {
        loadVocabulary()
    }

    private func loadVocabulary() {
        guard let url = Bundle.main.url(forResource: "vocabulary", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let vocabularyResponse = try? JSONDecoder().decode(VocabularyResponse.self, from: data) else {
            print("Warning: Could not load vocabulary.json from bundle")
            return
        }

        vocabularyTerms = vocabularyResponse.vocabularyTerms.sorted { $0.term < $1.term }
    }

    // MARK: - Helper Methods
    func termsByCategory(_ category: VocabularyCategory) -> [VocabularyTerm] {
        vocabularyTerms.filter { $0.categoryType == category }
    }

    func searchTerms(_ searchText: String) -> [VocabularyTerm] {
        if searchText.isEmpty {
            return vocabularyTerms
        }
        return vocabularyTerms.filter {
            $0.term.localizedCaseInsensitiveContains(searchText) ||
            $0.japaneseName.localizedCaseInsensitiveContains(searchText) ||
            $0.hiraganaName.localizedCaseInsensitiveContains(searchText) ||
            $0.definition.localizedCaseInsensitiveContains(searchText)
        }
    }

    func categoriesWithTerms() -> [VocabularyCategory] {
        let categories = Set(vocabularyTerms.map { $0.categoryType })
        return VocabularyCategory.allCases.filter { categories.contains($0) }
    }
}
