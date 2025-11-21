package dk.jlo.shotokankata.data.model

sealed class QuizState {
    data object NotStarted : QuizState()
    data class InProgress(val questionIndex: Int) : QuizState()
    data object Paused : QuizState()
    data class Completed(val result: QuizResult) : QuizState()
}

sealed class QuizAnswer {
    data class MultipleChoice(val selectedIndex: Int?) : QuizAnswer()
    data class KiaiSelection(val selectedIndices: Set<Int>) : QuizAnswer()
    data object Skipped : QuizAnswer()
}

data class QuizResult(
    val totalQuestions: Int,
    val correctAnswers: Int,
    val timeTaken: Int,
    val questionResults: List<QuestionResult> = emptyList()
) {
    val score: Float get() = if (totalQuestions > 0) correctAnswers.toFloat() / totalQuestions else 0f
    val percentage: Int get() = (score * 100).toInt()
    val passed: Boolean get() = percentage >= 70
}

data class QuestionResult(
    val question: QuizQuestion,
    val userAnswer: QuizAnswer,
    val isCorrect: Boolean
)
