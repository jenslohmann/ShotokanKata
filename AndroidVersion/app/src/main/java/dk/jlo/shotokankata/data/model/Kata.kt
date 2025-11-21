package dk.jlo.shotokankata.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import java.util.UUID

@Serializable
data class Kata(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    @SerialName("japanese_name") val japaneseName: String,
    @SerialName("hiragana_name") val hiraganaName: String? = null,
    @SerialName("number_of_moves") val numberOfMoves: Int,
    @SerialName("kata_number") val kataNumber: Int,
    @SerialName("belt_rank") val beltRank: String,
    val description: String,
    @SerialName("key_techniques") val keyTechniques: List<String> = emptyList(),
    @SerialName("reference_url") val referenceURL: String? = null,
    @SerialName("video_urls") val videoURLs: List<String>? = null,
    val moves: List<KataMove> = emptyList()
) {
    val rank: KarateRank? get() = KarateRank.fromString(beltRank)
    val beltColor: BeltColor get() = rank?.beltColor ?: BeltColor.WHITE
}

@Serializable
data class KataMove(
    val sequence: Int,
    @SerialName("japanese_name") val japaneseName: String,
    val direction: String,
    val kiai: Boolean? = null,
    @SerialName("sub_moves") val subMoves: List<KataSubMove> = emptyList(),
    @SerialName("sequence_name") val sequenceName: String? = null
)

@Serializable
data class KataSubMove(
    val order: Int,
    val technique: String,
    val hiragana: String? = null,
    val stance: String,
    @SerialName("stance_hiragana") val stanceHiragana: String? = null,
    val description: String,
    val icon: String,
    val kiai: Boolean? = null
)

@Serializable
data class KataConfiguration(
    val availableKata: List<KataEntry>
)

@Serializable
data class KataEntry(
    val fileName: String,
    val kataNumber: Int,
    val name: String,
    val enabled: Boolean
)
