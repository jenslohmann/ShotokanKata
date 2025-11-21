package dk.jlo.shotokankata.data.model

import java.util.UUID

data class QuizQuestion(
    val id: String = UUID.randomUUID().toString(),
    val question: String,
    val options: List<String>,
    val correctAnswerIndex: Int,
    val category: QuestionCategory,
    val questionType: QuestionType,
    val requiredRank: KarateRank,
    val explanation: String? = null,
    val relatedKataNames: List<String>? = null,
    val kataData: Kata? = null,
    val correctMoveIndices: List<Int>? = null
)

enum class QuestionType {
    STATIC_QUESTION,
    KATA_MOVES_COUNT,
    KATA_KIAI_SELECTION,
    KATA_TECHNIQUES,
    KATA_STANCES,
    KATA_RANK,
    KATA_ORDER
}

enum class QuestionCategory(
    val displayName: String,
    val icon: String
) {
    KATA_NAMES("Kata Names", "badge"),
    TECHNIQUES("Techniques", "sports_martial_arts"),
    SEQUENCES("Sequences", "format_list_numbered"),
    HISTORY("History", "history"),
    APPLICATIONS("Applications", "psychology"),
    BELT_RANKS("Belt Ranks", "military_tech"),
    KATA_ORDER("Kata Order", "sort"),
    TERMINOLOGY("Terminology", "translate"),
    PHILOSOPHY("Philosophy", "lightbulb");

    companion object {
        fun fromString(value: String): QuestionCategory? {
            return entries.find {
                it.name.equals(value, ignoreCase = true) ||
                it.displayName.equals(value, ignoreCase = true)
            }
        }
    }
}
