//
//  QuizMenuView.swift
//  Shotokan Kata
//
//  Created by Jens Lohmann on 16/08/2025.
//

import SwiftUI

struct QuizMenuView: View {
    @StateObject private var quizViewModel = QuizViewModel()
    @State private var showingQuiz = false
    @State private var selectedDifficultyLevel: DifficultyLevel?
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    QuizHeaderView()

                    // Rank Selection
                    RankSelectionView(quizViewModel: quizViewModel)

                    // Difficulty Level Quick Selection
                    DifficultyLevelView(
                        quizViewModel: quizViewModel,
                        selectedDifficultyLevel: $selectedDifficultyLevel
                    )

                    // Category Selection
                    CategorySelectionView(quizViewModel: quizViewModel)

                    // Quiz Configuration
                    QuizConfigurationView(quizViewModel: quizViewModel)

                    // Start Quiz Button
                    StartQuizButtonView(
                        quizViewModel: quizViewModel,
                        showingQuiz: $showingQuiz
                    )

                    Spacer(minLength: 20)
                }
                .padding()
            }
            .navigationTitle("Quiz")
            .navigationBarTitleDisplayMode(.large)
            .fullScreenCover(isPresented: $showingQuiz) {
                QuizView(viewModel: quizViewModel, selectedTab: $selectedTab)
            }
        }
    }
}

// MARK: - Quiz Header View
struct QuizHeaderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(.blue)

            Text("Test Your Knowledge")
                .font(.title2)
                .fontWeight(.bold)

            Text("Challenge yourself with questions about Shotokan kata, techniques, and philosophy based on your current rank.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Rank Selection View
struct RankSelectionView: View {
    @ObservedObject var quizViewModel: QuizViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Your Rank")
                .font(.headline)

            Text("Questions will be appropriate for your rank level and below.")
                .font(.caption)
                .foregroundColor(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(KarateRank.allCases, id: \.self) { rank in
                        RankButton(
                            rank: rank,
                            isSelected: quizViewModel.selectedRank == rank
                        ) {
                            quizViewModel.setRank(rank)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

// MARK: - Rank Button
struct RankButton: View {
    let rank: KarateRank
    let isSelected: Bool
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
                    .fontWeight(isSelected ? .bold : .medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
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

// MARK: - Difficulty Level View
struct DifficultyLevelView: View {
    @ObservedObject var quizViewModel: QuizViewModel
    @Binding var selectedDifficultyLevel: DifficultyLevel?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Difficulty Selection")
                .font(.headline)

            Text("Or choose by difficulty level instead of specific rank.")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                ForEach(DifficultyLevel.allCases, id: \.self) { level in
                    DifficultyButton(
                        level: level,
                        isSelected: selectedDifficultyLevel == level
                    ) {
                        selectedDifficultyLevel = level
                        // Set rank to the highest rank in this difficulty level
                        if let highestRank = level.associatedRanks.max(by: { $0.sortOrder < $1.sortOrder }) {
                            quizViewModel.setRank(highestRank)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

// MARK: - Difficulty Button
struct DifficultyButton: View {
    let level: DifficultyLevel
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: difficultyIcon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : difficultyColor)

                Text(level.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? difficultyColor : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var difficultyIcon: String {
        switch level {
        case .beginner: return "star.fill"
        case .intermediate: return "star.leadinghalf.filled"
        case .advanced: return "star.circle.fill"
        case .expert: return "crown.fill"
        }
    }

    private var difficultyColor: Color {
        switch level {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .orange
        case .expert: return .red
        }
    }
}

// MARK: - Category Selection View
struct CategorySelectionView: View {
    @ObservedObject var quizViewModel: QuizViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Question Category")
                .font(.headline)

            Text("Choose a specific category or leave unselected for mixed questions.")
                .font(.caption)
                .foregroundColor(.secondary)

            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 120), spacing: 12)
            ], spacing: 12) {
                // All Categories option
                CategoryButton(
                    title: "All Categories",
                    icon: "questionmark.circle",
                    isSelected: quizViewModel.selectedCategory == nil
                ) {
                    quizViewModel.setCategory(nil)
                }

                // Individual category options
                ForEach(QuestionCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        title: category.displayName,
                        icon: category.icon,
                        isSelected: quizViewModel.selectedCategory == category
                    ) {
                        quizViewModel.setCategory(category)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .white : .blue)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quiz Configuration View
struct QuizConfigurationView: View {
    @ObservedObject var quizViewModel: QuizViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quiz Settings")
                .font(.headline)

            // Number of Questions
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Number of Questions")
                        .font(.body)
                    Spacer()
                    Text("\(quizViewModel.numberOfQuestions)")
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }

                Slider(
                    value: Binding(
                        get: { Double(quizViewModel.numberOfQuestions) },
                        set: { quizViewModel.setNumberOfQuestions(Int($0)) }
                    ),
                    in: 5...30,
                    step: 5
                )
                .accentColor(.blue)
            }

            // Timer Toggle
            Toggle("Timed Quiz", isOn: Binding(
                get: { quizViewModel.isTimedQuiz },
                set: { _ in quizViewModel.toggleTimedQuiz() }
            ))
            .font(.body)

            // Time Limit (if timed)
            if quizViewModel.isTimedQuiz {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Time Limit")
                            .font(.body)
                        Spacer()
                        Text("\(Int(quizViewModel.timeLimit / 60)) minutes")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }

                    Slider(
                        value: Binding(
                            get: { quizViewModel.timeLimit },
                            set: { quizViewModel.setTimeLimit($0) }
                        ),
                        in: 300...1800, // 5 to 30 minutes
                        step: 300 // 5-minute increments
                    )
                    .accentColor(.blue)
                }
            }

            // Available Questions Info
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)

                Text("Available questions: \(quizViewModel.getAvailableQuestionCount())")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

// MARK: - Start Quiz Button View
struct StartQuizButtonView: View {
    @ObservedObject var quizViewModel: QuizViewModel
    @Binding var showingQuiz: Bool

    var body: some View {
        Button(action: {
            quizViewModel.startQuiz()
            showingQuiz = true
        }) {
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.title2)

                Text("Start Quiz")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.blue, .blue.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(quizViewModel.getAvailableQuestionCount() == 0)
        .opacity(quizViewModel.getAvailableQuestionCount() == 0 ? 0.6 : 1.0)
    }
}

#Preview {
    QuizMenuView(selectedTab: .constant(0))
}
