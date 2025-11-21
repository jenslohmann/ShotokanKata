# Android Migration Plan - Shotokan Kata

This document outlines the complete migration plan for porting the Shotokan Kata iOS app to Android.

## Executive Summary

The Shotokan Kata app is a karate learning tool with four main features:
1. **Kata Reference** - Browse and learn 26 Shotokan kata with move-by-move breakdowns
2. **Quiz System** - Test knowledge with static and dynamic questions
3. **Vocabulary** - 100+ Japanese karate terms with definitions
4. **About** - App information

The iOS app is built with SwiftUI/MVVM and has no external dependencies. The Android version will use Jetpack Compose with modern Android architecture.

---

## Phase 1: Project Setup & Foundation ✅ COMPLETE

### 1.1 Create Android Project ✅ COMPLETE
- [x] Create new Android Studio project (Compose to be added in 1.2)
- [x] Configure Kotlin 2.0.21 (exceeds 1.9+ requirement)
- [x] Set up Gradle with version catalog (libs.versions.toml)
- [x] Configure minimum SDK 26, target SDK 36 (exceeds SDK 34 requirement)

> **Note:** Basic project created in `AndroidVersion/` folder. Package: `dk.jlo.shotokankata`. Compose dependencies will be added in Phase 1.2.

### 1.2 Add Dependencies ✅ COMPLETE
- [x] Jetpack Compose (BOM 2024.12.01)
- [x] Material 3
- [x] Navigation Compose 2.8.5
- [x] Lifecycle ViewModel Compose 2.8.7
- [x] Hilt 2.53.1 for dependency injection
- [x] Kotlinx Serialization 1.7.3 for JSON
- [x] Kotlin Coroutines 1.9.0
- [x] KSP 2.0.21-1.0.28

### 1.3 Project Structure ✅ COMPLETE
Package structure created in `dk.jlo.shotokankata/`:
```
dk.jlo.shotokankata/
├── data/
│   ├── model/          # Kata, VocabularyTerm, QuizQuestion, etc.
│   ├── repository/     # KataRepository, VocabularyRepository, QuizRepository
│   └── source/         # JsonDataSource
├── di/                 # AppModule, RepositoryModule
├── ui/
│   ├── kata/           # KataListScreen, KataDetailScreen
│   ├── quiz/           # QuizMenuScreen, QuizScreen
│   ├── vocabulary/     # VocabularyListScreen, VocabularyDetailScreen
│   ├── about/          # AboutScreen
│   ├── components/     # BeltColorBadge
│   ├── navigation/     # ShotokanKataNavHost, NavRoutes, BottomNavItem
│   └── theme/          # Theme, Color, Type
└── viewmodel/          # KataListViewModel, QuizViewModel, etc.
```

### 1.4 Copy Data Files ✅ COMPLETE
- [x] Copy `kata.json` to `res/raw/`
- [x] Copy `vocabulary.json` to `res/raw/`
- [x] Copy 10 individual kata JSON files to `res/raw/`
- [x] Create `values/strings.xml` (English)
- [x] Create `values-da/strings.xml` (Danish)

### 1.5 Theme Setup ✅ COMPLETE
- [x] Create Material 3 theme with light/dark variants
- [x] Define belt color palette (7 colors with dark mode variants)
- [x] Set up typography for Japanese text support
- [x] Configure edge-to-edge display

---

## Phase 2: Data Layer ✅ COMPLETE

### 2.1 Data Models ✅ COMPLETE

**Kata.kt**
```kotlin
@Serializable
data class Kata(
    val id: String = UUID.randomUUID().toString(),
    val name: String,
    val japaneseName: String,
    val hiraganaName: String? = null,
    val numberOfMoves: Int,
    val kataNumber: Int,
    val beltRank: String,
    val description: String,
    val keyTechniques: List<String>,
    val referenceURL: String? = null,
    val videoURLs: List<String>? = null,
    val moves: List<KataMove>
) {
    val rank: KarateRank? get() = KarateRank.fromString(beltRank)
    val beltColor: BeltColor get() = rank?.beltColor ?: BeltColor.WHITE
}

@Serializable
data class KataMove(
    val sequence: Int,
    val japaneseName: String,
    val direction: String,
    val kiai: Boolean? = null,
    val subMoves: List<KataSubMove>,
    val sequenceName: String? = null
)

@Serializable
data class KataSubMove(
    val order: Int,
    val technique: String,
    val hiragana: String? = null,
    val stance: String,
    val stanceHiragana: String? = null,
    val description: String,
    val icon: String,
    val kiai: Boolean? = null
)
```

