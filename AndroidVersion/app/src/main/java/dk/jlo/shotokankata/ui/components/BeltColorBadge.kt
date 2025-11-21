package dk.jlo.shotokankata.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import dk.jlo.shotokankata.data.model.BeltColor

@Composable
fun BeltColorBadge(
    beltColor: BeltColor,
    modifier: Modifier = Modifier
) {
    val isDarkTheme = isSystemInDarkTheme()
    val backgroundColor = if (isDarkTheme) beltColor.darkModeColor else beltColor.color
    val textColor = when (beltColor) {
        BeltColor.WHITE, BeltColor.YELLOW -> Color.Black
        else -> Color.White
    }
    val borderColor = if (beltColor == BeltColor.WHITE) {
        MaterialTheme.colorScheme.outline
    } else {
        Color.Transparent
    }

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(4.dp))
            .background(backgroundColor)
            .border(1.dp, borderColor, RoundedCornerShape(4.dp))
            .padding(horizontal = 8.dp, vertical = 4.dp)
    ) {
        Text(
            text = beltColor.displayName,
            style = MaterialTheme.typography.labelMedium,
            color = textColor
        )
    }
}
