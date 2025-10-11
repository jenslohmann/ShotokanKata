//
//  KataListView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import SwiftUI

struct KataListView: View {
    @StateObject private var viewModel = KataListViewModel()
    @State private var showingFilters = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search and Filter Bar
                SearchAndFilterBar(viewModel: viewModel, showingFilters: $showingFilters)

                // Content
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.filteredKata.isEmpty {
                    EmptyStateView(viewModel: viewModel)
                } else {
                    KataListContentView(viewModel: viewModel)
                }
            }
            .navigationTitle("Kata")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingFilters) {
                FilterView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadKata()
            }
            .refreshable {
                viewModel.loadKata()
            }
        }
    }
}

// MARK: - Search and Filter Bar
struct SearchAndFilterBar: View {
    @ObservedObject var viewModel: KataListViewModel
    @Binding var showingFilters: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search kata...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())

                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            // Quick Filter Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // All Kata chip
                    FilterChip(
                        title: "All Kata",
                        isSelected: !viewModel.hasFiltersApplied,
                        action: { viewModel.clearFilters() }
                    )

                    // Belt Color chips
                    ForEach(viewModel.availableBeltColors, id: \.self) { beltColor in
                        FilterChip(
                            title: beltColor.displayName,
                            isSelected: viewModel.selectedBeltColor == beltColor,
                            beltColor: beltColor,
                            count: viewModel.getKataCount(for: beltColor),
                            action: {
                                if viewModel.selectedBeltColor == beltColor {
                                    viewModel.filterByBeltColor(nil)
                                } else {
                                    viewModel.filterByBeltColor(beltColor)
                                }
                            }
                        )
                    }

                    // More Filters button
                    Button(action: { showingFilters = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "slider.horizontal.3")
                            Text("More")
                        }
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var beltColor: BeltColor?
    var count: Int?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let beltColor = beltColor {
                    Circle()
                        .fill(chipBeltColor)
                        .frame(width: 8, height: 8)
                }

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)

                if let count = count, count > 0 {
                    Text("(\(count))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var chipBeltColor: Color {
        guard let beltColor = beltColor else { return .gray }

        switch beltColor {
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

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)

            Text("Loading kata...")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    @ObservedObject var viewModel: KataListViewModel

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.martial.arts")
                .font(.system(size: 64))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("No Kata Found")
                    .font(.title2)
                    .fontWeight(.semibold)

                if viewModel.hasFiltersApplied {
                    Text("Try adjusting your search or filters")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    Button("Clear Filters") {
                        viewModel.clearFilters()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                } else {
                    Text("No kata data available")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Kata List View (replacing grid)
struct KataListContentView: View {
    @ObservedObject var viewModel: KataListViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(viewModel.filteredKata.sorted { $0.kataNumber < $1.kataNumber }) { kata in
                    NavigationLink(destination: KataDetailView(kata: kata)) {
                        KataListRowView(kata: kata)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Kata List Row View
struct KataListRowView: View {
    let kata: Kata
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    // Device detection for techniques display
    private var shouldShowTechniques: Bool {
        horizontalSizeClass == .regular // Show on iPad, hide on iPhone
    }

    var body: some View {
        HStack(spacing: 16) {
            // Kata Number Badge
            Text("\(kata.kataNumber)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.blue, .blue.opacity(0.7)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                )
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )

            // Kata Information
            VStack(alignment: .leading, spacing: 8) {
                // Kata Names Section
                VStack(alignment: .leading, spacing: 2) {
                    Text(kata.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(kata.japaneseName)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    if let hiragana = kata.hiraganaName {
                        Text(hiragana)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }

                // Information Chips Row (Device Adaptive)
                HStack(spacing: 8) {
                    // Techniques Chip (iPad Only)
                    if shouldShowTechniques {
                        InfoChip(
                            icon: "🎯",
                            text: "\(kata.keyTechniques.count) techniques",
                            backgroundColor: .orange
                        )
                    }

                    Spacer()
                }
            }

            Spacer()

            // Rank Badge
            VStack(spacing: 4) {
                KataRankBadge(rank: kata.rank)

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(horizontalSizeClass == .regular ? 20 : 16) // Adaptive padding
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray5), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .scaleEffect(1.0) // For touch feedback animation
        .animation(.easeInOut(duration: 0.1), value: shouldShowTechniques)
    }
}

// MARK: - Information Chip Component
struct InfoChip: View {
    let icon: String
    let text: String
    let backgroundColor: Color

    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(.caption2)

            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .foregroundColor(.white)
        .clipShape(Capsule())
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        switch icon {
        case "📍":
            return text.replacingOccurrences(of: "Moves", with: "movements in this kata")
        case "🎯":
            return text.replacingOccurrences(of: "Techniques", with: "key techniques featured in this kata")
        case "🏆":
            return "\(text) difficulty level"
        default:
            return text
        }
    }
}

// MARK: - Kata Rank Badge
struct KataRankBadge: View {
    let rank: KarateRank?

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(beltColor)
                .frame(width: 6, height: 6)

            Text(rank?.displayName ?? "Unknown")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
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

// MARK: - Filter View
struct FilterView: View {
    @ObservedObject var viewModel: KataListViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Rank Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Filter by Rank")
                            .font(.headline)

                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 80), spacing: 12)
                        ], spacing: 12) {
                            ForEach(viewModel.availableRanks, id: \.self) { rank in
                                RankFilterButton(
                                    rank: rank,
                                    isSelected: viewModel.selectedRank == rank,
                                    count: viewModel.getKataCount(for: rank)
                                ) {
                                    if viewModel.selectedRank == rank {
                                        viewModel.filterByRank(nil)
                                    } else {
                                        viewModel.filterByRank(rank)
                                    }
                                }
                            }
                        }
                    }

                    // Belt Color Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Filter by Belt Color")
                            .font(.headline)

                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 120), spacing: 12)
                        ], spacing: 12) {
                            ForEach(viewModel.availableBeltColors, id: \.self) { beltColor in
                                BeltColorFilterButton(
                                    beltColor: beltColor,
                                    isSelected: viewModel.selectedBeltColor == beltColor,
                                    count: viewModel.getKataCount(for: beltColor)
                                ) {
                                    if viewModel.selectedBeltColor == beltColor {
                                        viewModel.filterByBeltColor(nil)
                                    } else {
                                        viewModel.filterByBeltColor(beltColor)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        viewModel.clearFilters()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(NSLocalizedString("common.done", comment: "Done")) {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Rank Filter Button
struct RankFilterButton: View {
    let rank: KarateRank
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Circle()
                    .fill(beltColor)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                    )

                Text(rank.displayName)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text("(\(count))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var beltColor: Color {
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

// MARK: - Belt Color Filter Button
struct BeltColorFilterButton: View {
    let beltColor: BeltColor
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Circle()
                    .fill(colorValue)
                    .frame(width: 16, height: 16)

                VStack(alignment: .leading, spacing: 2) {
                    Text(beltColor.displayName)
                        .font(.caption)
                        .fontWeight(.medium)

                    Text("(\(count) kata)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var colorValue: Color {
        switch beltColor {
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

#Preview {
    KataListView()
}
