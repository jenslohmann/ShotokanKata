//
//  KataListViewModel.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 16/08/2025.
//

import Foundation
import Combine

// MARK: - Kata List View Model
class KataListViewModel: ObservableObject {
    @Published var kata: [Kata] = []
    @Published var filteredKata: [Kata] = []
    @Published var searchText = ""
    @Published var selectedRank: KarateRank?
    @Published var selectedBeltColor: BeltColor?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let kataDataService: KataDataService
    private var cancellables = Set<AnyCancellable>()

    init(kataDataService: KataDataService = KataDataService()) {
        self.kataDataService = kataDataService
        setupBindings()
        loadKata()
    }

    // MARK: - Public Methods
    func loadKata() {
        kataDataService.loadKataData()
    }

    func clearFilters() {
        searchText = ""
        selectedRank = nil
        selectedBeltColor = nil
    }

    func filterByRank(_ rank: KarateRank?) {
        selectedRank = rank
        selectedBeltColor = nil // Clear belt color filter when rank is selected
    }

    func filterByBeltColor(_ beltColor: BeltColor?) {
        selectedBeltColor = beltColor
        selectedRank = nil // Clear rank filter when belt color is selected
    }

    // MARK: - Computed Properties
    var availableRanks: [KarateRank] {
        let uniqueRanks = Set(kata.compactMap { $0.rank })
        return Array(uniqueRanks).sorted { $0.sortOrder < $1.sortOrder }
    }

    var availableBeltColors: [BeltColor] {
        let uniqueBeltColors = Set(kata.map { $0.beltColor })
        return Array(uniqueBeltColors).sorted { first, second in
            // Sort by the minimum rank order for each belt color
            let firstMinOrder = kata.filter { $0.beltColor == first }.compactMap { $0.rank?.sortOrder }.min() ?? 0
            let secondMinOrder = kata.filter { $0.beltColor == second }.compactMap { $0.rank?.sortOrder }.min() ?? 0
            return firstMinOrder < secondMinOrder
        }
    }

    var kataByBeltColor: [BeltColor: [Kata]] {
        Dictionary(grouping: filteredKata) { $0.beltColor }
    }

    var hasFiltersApplied: Bool {
        !searchText.isEmpty || selectedRank != nil || selectedBeltColor != nil
    }

    // MARK: - Private Methods
    private func setupBindings() {
        // Bind kata data from service
        kataDataService.$kata
            .receive(on: DispatchQueue.main)
            .sink { [weak self] kata in
                self?.kata = kata
            }
            .store(in: &cancellables)

        // Bind loading state from service
        kataDataService.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)

        // Bind error message from service
        kataDataService.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.errorMessage = errorMessage
            }
            .store(in: &cancellables)

        // Set up filtering based on search text and selected filters
        Publishers.CombineLatest4(
            kataDataService.$kata,
            $searchText.debounce(for: .milliseconds(300), scheduler: DispatchQueue.main),
            $selectedRank,
            $selectedBeltColor
        )
        .map { [weak self] kata, searchText, selectedRank, selectedBeltColor in
            self?.kataDataService.filterKata(
                by: searchText,
                rank: selectedRank,
                beltColor: selectedBeltColor
            ) ?? []
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] filteredKata in
            self?.filteredKata = filteredKata
        }
        .store(in: &cancellables)
    }
}

// MARK: - Kata List View Model Extensions
extension KataListViewModel {
    func getKataCount(for beltColor: BeltColor) -> Int {
        filteredKata.filter { $0.beltColor == beltColor }.count
    }

    func getKataCount(for rank: KarateRank) -> Int {
        filteredKata.filter { $0.rank == rank }.count
    }

    func getKata(for beltColor: BeltColor) -> [Kata] {
        filteredKata.filter { $0.beltColor == beltColor }.sorted { $0.kataNumber < $1.kataNumber }
    }

    func getKata(for rank: KarateRank) -> [Kata] {
        filteredKata.filter { $0.rank == rank }.sorted { $0.kataNumber < $1.kataNumber }
    }
}
