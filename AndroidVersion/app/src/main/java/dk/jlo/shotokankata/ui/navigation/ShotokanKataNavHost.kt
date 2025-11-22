package dk.jlo.shotokankata.ui.navigation

import androidx.compose.animation.AnimatedContentTransitionScope
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
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

private const val ANIMATION_DURATION = 300

@Composable
fun ShotokanKataNavHost() {
    val navController = rememberNavController()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = navBackStackEntry?.destination

    // Determine if we should show bottom nav (hide on detail screens and quiz active)
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
                            icon = {
                                Icon(
                                    imageVector = item.icon,
                                    contentDescription = stringResource(item.titleResId)
                                )
                            },
                            label = { Text(stringResource(item.titleResId)) },
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
            modifier = Modifier.padding(innerPadding),
            enterTransition = {
                fadeIn(animationSpec = tween(ANIMATION_DURATION))
            },
            exitTransition = {
                fadeOut(animationSpec = tween(ANIMATION_DURATION))
            }
        ) {
            // Kata List
            composable(NavRoutes.KATA_LIST) {
                KataListScreen(
                    onKataClick = { kataNumber ->
                        navController.navigate(NavRoutes.kataDetail(kataNumber))
                    }
                )
            }

            // Kata Detail - slide in from right
            composable(
                route = NavRoutes.KATA_DETAIL,
                arguments = listOf(navArgument("kataNumber") { type = NavType.IntType }),
                enterTransition = {
                    slideIntoContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Left,
                        animationSpec = tween(ANIMATION_DURATION)
                    )
                },
                exitTransition = {
                    slideOutOfContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Left,
                        animationSpec = tween(ANIMATION_DURATION)
                    )
                },
                popEnterTransition = {
                    slideIntoContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Right,
                        animationSpec = tween(ANIMATION_DURATION)
                    )
                },
                popExitTransition = {
                    slideOutOfContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Right,
                        animationSpec = tween(ANIMATION_DURATION)
                    )
                }
            ) { backStackEntry ->
                val kataNumber = backStackEntry.arguments?.getInt("kataNumber") ?: 1
                KataDetailScreen(
                    kataNumber = kataNumber,
                    onBackClick = { navController.popBackStack() }
                )
            }

            // Quiz Menu
            composable(NavRoutes.QUIZ_MENU) {
                QuizMenuScreen(
                    onStartQuiz = { rankOrdinal, categoryOrdinal, questionCount ->
                        navController.navigate(NavRoutes.quizActive(rankOrdinal, categoryOrdinal, questionCount))
                    }
                )
            }

            // Quiz Active - slide up
            composable(
                route = NavRoutes.QUIZ_ACTIVE,
                arguments = listOf(
                    navArgument("rankOrdinal") { type = NavType.IntType },
                    navArgument("categoryOrdinal") { type = NavType.IntType },
                    navArgument("questionCount") { type = NavType.IntType }
                ),
                enterTransition = {
                    slideIntoContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Up,
                        animationSpec = tween(ANIMATION_DURATION)
                    )
                },
                exitTransition = {
                    slideOutOfContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Up,
                        animationSpec = tween(ANIMATION_DURATION)
                    )
                },
                popEnterTransition = {
                    slideIntoContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Down,
                        animationSpec = tween(ANIMATION_DURATION)
                    )
                },
                popExitTransition = {
                    slideOutOfContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Down,
                        animationSpec = tween(ANIMATION_DURATION)
                    )
                }
            ) { backStackEntry ->
                val rankOrdinal = backStackEntry.arguments?.getInt("rankOrdinal") ?: 0
                val categoryOrdinal = backStackEntry.arguments?.getInt("categoryOrdinal") ?: -1
                val questionCount = backStackEntry.arguments?.getInt("questionCount") ?: 10
                QuizScreen(
                    rankOrdinal = rankOrdinal,
                    categoryOrdinal = categoryOrdinal,
                    questionCount = questionCount,
                    onExit = { navController.popBackStack(NavRoutes.QUIZ_MENU, false) }
                )
            }

            // Vocabulary List
            composable(NavRoutes.VOCABULARY_LIST) {
                VocabularyListScreen(
                    onTermClick = { termId ->
                        navController.navigate(NavRoutes.vocabularyDetail(termId))
                    }
                )
            }

            // Vocabulary Detail - slide in from right
            composable(
                route = NavRoutes.VOCABULARY_DETAIL,
                arguments = listOf(navArgument("termId") { type = NavType.IntType }),
                enterTransition = {
                    slideIntoContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Left,
                        animationSpec = tween(ANIMATION_DURATION)
                    )
                },
                exitTransition = {
                    slideOutOfContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Left,
                        animationSpec = tween(ANIMATION_DURATION)
                    )
                },
                popEnterTransition = {
                    slideIntoContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Right,
                        animationSpec = tween(ANIMATION_DURATION)
                    )
                },
                popExitTransition = {
                    slideOutOfContainer(
                        towards = AnimatedContentTransitionScope.SlideDirection.Right,
                        animationSpec = tween(ANIMATION_DURATION)
                    )
                }
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
