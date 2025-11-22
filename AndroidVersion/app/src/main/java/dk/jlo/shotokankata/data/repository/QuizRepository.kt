package dk.jlo.shotokankata.data.repository

import dk.jlo.shotokankata.data.model.Kata
import dk.jlo.shotokankata.data.model.KarateRank
import dk.jlo.shotokankata.data.model.QuestionCategory
import dk.jlo.shotokankata.data.model.QuestionType
import dk.jlo.shotokankata.data.model.QuizQuestion
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class QuizRepository @Inject constructor(
    private val kataRepository: KataRepository,
    private val vocabularyRepository: VocabularyRepository
) {
    fun generateQuestions(
        rank: KarateRank,
        category: QuestionCategory?,
        limit: Int = 10,
        kataList: List<Kata> = kataRepository.kata.value
    ): List<QuizQuestion> {
        val questions = mutableListOf<QuizQuestion>()

        // Generate dynamic questions based on kata data
        questions.addAll(generateKataMovesCountQuestions(rank, kataList))
        questions.addAll(generateKiaiSelectionQuestions(rank, kataList))
        questions.addAll(generateKataRankQuestions(rank, kataList))

        // Filter by category if specified
        val filtered = if (category != null) {
            questions.filter { it.category == category }
        } else {
            questions
        }

        return filtered.shuffled().take(limit)
    }

    private fun generateKataMovesCountQuestions(maxRank: KarateRank, kataList: List<Kata>): List<QuizQuestion> {
        return kataList
            .filter { kata ->
                val kataRank = kata.rank ?: return@filter false
                kataRank.sortOrder <= maxRank.sortOrder
            }
            .map { kata ->
                val correctAnswer = kata.numberOfMoves
                val wrongAnswers = listOf(
                    correctAnswer - 5,
                    correctAnswer - 2,
                    correctAnswer + 3,
                    correctAnswer + 7
                ).filter { it > 0 && it != correctAnswer }.shuffled().take(3)

                val options = (wrongAnswers + correctAnswer).shuffled()
                val correctIndex = options.indexOf(correctAnswer)

                QuizQuestion(
                    question = "How many moves are in ${kata.name}?",
                    options = options.map { it.toString() },
                    correctAnswerIndex = correctIndex,
                    category = QuestionCategory.SEQUENCES,
                    questionType = QuestionType.KATA_MOVES_COUNT,
                    requiredRank = kata.rank ?: KarateRank.KYU_10,
                    relatedKataNames = listOf(kata.name)
                )
            }
    }

    private fun generateKiaiSelectionQuestions(maxRank: KarateRank, kataList: List<Kata>): List<QuizQuestion> {
        return kataList
            .filter { kata ->
                val kataRank = kata.rank ?: return@filter false
                kataRank.sortOrder <= maxRank.sortOrder && kata.moves.isNotEmpty()
            }
            .mapNotNull { kata ->
                // Filter out ceremonial moves (Rei, Yōi) - only include actual kata moves
                val actualMoves = kata.moves.filter { it.sequence >= 1 }
                if (actualMoves.isEmpty()) return@mapNotNull null

                // Check both move level and sub-move level for kiai
                val kiaiMoves = actualMoves.filter { move ->
                    move.kiai == true || move.subMoves.any { it.kiai == true }
                }
                if (kiaiMoves.isEmpty()) return@mapNotNull null

                val kiaiIndices = kiaiMoves.map { actualMoves.indexOf(it) }

                QuizQuestion(
                    question = "Select the moves where kiai occurs in ${kata.name}:",
                    options = actualMoves.map { "Move ${it.sequence}: ${it.japaneseName}" },
                    correctAnswerIndex = kiaiIndices.firstOrNull() ?: 0,
                    category = QuestionCategory.TECHNIQUES,
                    questionType = QuestionType.KATA_KIAI_SELECTION,
                    requiredRank = kata.rank ?: KarateRank.KYU_10,
                    kataData = kata,
                    correctMoveIndices = kiaiIndices
                )
            }
    }

    private fun generateKataRankQuestions(maxRank: KarateRank, kataList: List<Kata>): List<QuizQuestion> {
        return kataList
            .filter { kata ->
                val kataRank = kata.rank ?: return@filter false
                kataRank.sortOrder <= maxRank.sortOrder
            }
            .map { kata ->
                val correctAnswer = kata.beltColor.displayName
                val allBelts = listOf("White", "Yellow", "Orange", "Green", "Purple", "Brown", "Black")
                val wrongAnswers = allBelts.filter { it != correctAnswer }.shuffled().take(3)

                val options = (wrongAnswers + correctAnswer).shuffled()
                val correctIndex = options.indexOf(correctAnswer)

                QuizQuestion(
                    question = "What belt rank learns ${kata.name}?",
                    options = options,
                    correctAnswerIndex = correctIndex,
                    category = QuestionCategory.BELT_RANKS,
                    questionType = QuestionType.KATA_RANK,
                    requiredRank = kata.rank ?: KarateRank.KYU_10,
                    relatedKataNames = listOf(kata.name)
                )
            }
    }
}
