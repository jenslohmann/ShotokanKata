package dk.jlo.shotokankata.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import dk.jlo.shotokankata.data.model.VocabularyCategory
import dk.jlo.shotokankata.data.model.VocabularyTerm
import dk.jlo.shotokankata.data.repository.VocabularyRepository
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.debounce
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class VocabularyViewModel @Inject constructor(
    private val vocabularyRepository: VocabularyRepository
) : ViewModel() {

    private val _searchText = MutableStateFlow("")
    val searchText: StateFlow<String> = _searchText.asStateFlow()

    private val _selectedCategory = MutableStateFlow<VocabularyCategory?>(null)
    val selectedCategory: StateFlow<VocabularyCategory?> = _selectedCategory.asStateFlow()

    val isLoading: StateFlow<Boolean> = vocabularyRepository.isLoading

    @OptIn(FlowPreview::class)
    val filteredTerms: StateFlow<List<VocabularyTerm>> = combine(
        vocabularyRepository.terms,
        _searchText.debounce(300),
        _selectedCategory
    ) { _, search, category ->
        vocabularyRepository.filterTerms(search, category)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun loadVocabulary() {
        viewModelScope.launch {
            vocabularyRepository.loadVocabulary()
        }
    }

    fun setSearchText(text: String) {
        _searchText.value = text
    }

    fun setSelectedCategory(category: VocabularyCategory?) {
        _selectedCategory.value = category
    }
}
