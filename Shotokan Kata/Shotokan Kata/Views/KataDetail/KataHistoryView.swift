//
//  KataHistoryView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import SwiftUI

struct KataHistoryView: View {
    let kata: Kata

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HistoricalBackgroundSection()
                KataStatisticsSection(kata: kata)

                Spacer(minLength: 20)
            }
            .padding()
        }
    }
}

// MARK: - Historical Background Section
private struct HistoricalBackgroundSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Historical Background")
                .font(.headline)

            Text("This section will contain historical information about the kata, including its origins, development, and significance in Shōtōkan karate.")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Kata Statistics Section
private struct KataStatisticsSection: View {
    let kata: Kata

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Kata Statistics")
                .font(.headline)

            VStack(spacing: 12) {
                StatRowView(title: "Total Moves", value: "\(kata.numberOfMoves)")
                StatRowView(title: "Required Rank", value: kata.rankDisplayName)
                StatRowView(title: "Kata Number", value: "#\(kata.kataNumber)")
                StatRowView(title: "Key Techniques", value: "\(kata.keyTechniques.count)")
            }
        }
    }
}

// MARK: - Stat Row View
struct StatRowView: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.body)

            Spacer()

            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
