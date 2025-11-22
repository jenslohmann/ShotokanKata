package dk.jlo.shotokankata.data.model

import kotlinx.serialization.Serializable

@Serializable
data class VocabularyTerm(
    val id: Int,
    val term: String,
    val japaneseName: String,
    val hiraganaName: String,
    val shortDescription: String,
    val definition: String,
    val category: String,
    val componentBreakdown: String? = null
) {
    val categoryType: VocabularyCategory get() = VocabularyCategory.fromString(category)
}

@Serializable
data class VocabularyResponse(
    val vocabularyTerms: List<VocabularyTerm>
)
