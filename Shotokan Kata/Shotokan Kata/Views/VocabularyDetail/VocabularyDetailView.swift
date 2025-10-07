//
//  VocabularyDetailView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 07/10/2025.
//

import SwiftUI

struct VocabularyDetailView: View {
    let term: VocabularyTerm

    var body: some View {
        VStack(spacing: 0) {
            VocabularyHeaderView(term: term)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Definition Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("vocabulary.detail.definition", comment: "Definition"))
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(term.definition)
                            .font(.body)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

                    // Category Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("vocabulary.detail.category", comment: "Category"))
                            .font(.headline)
                            .foregroundColor(.primary)

                        HStack {
                            Image(systemName: term.categoryType.systemImage)
                                .foregroundColor(.blue)
                                .font(.title2)

                            Text(term.categoryType.displayName)
                                .font(.body)
                                .foregroundColor(.primary)

                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
        }
        .navigationTitle(term.term)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        VocabularyDetailView(term: VocabularyTerm(
            id: 1,
            term: "Kata",
            japaneseName: "型",
            hiraganaName: "かた",
            shortDescription: "Predetermined sequence of karate movements",
            definition: "A sequence of karate movements performed in a predetermined pattern against imaginary opponents. Kata is one of the three main pillars of karate training, along with kihon (basics) and kumite (sparring).",
            category: "general"
        ))
    }
}
