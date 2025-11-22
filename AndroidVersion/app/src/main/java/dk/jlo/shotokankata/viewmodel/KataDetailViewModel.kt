package dk.jlo.shotokankata.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import dk.jlo.shotokankata.data.model.Kata
import dk.jlo.shotokankata.data.model.VocabularyTerm
import dk.jlo.shotokankata.data.repository.KataRepository
import dk.jlo.shotokankata.data.repository.VocabularyRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class KataDetailViewModel @Inject constructor(
    private val kataRepository: KataRepository,
    private val vocabularyRepository: VocabularyRepository
) : ViewModel() {

    private val _kata = MutableStateFlow<Kata?>(null)
    val kata: StateFlow<Kata?> = _kata.asStateFlow()

    private val _vocabularyTerms = MutableStateFlow<List<VocabularyTerm>>(emptyList())
    val vocabularyTerms: StateFlow<List<VocabularyTerm>> = _vocabularyTerms.asStateFlow()

    private val _selectedVocabularyTerm = MutableStateFlow<VocabularyTerm?>(null)
    val selectedVocabularyTerm: StateFlow<VocabularyTerm?> = _selectedVocabularyTerm.asStateFlow()

    fun loadKata(kataNumber: Int) {
        viewModelScope.launch {
            // Ensure kata data is loaded
            kataRepository.loadKata()
            _kata.value = kataRepository.getKataByNumber(kataNumber)

            // Load vocabulary terms for clickable text
            vocabularyRepository.loadVocabulary()
            _vocabularyTerms.value = vocabularyRepository.getAllTerms()
        }
    }

    fun selectVocabularyTerm(term: VocabularyTerm) {
        _selectedVocabularyTerm.value = term
    }

    fun clearSelectedVocabularyTerm() {
        _selectedVocabularyTerm.value = null
    }
}
