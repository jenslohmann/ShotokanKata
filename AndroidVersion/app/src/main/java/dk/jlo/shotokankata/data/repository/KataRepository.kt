package dk.jlo.shotokankata.data.repository

import android.util.Log
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

private const val TAG = "KataRepository"

@Singleton
class KataRepository @Inject constructor(
    private val dataSource: JsonDataSource
) {
    private val _kata = MutableStateFlow<List<Kata>>(emptyList())
    val kata: StateFlow<List<Kata>> = _kata.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    suspend fun loadKata() = withContext(Dispatchers.IO) {
        Log.d(TAG, "loadKata called, current size: ${_kata.value.size}")
        if (_kata.value.isNotEmpty()) {
            Log.d(TAG, "Kata already loaded, returning early")
            return@withContext
        }

        _isLoading.value = true
        try {
            val config = dataSource.loadKataConfiguration()
            Log.d(TAG, "Loaded config with ${config.availableKata.size} kata entries")

            val enabledKata = config.availableKata.filter { it.enabled }
            Log.d(TAG, "Enabled kata: ${enabledKata.size}")

            val loadedKata = enabledKata
                .mapNotNull { entry ->
                    try {
                        val resourceId = dataSource.getKataResourceId(entry.fileName)
                        Log.d(TAG, "Resource ID for ${entry.fileName}: $resourceId")
                        if (resourceId != 0) {
                            val kata = dataSource.loadKata(resourceId)
                            Log.d(TAG, "Loaded kata: ${kata.name}")
                            kata
                        } else {
                            Log.w(TAG, "Resource not found for: ${entry.fileName}")
                            null
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error loading kata ${entry.fileName}: ${e.message}")
                        null
                    }
                }
                .sortedBy { it.kataNumber }

            Log.d(TAG, "Total loaded kata: ${loadedKata.size}")
            _kata.value = loadedKata
        } catch (e: Exception) {
            Log.e(TAG, "Error in loadKata: ${e.message}", e)
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
