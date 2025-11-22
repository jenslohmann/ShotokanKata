package dk.jlo.shotokankata.ui.kata

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.ui.Alignment
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.PrimaryTabRow
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Tab
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import dk.jlo.shotokankata.R
import dk.jlo.shotokankata.data.model.Kata
import dk.jlo.shotokankata.data.model.VocabularyTerm
import dk.jlo.shotokankata.ui.components.BeltColorBadge
import dk.jlo.shotokankata.ui.components.KataMoveCard
import dk.jlo.shotokankata.viewmodel.KataDetailViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun KataDetailScreen(
    kataNumber: Int,
    onBackClick: () -> Unit,
    viewModel: KataDetailViewModel = hiltViewModel()
) {
    val kata by viewModel.kata.collectAsState()
    val vocabularyTerms by viewModel.vocabularyTerms.collectAsState()
    val selectedVocabularyTerm by viewModel.selectedVocabularyTerm.collectAsState()
    var selectedTab by remember { mutableIntStateOf(0) }
    val tabs = listOf(
        stringResource(R.string.kata_tab_overview),
        stringResource(R.string.kata_tab_moves),
        stringResource(R.string.kata_tab_history)
    )
    val sheetState = rememberModalBottomSheetState()

    LaunchedEffect(kataNumber) {
        viewModel.loadKata(kataNumber)
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(kata?.name ?: "") },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(
                            imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                            contentDescription = stringResource(R.string.common_back)
                        )
                    }
                }
            )
        }
    ) { paddingValues ->
        kata?.let { currentKata ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
            ) {
                PrimaryTabRow(selectedTabIndex = selectedTab) {
                    tabs.forEachIndexed { index, title ->
                        Tab(
                            selected = selectedTab == index,
                            onClick = { selectedTab = index },
                            text = { Text(title) }
                        )
                    }
                }

                when (selectedTab) {
                    0 -> KataOverviewContent(currentKata)
                    1 -> KataMovesContent(
                        kata = currentKata,
                        vocabularyTerms = vocabularyTerms,
                        onVocabularyTermClick = { term ->
                            viewModel.selectVocabularyTerm(term)
                        }
                    )
                    2 -> KataHistoryContent(currentKata)
                }
            }
        }
    }

    // Vocabulary term bottom sheet
    selectedVocabularyTerm?.let { term ->
        ModalBottomSheet(
            onDismissRequest = { viewModel.clearSelectedVocabularyTerm() },
            sheetState = sheetState
        ) {
            VocabularyTermSheet(term = term)
        }
    }
}

@Composable
private fun VocabularyTermSheet(term: VocabularyTerm) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 24.dp, vertical = 16.dp)
            .padding(bottom = 32.dp)
    ) {
        // Term name (romanized)
        Text(
            text = term.term,
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold
        )

        // Japanese name
        Text(
            text = term.japaneseName,
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.primary
        )

        // Hiragana
        Text(
            text = term.hiraganaName,
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )

        Spacer(modifier = Modifier.height(16.dp))
        HorizontalDivider()
        Spacer(modifier = Modifier.height(16.dp))

        // Short description
        Text(
            text = term.shortDescription,
            style = MaterialTheme.typography.bodyLarge
        )

        // Definition if available and different from short description
        if (term.definition.isNotBlank() && term.definition != term.shortDescription) {
            Spacer(modifier = Modifier.height(12.dp))
            Text(
                text = term.definition,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        // Category
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = "Category: ${term.category}",
            style = MaterialTheme.typography.labelMedium,
            color = MaterialTheme.colorScheme.tertiary
        )
    }
}

