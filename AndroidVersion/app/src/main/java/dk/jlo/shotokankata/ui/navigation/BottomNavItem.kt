package dk.jlo.shotokankata.ui.navigation

import androidx.annotation.StringRes
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.List
import androidx.compose.material.icons.automirrored.filled.MenuBook
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Quiz
import androidx.compose.ui.graphics.vector.ImageVector
import dk.jlo.shotokankata.R

enum class BottomNavItem(
    @StringRes val titleResId: Int,
    val icon: ImageVector,
    val route: String
) {
    KATA(R.string.nav_kata, Icons.AutoMirrored.Filled.List, NavRoutes.KATA_LIST),
    QUIZ(R.string.nav_quiz, Icons.Default.Quiz, NavRoutes.QUIZ_MENU),
    VOCABULARY(R.string.nav_vocabulary, Icons.AutoMirrored.Filled.MenuBook, NavRoutes.VOCABULARY_LIST),
    ABOUT(R.string.nav_about, Icons.Default.Info, NavRoutes.ABOUT)
}
