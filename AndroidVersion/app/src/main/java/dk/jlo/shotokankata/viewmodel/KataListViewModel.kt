package dk.jlo.shotokankata.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import dk.jlo.shotokankata.data.model.BeltColor
import dk.jlo.shotokankata.data.model.Kata
import dk.jlo.shotokankata.data.model.KarateRank
import dk.jlo.shotokankata.data.repository.KataRepository
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
class KataListViewModel @Inject constructor(
    private val kataRepository: KataRepository
) : ViewModel() {

    private val _searchText = MutableStateFlow("")
    val searchText: StateFlow<String> = _searchText.asStateFlow()

    private val _selectedRank = MutableStateFlow<KarateRank?>(null)
    val selectedRank: StateFlow<KarateRank?> = _selectedRank.asStateFlow()

    private val _selectedBeltColor = MutableStateFlow<BeltColor?>(null)
    val selectedBeltColor: StateFlow<BeltColor?> = _selectedBeltColor.asStateFlow()

    val isLoading: StateFlow<Boolean> = kataRepository.isLoading

    @OptIn(FlowPreview::class)
    val filteredKata: StateFlow<List<Kata>> = combine(
        kataRepository.kata,
        _searchText.debounce(300),
        _selectedRank,
        _selectedBeltColor
    ) { _, search, rank, belt ->
        kataRepository.filterKata(search, rank, belt)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun loadKata() {
        viewModelScope.launch {
            kataRepository.loadKata()
        }
    }

    fun setSearchText(text: String) {
        _searchText.value = text
    }

    fun setSelectedRank(rank: KarateRank?) {
        _selectedRank.value = rank
    }

    fun setSelectedBeltColor(color: BeltColor?) {
        _selectedBeltColor.value = color
    }
}
