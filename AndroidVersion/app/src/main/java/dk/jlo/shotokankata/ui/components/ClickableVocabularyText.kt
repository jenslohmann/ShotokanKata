package dk.jlo.shotokankata.ui.components

import androidx.compose.foundation.text.ClickableText
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import dk.jlo.shotokankata.data.model.VocabularyTerm

/**
 * Data class representing a match of a vocabulary term in text
 */
data class VocabularyMatch(
    val term: VocabularyTerm,
    val startIndex: Int,
    val endIndex: Int
)

/**
 * Finds vocabulary terms within the given text using longest-term-first matching.
 * This ensures that longer terms are matched before shorter overlapping terms.
 */
fun findVocabularyMatches(
    text: String,
    vocabularyTerms: List<VocabularyTerm>
): List<VocabularyMatch> {
    if (text.isBlank() || vocabularyTerms.isEmpty()) return emptyList()

    val matches = mutableListOf<VocabularyMatch>()
    val textLower = text.lowercase()

    // Sort terms by length (longest first) to handle overlapping matches
    val sortedTerms = vocabularyTerms.sortedByDescending {
        maxOf(it.term.length, it.japaneseName.length)
    }

    // Track which character positions are already matched
    val matchedPositions = BooleanArray(text.length)

    for (term in sortedTerms) {
        // Try to match the term name (romanized)
        findTermOccurrences(textLower, term.term.lowercase()).forEach { startIndex ->
            val endIndex = startIndex + term.term.length
            if (!isOverlapping(matchedPositions, startIndex, endIndex)) {
                matches.add(VocabularyMatch(term, startIndex, endIndex))
                markPositions(matchedPositions, startIndex, endIndex)
            }
        }

        // Also try to match Japanese name if different
        if (term.japaneseName != term.term) {
            findTermOccurrences(text, term.japaneseName).forEach { startIndex ->
                val endIndex = startIndex + term.japaneseName.length
                if (!isOverlapping(matchedPositions, startIndex, endIndex)) {
                    matches.add(VocabularyMatch(term, startIndex, endIndex))
                    markPositions(matchedPositions, startIndex, endIndex)
                }
            }
        }
    }

    // Sort matches by start index for proper rendering
    return matches.sortedBy { it.startIndex }
}

/**
 * Find all occurrences of a term in text, ensuring whole-word matching
 */
private fun findTermOccurrences(text: String, term: String): List<Int> {
    if (term.isBlank()) return emptyList()

    val occurrences = mutableListOf<Int>()
    var startIndex = 0

    while (startIndex < text.length) {
        val index = text.indexOf(term, startIndex, ignoreCase = true)
        if (index < 0) break

        // Check for whole-word match (not part of a larger word)
        val isWordStart = index == 0 || !text[index - 1].isLetterOrDigit()
        val endIndex = index + term.length
        val isWordEnd = endIndex >= text.length || !text[endIndex].isLetterOrDigit()

        if (isWordStart && isWordEnd) {
            occurrences.add(index)
        }
        startIndex = index + 1
    }

    return occurrences
}

private fun isOverlapping(matchedPositions: BooleanArray, start: Int, end: Int): Boolean {
    for (i in start until minOf(end, matchedPositions.size)) {
        if (matchedPositions[i]) return true
    }
    return false
}

private fun markPositions(matchedPositions: BooleanArray, start: Int, end: Int) {
    for (i in start until minOf(end, matchedPositions.size)) {
        matchedPositions[i] = true
    }
}

/**
 * A composable that displays text with clickable vocabulary terms.
 * Matched terms are highlighted in blue and bold.
 */
@Composable
fun ClickableVocabularyText(
    text: String,
    vocabularyTerms: List<VocabularyTerm>,
    onTermClick: (VocabularyTerm) -> Unit,
    modifier: Modifier = Modifier,
    style: androidx.compose.ui.text.TextStyle = MaterialTheme.typography.bodySmall
) {
    val primaryColor = MaterialTheme.colorScheme.primary
    val textColor = MaterialTheme.colorScheme.onSurfaceVariant

    val annotatedString = remember(text, vocabularyTerms) {
        val matches = findVocabularyMatches(text, vocabularyTerms)

        buildAnnotatedString {
            var currentIndex = 0

            for (match in matches) {
                // Add text before the match
                if (currentIndex < match.startIndex) {
                    withStyle(SpanStyle(color = textColor)) {
                        append(text.substring(currentIndex, match.startIndex))
                    }
                }

                // Add the matched term with styling and annotation
                val matchedText = text.substring(match.startIndex, match.endIndex)
                pushStringAnnotation(
                    tag = "vocabulary",
                    annotation = match.term.id.toString()
                )
                withStyle(
                    SpanStyle(
                        color = primaryColor,
                        fontWeight = FontWeight.Bold
                    )
                ) {
                    append(matchedText)
                }
                pop()

                currentIndex = match.endIndex
            }

            // Add remaining text after the last match
            if (currentIndex < text.length) {
                withStyle(SpanStyle(color = textColor)) {
                    append(text.substring(currentIndex))
                }
            }
        }
    }

    ClickableText(
        text = annotatedString,
        modifier = modifier,
        style = style,
        onClick = { offset ->
            annotatedString.getStringAnnotations(
                tag = "vocabulary",
                start = offset,
                end = offset
            ).firstOrNull()?.let { annotation ->
                val termId = annotation.item.toIntOrNull()
                termId?.let { id ->
                    vocabularyTerms.find { it.id == id }?.let { term ->
                        onTermClick(term)
                    }
                }
            }
        }
    )
}
