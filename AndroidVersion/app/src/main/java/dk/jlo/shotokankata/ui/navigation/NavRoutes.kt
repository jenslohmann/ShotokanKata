package dk.jlo.shotokankata.ui.navigation

object NavRoutes {
    const val KATA_LIST = "kata_list"
    const val KATA_DETAIL = "kata_detail/{kataNumber}"
    const val QUIZ_MENU = "quiz_menu"
    const val QUIZ_ACTIVE = "quiz_active/{rankOrdinal}/{categoryOrdinal}/{questionCount}"
    const val VOCABULARY_LIST = "vocabulary_list"
    const val VOCABULARY_DETAIL = "vocabulary_detail/{termId}"
    const val ABOUT = "about"

    fun kataDetail(kataNumber: Int) = "kata_detail/$kataNumber"
    fun vocabularyDetail(termId: Int) = "vocabulary_detail/$termId"
    fun quizActive(rankOrdinal: Int, categoryOrdinal: Int, questionCount: Int) =
        "quiz_active/$rankOrdinal/$categoryOrdinal/$questionCount"
}
