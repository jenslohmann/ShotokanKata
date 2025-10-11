//
//  VocabularyHeaderView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 07/10/2025.
//

import SwiftUI

struct VocabularyHeaderView: View {
    let term: VocabularyTerm

    var body: some View {
        VStack(spacing: 1) {
            // Main term and Japanese characters
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(term.term)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    HStack {
                        Text(term.japaneseName)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)

                        Text("•")
                            .foregroundColor(.secondary)

                        Text(term.hiraganaName)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Category icon
                Image(systemName: term.categoryType.systemImage)
                    .font(.title2)
                    .foregroundColor(.blue)
            }

            // Short description
            HStack {
                Text(term.shortDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}

#Preview {
    VocabularyHeaderView(term: VocabularyTerm(
        id: 1,
        term: "Kata",
        japaneseName: "型",
        hiraganaName: "かた",
        shortDescription: "Predetermined sequence of karate movements",
        definition: "A sequence of karate movements performed in a predetermined pattern against imaginary opponents.",
        category: "general",
        componentBreakdown: "型 (kata) - This single kanji character means 'form', 'shape', or 'mold'. It represents the concept of a fixed pattern or template that preserves traditional techniques and movements for future generations."
    ))
}
