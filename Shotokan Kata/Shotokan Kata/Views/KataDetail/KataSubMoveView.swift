//
//  KataSubMoveView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import SwiftUI

struct KataSubMoveView: View {
    let subMove: KataSubMove
    @EnvironmentObject var vocabularyService: VocabularyDataService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SubMoveHeader(subMove: subMove)
            ExpandableDescriptionView(
                description: subMove.description,
                vocabularyTerms: vocabularyService.vocabularyTerms
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Sub-Move Header
private struct SubMoveHeader: View {
    let subMove: KataSubMove
    @EnvironmentObject var vocabularyService: VocabularyDataService

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: subMove.icon)
                .foregroundColor(.blue)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 4) {
                ClickableVocabularyText(
                    text: subMove.technique,
                    vocabularyTerms: vocabularyService.vocabularyTerms
                )
                .font(.body)
                .fontWeight(.medium)

                if let hiragana = subMove.hiragana {
                    Text(hiragana)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                StanceBadge(
                    stance: subMove.stance,
                    hiragana: subMove.stanceHiragana
                )
            }

            Spacer()

            // Show kiai badge if this sub-move has kiai
            if subMove.kiai == true {
                SubMoveKiaiBadge()
            }
        }
    }
}

// MARK: - Sub-Move Kiai Badge
private struct SubMoveKiaiBadge: View {
    var body: some View {
        Text("KIAI!")
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundColor(.red)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.red.opacity(0.1))
            .clipShape(Capsule())
    }
}

