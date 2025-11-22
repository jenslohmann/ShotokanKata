package dk.jlo.shotokankata.data.repository

import dk.jlo.shotokankata.data.model.VocabularyCategory
import dk.jlo.shotokankata.data.model.VocabularyTerm
import dk.jlo.shotokankata.data.source.JsonDataSource
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.withContext
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class VocabularyRepository @Inject constructor(
    private val dataSource: JsonDataSource
) {
    private val _terms = MutableStateFlow<List<VocabularyTerm>>(emptyList())
    val terms: StateFlow<List<VocabularyTerm>> = _terms.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    suspend fun loadVocabulary() = withContext(Dispatchers.IO) {
        if (_terms.value.isNotEmpty()) return@withContext

        _isLoading.value = true
        try {
            _terms.value = dataSource.loadVocabulary()
        } finally {
            _isLoading.value = false
        }
    }

    fun getAllTerms(): List<VocabularyTerm> = _terms.value

    fun searchTerms(query: String): List<VocabularyTerm> {
        if (query.isBlank()) return _terms.value
        return _terms.value.filter { term ->
            term.term.contains(query, ignoreCase = true) ||
            term.japaneseName.contains(query, ignoreCase = true) ||
            term.hiraganaName.contains(query, ignoreCase = true) ||
            term.shortDescription.contains(query, ignoreCase = true)
        }
    }

    fun getTermsByCategory(category: VocabularyCategory): List<VocabularyTerm> {
        return _terms.value.filter { it.categoryType == category }
    }

    fun getTermById(id: Int): VocabularyTerm? {
        return _terms.value.find { it.id == id }
    }

    fun filterTerms(
        searchText: String = "",
        category: VocabularyCategory? = null
    ): List<VocabularyTerm> {
        return _terms.value.filter { term ->
            val matchesSearch = searchText.isBlank() ||
                term.term.contains(searchText, ignoreCase = true) ||
                term.japaneseName.contains(searchText, ignoreCase = true) ||
                term.hiraganaName.contains(searchText, ignoreCase = true)

            val matchesCategory = category == null || term.categoryType == category

            matchesSearch && matchesCategory
        }
    }

    /**
     * Find a vocabulary term by its romanized name (exact match, case-insensitive)
     */
    fun findTermByName(name: String): VocabularyTerm? {
        return _terms.value.find { term ->
            term.term.equals(name, ignoreCase = true) ||
            term.japaneseName.equals(name, ignoreCase = true)
        }
    }
}
