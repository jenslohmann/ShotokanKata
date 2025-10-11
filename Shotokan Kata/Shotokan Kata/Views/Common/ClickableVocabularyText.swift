import SwiftUI

struct ClickableVocabularyText: View {
    let text: String
    let vocabularyTerms: [VocabularyTerm]
    let enableTapGesture: Bool
    let onBackgroundTap: (() -> Void)?
    let lineLimit: Int?

    @State private var presentedTerm: VocabularyTerm?

    init(text: String, vocabularyTerms: [VocabularyTerm], enableTapGesture: Bool = true, onBackgroundTap: (() -> Void)? = nil, lineLimit: Int? = nil) {
        self.text = text
        self.vocabularyTerms = vocabularyTerms
        self.enableTapGesture = enableTapGesture
        self.onBackgroundTap = onBackgroundTap
        self.lineLimit = lineLimit
    }

    var body: some View {
        if vocabularyTerms.isEmpty {
            // Simple text without vocabulary highlighting
            Text(text)
                .textSelection(.enabled)
                .contentShape(Rectangle())
                .lineLimit(lineLimit)
                .onTapGesture {
                    onBackgroundTap?()
                }
        } else {
            // Text with vocabulary highlighting and clickable links
            Text(buildAttributedStringWithLinks())
                .textSelection(.enabled)
                .lineLimit(lineLimit)
                .contentShape(Rectangle())
                .environment(\.openURL, OpenURLAction { url in
                    // Intercept our custom vocabulary URLs before they reach the system
                    if url.scheme == "vocabulary" {
                        handleVocabularyTermURL(url)
                        return .handled
                    }
                    return .systemAction
                })
                .onTapGesture {
                    // Handle background taps (for expansion) when not clicking on a link
                    onBackgroundTap?()
                }
                .sheet(item: $presentedTerm) { term in
                    NavigationStack {
                        VocabularyDetailView(term: term)
                            .navigationBarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    Button(NSLocalizedString("common.done", comment: "Done")) {
                                        presentedTerm = nil
                                    }
                                }
                            }
                    }
                    .presentationDetents([.medium, .large])
                }
        }
    }

    private func buildAttributedStringWithLinks() -> AttributedString {
        var attributedString = AttributedString(text)

        // Only add links if tap gestures are enabled
        guard enableTapGesture else {
            return attributedString
        }

        // Sort terms by length (longest first) to handle overlapping terms correctly
        let sortedTerms = vocabularyTerms.sorted { $0.term.count > $1.term.count }

        for term in sortedTerms {
            let termVariations = getTermVariations(for: term)

            for variation in termVariations {
                var searchRange = attributedString.startIndex..<attributedString.endIndex

                while searchRange.lowerBound < attributedString.endIndex {
                    if let range = attributedString[searchRange].range(of: variation, options: [.caseInsensitive, .diacriticInsensitive]) {
                        if isWholeWordMatch(range: range, in: attributedString) {
                            // Style the vocabulary term
                            attributedString[range].foregroundColor = .blue
                            attributedString[range].font = .body.weight(.bold)

                            // Add clickable link using custom URL scheme
                            if let url = URL(string: "vocabulary://\(term.id)") {
                                attributedString[range].link = url
                            }

                            break // Found this variation, move to next term
                        }

                        if range.upperBound < attributedString.endIndex {
                            searchRange = range.upperBound..<attributedString.endIndex
                        } else {
                            break
                        }
                    } else {
                        break
                    }
                }
            }
        }

        return attributedString
    }

    private func handleVocabularyTermURL(_ url: URL) {
        // Parse the vocabulary term ID from the URL
        guard url.scheme == "vocabulary",
              let termIdString = url.host,
              let termId = Int(termIdString) else {
            return
        }

        // Find the vocabulary term by ID
        guard let term = vocabularyTerms.first(where: { $0.id == termId }) else {
            return
        }

        presentedTerm = term
    }

    private func isWholeWordMatch(range: Range<AttributedString.Index>, in attributedString: AttributedString) -> Bool {
        let wordCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))

        if range.lowerBound > attributedString.startIndex {
            let beforeIndex = attributedString.index(range.lowerBound, offsetByCharacters: -1)
            let beforeRange = beforeIndex..<range.lowerBound
            if let char = attributedString[beforeRange].characters.first {
                if char.unicodeScalars.allSatisfy(wordCharacterSet.contains) {
                    return false
                }
            }
        }

        if range.upperBound < attributedString.endIndex {
            let afterIndex = attributedString.index(range.upperBound, offsetByCharacters: 1)
            if afterIndex <= attributedString.endIndex {
                let afterRange = range.upperBound..<afterIndex
                if let char = attributedString[afterRange].characters.first {
                    if char.unicodeScalars.allSatisfy(wordCharacterSet.contains) {
                        return false
                    }
                }
            }
        }

        return true
    }

    private func getTermVariations(for term: VocabularyTerm) -> [String] {
        var variations: [String] = []
        variations.append(term.term)
        variations.append(term.term.lowercased())
        variations.append(term.term.capitalized)

        if !term.japaneseName.isEmpty && term.japaneseName != term.term {
            variations.append(term.japaneseName)
        }

        if !term.hiraganaName.isEmpty {
            variations.append(term.hiraganaName)
        }

        return Array(Set(variations)).filter { !$0.isEmpty }
    }
}

// MARK: - Preview
#Preview {
    let sampleTerms = [
        VocabularyTerm(
            id: 1,
            term: "Kata",
            japaneseName: "型",
            hiraganaName: "かた",
            shortDescription: "Predetermined sequence of karate movements",
            definition: "A sequence of karate movements performed in a predetermined pattern against imaginary opponents.",
            category: "general",
            componentBreakdown: "型 (kata) - This single kanji character means 'form', 'shape', or 'mold'. It represents the concept of a fixed pattern or template that preserves traditional techniques and movements for future generations."
        ),
        VocabularyTerm(
            id: 7,
            term: "Zenkutsu-dachi",
            japaneseName: "前屈立",
            hiraganaName: "ぜんくつだち",
            shortDescription: "Forward stance with long, low position",
            definition: "Front stance; a long, low stance with most weight on the front leg.",
            category: "stances",
            componentBreakdown: "前 (zen) - 'front' or 'forward'; 屈 (kutsu) - 'bend' or 'crouch'; 立 (dachi/tachi) - 'stand' or 'stance'. Together they describe a stance where you stand forward with bent legs."
        )
    ]

    let sampleText = "This kata uses the zenkutsu-dachi stance and demonstrates basic kata principles."

    VStack {
        ClickableVocabularyText(text: sampleText, vocabularyTerms: sampleTerms)
            .padding()

        Text("The above text should have clickable terms in blue.")
            .font(.caption)
            .foregroundColor(.secondary)
    }
}