**VocabularyTerm.kt**
```kotlin
@Serializable
data class VocabularyTerm(
    val id: Int,
    val term: String,
    val japaneseName: String,
    val hiraganaName: String,
    val shortDescription: String,
    val definition: String,
    val category: String,
    val componentBreakdown: String? = null
) {
    val categoryType: VocabularyCategory get() = VocabularyCategory.fromString(category)
}
```

**QuizQuestion.kt**
```kotlin
@Serializable
data class QuizQuestion(
    val id: String = UUID.randomUUID().toString(),
    var question: String,
    var options: List<String>,
    var correctAnswerIndex: Int,
    val category: QuestionCategory,
    val questionType: QuestionType,
    val requiredRank: String,
    val explanation: String? = null,
    val relatedKataNames: List<String>? = null,
    val kataData: Kata? = null,
    val correctMoveIndices: List<Int>? = null
)

enum class QuestionType {
    STATIC_QUESTION,
    KATA_MOVES_COUNT,
    KATA_KIAI_SELECTION,
    KATA_TECHNIQUES,
    KATA_STANCES,
    KATA_RANK,
    KATA_ORDER
}
```

**Enums**
```kotlin
enum class KarateRank(val displayName: String, val beltColor: BeltColor, val sortOrder: Int) {
    KYU_10("10th Kyu", BeltColor.WHITE, 1),
    KYU_9("9th Kyu", BeltColor.WHITE, 2),
    KYU_8("8th Kyu", BeltColor.YELLOW, 3),
    // ... all ranks
    DAN_10("10th Dan", BeltColor.BLACK, 20);

    companion object {
        fun fromString(value: String): KarateRank? = // parse "8_kyu" format
    }
}

enum class BeltColor(val displayName: String, val colorValue: Long) {
    WHITE("White", 0xFFFFFFFF),
    YELLOW("Yellow", 0xFFFFEB3B),
    ORANGE("Orange", 0xFFFF9800),
    GREEN("Green", 0xFF4CAF50),
    PURPLE("Purple", 0xFF9C27B0),
    BROWN("Brown", 0xFF795548),
    BLACK("Black", 0xFF212121)
}

enum class QuestionCategory(val displayName: String, val icon: String) {
    HISTORY("History", "history"),
    TECHNIQUES("Techniques", "sports_martial_arts"),
    // ... all categories
}

enum class VocabularyCategory(val displayName: String, val icon: String) {
    GENERAL("General", "info"),
    ETIQUETTE("Etiquette", "handshake"),
    // ... all 10 categories
}
```

### 2.2 Data Sources ✅ COMPLETE

**JsonDataSource.kt**
```kotlin
class JsonDataSource @Inject constructor(
    @ApplicationContext private val context: Context
) {
    fun loadKataConfiguration(): KataConfiguration {
        return context.resources.openRawResource(R.raw.kata)
            .bufferedReader()
            .use { Json.decodeFromString(it.readText()) }
    }

    fun loadKata(fileName: String): Kata { /* load individual kata */ }
    fun loadVocabulary(): List<VocabularyTerm> { /* load vocabulary.json */ }
}
```

### 2.3 Repositories ✅ COMPLETE

**KataRepository.kt**
```kotlin
class KataRepository @Inject constructor(
    private val dataSource: JsonDataSource
) {
    private val _kata = MutableStateFlow<List<Kata>>(emptyList())
    val kata: StateFlow<List<Kata>> = _kata.asStateFlow()

    suspend fun loadKata() { /* load all enabled kata */ }
    fun filterKata(searchText: String, rank: KarateRank?, beltColor: BeltColor?): List<Kata>
    fun getKataByNumber(number: Int): Kata?
}
```

