package dk.jlo.shotokankata.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class VocabularyTerm(
    val id: Int,
    val term: String,
    @SerialName("japanese_name") val japaneseName: String,
    @SerialName("hiragana_name") val hiraganaName: String,
    @SerialName("short_description") val shortDescription: String,
    val definition: String,
    val category: String,
    @SerialName("component_breakdown") val componentBreakdown: String? = null
) {
    val categoryType: VocabularyCategory get() = VocabularyCategory.fromString(category)
}

@Serializable
data class VocabularyResponse(
    val vocabularyTerms: List<VocabularyTerm>
)
