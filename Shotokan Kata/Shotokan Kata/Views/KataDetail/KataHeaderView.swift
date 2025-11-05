//
//  KataHeaderView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import SwiftUI

struct KataHeaderView: View {
    let kata: Kata

    var body: some View {
        VStack(spacing: 1) {
            headerTopRow
            headerBottomRow
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemGroupedBackground))
    }

    private var headerTopRow: some View {
        HStack {
            KataNumberBadge(number: kata.kataNumber)

            JapaneseNameDisplay(
                hiragana: kata.hiraganaName,
                japanese: kata.japaneseName
            )

            Spacer()

            RankBadgeView(rank: kata.rank)
        }
    }

    private var headerBottomRow: some View {
        HStack {
            Text("Moves: \(kata.numberOfMoves)")
                .font(.caption2)
                .foregroundColor(.primary)

            Spacer()

            Text(KiaiInfoFormatter.format(kata.moves))
                .font(.caption2)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Supporting Views
private struct KataNumberBadge: View {
    let number: Int

    var body: some View {
        Text("#\(number)")
            .font(.subheadline)
            .fontWeight(.semibold)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color.secondary.opacity(0.2))
            .clipShape(Capsule())
    }
}

private struct JapaneseNameDisplay: View {
    let hiragana: String?
    let japanese: String

    var body: some View {
        HStack(spacing: 3) {
            if let hiragana = hiragana {
                Text(hiragana)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }

            Text("(\(japanese))")
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Kiai Info Formatter
struct KiaiInfoFormatter {
    static func format(_ moves: [KataMove]) -> String {
        // Collect all moves that have kiai at move level or sub-move level
        var kiaiMoveNumbers: [Int] = []

        for move in moves {
            // Check if move-level kiai is set
            if move.kiai == true {
                kiaiMoveNumbers.append(move.sequence)
            } else {
                // Check if any sub-move has kiai
                let hasSubMoveKiai = move.subMoves.contains { $0.kiai == true }
                if hasSubMoveKiai {
                    kiaiMoveNumbers.append(move.sequence)
                }
            }
        }

        // Remove duplicates and sort
        kiaiMoveNumbers = Array(Set(kiaiMoveNumbers)).sorted()

        switch kiaiMoveNumbers.count {
        case 0:
            return "No kiai in this kata."
        case 1:
            return "Kiai on move \(kiaiMoveNumbers[0])."
        default:
            let moveNumberStrings = kiaiMoveNumbers.map { "\($0)" }
            return "Kiai on moves \(moveNumberStrings.joined(separator: " and "))."
        }
    }
}