**VocabularyRepository.kt**
```kotlin
class VocabularyRepository @Inject constructor(
    private val dataSource: JsonDataSource
) {
    fun getAllTerms(): List<VocabularyTerm>
    fun searchTerms(query: String): List<VocabularyTerm>
    fun getTermsByCategory(category: VocabularyCategory): List<VocabularyTerm>
}
```

**QuizRepository.kt**
```kotlin
class QuizRepository @Inject constructor(
    private val kataRepository: KataRepository
) {
    fun generateQuestions(
        rank: KarateRank,
        category: QuestionCategory?,
        limit: Int
    ): List<QuizQuestion>

    // Dynamic question generators
    private fun generateKataMovesCountQuestions(): List<QuizQuestion>
    private fun generateKiaiSelectionQuestions(): List<QuizQuestion>
    private fun generateTechniqueQuestions(): List<QuizQuestion>
    private fun generateStanceQuestions(): List<QuizQuestion>
}
```

---

## Phase 3: UI Layer - Kata Feature ✅ COMPLETE

### 3.1 KataListViewModel ✅ COMPLETE
```kotlin
@HiltViewModel
class KataListViewModel @Inject constructor(
    private val kataRepository: KataRepository
) : ViewModel() {
    private val _searchText = MutableStateFlow("")
    private val _selectedRank = MutableStateFlow<KarateRank?>(null)
    private val _selectedBeltColor = MutableStateFlow<BeltColor?>(null)

    val filteredKata: StateFlow<List<Kata>> = combine(
        kataRepository.kata,
        _searchText.debounce(300),
        _selectedRank,
        _selectedBeltColor
    ) { kata, search, rank, belt ->
        kataRepository.filterKata(search, rank, belt)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    fun setSearchText(text: String) { _searchText.value = text }
    fun setSelectedRank(rank: KarateRank?) { _selectedRank.value = rank }
    fun setSelectedBeltColor(color: BeltColor?) { _selectedBeltColor.value = color }
}
```

### 3.2 KataListScreen ✅ COMPLETE
```kotlin
@Composable
fun KataListScreen(
    viewModel: KataListViewModel = hiltViewModel(),
    onKataClick: (Int) -> Unit
) {
    val kata by viewModel.filteredKata.collectAsStateWithLifecycle()
    val searchText by viewModel.searchText.collectAsStateWithLifecycle()

    Column {
        SearchBar(query = searchText, onQueryChange = viewModel::setSearchText)
        BeltColorFilterChips(onColorSelected = viewModel::setSelectedBeltColor)
        LazyColumn {
            items(kata) { kata ->
                KataListItem(kata = kata, onClick = { onKataClick(kata.kataNumber) })
            }
        }
    }
}
```

### 3.3 KataDetailScreen ✅ COMPLETE
```kotlin
@Composable
fun KataDetailScreen(
    kataNumber: Int,
    viewModel: KataDetailViewModel = hiltViewModel()
) {
    var selectedTab by remember { mutableIntStateOf(0) }
    val tabs = listOf("Overview", "Moves", "History")

    Column {
        KataHeader(kata = kata)
        TabRow(selectedTabIndex = selectedTab) {
            tabs.forEachIndexed { index, title ->
                Tab(selected = selectedTab == index, onClick = { selectedTab = index })
            }
        }
        when (selectedTab) {
            0 -> KataOverviewContent(kata)
            1 -> KataMovesContent(kata)
            2 -> KataHistoryContent(kata)
        }
    }
}
```

---

## Phase 4: UI Layer - Vocabulary Feature

### 4.1 VocabularyViewModel
```kotlin
@HiltViewModel
class VocabularyViewModel @Inject constructor(
    private val vocabularyRepository: VocabularyRepository
) : ViewModel() {
    private val _searchText = MutableStateFlow("")
    private val _selectedCategory = MutableStateFlow<VocabularyCategory?>(null)

    val filteredTerms: StateFlow<List<VocabularyTerm>> = combine(
        _searchText.debounce(300),
        _selectedCategory
    ) { search, category ->
        var terms = vocabularyRepository.getAllTerms()
        if (category != null) terms = terms.filter { it.categoryType == category }
        if (search.isNotBlank()) terms = vocabularyRepository.searchTerms(search)
        terms
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())
}
```

