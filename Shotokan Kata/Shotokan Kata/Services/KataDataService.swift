//
//  KataDataService.swift
//  Shotokan Kata
//
//  Created by Jens Lohmann on 16/08/2025.
//

import Foundation
import Combine

// MARK: - Kata Data Service Error
enum KataDataServiceError: Error, LocalizedError {
    case fileNotFound(fileName: String)
    case invalidData(fileName: String)
    case decodingError(fileName: String, error: Error)
    case configurationLoadError(error: Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return "Kata file not found: \(fileName)"
        case .invalidData(let fileName):
            return "Invalid data in kata file: \(fileName)"
        case .decodingError(let fileName, let error):
            return "Failed to decode kata file \(fileName): \(error.localizedDescription)"
        case .configurationLoadError(let error):
            return "Failed to load kata configuration: \(error.localizedDescription)"
        }
    }
}

// MARK: - Kata Data Service
class KataDataService: ObservableObject {
    @Published var kata: [Kata] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var configuration: KataConfiguration?

    init() {
        loadKataData()
    }

    // MARK: - Public Methods
    func loadKataData() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let loadedKata = try await loadAllKata()
                await MainActor.run {
                    self.kata = loadedKata.sorted { $0.kataNumber < $1.kataNumber }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("Error loading kata data: \(error)")
                }
            }
        }
    }

    // New async method that can be awaited
    func loadKataDataAsync() async throws -> [Kata] {
        print("Loading kata data asynchronously...")
        let loadedKata = try await loadAllKata()

        await MainActor.run {
            self.kata = loadedKata.sorted { $0.kataNumber < $1.kataNumber }
            self.isLoading = false
        }

        return self.kata
    }

    func getKataByNumber(_ number: Int) -> Kata? {
        return kata.first { $0.kataNumber == number }
    }

    func getKataByRank(_ rank: KarateRank) -> [Kata] {
        return kata.filter { $0.rank == rank }
    }

    func getKataByBeltColor(_ beltColor: BeltColor) -> [Kata] {
        return kata.filter { $0.beltColor == beltColor }
    }

    // MARK: - Private Methods
    private func loadAllKata() async throws -> [Kata] {
        print("Starting to load kata data...")

        // Load configuration first
        try await loadConfiguration()

        guard let config = configuration else {
            throw KataDataServiceError.configurationLoadError(error: NSError(domain: "KataDataService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Configuration not loaded"]))
        }

        var loadedKata: [Kata] = []

        // Load only enabled kata from configuration
        let enabledKataFiles = config.availableKata.filter { $0.enabled }
        print("Found \(enabledKataFiles.count) enabled kata files in configuration")

        for kataFileInfo in enabledKataFiles {
            print("Attempting to load kata file: \(kataFileInfo.fileName)")

            do {
                let kata = try await loadKataFromFile(kataFileInfo.fileName)
                loadedKata.append(kata)
                print("Successfully loaded kata: \(kata.name)")
            } catch {
                print("Error loading kata from file \(kataFileInfo.fileName): \(error)")
                // Continue loading other kata even if one fails
            }
        }

        print("Total kata loaded: \(loadedKata.count)")
        return loadedKata
    }

    private func loadConfiguration() async throws {
        print("Loading kata configuration...")

        guard let configURL = Bundle.main.url(forResource: "kata", withExtension: "json") else {
            throw KataDataServiceError.fileNotFound(fileName: "kata.json")
        }

        do {
            let configData = try Data(contentsOf: configURL)
            let decoder = JSONDecoder()
            configuration = try decoder.decode(KataConfiguration.self, from: configData)
            print("Configuration loaded successfully with \(configuration?.availableKata.count ?? 0) kata entries")
        } catch {
            throw KataDataServiceError.configurationLoadError(error: error)
        }
    }

    private func loadKataFromFile(_ fileName: String) async throws -> Kata {
        let jsonFileName = "\(fileName).json"

        // Try multiple methods to find the file in the bundle
        var url: URL?

        // Method 1: Try subdirectory approach
        url = Bundle.main.url(forResource: fileName, withExtension: "json", subdirectory: "kata")

        // Method 2: If that fails, try direct path in Resources/kata
        if url == nil {
            url = Bundle.main.url(forResource: "kata/\(fileName)", withExtension: "json")
        }

        // Method 3: If that fails, try without subdirectory (this is working)
        if url == nil {
            url = Bundle.main.url(forResource: fileName, withExtension: "json")
        }

        guard let finalURL = url else {
            print("❌ File not found: \(jsonFileName)")
            throw KataDataServiceError.fileNotFound(fileName: fileName)
        }

        do {
            let data = try Data(contentsOf: finalURL)
            let decoder = JSONDecoder()
            let kata = try decoder.decode(Kata.self, from: data)
            print("✅ Successfully loaded kata: \(kata.name)")
            return kata
        } catch let decodingError as DecodingError {
            print("❌ Decoding error for \(fileName): \(decodingError)")
            throw KataDataServiceError.decodingError(fileName: fileName, error: decodingError)
        } catch {
            print("❌ General error loading \(fileName): \(error)")
            throw KataDataServiceError.invalidData(fileName: fileName)
        }
    }
}

// MARK: - Kata Data Service Extension for Filtering
extension KataDataService {
    func filterKata(by searchText: String, rank: KarateRank? = nil, beltColor: BeltColor? = nil) -> [Kata] {
        var filteredKata = kata

        // Filter by search text
        if !searchText.isEmpty {
            filteredKata = filteredKata.filter { kata in
                kata.name.localizedCaseInsensitiveContains(searchText) ||
                kata.japaneseName.localizedCaseInsensitiveContains(searchText) ||
                kata.keyTechniques.joined(separator: " ").localizedCaseInsensitiveContains(searchText)
            }
        }

        // Filter by rank
        if let rank = rank {
            filteredKata = filteredKata.filter { $0.rank == rank }
        }

        // Filter by belt color
        if let beltColor = beltColor {
            filteredKata = filteredKata.filter { $0.beltColor == beltColor }
        }

        return filteredKata.sorted { $0.kataNumber < $1.kataNumber }
    }
}
