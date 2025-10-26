//
//  ExpandableDescriptionView.swift
//  Shōtōkan Kata
//
//  Created by Jens Lohmann on 19/08/2025.
//

import SwiftUI

struct ExpandableDescriptionView: View {
    let description: String
    let expandThreshold: Int
    let vocabularyTerms: [VocabularyTerm]
    @State private var isExpanded = false
    @State private var isTruncated = false
    @State private var intrinsicSize: CGSize = .zero
    @State private var truncatedSize: CGSize = .zero

    init(description: String, vocabularyTerms: [VocabularyTerm] = [], expandThreshold: Int = 100) {
        self.description = description
        self.vocabularyTerms = vocabularyTerms
        self.expandThreshold = expandThreshold
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 0) {
                    if vocabularyTerms.isEmpty {
                        // Fallback to plain text if no vocabulary terms provided
                        Text(description)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineLimit(isExpanded ? nil : 2)
                            .multilineTextAlignment(.leading)
                            .contentShape(Rectangle())
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(
                                        key: TruncatedSizePreferenceKey.self,
                                        value: geo.size
                                    )
                                }
                            )
                            .background(
                                // Hidden full-height text to measure intrinsic size
                                Text(description)
                                    .font(.body)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .hidden()
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear.preference(
                                                key: IntrinsicSizePreferenceKey.self,
                                                value: geo.size
                                            )
                                        }
                                    )
                            )
                            .onPreferenceChange(TruncatedSizePreferenceKey.self) { size in
                                truncatedSize = size
                                updateTruncationState()
                            }
                            .onPreferenceChange(IntrinsicSizePreferenceKey.self) { size in
                                intrinsicSize = size
                                updateTruncationState()
                            }
                            .onTapGesture {
                                if shouldShowExpandButton {
                                    withAnimation(.easeInOut(duration: 0.1)) {
                                        isExpanded.toggle()
                                    }
                                }
                            }
                    } else {
                        // Use vocabulary highlighting when terms are available
                        ClickableVocabularyText(
                            text: description,
                            vocabularyTerms: vocabularyTerms,
                            enableTapGesture: true,
                            onBackgroundTap: shouldShowExpandButton ? {
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    isExpanded.toggle()
                                }
                            } : nil,
                            lineLimit: isExpanded ? nil : 2
                        )
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: TruncatedSizePreferenceKey.self,
                                    value: geo.size
                                )
                            }
                        )
                        .background(
                            // Hidden full-height text to measure intrinsic size
                            Text(description)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                                .hidden()
                                .background(
                                    GeometryReader { geo in
                                        Color.clear.preference(
                                            key: IntrinsicSizePreferenceKey.self,
                                            value: geo.size
                                        )
                                    }
                                )
                        )
                        .onPreferenceChange(TruncatedSizePreferenceKey.self) { size in
                            truncatedSize = size
                            updateTruncationState()
                        }
                        .onPreferenceChange(IntrinsicSizePreferenceKey.self) { size in
                            intrinsicSize = size
                            updateTruncationState()
                        }
                    }
                }

                if shouldShowExpandButton {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.leading, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var shouldShowExpandButton: Bool {
        // Use both character count as a quick check AND the measured truncation state
        description.count > expandThreshold || isTruncated
    }

    private func updateTruncationState() {
        // Check if the intrinsic (full) height is greater than truncated height
        // Add a small threshold (1pt) to account for floating point comparison issues
        isTruncated = intrinsicSize.height > truncatedSize.height + 1
    }
}

// MARK: - Preference Keys
private struct IntrinsicSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

private struct TruncatedSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

#Preview {
    VStack(spacing: 20) {
        Text("Short Text (No Arrow)")
            .font(.caption)
            .foregroundColor(.secondary)
        ExpandableDescriptionView(
            description: "This is a short description."
        )
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)

        Text("Medium Text (2 Lines - May Show Arrow)")
            .font(.caption)
            .foregroundColor(.secondary)
        ExpandableDescriptionView(
            description: "This is a medium-length description that might show on exactly two lines depending on your screen size."
        )
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)

        Text("Long Text (Should Show Arrow)")
            .font(.caption)
            .foregroundColor(.secondary)
        ExpandableDescriptionView(
            description: "This is a much longer description that contains a lot of text and should definitely show an expand button because it exceeds two lines and will be truncated to show only the first two lines unless the user taps to expand it fully. Additional text here to ensure it definitely needs expansion."
        )
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    .padding()
}
