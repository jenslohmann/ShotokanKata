//
//  KataOverviewView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import SwiftUI

struct KataOverviewView: View {
    let kata: Kata
    @EnvironmentObject var vocabularyService: VocabularyDataService

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if vocabularyService.vocabularyTerms.isEmpty {
                    Text("⚠️ No vocabulary terms loaded")
                        .foregroundColor(.red)
                        .font(.caption)
                }

                DescriptionSection(description: kata.description, vocabularyTerms: vocabularyService.vocabularyTerms)
                KeyTechniquesSection(techniques: kata.keyTechniques, vocabularyTerms: vocabularyService.vocabularyTerms)
                ReferenceSection(urlString: kata.referenceURL)

                Spacer(minLength: 20)
            }
            .padding()
        }
    }
}

// MARK: - Description Section
private struct DescriptionSection: View {
    let description: String
    let vocabularyTerms: [VocabularyTerm]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)

            ClickableVocabularyText(text: description, vocabularyTerms: vocabularyTerms)
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Key Techniques Section
private struct KeyTechniquesSection: View {
    let techniques: [String]
    let vocabularyTerms: [VocabularyTerm]

    var body: some View {
        if !techniques.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Key Techniques")
                    .font(.headline)

                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 150))
                ], spacing: 8) {
                    ForEach(techniques, id: \.self) { technique in
                        TechniqueBadge(technique: technique, vocabularyTerms: vocabularyTerms)
                    }
                }
            }
        }
    }
}

// MARK: - Technique Badge
private struct TechniqueBadge: View {
    let technique: String
    let vocabularyTerms: [VocabularyTerm]

    var body: some View {
        ClickableVocabularyText(text: technique, vocabularyTerms: vocabularyTerms)
            .font(.caption)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.blue.opacity(0.1))
            .clipShape(Capsule())
    }
}

// MARK: - Reference Section
private struct ReferenceSection: View {
    let urlString: String?

    var body: some View {
        if let urlString = urlString, let url = URL(string: urlString) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Reference")
                    .font(.headline)

                Link(destination: url) {
                    HStack {
                        Image(systemName: "link")
                        Text("Learn More")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                    }
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}
