//
//  KataDetailView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import SwiftUI

struct KataDetailView: View {
    let kata: Kata
    @State private var selectedSection: DetailSection = .moves

    var body: some View {
        VStack(spacing: 0) {
            KataHeaderView(kata: kata)

            DetailSectionPicker(selectedSection: $selectedSection)

            selectedSection.contentView(for: kata)
        }
        .navigationTitle(kata.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Detail Section Configuration
extension KataDetailView {
    enum DetailSection: Int, CaseIterable {
        case overview = 0
        case moves = 1
        case history = 2

        var title: String {
            switch self {
            case .overview: return "Overview"
            case .moves: return "Moves"
            case .history: return "History"
            }
        }

        var icon: String {
            switch self {
            case .overview: return "info.circle"
            case .moves: return "list.bullet"
            case .history: return "book"
            }
        }

        @ViewBuilder
        func contentView(for kata: Kata) -> some View {
            switch self {
            case .overview:
                KataOverviewView(kata: kata)
            case .moves:
                KataMovesView(kata: kata)
            case .history:
                KataHistoryView(kata: kata)
            }
        }
    }
}

#Preview {
    NavigationStack {
        KataDetailView(kata: PreviewData.sampleKata)
    }
}
