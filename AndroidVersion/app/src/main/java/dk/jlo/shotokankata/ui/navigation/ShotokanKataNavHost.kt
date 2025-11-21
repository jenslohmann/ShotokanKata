package dk.jlo.shotokankata.ui.navigation

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import dk.jlo.shotokankata.ui.about.AboutScreen
import dk.jlo.shotokankata.ui.kata.KataDetailScreen
import dk.jlo.shotokankata.ui.kata.KataListScreen
import dk.jlo.shotokankata.ui.quiz.QuizMenuScreen
import dk.jlo.shotokankata.ui.quiz.QuizScreen
import dk.jlo.shotokankata.ui.vocabulary.VocabularyDetailScreen
import dk.jlo.shotokankata.ui.vocabulary.VocabularyListScreen

@Composable
fun ShotokanKataNavHost() {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination

    // Determine if we should show bottom nav (hide on detail screens)
    val showBottomNav = currentDestination?.route in listOf(
        NavRoutes.KATA_LIST,
        NavRoutes.QUIZ_MENU,
        NavRoutes.VOCABULARY_LIST,
        NavRoutes.ABOUT
    )

    Scaffold(
        bottomBar = {
            if (showBottomNav) {
                NavigationBar {
                    BottomNavItem.entries.forEach { item ->
                        NavigationBarItem(
                            icon = { Icon(item.icon, contentDescription = item.title) },
                            label = { Text(item.title) },
                            selected = currentDestination?.hierarchy?.any { it.route == item.route } == true,
                            onClick = {
                                navController.navigate(item.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState = true
                                }
                            }
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController = navController,
            startDestination = NavRoutes.KATA_LIST,
            modifier = Modifier.padding(innerPadding)
        ) {
            // Kata
            composable(NavRoutes.KATA_LIST) {
                KataListScreen(
                    onKataClick = { kataNumber ->
                        navController.navigate(NavRoutes.kataDetail(kataNumber))
                    }
                )
            }
            composable(
                route = NavRoutes.KATA_DETAIL,
                arguments = listOf(navArgument("kataNumber") { type = NavType.IntType })
            ) { backStackEntry ->
                val kataNumber = backStackEntry.arguments?.getInt("kataNumber") ?: 1
                KataDetailScreen(
                    kataNumber = kataNumber,
                    onBackClick = { navController.popBackStack() }
                )
            }

            // Quiz
            composable(NavRoutes.QUIZ_MENU) {
                QuizMenuScreen(
                    onStartQuiz = { navController.navigate(NavRoutes.QUIZ_ACTIVE) }
                )
            }
            composable(NavRoutes.QUIZ_ACTIVE) {
                QuizScreen(
                    onExit = { navController.popBackStack(NavRoutes.QUIZ_MENU, false) }
                )
            }

            // Vocabulary
            composable(NavRoutes.VOCABULARY_LIST) {
                VocabularyListScreen(
                    onTermClick = { termId ->
                        navController.navigate(NavRoutes.vocabularyDetail(termId))
                    }
                )
            }
            composable(
                route = NavRoutes.VOCABULARY_DETAIL,
                arguments = listOf(navArgument("termId") { type = NavType.IntType })
            ) { backStackEntry ->
                val termId = backStackEntry.arguments?.getInt("termId") ?: 0
                VocabularyDetailScreen(
                    termId = termId,
                    onBackClick = { navController.popBackStack() }
                )
            }

            // About
            composable(NavRoutes.ABOUT) {
                AboutScreen()
            }
        }
    }
}
