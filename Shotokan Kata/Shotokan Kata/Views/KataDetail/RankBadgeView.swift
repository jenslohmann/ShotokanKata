//
//  RankBadgeView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import SwiftUI

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

        return BeltColorMapper.color(for: rank.beltColor)
    }
}

// MARK: - Belt Color Mapper
enum BeltColorMapper {
    static func color(for beltColor: BeltColor) -> Color {
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
