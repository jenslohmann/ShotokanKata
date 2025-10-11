//
//  QuizView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 16/08/2025.
//

import SwiftUI

struct QuizView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showingExitConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress and Timer Header
                    QuizProgressHeader(viewModel: viewModel)

                    // Main Content
                    Group {
                        switch viewModel.quizState {
                        case .notStarted:
                            QuizNotStartedView()
                        case .inProgress:
                            QuizInProgressView(viewModel: viewModel)
                        case .paused:
                            QuizPausedView(viewModel: viewModel)
                        case .completed:
                            QuizResultsView(viewModel: viewModel, selectedTab: $selectedTab)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(viewModel.quizState == .inProgress || viewModel.quizState == .paused)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.quizState == .inProgress || viewModel.quizState == .paused {
                        Button("Exit") {
                            showingExitConfirmation = true
                        }
                        .foregroundColor(.red)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.quizState == .completed {
                        Button(NSLocalizedString("common.done", comment: "Done")) {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .alert("Exit Quiz?", isPresented: $showingExitConfirmation) {
                Button("Continue Quiz", role: .cancel) { }
                Button("Exit", role: .destructive) {
                    viewModel.resetQuiz()
                    dismiss()
                }
            } message: {
                Text("Your progress will be lost if you exit now.")
            }
        }
    }
}

// MARK: - Quiz Progress Header
struct QuizProgressHeader: View {
    @ObservedObject var viewModel: QuizViewModel

    var body: some View {
        VStack(spacing: 12) {
            // Progress Bar
            if viewModel.quizState == .inProgress || viewModel.quizState == .completed {
                VStack(spacing: 8) {
                    HStack {
                        Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                            .font(.caption)
                            .fontWeight(.medium)

                        Spacer()

                        if viewModel.isTimedQuiz && viewModel.timeRemaining > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .foregroundColor(timeRemainingColor)
                                Text(formatTime(viewModel.timeRemaining))
                                    .fontWeight(.medium)
                                    .foregroundColor(timeRemainingColor)
                            }
                            .font(.caption)
                        }
                    }

                    ProgressView(value: viewModel.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(y: 2)
                }
            }

            // Quiz Info
            if viewModel.quizState != .notStarted {
                HStack {
                    QuizInfoChip(
                        title: "Rank",
                        value: viewModel.selectedRank.displayName,
                        color: .blue
                    )

                    if let category = viewModel.selectedCategory {
                        QuizInfoChip(
                            title: "Category",
                            value: category.displayName,
                            color: .green
                        )
                    }

                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }

    private var timeRemainingColor: Color {
        if viewModel.timeRemaining > 60 { return .primary }
        if viewModel.timeRemaining > 30 { return .orange }
        return .red
    }

    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Quiz Info Chip
struct QuizInfoChip: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

// MARK: - Quiz Not Started View
struct QuizNotStartedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 64))
                .foregroundColor(.blue)

            Text("Quiz Ready")
                .font(.title)
                .fontWeight(.bold)

            Text("Your quiz is ready to begin. Good luck!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Quiz In Progress View
struct QuizInProgressView: View {
    @ObservedObject var viewModel: QuizViewModel
    @State private var kiaiSelectedMoves: Set<Int> = []
    @State private var isKiaiAnswered = false

    var body: some View {
        VStack(spacing: 0) {
            if let currentQuestion = viewModel.currentQuestion {
                ScrollView {
                    VStack(spacing: 24) {
                        // Question - handle different types
                        if currentQuestion.questionType == .kataKiaiSelection {
                            // Use special view for kata kiai selection
                            KataKiaiSelectionView(
                                question: currentQuestion,
                                userAnswer: $kiaiSelectedMoves,
                                isAnswered: $isKiaiAnswered
                            )
                        } else {
                            // Standard multiple choice question
                            QuestionView(
                                question: currentQuestion,
                                selectedAnswerIndex: viewModel.selectedAnswerIndex,
                                showingExplanation: viewModel.showingExplanation,
                                onAnswerSelected: { index in
                                    viewModel.selectAnswer(index)
                                }
                            )

                            // Explanation (if showing)
                            if viewModel.showingExplanation {
                                ExplanationView(
                                    question: currentQuestion,
                                    selectedAnswerIndex: viewModel.selectedAnswerIndex
                                )
                            }
                        }
                    }
                    .padding()
                }

                // Navigation Buttons
                if currentQuestion.questionType == .kataKiaiSelection {
                    KiaiQuizNavigationButtons(
                        viewModel: viewModel,
                        isAnswered: $isKiaiAnswered,
                        selectedMoves: $kiaiSelectedMoves
                    )
                } else {
                    QuizNavigationButtons(viewModel: viewModel)
                }
            }
        }
        .onAppear {
            // Reset kiai selection state when question changes
            kiaiSelectedMoves = []
            isKiaiAnswered = false
        }
    }
}

// MARK: - Question View
struct QuestionView: View {
    let question: QuizQuestion
    let selectedAnswerIndex: Int?
    let showingExplanation: Bool
    let onAnswerSelected: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Question Text
            VStack(alignment: .leading, spacing: 8) {
                Text("Question")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(1)

                Text(question.question)
                    .font(.title3)
                    .fontWeight(.medium)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Answer Options
            VStack(spacing: 12) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    AnswerOptionButton(
                        option: option,
                        index: index,
                        isSelected: selectedAnswerIndex == index,
                        isCorrect: showingExplanation ? index == question.correctAnswerIndex : nil,
                        isIncorrect: showingExplanation && selectedAnswerIndex == index && index != question.correctAnswerIndex,
                        isDisabled: showingExplanation
                    ) {
                        if !showingExplanation {
                            onAnswerSelected(index)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Answer Option Button
struct AnswerOptionButton: View {
    let option: String
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool?
    let isIncorrect: Bool
    let isDisabled: Bool
    let action: () -> Void

    private let letters = ["A", "B", "C", "D", "E"]

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Letter indicator
                Text(letters[index])
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(letterColor)
                    .frame(width: 32, height: 32)
                    .background(letterBackgroundColor)
                    .clipShape(Circle())

                // Option text
                Text(option)
                    .font(.body)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                // Status icon
                if let isCorrect = isCorrect {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isCorrect ? .green : .red)
                        .font(.title3)
                }
            }
            .padding()
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled)
    }

    private var backgroundColor: Color {
        if isCorrect == true { return .green.opacity(0.1) }
        if isIncorrect { return .red.opacity(0.1) }
        if isSelected { return .blue.opacity(0.1) }
        return Color(.systemGray6)
    }

    private var borderColor: Color {
        if isCorrect == true { return .green }
        if isIncorrect { return .red }
        if isSelected { return .blue }
        return .clear
    }

    private var letterBackgroundColor: Color {
        if isCorrect == true { return .green }
        if isIncorrect { return .red }
        if isSelected { return .blue }
        return Color(.systemGray4)
    }

    private var letterColor: Color {
        if isCorrect == true || isIncorrect || isSelected { return .white }
        return .primary
    }

    private var textColor: Color {
        if isCorrect == true { return .green }
        if isIncorrect { return .red }
        return .primary
    }
}

// MARK: - Explanation View
struct ExplanationView: View {
    let question: QuizQuestion
    let selectedAnswerIndex: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.orange)
                Text("Explanation")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }

            if let explanation = question.explanation {
                Text(explanation)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Related Kata
            if let relatedKata = question.relatedKataNames, !relatedKata.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Related Kata")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(relatedKata, id: \.self) { kataName in
                                Text(kataName)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Quiz Navigation Buttons
struct QuizNavigationButtons: View {
    @ObservedObject var viewModel: QuizViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Previous Button
                if viewModel.canGoBack && !viewModel.showingExplanation {
                    Button(action: { viewModel.previousQuestion() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                // Main Action Button
                Button(action: {
                    if viewModel.hasAnsweredCurrentQuestion || viewModel.showingExplanation {
                        viewModel.nextQuestion()
                    }
                }) {
                    HStack {
                        if viewModel.showingExplanation {
                            if viewModel.isLastQuestion {
                                Text("Finish Quiz")
                                Image(systemName: "flag.checkered")
                            } else {
                                Text("Next Question")
                                Image(systemName: "chevron.right")
                            }
                        } else {
                            Text("Submit Answer")
                            Image(systemName: "checkmark")
                        }
                    }
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        viewModel.hasAnsweredCurrentQuestion || viewModel.showingExplanation
                        ? Color.blue
                        : Color.gray
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!viewModel.hasAnsweredCurrentQuestion && !viewModel.showingExplanation)
            }

            // Skip Button (only when not showing explanation)
            if !viewModel.showingExplanation {
                Button(action: { viewModel.skipQuestion() }) {
                    Text("Skip Question")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Kiai Quiz Navigation Buttons
struct KiaiQuizNavigationButtons: View {
    @ObservedObject var viewModel: QuizViewModel
    @Binding var isAnswered: Bool
    @Binding var selectedMoves: Set<Int>

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Previous Button
                if viewModel.canGoBack && !isAnswered {
                    Button(action: { viewModel.previousQuestion() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Previous")
                        }
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                // Submit/Next Button
                Button(action: {
                    if isAnswered {
                        // Move to next question or complete quiz
                        if viewModel.isLastQuestion {
                            viewModel.completeQuiz()
                        } else {
                            viewModel.nextQuestion()
                        }
                    } else {
                        // Submit the kiai selection
                        viewModel.selectKiaiMoves(selectedMoves)
                        isAnswered = true
                    }
                }) {
                    HStack {
                        if isAnswered {
                            Text(viewModel.isLastQuestion ? "Finish Quiz" : "Next Question")
                            Image(systemName: viewModel.isLastQuestion ? "flag.checkered" : "chevron.right")
                        } else {
                            Text("Submit Answer")
                            Image(systemName: "checkmark")
                        }
                    }
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        (isAnswered || !selectedMoves.isEmpty) ? Color.blue : Color.gray
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!isAnswered && selectedMoves.isEmpty)
            }

            // Skip Button
            if !isAnswered {
                Button(action: {
                    viewModel.skipQuestion()
                }) {
                    Text("Skip Question")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Quiz Paused View
struct QuizPausedView: View {
    @ObservedObject var viewModel: QuizViewModel

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "pause.circle")
                .font(.system(size: 64))
                .foregroundColor(.orange)

            VStack(spacing: 8) {
                Text("Quiz Paused")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Take your time. Resume when ready.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: { viewModel.resumeQuiz() }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Resume Quiz")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Quiz Results View
struct QuizResultsView: View {
    @ObservedObject var viewModel: QuizViewModel
    @Binding var selectedTab: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Results Header
                VStack(spacing: 16) {
                    Image(systemName: resultIcon)
                        .font(.system(size: 64))
                        .foregroundColor(resultColor)

                    VStack(spacing: 8) {
                        Text("Quiz Complete!")
                            .font(.title)
                            .fontWeight(.bold)

                        if let result = viewModel.quizResult {
                            Text("\(Int(result.score))% Score")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(resultColor)
                        }
                    }
                }

                // Results Stats
                if let result = viewModel.quizResult {
                    VStack(spacing: 16) {
                        ResultStatRow(
                            title: "Correct Answers",
                            value: "\(result.correctAnswers)/\(result.totalQuestions)",
                            color: .green
                        )

                        ResultStatRow(
                            title: "Incorrect Answers",
                            value: "\(result.incorrectAnswers)",
                            color: .red
                        )

                        if result.skippedQuestions > 0 {
                            ResultStatRow(
                                title: "Skipped Questions",
                                value: "\(result.skippedQuestions)",
                                color: .orange
                            )
                        }

                        ResultStatRow(
                            title: "Time Spent",
                            value: formatTimeSpent(result.timeSpent),
                            color: .blue
                        )

                        ResultStatRow(
                            title: "Rank Level",
                            value: result.selectedRank.displayName,
                            color: .purple
                        )

                        if let category = result.selectedCategory {
                            ResultStatRow(
                                title: "Category",
                                value: category.displayName,
                                color: .indigo
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        viewModel.resetQuiz()
                        selectedTab = 0 // Switch to Kata tab (index 0)
                        dismiss() // Dismiss the quiz modal
                    }) {
                        HStack {
                            Image(systemName: "house")
                            Text("Back to Main Menu")
                        }
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
    }

    private var resultIcon: String {
        guard let result = viewModel.quizResult else { return "questionmark.circle" }
        if result.isPassing { return "checkmark.circle.fill" }
        return "xmark.circle.fill"
    }

    private var resultColor: Color {
        guard let result = viewModel.quizResult else { return .gray }
        if result.score >= 90 { return .green }
        if result.score >= 70 { return .blue }
        if result.score >= 50 { return .orange }
        return .red
    }

    private func formatTimeSpent(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        if minutes > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        } else {
            return "\(remainingSeconds)s"
        }
    }
}

// MARK: - Result Stat Row
struct ResultStatRow: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack {
            Text(title)
                .font(.body)

            Spacer()

            Text(value)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    QuizView(viewModel: QuizViewModel(), selectedTab: .constant(0))
}
