package dk.jlo.shotokankata.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import dk.jlo.shotokankata.data.model.KataMove
import dk.jlo.shotokankata.data.model.KataSubMove
import dk.jlo.shotokankata.data.model.VocabularyTerm

@Composable
fun KataMoveCard(
    move: KataMove,
    modifier: Modifier = Modifier,
    vocabularyTerms: List<VocabularyTerm> = emptyList(),
    onVocabularyTermClick: (VocabularyTerm) -> Unit = {}
) {
    // Check if any sub-move has kiai
    val hasKiai = move.kiai == true || move.subMoves.any { it.kiai == true }
    val firstSubMove = move.subMoves.firstOrNull()

    Card(
        modifier = modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            verticalAlignment = Alignment.Top
        ) {
            // Move number or sequence name in blue circle
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .clip(CircleShape)
                    .background(MaterialTheme.colorScheme.primary),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = move.sequenceName ?: if (move.sequence > 0) move.sequence.toString() else "-",
                    color = MaterialTheme.colorScheme.onPrimary,
                    style = if (move.sequenceName != null) MaterialTheme.typography.labelSmall else MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.width(16.dp))

            Column(modifier = Modifier.weight(1f)) {
                // Header: Show first sub-move technique or fall back to move's japaneseName
                val headerTechnique = firstSubMove?.technique ?: move.japaneseName
                Text(
                    text = headerTechnique,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )

                // Hiragana for technique
                firstSubMove?.hiragana?.let { hiragana ->
                    Text(
                        text = hiragana,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                Spacer(modifier = Modifier.height(4.dp))

                // Stance with hiragana
                firstSubMove?.let { subMove ->
                    val stanceText = if (subMove.stanceHiragana != null) {
                        "${subMove.stance}, ${subMove.stanceHiragana}"
                    } else {
                        subMove.stance
                    }
                    StanceBadge(stanceText)
                    Spacer(modifier = Modifier.height(4.dp))
                }

                // Direction and KIAI row
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Direction with arrow
                    Text(
                        text = "${move.direction} ${getDirectionArrow(move.direction)}",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )

                    // KIAI badge
                    if (hasKiai) {
                        KiaiBadge()
                    }
                }

                // Description from first sub-move (with clickable vocabulary)
                firstSubMove?.let { subMove ->
                    Spacer(modifier = Modifier.height(8.dp))
                    if (vocabularyTerms.isNotEmpty()) {
                        ClickableVocabularyText(
                            text = subMove.description,
                            vocabularyTerms = vocabularyTerms,
                            onTermClick = onVocabularyTermClick,
                            style = MaterialTheme.typography.bodySmall
                        )
                    } else {
                        Text(
                            text = subMove.description,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                // Additional sub-moves (if more than 1)
                if (move.subMoves.size > 1) {
                    Spacer(modifier = Modifier.height(12.dp))
                    move.subMoves.drop(1).forEach { subMove ->
                        SubMoveCard(
                            subMove = subMove,
                            vocabularyTerms = vocabularyTerms,
                            onVocabularyTermClick = onVocabularyTermClick
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                    }
                }
            }
        }
    }
}

@Composable
private fun SubMoveCard(
    subMove: KataSubMove,
    vocabularyTerms: List<VocabularyTerm> = emptyList(),
    onVocabularyTermClick: (VocabularyTerm) -> Unit = {}
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(start = 8.dp),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surface
        )
    ) {
        Column(
            modifier = Modifier.padding(12.dp)
        ) {
            // Technique name
            Text(
                text = subMove.technique,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Medium
            )

            // Hiragana
            subMove.hiragana?.let { hiragana ->
                Text(
                    text = hiragana,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Spacer(modifier = Modifier.height(4.dp))

            // Stance with hiragana
            val stanceText = if (subMove.stanceHiragana != null) {
                "${subMove.stance}, ${subMove.stanceHiragana}"
            } else {
                subMove.stance
            }
            StanceBadge(stanceText)

            // KIAI badge if applicable
            if (subMove.kiai == true) {
                Spacer(modifier = Modifier.height(4.dp))
                KiaiBadge()
            }

            // Description (with clickable vocabulary)
            Spacer(modifier = Modifier.height(8.dp))
            if (vocabularyTerms.isNotEmpty()) {
                ClickableVocabularyText(
                    text = subMove.description,
                    vocabularyTerms = vocabularyTerms,
                    onTermClick = onVocabularyTermClick,
                    style = MaterialTheme.typography.bodySmall
                )
            } else {
                Text(
                    text = subMove.description,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
private fun StanceBadge(stance: String) {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(4.dp))
            .background(MaterialTheme.colorScheme.secondaryContainer)
            .padding(horizontal = 8.dp, vertical = 2.dp)
    ) {
        Text(
            text = stance,
            style = MaterialTheme.typography.labelSmall,
            color = MaterialTheme.colorScheme.onSecondaryContainer
        )
    }
}

@Composable
private fun KiaiBadge() {
    Box(
        modifier = Modifier
            .clip(RoundedCornerShape(4.dp))
            .background(MaterialTheme.colorScheme.error)
            .padding(horizontal = 8.dp, vertical = 2.dp)
    ) {
        Text(
            text = "KIAI!",
            style = MaterialTheme.typography.labelSmall,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.onError
        )
    }
}

private fun getDirectionArrow(direction: String): String {
    return when (direction.uppercase()) {
        "N" -> "↑"
        "NNE" -> "↑"
        "NE" -> "↗"
        "ENE" -> "→"
        "E" -> "→"
        "ESE" -> "→"
        "SE" -> "↘"
        "SSE" -> "↓"
        "S" -> "↓"
        "SSW" -> "↓"
        "SW" -> "↙"
        "WSW" -> "←"
        "W" -> "←"
        "WNW" -> "←"
        "NW" -> "↖"
        "NNW" -> "↑"
        else -> ""
    }
}
