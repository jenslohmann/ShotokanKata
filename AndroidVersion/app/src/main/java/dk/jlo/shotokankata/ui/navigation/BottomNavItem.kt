package dk.jlo.shotokankata.ui.navigation

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.filled.MenuBook
import androidx.compose.material.icons.filled.Quiz
import androidx.compose.ui.graphics.vector.ImageVector

enum class BottomNavItem(
    val title: String,
    val icon: ImageVector,
    val route: String
) {
    KATA("Kata", Icons.Default.List, NavRoutes.KATA_LIST),
    QUIZ("Quiz", Icons.Default.Quiz, NavRoutes.QUIZ_MENU),
    VOCABULARY("Vocabulary", Icons.Default.MenuBook, NavRoutes.VOCABULARY_LIST),
    ABOUT("About", Icons.Default.Info, NavRoutes.ABOUT)
}
