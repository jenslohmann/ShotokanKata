//
//  KataDetailView.swift
//  Shotokan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import SwiftUI

struct KataDetailView: View {
    let kata: Kata
    @State private var selectedTab = 1  // Default to Moves tab instead of Overview

    var body: some View {
        VStack(spacing: 0) {
            // Header with kata info
            KataHeaderView(kata: kata)

            // Tab view for different sections
            TabView(selection: $selectedTab) {
                // Overview Tab
                KataOverviewView(kata: kata)
                    .tabItem {
                        Image(systemName: "info.circle")
                        Text("Overview")
                    }
                    .tag(0)

                // Moves Tab
                KataMovesView(kata: kata)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Moves")
                    }
                    .tag(1)

                // History Tab
                KataHistoryView(kata: kata)
                    .tabItem {
                        Image(systemName: "book")
                        Text("History")
                    }
                    .tag(2)
            }
        }
        .navigationTitle(kata.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Kata Header View
struct KataHeaderView: View {
    let kata: Kata

    var body: some View {
        VStack(spacing: 12) {
            // Top row: kata number, hiragana/Japanese name, rank badge
            HStack {
                // Kata number badge on the left
                Text("#\(kata.kataNumber)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Capsule())

                // Center: hiragana and Japanese name
                HStack(spacing: 4) {
                    if let hiragana = kata.hiraganaName {
                        Text(hiragana)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Text("(\(kata.japaneseName))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Rank badge on the right
                RankBadgeView(rank: kata.rank)
            }

            // Bottom row: Moves info chip and kiai information
            HStack {
                // Moves info chip on the left
                InfoChipView(title: "Moves", value: "\(kata.numberOfMoves)")

                Spacer()

                // Kiai information text on the right
                Text(kiaiInfoText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }

    // Computed property for kiai information text
    private var kiaiInfoText: String {
        let kiaiMoves = kata.moves.filter { $0.kiai == true }

        if kiaiMoves.isEmpty {
            return "No kiai in this kata."
        } else if kiaiMoves.count == 1 {
            return "Kiai on move \(kiaiMoves[0].sequence)."
        } else {
            let moveNumbers = kiaiMoves.map { "\($0.sequence)" }
            return "Kiai on moves \(moveNumbers.joined(separator: " and "))."
        }
    }
}

// MARK: - Rank Badge View
struct RankBadgeView: View {
    let rank: KarateRank?

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(beltColor)
                .frame(width: 8, height: 8)

            Text(rank?.displayName ?? "Unknown")
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(beltColor.opacity(0.2))
        .clipShape(Capsule())
    }

    private var beltColor: Color {
        guard let rank = rank else { return .gray }

        switch rank.beltColor {
        case .white: return .gray
        case .yellow: return .yellow
        case .orange: return .orange
        case .green: return .green
        case .purple: return .purple
        case .brown: return .brown
        case .black: return .black
        }
    }
}

// MARK: - Info Chip View
struct InfoChipView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Kata Overview View
struct KataOverviewView: View {
    let kata: Kata

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Description
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.headline)

                    Text(kata.description)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Key Techniques
                if !kata.keyTechniques.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Key Techniques")
                            .font(.headline)

                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 150))
                        ], spacing: 8) {
                            ForEach(kata.keyTechniques, id: \.self) { technique in
                                Text(technique)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }

                // Reference URL
                if let urlString = kata.referenceURL, let url = URL(string: urlString) {
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

                Spacer(minLength: 20)
            }
            .padding()
        }
    }
}

// MARK: - Kata Moves View
struct KataMovesView: View {
    let kata: Kata

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Display all moves in sequence order, regardless of sequence names
                ForEach(kata.moves.sorted { $0.sequence < $1.sequence }, id: \.sequence) { move in
                    KataMoveRowView(move: move)
                }
            }
            .padding()
        }
    }
}

// MARK: - Kata Move Row View
struct KataMoveRowView: View {
    let move: KataMove
    @State private var isMainDescriptionExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main move header
            HStack(spacing: 12) {
                Text(sequenceDisplayText)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: sequenceDisplayWidth, height: 30)
                    .background(Color.blue)
                    .clipShape(Capsule())