### 4.2 VocabularyListScreen & VocabularyDetailScreen
- Searchable list with category filter chips
- Detail view with term, Japanese name, hiragana, definition, component breakdown

---

## Phase 5: UI Layer - Quiz Feature

### 5.1 QuizViewModel
```kotlin
@HiltViewModel
class QuizViewModel @Inject constructor(
    private val quizRepository: QuizRepository
) : ViewModel() {
    // Configuration
    private val _selectedRank = MutableStateFlow(KarateRank.KYU_10)
    private val _selectedCategory = MutableStateFlow<QuestionCategory?>(null)
    private val _questionCount = MutableStateFlow(10)
    private val _timedMode = MutableStateFlow(false)

    // Quiz state
    private val _quizState = MutableStateFlow<QuizState>(QuizState.NotStarted)
    val quizState: StateFlow<QuizState> = _quizState.asStateFlow()

    private val _questions = MutableStateFlow<List<QuizQuestion>>(emptyList())
    private val _currentQuestionIndex = MutableStateFlow(0)
    private val _userAnswers = MutableStateFlow<Map<Int, QuizAnswer>>(emptyMap())
    private val _remainingTime = MutableStateFlow(600) // 10 minutes in seconds

    fun startQuiz() {
        val questions = quizRepository.generateQuestions(
            _selectedRank.value,
            _selectedCategory.value,
            _questionCount.value
        )
        _questions.value = questions.shuffled()
        _quizState.value = QuizState.InProgress(0)
        if (_timedMode.value) startTimer()
    }

    fun submitAnswer(answer: QuizAnswer) { /* record answer, move to next */ }
    fun finishQuiz(): QuizResult { /* calculate score */ }
}

sealed class QuizState {
    object NotStarted : QuizState()
    data class InProgress(val questionIndex: Int) : QuizState()
    object Paused : QuizState()
    data class Completed(val result: QuizResult) : QuizState()
}

sealed class QuizAnswer {
    data class MultipleChoice(val selectedIndex: Int?) : QuizAnswer()
    data class KiaiSelection(val selectedIndices: Set<Int>) : QuizAnswer()
    object Skipped : QuizAnswer()
}

data class QuizResult(
    val totalQuestions: Int,
    val correctAnswers: Int,
    val timeTaken: Int,
    val passed: Boolean // 70% threshold
)
```

### 5.2 QuizMenuScreen
```kotlin
@Composable
fun QuizMenuScreen(
    viewModel: QuizViewModel = hiltViewModel(),
    onStartQuiz: () -> Unit
) {
    Column {
        Text("Quiz Configuration", style = MaterialTheme.typography.headlineMedium)

        // Rank selection
        RankSelector(
            selectedRank = viewModel.selectedRank.collectAsStateWithLifecycle().value,
            onRankSelected = viewModel::setSelectedRank
        )

        // Category selection
        CategorySelector(
            selectedCategory = viewModel.selectedCategory.collectAsStateWithLifecycle().value,
            onCategorySelected = viewModel::setSelectedCategory
        )

        // Question count slider
        QuestionCountSlider(
            count = viewModel.questionCount.collectAsStateWithLifecycle().value,
            onCountChanged = viewModel::setQuestionCount
        )

        // Timed mode toggle
        TimedModeSwitch(
            enabled = viewModel.timedMode.collectAsStateWithLifecycle().value,
            onToggle = viewModel::setTimedMode
        )

        Button(onClick = { viewModel.startQuiz(); onStartQuiz() }) {
            Text("Start Quiz")
        }
    }
}
```

