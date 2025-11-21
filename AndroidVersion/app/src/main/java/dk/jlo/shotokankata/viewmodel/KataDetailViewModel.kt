package dk.jlo.shotokankata.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import dk.jlo.shotokankata.data.model.Kata
import dk.jlo.shotokankata.data.repository.KataRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class KataDetailViewModel @Inject constructor(
    private val kataRepository: KataRepository
) : ViewModel() {

    private val _kata = MutableStateFlow<Kata?>(null)
    val kata: StateFlow<Kata?> = _kata.asStateFlow()

    fun loadKata(kataNumber: Int) {
        viewModelScope.launch {
            // Ensure kata data is loaded
            kataRepository.loadKata()
            _kata.value = kataRepository.getKataByNumber(kataNumber)
        }
    }
}
