//
//  VocabularyViewModel.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 07/10/2025.
//

import Foundation
import Combine

class VocabularyViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: VocabularyCategory?
    @Published var filteredTerms: [VocabularyTerm] = []

    private let dataService = VocabularyDataService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Observe data service changes
        dataService.$vocabularyTerms
            .combineLatest($searchText, $selectedCategory)
            .map { [weak self] terms, searchText, selectedCategory in
                self?.filterTerms(terms: terms, searchText: searchText, selectedCategory: selectedCategory) ?? []
            }
            .assign(to: \.filteredTerms, on: self)
            .store(in: &cancellables)
    }

    var vocabularyDataService: VocabularyDataService {
        dataService
    }

    var availableCategories: [VocabularyCategory] {
        dataService.categoriesWithTerms()
    }

    private func filterTerms(terms: [VocabularyTerm], searchText: String, selectedCategory: VocabularyCategory?) -> [VocabularyTerm] {
        var filtered = terms

        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.categoryType == category }
        }

        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.term.localizedCaseInsensitiveContains(searchText) ||
                $0.japaneseName.localizedCaseInsensitiveContains(searchText) ||
                $0.hiraganaName.localizedCaseInsensitiveContains(searchText) ||
                $0.definition.localizedCaseInsensitiveContains(searchText)
            }
        }

        return filtered.sorted { $0.term < $1.term }
    }

    func clearFilters() {
        searchText = ""
        selectedCategory = nil
    }
}