### 5.3 QuizScreen
```kotlin
@Composable
fun QuizScreen(
    viewModel: QuizViewModel = hiltViewModel(),
    onExit: () -> Unit
) {
    val quizState by viewModel.quizState.collectAsStateWithLifecycle()

    when (val state = quizState) {
        is QuizState.NotStarted -> { /* shouldn't happen */ }
        is QuizState.InProgress -> {
            QuizInProgressContent(
                question = viewModel.currentQuestion,
                questionIndex = state.questionIndex,
                totalQuestions = viewModel.totalQuestions,
                remainingTime = viewModel.remainingTime.collectAsStateWithLifecycle().value,
                onAnswerSelected = viewModel::submitAnswer
            )
        }
        is QuizState.Paused -> QuizPausedContent(onResume = viewModel::resumeQuiz)
        is QuizState.Completed -> QuizResultsContent(result = state.result, onExit = onExit)
    }
}
```

### 5.4 KiaiSelectionScreen
Special composable for kiai selection questions:
```kotlin
@Composable
fun KiaiSelectionQuestion(
    kata: Kata,
    selectedIndices: Set<Int>,
    onSelectionChanged: (Set<Int>) -> Unit
) {
    LazyColumn {
        itemsIndexed(kata.moves) { index, move ->
            KiaiMoveItem(
                move = move,
                index = index,
                isSelected = index in selectedIndices,
                onToggle = { /* toggle selection */ }
            )
        }
    }
}
```

---

## Phase 6: Navigation

### 6.1 Navigation Setup
```kotlin
@Composable
fun ShotokanKataNavHost(navController: NavHostController) {
    NavHost(navController = navController, startDestination = "kata_list") {
        // Kata
        composable("kata_list") {
            KataListScreen(onKataClick = { navController.navigate("kata_detail/$it") })
        }
        composable("kata_detail/{kataNumber}") { backStackEntry ->
            val kataNumber = backStackEntry.arguments?.getString("kataNumber")?.toInt() ?: 1
            KataDetailScreen(kataNumber = kataNumber)
        }

        // Quiz
        composable("quiz_menu") {
            QuizMenuScreen(onStartQuiz = { navController.navigate("quiz_active") })
        }
        composable("quiz_active") {
            QuizScreen(onExit = { navController.popBackStack("quiz_menu", false) })
        }

        // Vocabulary
        composable("vocabulary_list") {
            VocabularyListScreen(onTermClick = { navController.navigate("vocabulary_detail/$it") })
        }
        composable("vocabulary_detail/{termId}") { backStackEntry ->
            val termId = backStackEntry.arguments?.getString("termId")?.toInt() ?: 0
            VocabularyDetailScreen(termId = termId)
        }

        // About
        composable("about") { AboutScreen() }
    }
}
```

### 6.2 Bottom Navigation
```kotlin
@Composable
fun ShotokanKataApp() {
    val navController = rememberNavController()
    val items = listOf(
        BottomNavItem("Kata", Icons.Default.List, "kata_list"),
        BottomNavItem("Quiz", Icons.Default.Quiz, "quiz_menu"),
        BottomNavItem("Vocabulary", Icons.Default.Book, "vocabulary_list"),
        BottomNavItem("About", Icons.Default.Info, "about")
    )

    Scaffold(
        bottomBar = {
            NavigationBar {
                items.forEach { item ->
                    NavigationBarItem(
                        icon = { Icon(item.icon, contentDescription = item.title) },
                        label = { Text(item.title) },
                        selected = currentRoute == item.route,
                        onClick = { navController.navigate(item.route) }
                    )
                }
            }
        }
    ) { paddingValues ->
        ShotokanKataNavHost(
            navController = navController,
            modifier = Modifier.padding(paddingValues)
        )
    }
}
```

---

## Phase 7: Polish & Testing

### 7.1 Adaptive Layouts
- Use `WindowSizeClass` for responsive design
- Two-pane layout on tablets (list + detail)
- Single-pane on phones

### 7.2 Dark Mode
- Already supported via Material 3 theming
- Ensure belt colors have good contrast in both modes

### 7.3 Localization
- Copy strings from iOS `Localizable.strings` to:
  - `res/values/strings.xml` (English)
  - `res/values-da/strings.xml` (Danish)

