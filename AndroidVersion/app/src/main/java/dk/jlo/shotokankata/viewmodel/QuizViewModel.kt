package dk.jlo.shotokankata.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import dk.jlo.shotokankata.data.model.KarateRank
import dk.jlo.shotokankata.data.model.QuestionCategory
import dk.jlo.shotokankata.data.model.QuestionResult
import dk.jlo.shotokankata.data.model.QuizAnswer
import dk.jlo.shotokankata.data.model.QuizQuestion
import dk.jlo.shotokankata.data.model.QuizResult
import dk.jlo.shotokankata.data.model.QuizState
import dk.jlo.shotokankata.data.repository.KataRepository
import dk.jlo.shotokankata.data.repository.QuizRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class QuizViewModel @Inject constructor(
    private val quizRepository: QuizRepository,
    private val kataRepository: KataRepository
) : ViewModel() {

    // Configuration
    private val _selectedRank = MutableStateFlow(KarateRank.KYU_10)
    val selectedRank: StateFlow<KarateRank> = _selectedRank.asStateFlow()

    private val _selectedCategory = MutableStateFlow<QuestionCategory?>(null)
    val selectedCategory: StateFlow<QuestionCategory?> = _selectedCategory.asStateFlow()

    private val _questionCount = MutableStateFlow(10)
    val questionCount: StateFlow<Int> = _questionCount.asStateFlow()

    // Quiz state
    private val _quizState = MutableStateFlow<QuizState>(QuizState.NotStarted)
    val quizState: StateFlow<QuizState> = _quizState.asStateFlow()

    private val _questions = MutableStateFlow<List<QuizQuestion>>(emptyList())

    private val _currentQuestionIndex = MutableStateFlow(0)
    val currentQuestionIndex: StateFlow<Int> = _currentQuestionIndex.asStateFlow()

    private val _currentQuestion = MutableStateFlow<QuizQuestion?>(null)
    val currentQuestion: StateFlow<QuizQuestion?> = _currentQuestion.asStateFlow()

    private val _totalQuestions = MutableStateFlow(0)
    val totalQuestions: StateFlow<Int> = _totalQuestions.asStateFlow()

    private val _userAnswers = MutableStateFlow<MutableList<QuestionResult>>(mutableListOf())

    private var startTime: Long = 0

    fun setSelectedRank(rank: KarateRank) {
        _selectedRank.value = rank
    }

    fun setSelectedCategory(category: QuestionCategory?) {
        _selectedCategory.value = category
    }

    fun setQuestionCount(count: Int) {
        _questionCount.value = count
    }

    fun startQuiz() {
        viewModelScope.launch {
            // Ensure kata data is loaded for question generation
            kataRepository.loadKata()

            val questions = quizRepository.generateQuestions(
                _selectedRank.value,
                _selectedCategory.value,
                _questionCount.value
            )

            if (questions.isEmpty()) {
                return@launch
            }

            _questions.value = questions
            _totalQuestions.value = questions.size
            _currentQuestionIndex.value = 0
            _currentQuestion.value = questions.firstOrNull()
            _userAnswers.value = mutableListOf()
            startTime = System.currentTimeMillis()
            _quizState.value = QuizState.InProgress(0)
        }
    }

    fun submitAnswer(selectedIndex: Int) {
        val question = _currentQuestion.value ?: return
        val isCorrect = selectedIndex == question.correctAnswerIndex

        val result = QuestionResult(
            question = question,
            userAnswer = QuizAnswer.MultipleChoice(selectedIndex),
            isCorrect = isCorrect
        )
        _userAnswers.value.add(result)

        moveToNextQuestion()
    }

    private fun moveToNextQuestion() {
        val nextIndex = _currentQuestionIndex.value + 1
        if (nextIndex < _questions.value.size) {
            _currentQuestionIndex.value = nextIndex
            _currentQuestion.value = _questions.value[nextIndex]
            _quizState.value = QuizState.InProgress(nextIndex)
        } else {
            finishQuiz()
        }
    }

    private fun finishQuiz() {
        val timeTaken = ((System.currentTimeMillis() - startTime) / 1000).toInt()
        val correctAnswers = _userAnswers.value.count { it.isCorrect }

        val result = QuizResult(
            totalQuestions = _questions.value.size,
            correctAnswers = correctAnswers,
            timeTaken = timeTaken,
            questionResults = _userAnswers.value.toList()
        )

        _quizState.value = QuizState.Completed(result)
    }

    fun resetQuiz() {
        _quizState.value = QuizState.NotStarted
        _questions.value = emptyList()
        _currentQuestionIndex.value = 0
        _currentQuestion.value = null
        _userAnswers.value = mutableListOf()
    }
}
