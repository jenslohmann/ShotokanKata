package dk.jlo.shotokankata.data.repository

import dk.jlo.shotokankata.data.model.BeltColor
import dk.jlo.shotokankata.data.model.Kata
import dk.jlo.shotokankata.data.model.KarateRank
import dk.jlo.shotokankata.data.source.JsonDataSource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.withContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class KataRepository @Inject constructor(
    private val dataSource: JsonDataSource
) {
    private val _kata = MutableStateFlow<List<Kata>>(emptyList())
    val kata: StateFlow<List<Kata>> = _kata.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    suspend fun loadKata() = withContext(Dispatchers.IO) {
        if (_kata.value.isNotEmpty()) return@withContext

        _isLoading.value = true
        try {
            val config = dataSource.loadKataConfiguration()
            val loadedKata = config.availableKata
                .filter { it.enabled }
                .mapNotNull { entry ->
                    try {
                        val resourceId = dataSource.getKataResourceId(entry.fileName)
                        if (resourceId != 0) {
                            dataSource.loadKata(resourceId)
                        } else null
                    } catch (e: Exception) {
                        null
                    }
                }
                .sortedBy { it.kataNumber }
            _kata.value = loadedKata
        } finally {
            _isLoading.value = false
        }
    }

    fun filterKata(
        searchText: String = "",
        rank: KarateRank? = null,
        beltColor: BeltColor? = null
    ): List<Kata> {
        return _kata.value.filter { kata ->
            val matchesSearch = searchText.isBlank() ||
                kata.name.contains(searchText, ignoreCase = true) ||
                kata.japaneseName.contains(searchText, ignoreCase = true)

            val matchesRank = rank == null || kata.rank == rank
            val matchesBelt = beltColor == null || kata.beltColor == beltColor

            matchesSearch && matchesRank && matchesBelt
        }
    }

    fun getKataByNumber(number: Int): Kata? {
        return _kata.value.find { it.kataNumber == number }
    }

    fun getKataById(id: String): Kata? {
        return _kata.value.find { it.id == id }
    }
}