@Composable
fun KataOverviewContent(kata: Kata) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
            .verticalScroll(rememberScrollState())
    ) {
        // Header with belt and basic info
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.primaryContainer
            )
        ) {
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Row {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = kata.japaneseName,
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                        kata.hiraganaName?.let {
                            Text(
                                text = it,
                                style = MaterialTheme.typography.titleMedium,
                                color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f)
                            )
                        }
                    }
                    BeltColorBadge(beltColor = kata.beltColor)
                }

                Spacer(modifier = Modifier.height(12.dp))

                Row(
                    horizontalArrangement = Arrangement.spacedBy(24.dp)
                ) {
                    Column {
                        Text(
                            text = stringResource(R.string.kata_moves),
                            style = MaterialTheme.typography.labelMedium,
                            color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.7f)
                        )
                        Text(
                            text = kata.numberOfMoves.toString(),
                            style = MaterialTheme.typography.titleLarge,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                    }
                    Column {
                        Text(
                            text = stringResource(R.string.kata_number),
                            style = MaterialTheme.typography.labelMedium,
                            color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.7f)
                        )
                        Text(
                            text = "#${kata.kataNumber}",
                            style = MaterialTheme.typography.titleLarge,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Description
        Text(
            text = stringResource(R.string.kata_description),
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = kata.description,
            style = MaterialTheme.typography.bodyMedium
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Key Techniques
        Text(
            text = stringResource(R.string.kata_key_techniques),
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(8.dp))

        kata.keyTechniques.forEach { technique ->
            Row(modifier = Modifier.padding(vertical = 2.dp)) {
                Text(
                    text = "•",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.primary
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = technique,
                    style = MaterialTheme.typography.bodyMedium
                )
            }
        }

        // Reference URL if available
        kata.referenceURL?.let { url ->
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = stringResource(R.string.kata_reference),
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = url,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.primary
            )
        }
    }
}

@Composable
fun KataMovesContent(
    kata: Kata,
    vocabularyTerms: List<VocabularyTerm> = emptyList(),
    onVocabularyTermClick: (VocabularyTerm) -> Unit = {}
) {
    // Filter out ceremonial moves (sequence < 1)
    val actualMoves = kata.moves.filter { it.sequence >= 1 }
    // Get the move numbers where kiai occurs (check both move level and sub-move level)
    val kiaiMoves = actualMoves.filter { move ->
        move.kiai == true || move.subMoves.any { subMove -> subMove.kiai == true }
    }.map { it.sequence }

    // Format kiai text as descriptive sentence
    val kiaiInfoText = when {
        kiaiMoves.isEmpty() -> "No kiai in this kata"
        kiaiMoves.size == 1 -> "Kiai on move ${kiaiMoves.first()}"
        kiaiMoves.size == 2 -> "Kiai on moves ${kiaiMoves[0]} and ${kiaiMoves[1]}"
        else -> "Kiai on moves ${kiaiMoves.dropLast(1).joinToString(", ")} and ${kiaiMoves.last()}"
    }

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // Summary header
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.secondaryContainer
                )
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    // Moves count
                    Column(
                        horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.padding(end = 24.dp)
                    ) {
                        Text(
                            text = kata.numberOfMoves.toString(),
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onSecondaryContainer
                        )
                        Text(
                            text = stringResource(R.string.kata_moves),
                            style = MaterialTheme.typography.labelMedium,
                            color = MaterialTheme.colorScheme.onSecondaryContainer.copy(alpha = 0.7f)
                        )
                    }

                    // Kiai info text
                    Text(
                        text = kiaiInfoText,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSecondaryContainer
                    )
                }
            }
        }

        // Move cards
        items(
            items = kata.moves,
            key = { "${it.sequence}-${it.japaneseName}" }
        ) { move ->
            KataMoveCard(
                move = move,
                vocabularyTerms = vocabularyTerms,
                onVocabularyTermClick = onVocabularyTermClick
            )
        }
    }
}

@Composable
fun KataHistoryContent(kata: Kata) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
            .verticalScroll(rememberScrollState())
    ) {
        Text(
            text = kata.name,
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold
        )
        Text(
            text = kata.japaneseName,
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )

        Spacer(modifier = Modifier.height(16.dp))

        Text(
            text = kata.description,
            style = MaterialTheme.typography.bodyLarge
        )

        // Note about history
        Spacer(modifier = Modifier.height(24.dp))
        Card(
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.tertiaryContainer
            )
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = "About Shotokan Kata",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onTertiaryContainer
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Shotokan kata were developed and refined by Master Gichin Funakoshi, who introduced karate from Okinawa to mainland Japan in the early 20th century. Each kata preserves combat techniques and principles passed down through generations of martial artists.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onTertiaryContainer
                )
            }
        }
    }
}
