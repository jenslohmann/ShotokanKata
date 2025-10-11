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
        description.count > expandThreshold
    }
}

#Preview {
    VStack {
        ExpandableDescriptionView(
            description: "This is a short description that shouldn't expand."
        )

        ExpandableDescriptionView(
            description: "This is a much longer description that contains a lot of text and should show an expand button because it exceeds the threshold length and will be truncated to show only the first two lines unless the user taps to expand it fully."
        )
    }
    .padding()
}