### 7.4 Accessibility
- Content descriptions for all images
- Sufficient touch targets (48dp minimum)
- Screen reader support

### 7.5 Testing
- Unit tests for ViewModels and Repositories
- UI tests with Compose testing
- Test quiz scoring and timing

---

## File Checklist

### Data Files to Copy (from iOS `Resources/` folder)
- [ ] `kata.json`
- [ ] `vocabulary.json`
- [ ] `kata/01_heian_shodan.json`
- [ ] `kata/02_heian_nidan.json`
- [ ] `kata/03_heian_sandan.json`
- [ ] `kata/04_heian_yondan.json`
- [ ] `kata/05_heian_godan.json`
- [ ] `kata/06_tekki_shodan.json`
- [ ] `kata/09_bassai_dai.json`
- [ ] `kata/10_kanku_dai.json`
- [ ] `kata/11_empi.json`
- [ ] `kata/15_jion.json`

### Kotlin Files to Create
- [ ] `data/model/Kata.kt`
- [ ] `data/model/KataMove.kt`
- [ ] `data/model/KataSubMove.kt`
- [ ] `data/model/VocabularyTerm.kt`
- [ ] `data/model/QuizQuestion.kt`
- [ ] `data/model/KarateRank.kt`
- [ ] `data/model/BeltColor.kt`
- [ ] `data/model/QuestionCategory.kt`
- [ ] `data/model/VocabularyCategory.kt`
- [ ] `data/model/QuizState.kt`
- [ ] `data/model/QuizResult.kt`
- [ ] `data/source/JsonDataSource.kt`
- [ ] `data/repository/KataRepository.kt`
- [ ] `data/repository/VocabularyRepository.kt`
- [ ] `data/repository/QuizRepository.kt`
- [ ] `di/AppModule.kt`
- [ ] `di/RepositoryModule.kt`
- [ ] `viewmodel/KataListViewModel.kt`
- [ ] `viewmodel/KataDetailViewModel.kt`
- [ ] `viewmodel/VocabularyViewModel.kt`
- [ ] `viewmodel/QuizViewModel.kt`
- [ ] `ui/theme/Theme.kt`
- [ ] `ui/theme/Color.kt`
- [ ] `ui/theme/Typography.kt`
- [ ] `ui/navigation/NavHost.kt`
- [ ] `ui/navigation/BottomNavItem.kt`
- [ ] `ui/kata/KataListScreen.kt`
- [ ] `ui/kata/KataDetailScreen.kt`
- [ ] `ui/kata/components/*.kt` (header, moves, overview, etc.)
- [ ] `ui/vocabulary/VocabularyListScreen.kt`
- [ ] `ui/vocabulary/VocabularyDetailScreen.kt`
- [ ] `ui/quiz/QuizMenuScreen.kt`
- [ ] `ui/quiz/QuizScreen.kt`
- [ ] `ui/quiz/KiaiSelectionQuestion.kt`
- [ ] `ui/about/AboutScreen.kt`
- [ ] `ui/components/SearchBar.kt`
- [ ] `ui/components/FilterChips.kt`
- [ ] `ui/components/RankBadge.kt`
- [ ] `MainActivity.kt`
- [ ] `ShotokanKataApp.kt` (Application class)

---

## Summary

| Phase | Focus | Key Deliverables | Status |
|-------|-------|------------------|--------|
| 1 | Setup | Project structure, dependencies, theme | ✅ Complete |
| 2 | Data | Models, JSON loading, repositories | ✅ Complete |
| 3 | Kata | List, detail, filtering, search | ✅ Complete |
| 4 | Vocabulary | List, detail, search, categories | ⏳ Pending |
| 5 | Quiz | Configuration, questions, scoring, timer | ⏳ Pending |
| 6 | Navigation | Bottom nav, routes, adaptive layout | ⏳ Pending |
| 7 | Polish | Dark mode, localization, testing | ⏳ Pending |

The iOS app has no external dependencies and uses JSON files for all data, making this migration straightforward. The main work is translating SwiftUI patterns to Compose equivalents while maintaining feature parity.
