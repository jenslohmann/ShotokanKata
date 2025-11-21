package dk.jlo.shotokankata.data.model

import androidx.compose.ui.graphics.Color

enum class BeltColor(
    val displayName: String,
    val color: Color,
    val darkModeColor: Color
) {
    WHITE("White", Color(0xFFF5F5F5), Color(0xFFE0E0E0)),
    YELLOW("Yellow", Color(0xFFFFEB3B), Color(0xFFFDD835)),
    ORANGE("Orange", Color(0xFFFF9800), Color(0xFFFFB74D)),
    GREEN("Green", Color(0xFF4CAF50), Color(0xFF81C784)),
    PURPLE("Purple", Color(0xFF9C27B0), Color(0xFFBA68C8)),
    BROWN("Brown", Color(0xFF795548), Color(0xFFA1887F)),
    BLACK("Black", Color(0xFF212121), Color(0xFF424242));

    companion object {
        fun fromString(value: String): BeltColor? {
            return entries.find {
                it.name.equals(value, ignoreCase = true) ||
                it.displayName.equals(value, ignoreCase = true)
            }
        }
    }
}
