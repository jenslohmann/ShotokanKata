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
        .background(Color(.systemGray6))
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
        let kiaiMoves = moves.filter { $0.kiai == true }

        switch kiaiMoves.count {
        case 0:
            return "No kiai in this kata."
        case 1:
            return "Kiai on move \(kiaiMoves[0].sequence)."
        default:
            let moveNumbers = kiaiMoves.map { "\($0.sequence)" }
            return "Kiai on moves \(moveNumbers.joined(separator: " and "))."
        }
    }
}
