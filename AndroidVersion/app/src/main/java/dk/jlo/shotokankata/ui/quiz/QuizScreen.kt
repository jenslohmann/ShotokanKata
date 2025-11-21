package dk.jlo.shotokankata.ui.quiz

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import dk.jlo.shotokankata.R
import dk.jlo.shotokankata.data.model.QuizState
import dk.jlo.shotokankata.viewmodel.QuizViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun QuizScreen(
    onExit: () -> Unit,
    viewModel: QuizViewModel = hiltViewModel()
) {
    val quizState by viewModel.quizState.collectAsState()
    val currentQuestion by viewModel.currentQuestion.collectAsState()
    val currentIndex by viewModel.currentQuestionIndex.collectAsState()
    val totalQuestions by viewModel.totalQuestions.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(stringResource(R.string.nav_quiz)) }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            when (val state = quizState) {
                is QuizState.NotStarted -> {
                    Text(
                        text = "Quiz not started",
                        style = MaterialTheme.typography.bodyLarge
                    )
                }

                is QuizState.InProgress -> {
                    currentQuestion?.let { question ->
                        Text(
                            text = stringResource(
                                R.string.quiz_question_progress,
                                currentIndex + 1,
                                totalQuestions
                            ),
                            style = MaterialTheme.typography.labelLarge
                        )

                        Spacer(modifier = Modifier.height(16.dp))

                        Text(
                            text = question.question,
                            style = MaterialTheme.typography.headlineSmall,
                            textAlign = TextAlign.Center
                        )

                        Spacer(modifier = Modifier.height(24.dp))

                        question.options.forEachIndexed { index, option ->
                            OutlinedButton(
                                onClick = { viewModel.submitAnswer(index) },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(vertical = 4.dp)
                            ) {
                                Text(option)
                            }
                        }
                    }
                }

                is QuizState.Paused -> {
                    Text(
                        text = "Quiz Paused",
                        style = MaterialTheme.typography.headlineMedium
                    )
                }

                is QuizState.Completed -> {
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center,
                        modifier = Modifier.fillMaxSize()
                    ) {
                        Text(
                            text = stringResource(R.string.quiz_results),
                            style = MaterialTheme.typography.headlineMedium
                        )

                        Spacer(modifier = Modifier.height(16.dp))

                        Text(
                            text = stringResource(
                                R.string.quiz_final_score,
                                state.result.percentage
                            ),
                            style = MaterialTheme.typography.headlineSmall
                        )

                        Spacer(modifier = Modifier.height(8.dp))

                        Text(
                            text = "${state.result.correctAnswers} / ${state.result.totalQuestions} ${stringResource(R.string.quiz_correct)}",
                            style = MaterialTheme.typography.bodyLarge
                        )

                        Spacer(modifier = Modifier.height(32.dp))

                        Button(onClick = onExit) {
                            Text(stringResource(R.string.common_done))
                        }
                    }
                }
            }
        }
    }
}
