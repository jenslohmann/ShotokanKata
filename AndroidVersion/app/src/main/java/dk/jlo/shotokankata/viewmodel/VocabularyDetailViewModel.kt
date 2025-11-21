package dk.jlo.shotokankata.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import dk.jlo.shotokankata.data.model.VocabularyTerm
import dk.jlo.shotokankata.data.repository.VocabularyRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class VocabularyDetailViewModel @Inject constructor(
    private val vocabularyRepository: VocabularyRepository
) : ViewModel() {

    private val _term = MutableStateFlow<VocabularyTerm?>(null)
    val term: StateFlow<VocabularyTerm?> = _term.asStateFlow()

    fun loadTerm(termId: Int) {
        viewModelScope.launch {
            // Ensure vocabulary data is loaded
            vocabularyRepository.loadVocabulary()
            _term.value = vocabularyRepository.getTermById(termId)
        }
    }
}
