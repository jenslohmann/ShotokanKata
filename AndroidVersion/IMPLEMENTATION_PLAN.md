# Android App Implementation Plan

Based on `.github/copilot-instructions.md` - aligning Android app with iOS design specifications.

---

## 1. Kata Move Card Layout (High Priority)

### 1.1 Show technique from first sub-move in header
- [ ] Display `firstSubMove.technique` instead of `move.japaneseName` as the main header
- [ ] Fall back to `move.japaneseName` if no sub-moves exist

### 1.2 Add hiragana display
- [ ] Show hiragana below technique name (from `firstSubMove.hiragana`)
- [ ] Show stance with hiragana: "Zenkutsu-dachi, ぜんくつだち"

### 1.3 Expandable descriptions
- [ ] Add expandable/collapsible description section with chevron toggle (▼/▲)
- [ ] Default state: collapsed
- [ ] Smooth animation on expand/collapse (0.1s ease-in-out)

### 1.4 Direction display with arrow
- [ ] Show direction as text + arrow icon (N → ↑, NE → ↗, E → →, etc.)
- [ ] Map all 16 compass directions to appropriate arrows

### 1.5 Multiple sub-moves support
- [ ] When `move.subMoves.count > 1`, display additional sub-moves below header
- [ ] Use proper indentation for nested sub-moves
- [ ] Each sub-move should have its own expandable description

### 1.6 KIAI indicator styling
- [ ] Style KIAI as a red badge/chip
- [ ] Check both move-level and sub-move-level kiai

---

## 2. Kata List Row View (Medium Priority)

### 2.1 Info chips row
- [ ] Add "Moves" chip with count
- [ ] Add "Techniques" chip with key techniques count (hide on phones)
- [ ] Add "Level" chip showing difficulty (Basic/Intermediate/Advanced/Master)

### 2.2 Kata number formatting
- [ ] Display kata number as "#N" format in blue circle

### 2.3 Device-adaptive layout
- [ ] Detect screen size (phone vs tablet)
- [ ] Hide techniques chip on phones
- [ ] Adjust spacing/padding for different screen sizes

---

## 3. Kata Header/Overview (Medium Priority)

### 3.1 Kiai info text
- [ ] Change from showing move numbers to descriptive text
- [ ] Format: "Kiai on moves X and Y" or "Kiai on move X"

### 3.2 Header layout refinement
- [ ] Ensure layout matches: English name, Japanese name, hiragana
- [ ] Rank badge with proper belt color styling

---

## 4. Interactive Vocabulary Lookup (Lower Priority)

### 4.1 Clickable Japanese terms
- [ ] Scan technique descriptions for vocabulary matches
- [ ] Highlight matched terms in blue/bold
- [ ] On tap, navigate to vocabulary detail or show sheet

### 4.2 Term matching
- [ ] Implement whole-word matching algorithm
- [ ] Use longest-term-first matching to handle overlapping terms

---

## 5. Quiz System Fixes (Quick Fix)

### 5.1 Exclude ceremonial moves
- [ ] Filter out moves with `sequence < 1` (Rei, Yōi) from quiz questions
- [ ] Update `generateKiaiSelectionQuestions` to exclude ceremonial moves

---

## 6. Device Adaptation (Lower Priority)

### 6.1 Tablet layout enhancements
- [ ] Show full info chips on tablets
- [ ] Consider NavigationSplitView equivalent for tablets

### 6.2 Phone layout optimizations
- [ ] Compact info display
- [ ] Ensure touch targets are at least 48dp

---

## Reference

See `.github/copilot-instructions.md` for:
- Visual layout diagrams (ASCII art)
- SwiftUI code examples (adapt to Compose)
- Dark mode requirements
- Accessibility requirements
