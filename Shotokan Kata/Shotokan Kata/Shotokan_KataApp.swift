//
//  Shotokan_KataApp.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import SwiftUI

@main
struct Shotokan_KataApp: App {
    @StateObject private var vocabularyService = VocabularyDataService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vocabularyService)
                .preferredColorScheme(nil) // Respect system setting
        }
    }
}
