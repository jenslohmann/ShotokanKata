package dk.jlo.shotokankata.ui.components

import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import dk.jlo.shotokankata.R
import dk.jlo.shotokankata.data.model.BeltColor

@Composable
fun BeltColorFilterChips(
    selectedColor: BeltColor?,
    onColorSelected: (BeltColor?) -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .horizontalScroll(rememberScrollState())
            .padding(horizontal = 16.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // "All" chip
        FilterChip(
            selected = selectedColor == null,
            onClick = { onColorSelected(null) },
            label = { Text(stringResource(R.string.filter_all_kata)) }
        )

        // Belt color chips
        BeltColor.entries.forEach { color ->
            val chipColor = color.color
            val textColor = when (color) {
                BeltColor.WHITE, BeltColor.YELLOW -> Color.Black
                else -> Color.White
            }

            FilterChip(
                selected = selectedColor == color,
                onClick = { onColorSelected(if (selectedColor == color) null else color) },
                label = { Text(color.displayName) },
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = chipColor,
                    selectedLabelColor = textColor
                )
            )
        }
    }
}
