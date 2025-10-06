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
    @State private var isExpanded = false

    init(description: String, expandThreshold: Int = 100) {
        self.description = description
        self.expandThreshold = expandThreshold
    }

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isExpanded.toggle()
            }
        }) {
            HStack {
                Text(description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(isExpanded ? nil : 2)
                    .multilineTextAlignment(.leading)

                Spacer()

                if shouldShowExpandButton {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
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
