package dk.jlo.shotokankata.data.model

enum class VocabularyCategory(
    val displayName: String,
    val icon: String
) {
    GENERAL("General", "info"),
    ETIQUETTE("Etiquette", "handshake"),
    TITLES("Titles", "badge"),
    TECHNIQUES("Techniques", "sports_martial_arts"),
    STANCES("Stances", "accessibility"),
    BLOCKS("Blocks", "shield"),
    PUNCHES("Punches", "front_hand"),
    KICKS("Kicks", "directions_walk"),
    TRAINING("Training", "fitness_center"),
    RANKS("Ranks", "military_tech"),
    EQUIPMENT("Equipment", "inventory_2");

    companion object {
        fun fromString(value: String): VocabularyCategory {
            return entries.find {
                it.name.equals(value, ignoreCase = true) ||
                it.displayName.equals(value, ignoreCase = true)
            } ?: GENERAL
        }
    }
}
