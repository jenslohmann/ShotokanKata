//
//  RankBadgeView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import SwiftUI

struct RankBadgeView: View {
    let rank: KarateRank?
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(beltColor)
                .frame(width: 8, height: 8)

            Text(rank?.displayName ?? "Unknown")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(textColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .clipShape(Capsule())
    }

    private var beltColor: Color {
        guard let rank = rank else { return .gray }
        return BeltColorMapper.color(for: rank.beltColor)
    }

    private var backgroundColor: Color {
        if colorScheme == .dark {
            return beltColor.opacity(0.3)
        } else {
            return beltColor.opacity(0.2)
        }
    }

    private var textColor: Color {
        guard let rank = rank else { return .primary }

        // Use white text for dark belts in dark mode, otherwise use the belt color
        if colorScheme == .dark {
            switch rank.beltColor {
            case .brown, .black:
                return .white
            default:
                return beltColor
            }
        } else {
            return .primary
        }
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
