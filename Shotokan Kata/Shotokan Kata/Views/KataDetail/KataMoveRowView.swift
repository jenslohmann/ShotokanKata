//
//  KataMoveRowView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import SwiftUI

struct KataMoveRowView: View {
    let move: KataMove
    @EnvironmentObject var vocabularyService: VocabularyDataService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MoveHeader(move: move)

            if let firstSubMove = move.subMoves.first {
                ExpandableDescriptionView(
                    description: firstSubMove.description,
                    vocabularyTerms: vocabularyService.vocabularyTerms
                )
            }

            AdditionalSubMovesView(subMoves: Array(move.subMoves.dropFirst()))
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Move Header
private struct MoveHeader: View {
    let move: KataMove

    var body: some View {
        HStack(spacing: 12) {
            SequenceBadge(move: move)

            MainTechniqueInfo(move: move)

            Spacer()

            MoveMetadata(move: move)
        }
    }
}

// MARK: - Sequence Badge
private struct SequenceBadge: View {
    let move: KataMove

    var body: some View {
        Text(displayText)
            .font(.headline)
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(width: displayWidth, height: 30)
            .background(Color.blue)
            .clipShape(Capsule())
    }

    private var displayText: String {
        move.sequenceName ?? "\(move.sequence)"
    }

    private var displayWidth: CGFloat {
        move.sequenceName != nil ? 50 : 30
    }
}

// MARK: - Main Technique Info
private struct MainTechniqueInfo: View {
    let move: KataMove

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let firstSubMove = move.subMoves.first {
                Text(firstSubMove.technique)
                    .font(.body)
                    .fontWeight(.medium)

                if let hiragana = firstSubMove.hiragana {
                    Text(hiragana)
                        .font(.caption)
                        .foregroundColor(.black)
                }

                StanceBadge(
                    stance: firstSubMove.stance,
                    hiragana: firstSubMove.stanceHiragana
                )
            } else {
                Text(move.japaneseName)
                    .font(.body)
                    .fontWeight(.medium)
            }
        }
    }
}

// MARK: - Stance Badge
struct StanceBadge: View {
    let stance: String
    let hiragana: String?

    var body: some View {
        HStack(spacing: 4) {
            Text(stance)
                .font(.caption2)
                .fontWeight(.medium)

            if let hiragana = hiragana {
                Text("(\(hiragana))")
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

// MARK: - Move Metadata
private struct MoveMetadata: View {
    let move: KataMove

    var body: some View {
        VStack(spacing: 4) {
            if move.kiai == true {
                KiaiBadge()
            }

            DirectionIndicator(direction: move.direction)
        }
    }
}

// MARK: - Kiai Badge
private struct KiaiBadge: View {
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

// MARK: - Direction Indicator
struct DirectionIndicator: View {
    let direction: String

    var body: some View {
        HStack(spacing: 2) {
            Text(direction.uppercased())
                .font(.caption)
                .foregroundColor(.black)

            Text("(\(directionArrow))")
                .font(.caption)
                .foregroundColor(.black)
        }
    }

    private var directionArrow: String {
        DirectionMapper.arrow(for: direction)
    }
}

// MARK: - Direction Mapper
enum DirectionMapper {
    static func arrow(for direction: String) -> String {
        switch direction.uppercased() {
        case "N": return "↑"
        case "NNE", "NE", "ENE": return "↗"
        case "E": return "→"
        case "ESE", "SE", "SSE": return "↘"
        case "S": return "↓"
        case "SSW", "SW", "WSW": return "↙"
        case "W": return "←"
        case "WNW", "NW", "NNW": return "↖"
        default: return "•"
        }
    }
}

// MARK: - Additional Sub-Moves
private struct AdditionalSubMovesView: View {
    let subMoves: [KataSubMove]

    var body: some View {
        if !subMoves.isEmpty {
            VStack(spacing: 8) {
                ForEach(subMoves, id: \.order) { subMove in
                    KataSubMoveView(subMove: subMove)
                }
            }
            .padding(.leading, 42)
        }
    }
}
