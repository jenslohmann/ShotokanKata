//
//  VocabularyTermRowView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 07/10/2025.
//

import SwiftUI

struct VocabularyTermRowView: View {
    let term: VocabularyTerm

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(term.term)
                        .font(.headline)
                        .fontWeight(.semibold)

                    Spacer()

                    Image(systemName: term.categoryType.systemImage)
                        .foregroundColor(.blue)
                        .font(.caption)
                }

                HStack {
                    Text(term.japaneseName)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text("•")
                        .foregroundColor(.secondary)

                    Text(term.hiraganaName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(term.shortDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

#Preview {
    VocabularyTermRowView(term: VocabularyTerm(
        id: 1,
        term: "Kata",
        japaneseName: "型",
        hiraganaName: "かた",
        shortDescription: "Predetermined sequence of karate movements",
        definition: "A sequence of karate movements performed in a predetermined pattern against imaginary opponents",
        category: "general"
    ))
    .padding()
}
