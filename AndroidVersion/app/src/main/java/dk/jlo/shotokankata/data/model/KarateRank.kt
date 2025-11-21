package dk.jlo.shotokankata.data.model

enum class KarateRank(
    val displayName: String,
    val beltColor: BeltColor,
    val sortOrder: Int
) {
    KYU_10("10th Kyu", BeltColor.WHITE, 1),
    KYU_9("9th Kyu", BeltColor.WHITE, 2),
    KYU_8("8th Kyu", BeltColor.YELLOW, 3),
    KYU_7("7th Kyu", BeltColor.ORANGE, 4),
    KYU_6("6th Kyu", BeltColor.GREEN, 5),
    KYU_5("5th Kyu", BeltColor.GREEN, 6),
    KYU_4("4th Kyu", BeltColor.PURPLE, 7),
    KYU_3("3rd Kyu", BeltColor.BROWN, 8),
    KYU_2("2nd Kyu", BeltColor.BROWN, 9),
    KYU_1("1st Kyu", BeltColor.BROWN, 10),
    DAN_1("1st Dan", BeltColor.BLACK, 11),
    DAN_2("2nd Dan", BeltColor.BLACK, 12),
    DAN_3("3rd Dan", BeltColor.BLACK, 13),
    DAN_4("4th Dan", BeltColor.BLACK, 14),
    DAN_5("5th Dan", BeltColor.BLACK, 15),
    DAN_6("6th Dan", BeltColor.BLACK, 16),
    DAN_7("7th Dan", BeltColor.BLACK, 17),
    DAN_8("8th Dan", BeltColor.BLACK, 18),
    DAN_9("9th Dan", BeltColor.BLACK, 19),
    DAN_10("10th Dan", BeltColor.BLACK, 20);

    companion object {
        fun fromString(value: String): KarateRank? {
            return when (value.lowercase().replace(" ", "_").replace("-", "_")) {
                "10_kyu", "10th_kyu", "kyu_10" -> KYU_10
                "9_kyu", "9th_kyu", "kyu_9" -> KYU_9
                "8_kyu", "8th_kyu", "kyu_8" -> KYU_8
                "7_kyu", "7th_kyu", "kyu_7" -> KYU_7
                "6_kyu", "6th_kyu", "kyu_6" -> KYU_6
                "5_kyu", "5th_kyu", "kyu_5" -> KYU_5
                "4_kyu", "4th_kyu", "kyu_4" -> KYU_4
                "3_kyu", "3rd_kyu", "kyu_3" -> KYU_3
                "2_kyu", "2nd_kyu", "kyu_2" -> KYU_2
                "1_kyu", "1st_kyu", "kyu_1" -> KYU_1
                "1_dan", "1st_dan", "dan_1", "shodan" -> DAN_1
                "2_dan", "2nd_dan", "dan_2", "nidan" -> DAN_2
                "3_dan", "3rd_dan", "dan_3", "sandan" -> DAN_3
                "4_dan", "4th_dan", "dan_4", "yondan" -> DAN_4
                "5_dan", "5th_dan", "dan_5", "godan" -> DAN_5
                "6_dan", "6th_dan", "dan_6", "rokudan" -> DAN_6
                "7_dan", "7th_dan", "dan_7", "shichidan" -> DAN_7
                "8_dan", "8th_dan", "dan_8", "hachidan" -> DAN_8
                "9_dan", "9th_dan", "dan_9", "kudan" -> DAN_9
                "10_dan", "10th_dan", "dan_10", "judan" -> DAN_10
                else -> null
            }
        }
    }
}
