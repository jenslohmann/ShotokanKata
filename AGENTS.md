# AGENTS.md - Shotokan Kata Android Migration

This document provides guidance for AI agents working on the Android migration of the Shotokan Kata app.

---

## Current Progress

| Phase | Status | Notes |
|-------|--------|-------|
| **Phase 1** | ✅ **Complete** | **Project Setup & Foundation** |
| 1.1 Create Android Project | ✅ Complete | Kotlin 2.0.21, SDK 26-35 |
| 1.2 Add Dependencies | ✅ Complete | Compose BOM 2024.12.01, Hilt 2.53.1, Navigation 2.8.5 |
| 1.3 Project Structure | ✅ Complete | Full package structure with models, repos, viewmodels, UI |
| 1.4 Copy Data Files | ✅ Complete | 12 JSON files, English + Danish strings |
| 1.5 Theme Setup | ✅ Complete | Material 3 light/dark themes, belt colors |
| **Phase 2-7** | ⏳ Pending | Data layer, UI, Quiz, Navigation, Polish |

### Project Location
- **Android project**: `AndroidVersion/`
- **Package name**: `dk.jlo.shotokankata`
- **iOS reference**: `Shotokan Kata/`

### Files Created in Phase 1 (40+ files)
- **Data Models**: Kata, KataMove, VocabularyTerm, QuizQuestion, KarateRank, BeltColor, etc.
- **Repositories**: KataRepository, VocabularyRepository, QuizRepository
- **ViewModels**: KataListViewModel, KataDetailViewModel, VocabularyViewModel, QuizViewModel
- **UI Screens**: KataListScreen, KataDetailScreen, VocabularyListScreen, QuizMenuScreen, AboutScreen
- **Navigation**: ShotokanKataNavHost, BottomNavItem, NavRoutes
- **Theme**: Color.kt, Type.kt, Theme.kt (with light/dark support)
- **Resources**: strings.xml (EN/DA), colors.xml, themes.xml, 12 JSON data files

---

## Project Overview

**Shotokan Kata** is a learning and training tool for Shotokan karate practitioners. The iOS version is built with SwiftUI and follows MVVM architecture. The Android version should mirror the functionality using Jetpack Compose and modern Android architecture patterns.

## Architecture Guidelines

### Target Architecture
- **UI Framework**: Jetpack Compose
- **Architecture Pattern**: MVVM with Repository pattern
- **Dependency Injection**: Hilt
- **Async Operations**: Kotlin Coroutines + Flow
- **JSON Parsing**: Kotlinx.serialization or Moshi
- **Navigation**: Compose Navigation
- **Minimum SDK**: API 26 (Android 8.0)
- **Target SDK**: API 34 (Android 14)

### Project Structure

```
app/
├── src/main/
│   ├── java/com/shotokankata/
│   │   ├── data/
│   │   │   ├── model/           # Data classes (Kata, VocabularyTerm, QuizQuestion)
│   │   │   ├── repository/      # Data repositories
│   │   │   └── source/          # JSON data sources
│   │   ├── di/                  # Hilt modules
│   │   ├── ui/
│   │   │   ├── kata/            # Kata list and detail screens
│   │   │   ├── quiz/            # Quiz screens
│   │   │   ├── vocabulary/      # Vocabulary screens
│   │   │   ├── about/           # About screen
│   │   │   ├── components/      # Reusable composables
│   │   │   ├── navigation/      # Navigation setup
│   │   │   └── theme/           # Material theme
│   │   └── viewmodel/           # ViewModels
│   ├── res/
│   │   ├── raw/                 # JSON data files (copy from iOS)
│   │   ├── values/              # Strings, colors, themes
│   │   └── values-da/           # Danish localization
│   └── assets/                  # Additional assets
└── build.gradle.kts
```

## Data Models Mapping

### iOS to Android Type Mapping

| Swift | Kotlin |
|-------|--------|
| `struct` | `data class` |
| `enum` with associated values | `sealed class` |
| `enum` simple | `enum class` |
| `UUID` | `String` (UUID.randomUUID().toString()) |
| `Bool?` | `Boolean?` |
| `[String]` | `List<String>` |
| `@Published` | `StateFlow<T>` / `MutableStateFlow<T>` |
| `ObservableObject` | `ViewModel` |

### Core Models to Implement

1. **Kata.kt** - Main kata data class
2. **KataMove.kt** - Individual move in a kata
3. **KataSubMove.kt** - Sub-move details
4. **VocabularyTerm.kt** - Vocabulary entry
5. **QuizQuestion.kt** - Quiz question with multiple types
6. **KarateRank.kt** - Rank enum (10 kyu + 10 dan)
7. **BeltColor.kt** - Belt color enum
8. **QuestionCategory.kt** - Quiz category enum
9. **VocabularyCategory.kt** - Vocabulary category enum

## Feature Implementation Order

### Phase 1: Foundation
1. Project setup with Compose, Hilt, Navigation
2. Theme and color system (Material 3)
3. Data models (all Kotlin data classes)
4. JSON loading utilities
5. Repository layer