                VStack(alignment: .leading, spacing: 2) {
                    // Display Japanese technique name from first sub-move
                    if let firstSubMove = move.subMoves.first {
                        Text(firstSubMove.technique)
                            .font(.body)
                            .fontWeight(.medium)

                        // Display hiragana if available
                        if let hiragana = firstSubMove.hiragana {
                            Text(hiragana)
                                .font(.caption)
                                .foregroundColor(.black)
                        }

                        // Display stance with hiragana
                        HStack(spacing: 4) {
                            Text(firstSubMove.stance)
                                .font(.caption2)
                                .fontWeight(.medium)

                            if let stanceHiragana = firstSubMove.stanceHiragana {
                                Text("(\(stanceHiragana))")
                                    .font(.caption2)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                    } else {
                        // Fallback if no sub-moves exist
                        Text(move.japaneseName)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                }

                Spacer()

                VStack(spacing: 4) {
                    if move.kiai == true {
                        Text("KIAI!")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    // Direction with arrow format: "N (^)"
                    HStack(spacing: 2) {
                        Text(directionAbbreviation)
                            .font(.caption)
                            .foregroundColor(.black)

                        Text("(\(directionArrow))")
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
            }

            // Expandable description for main move
            if let firstSubMove = move.subMoves.first {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isMainDescriptionExpanded.toggle()
                    }
                }) {
                    HStack {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Image(systemName: isMainDescriptionExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                if isMainDescriptionExpanded {
                    Text(firstSubMove.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }

            // Display additional sub-moves if there are more than one
            if move.subMoves.count > 1 {
                VStack(spacing: 8) {
                    ForEach(move.subMoves.dropFirst(), id: \.order) { subMove in
                        KataSubMoveView(subMove: subMove)
                    }
                }
                .padding(.leading, 42) // Indent to align with main content
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // Computed properties for sequence display
    private var sequenceDisplayText: String {
        if let sequenceName = move.sequenceName {
            return sequenceName
        } else {
            return "\(move.sequence)"
        }
    }

    private var sequenceDisplayWidth: CGFloat {
        if move.sequenceName != nil {
            // Wider for text like "Rei", "Yoi"
            return 50
        } else {
            // Standard width for numbers
            return 30
        }
    }

    // Computed properties for direction display
    private var directionAbbreviation: String {
        // Return the direction as-is since it's already abbreviated in the JSON
        return move.direction.uppercased()
    }

    private var directionArrow: String {
        switch move.direction.uppercased() {
        case "N": return "↑"
        case "NNE": return "↗"
        case "NE": return "↗"
        case "ENE": return "↗"
        case "E": return "→"
        case "ESE": return "↘"
        case "SE": return "↘"
        case "SSE": return "↘"
        case "S": return "↓"
        case "SSW": return "↙"
        case "SW": return "↙"
        case "WSW": return "↙"
        case "W": return "←"
        case "WNW": return "↖"
        case "NW": return "↖"
        case "NNW": return "↖"
        default: return "•"
        }
    }
}

// MARK: - Kata Sub-Move View
struct KataSubMoveView: View {
    let subMove: KataSubMove
    @State private var isDescriptionExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: subMove.icon)
                    .foregroundColor(.blue)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 4) {
                    Text(subMove.technique)
                        .font(.body)
                        .fontWeight(.medium)

                    if let hiragana = subMove.hiragana {
                        Text(hiragana)
                            .font(.caption)
                            .foregroundColor(.black)
                    }

                    HStack {
                        HStack(spacing: 4) {
                            Text("Stance: \(subMove.stance)")
                                .font(.caption2)
                                .fontWeight(.medium)

                            if let stanceHiragana = subMove.stanceHiragana {
                                Text("(\(stanceHiragana))")
                                    .font(.caption2)
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.1))
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                    }
                }

                Spacer()
            }

            // Expandable description
            Button(action: {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isDescriptionExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Description")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Image(systemName: isDescriptionExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(PlainButtonStyle())

            if isDescriptionExpanded {
                Text(subMove.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Kata History View
struct KataHistoryView: View {
    let kata: Kata

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Historical information would go here
                VStack(alignment: .leading, spacing: 8) {
                    Text("Historical Background")
                        .font(.headline)

                    Text("This section will contain historical information about \(kata.name), including its origins, development, and significance in Shotokan karate.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                // Kata statistics
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

                Spacer(minLength: 20)
            }
            .padding()
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

#Preview {
    NavigationStack {
        KataDetailView(kata: Kata(
            name: "Heian Shodan",
            japaneseName: "平安初段",
            hiraganaName: "へいあん しょだん",
            numberOfMoves: 21,
            kataNumber: 1,
            beltRank: "9_kyu",
            description: "The first kata in the Heian series, teaching basic blocks and punches in a simple linear pattern.",
            keyTechniques: ["Gedan-barai", "Oi-zuki", "Age-uke", "Gyaku-zuki"],
            referenceURL: "https://www.example.com",
            moves: [
                KataMove(
                    sequence: 1,
                    japaneseName: "Hidari gedan-barai",
                    direction: "West",
                    kiai: false,
                    subMoves: [
                        KataSubMove(
                            order: 1,
                            technique: "Hidari gedan-barai",
                            hiragana: "ひだり げだんばらい",
                            stance: "Zenkutsu-dachi",
                            stanceHiragana: "ぜんくつだち",
                            description: "Turn left 90° into front stance with left downward block",
                            icon: "shield.lefthalf.filled"
                        )
                    ],
                    sequenceName: nil
                )
            ]
        ))
    }
}
