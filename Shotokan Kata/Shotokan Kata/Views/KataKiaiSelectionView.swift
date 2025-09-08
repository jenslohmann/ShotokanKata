//
//  KataKiaiSelectionView.swift
//  Shotokan Kata
//
//  Created by Jens Lohmann on 22/08/2025.
//

import SwiftUI

// MARK: - Kata Kiai Selection View
struct KataKiaiSelectionView: View {
    let question: QuizQuestion
    @State private var selectedMoves: Set<Int> = []
    @Binding var userAnswer: Set<Int>
    @Binding var isAnswered: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Question text
            Text(question.question)
                .font(.headline)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)

            // Instructions
            Text("Tap the move numbers to select which moves have kiai")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            // Kata moves display
            if let kata = question.kataData {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(kata.moves, id: \.sequence) { move in
                            KataKiaiMoveRowView(
                                move: move,
                                isSelected: selectedMoves.contains(move.sequence),
                                showKiaiIndicator: isAnswered, // Only show kiai indicators after answering
                                onTap: {
                                    toggleMoveSelection(move.sequence)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }

            // Show result if answered
            if isAnswered {
                VStack(spacing: 12) {
                    if let correctIndices = question.correctMoveIndices {
                        let correctMoves = Set(correctIndices)
                        let isCorrect = selectedMoves == correctMoves

                        HStack {
                            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(isCorrect ? .green : .red)

                            Text(isCorrect ? "Correct!" : "Incorrect")
                                .font(.headline)
                                .foregroundColor(isCorrect ? .green : .red)
                        }

                        if !isCorrect {
                            Text("Correct answer: \(correctIndices.map(String.init).joined(separator: ", "))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        if let explanation = question.explanation {
                            Text(explanation)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
        .onAppear {
            // Reset state when question changes
            selectedMoves = []
            userAnswer = []
            isAnswered = false
        }
        .onChange(of: selectedMoves) { newValue in
            // Sync with parent binding
            userAnswer = newValue
        }
    }

    private func toggleMoveSelection(_ moveNumber: Int) {
        guard !isAnswered else { return }

        if selectedMoves.contains(moveNumber) {
            selectedMoves.remove(moveNumber)
        } else {
            selectedMoves.insert(moveNumber)
        }
    }
}

// MARK: - Kata Kiai Move Row View
struct KataKiaiMoveRowView: View {
    let move: KataMove
    let isSelected: Bool
    let showKiaiIndicator: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Move number badge
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)

                    Text("\(move.sequence)")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(isSelected ? .white : .primary)
                }

                // Move details
                VStack(alignment: .leading, spacing: 4) {
                    Text(move.japaneseName)
                        .font(.body.weight(.medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)

                    if let firstSubMove = move.subMoves.first {
                        HStack {
                            HStack(spacing: 4) {
                                Text(firstSubMove.stance)
                                    .font(.caption)
                                    .fontWeight(.medium)

                                if let stanceHiragana = firstSubMove.stanceHiragana {
                                    Text("(\(stanceHiragana))")
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)

                            Text(move.direction)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Spacer()

                            // Only show kiai indicator when explicitly allowed
                            if showKiaiIndicator && (move.kiai == true) {
                                Text("KIAI!")
                                    .font(.caption.weight(.bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.red.opacity(0.2))
                                    .foregroundColor(.red)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }

                Spacer()

                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .gray)
                    .font(.title2)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
struct KataKiaiSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        // Create sample data for preview
        let sampleMove1 = KataMove(
            sequence: 9,
            japaneseName: "Migi jodan age-uke",
            direction: "North",
            kiai: true,
            subMoves: [
                KataSubMove(
                    order: 1,
                    technique: "Migi jōdan age-uke",
                    hiragana: "みぎ じょうだん あげうけ",
                    stance: "Zenkutsu-dachi",
                    stanceHiragana: "ぜんくつだち",
                    description: "Advance the right foot in zenkutsu-dachi, realizing a right ascending right block (jodan age-uke) with KIAI",
                    icon: "arrow.up.circle.fill"
                )
            ], sequenceName: nil
        )

        let sampleMove2 = KataMove(
            sequence: 10,
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
                    description: "Pivot on the right foot by bringing the left foot 90° to the left, in zenkutsu-dachi position",
                    icon: "shield.lefthalf.filled"
                )
            ], sequenceName: nil
        )

        let sampleKata = Kata(
            name: "Heian Shodan",
            japaneseName: "平安初段",
            hiraganaName: "へいあん しょだん",
            numberOfMoves: 21,
            kataNumber: 1,
            beltRank: "9_kyu",
            description: "Sample kata for preview",
            keyTechniques: ["Gedan-barai", "Age-uke"],
            referenceURL: nil,
            moves: [sampleMove1, sampleMove2]
        )

        let sampleQuestion = QuizQuestion(
            question: "Select the moves where the karateka should say kiai in Heian Shodan:",
            options: [],
            correctAnswerIndex: 0,
            category: .sequences,
            questionType: .kataKiaiSelection,
            requiredRank: "9_kyu",
            explanation: "In Heian Shodan, kiai is performed on move 9.",
            relatedKataNames: ["Heian Shodan"],
            kataData: sampleKata,
            correctMoveIndices: [9]
        )

        KataKiaiSelectionView(
            question: sampleQuestion,
            userAnswer: .constant(Set<Int>()),
            isAnswered: .constant(false)
        )
    }
}
