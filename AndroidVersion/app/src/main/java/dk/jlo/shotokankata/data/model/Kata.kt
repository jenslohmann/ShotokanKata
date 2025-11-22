package dk.jlo.shotokankata.data.model

import kotlinx.serialization.Serializable
import java.util.UUID

@Serializable
data class Kata(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val japaneseName: String,
    val hiraganaName: String? = null,
    val numberOfMoves: Int,
    val kataNumber: Int,
    val beltRank: String,
    val description: String,
    val keyTechniques: List<String> = emptyList(),
    val referenceURL: String? = null,
    val videoURLs: List<String>? = null,
    val moves: List<KataMove> = emptyList()
) {
    val rank: KarateRank? get() = KarateRank.fromString(beltRank)
    val beltColor: BeltColor get() = rank?.beltColor ?: BeltColor.WHITE
}

@Serializable
data class KataMove(
    val sequence: Int,
    val japaneseName: String,
    val direction: String,
    val kiai: Boolean? = null,
    val subMoves: List<KataSubMove> = emptyList(),
    val sequenceName: String? = null
)

@Serializable
data class KataSubMove(
    val order: Int,
    val technique: String,
    val hiragana: String? = null,
    val stance: String,
    val stanceHiragana: String? = null,
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
