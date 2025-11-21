package dk.jlo.shotokankata.ui.vocabulary

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import dk.jlo.shotokankata.R
import dk.jlo.shotokankata.viewmodel.VocabularyDetailViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VocabularyDetailScreen(
    termId: Int,
    onBackClick: () -> Unit,
    viewModel: VocabularyDetailViewModel = hiltViewModel()
) {
    val term by viewModel.term.collectAsState()

    LaunchedEffect(termId) {
        viewModel.loadTerm(termId)
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(term?.term ?: "") },
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
        term?.let { currentTerm ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .padding(16.dp)
                    .verticalScroll(rememberScrollState())
            ) {
                Text(
                    text = currentTerm.japaneseName,
                    style = MaterialTheme.typography.headlineMedium
                )
                Text(
                    text = currentTerm.hiraganaName,
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = stringResource(R.string.vocabulary_detail_definition),
                    style = MaterialTheme.typography.titleMedium
                )
                Text(
                    text = currentTerm.definition,
                    style = MaterialTheme.typography.bodyMedium
                )

                currentTerm.componentBreakdown?.let { breakdown ->
                    Spacer(modifier = Modifier.height(16.dp))
                    Text(
                        text = stringResource(R.string.vocabulary_detail_breakdown),
                        style = MaterialTheme.typography.titleMedium
                    )
                    Text(
                        text = breakdown,
                        style = MaterialTheme.typography.bodyMedium
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                Text(
                    text = stringResource(R.string.vocabulary_detail_category),
                    style = MaterialTheme.typography.titleMedium
                )
                Text(
                    text = currentTerm.categoryType.displayName,
                    style = MaterialTheme.typography.bodyMedium
                )
            }
        }
    }
}