### Phase 2: Kata Feature
1. KataRepository - load and filter kata
2. KataListViewModel
3. KataListScreen (with search/filter)
4. KataDetailScreen (overview, moves, history tabs)
5. Navigation between list and detail

### Phase 3: Vocabulary Feature
1. VocabularyRepository
2. VocabularyViewModel
3. VocabularyListScreen (with search/category filter)
4. VocabularyDetailScreen

### Phase 4: Quiz Feature
1. QuizRepository (static + dynamic question generation)
2. QuizViewModel (state machine for quiz flow)
3. QuizMenuScreen (configuration)
4. QuizScreen (questions, timer, results)
5. KiaiSelectionScreen (special question type)

### Phase 5: Polish
1. About screen
2. Adaptive layout (phone/tablet)
3. Dark mode support
4. Localization (English + Danish)
5. Testing

## Key Implementation Notes

### JSON Data Files
Copy these files from iOS to `app/src/main/res/raw/`:
- `kata.json` - Kata configuration
- `vocabulary.json` - All vocabulary terms
- `kata/*.json` - Individual kata files (10 enabled)

The JSON structure is identical - no modifications needed.

### Navigation Structure
```
NavHost
├── kata_list → kata_detail/{kataNumber}
├── quiz_menu → quiz_active
├── vocabulary_list → vocabulary_detail/{termId}
└── about
```

### Quiz State Machine
```kotlin
sealed class QuizState {
    object NotStarted : QuizState()
    data class InProgress(val questionIndex: Int) : QuizState()
    object Paused : QuizState()
    data class Completed(val result: QuizResult) : QuizState()
}
```

### Filtering Implementation
Use Kotlin Flow for reactive filtering:
```kotlin
val filteredKata: StateFlow<List<Kata>> = combine(
    allKata,
    searchText.debounce(300),
    selectedRank,
    selectedBeltColor
) { kata, search, rank, belt ->
    // Apply filters
}.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())
```

### Belt Color Scheme
Map iOS belt colors to Material 3 color tokens or custom colors:
- White: `Color(0xFFFFFFFF)`
- Yellow: `Color(0xFFFFEB3B)`
- Orange: `Color(0xFFFF9800)`
- Green: `Color(0xFF4CAF50)`
- Purple: `Color(0xFF9C27B0)`
- Brown: `Color(0xFF795548)`
- Black: `Color(0xFF212121)`

## Testing Guidelines

### Unit Tests
- ViewModel tests with fake repositories
- Repository tests with test JSON data
- Quiz question generation tests
- Filter logic tests

### UI Tests
- Navigation flows
- Quiz completion flow
- Search and filter functionality

## Common Pitfalls to Avoid

1. **Don't modify JSON files** - They work as-is from iOS
2. **Preserve Japanese characters** - Ensure UTF-8 encoding everywhere
3. **Quiz randomization** - Use `shuffled()` with seeded random for reproducibility in tests
4. **Kiai selection** - Store as `Set<Int>` for selected move indices
5. **Sequence handling** - Kata moves can have null sequenceName

## Reference Files (iOS)

When implementing features, reference these iOS source files:

### Models
- `Shotokan Kata/Shotokan Kata/Models/Kata.swift`
- `Shotokan Kata/Shotokan Kata/Models/VocabularyTerm.swift`
- `Shotokan Kata/Shotokan Kata/Models/QuizQuestion.swift`
- `Shotokan Kata/Shotokan Kata/Models/DifficultyLevel.swift`

### ViewModels
- `Shotokan Kata/Shotokan Kata/ViewModels/KataListViewModel.swift`
- `Shotokan Kata/Shotokan Kata/ViewModels/QuizViewModel.swift`
- `Shotokan Kata/Shotokan Kata/ViewModels/VocabularyViewModel.swift`

### Services (→ Repositories)
- `Shotokan Kata/Shotokan Kata/Services/KataDataService.swift`
- `Shotokan Kata/Shotokan Kata/Services/QuizDataService.swift`
- `Shotokan Kata/Shotokan Kata/Services/VocabularyDataService.swift`

### Key Views
- `Shotokan Kata/Shotokan Kata/ContentView.swift` - Main navigation
- `Shotokan Kata/Shotokan Kata/Views/KataListView.swift` - List with filters
- `Shotokan Kata/Shotokan Kata/Views/QuizView.swift` - Quiz flow
- `Shotokan Kata/Shotokan Kata/Views/VocabularyView.swift` - Vocabulary list

## Dependencies (build.gradle.kts)

```kotlin
dependencies {
    // Compose BOM
    implementation(platform("androidx.compose:compose-bom:2024.01.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")

    // Navigation
    implementation("androidx.navigation:navigation-compose:2.7.6")

    // ViewModel
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.7.0")

    // Hilt
    implementation("com.google.dagger:hilt-android:2.50")
    kapt("com.google.dagger:hilt-compiler:2.50")
    implementation("androidx.hilt:hilt-navigation-compose:1.1.0")

    // JSON
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.2")

    // Coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
}
```

## Questions to Ask Before Starting

1. Should quiz scores be persisted locally (Room database)?
2. Any additional features for Android not in iOS?
3. Should the app support Android Wear or widgets?
4. Any specific accessibility requirements?
5. Google Play Store listing requirements?
