# LaborForecast — Claude Code Briefing

## What is LaborForecast

LaborForecast is a native iOS app that shows AI exposure risk (0–10 scale) for every US occupation tracked by the Bureau of Labor Statistics. Users can explore all 342 careers, check their own job's risk score, save favorites, and find safer career alternatives. The app is data-only — no backend, no network calls at runtime, no authentication.

---

## Tech Stack

| Layer | Choice |
|---|---|
| UI | SwiftUI |
| Architecture | MVVM — `@Observable` ViewModels, `@AppStorage` for persistence |
| Data | Local JSON bundle — `labor_forecast_data.json` loaded once at app start |
| Persistence | `@AppStorage` (UserDefaults) — saved career slugs + selected job slug |
| Minimum iOS | iOS 17 |
| No backend | No Firebase, no network requests, no authentication |
| Dependencies | None — zero third-party packages |

---

## Project Folder Structure

```
LaborForecast/
├── App/
│   ├── OccForecastApp.swift
│   └── ContentView.swift
├── Models/
│   ├── Occupation.swift
│   └── OccupationService.swift
├── ViewModels/
│   ├── ExploreViewModel.swift
│   ├── MyRiskViewModel.swift
│   └── FavoritesViewModel.swift
├── Views/
│   ├── Launch/
│   │   └── LaunchView.swift
│   ├── Explore/
│   │   ├── ExploreView.swift
│   │   ├── OccupationCard.swift
│   │   └── CategoriesView.swift
│   ├── Detail/
│   │   ├── CareerDetailView.swift
│   │   └── RiskGauge.swift
│   ├── Risk/
│   │   └── MyRiskView.swift
│   ├── Favorites/
│   │   └── FavoritesView.swift
│   └── Settings/
│       ├── SettingsView.swift
│       ├── AboutView.swift
│       └── DataSourcesView.swift
└── Resources/
    ├── labor_forecast_data.json
    └── Assets.xcassets
```

---

## Data Model

### JSON source
`Resources/labor_forecast_data.json` — array of 342 occupation objects, loaded once at app start by `OccupationService`.

### Occupation struct (exact field names from JSON)

```swift
struct Occupation: Codable, Identifiable {
    let slug: String           // unique ID — e.g. "accountants-and-auditors"
    let title: String          // "Accountants and auditors"
    let category: String       // "business-and-financial" (25 categories)
    let socCode: String        // "13-2011" — empty string if unavailable
    let exposure: Int          // AI score 0–10, never null
    let aiTier: String         // "minimal" | "low" | "moderate" | "high" | "veryHigh"
    let aiReason: String       // 2–3 sentence rationale
    let pay: Int?              // annual median wage — null for 2 occupations
    let jobs: Int?             // 2024 employment count — null for 1 occupation
    let outlook: Double?       // 10-yr projected growth % — can be negative
    let outlookDesc: String    // "Faster than average"
    let education: String      // "Bachelor's degree"
    let saferAlts: [String]    // array of slugs — up to 5, empty for ~48 low-risk jobs
    let url: String            // BLS OOH source URL

    var id: String { slug }
}
```

### OccupationService

```swift
@Observable
class OccupationService {
    var occupations: [Occupation] = []
    var isLoaded = false

    // Loads labor_forecast_data.json from Bundle synchronously at init
    // Builds a slug-indexed dictionary for O(1) lookups
    func occupation(for slug: String) -> Occupation?
    func saferAlternatives(for occupation: Occupation) -> [Occupation]
}
```

---

## Navigation Structure

```
LaunchView (full screen, ~2 seconds)
    ↓
TabView (persistent)
    ├── Tab 1: ExploreView         (SF Symbol: square.grid.2x2)
    │   ├── CategoriesView         (sheet)
    │   ├── SettingsView           (sheet, via gear icon top-right toolbar)
    │   │   ├── AboutView          (pushed)
    │   │   └── DataSourcesView    (pushed)
    │   └── CareerDetailView       (pushed)
    │
    ├── Tab 2: MyRiskView          (SF Symbol: gauge.medium)
    │   └── CareerDetailView       (pushed)
    │
    └── Tab 3: FavoritesView       (SF Symbol: heart)
        └── CareerDetailView       (pushed)
```

**CareerDetailView is shared** — it takes an `Occupation` and can be pushed from Explore, MyRisk, or Favorites. It is not a tab root.

---

## Views — Detailed Spec

### 1. LaunchView
- Full screen dark background (`#090B10`)
- 7 vertical bars animate in sequentially left to right with staggered `.delay()`, colors green → red matching risk tiers
- "LABOR" bold text fades in below bars, "FORECAST" light text below that
- Loading indicator at bottom
- Transitions to TabView after `OccupationService` finishes loading (minimum 1.5s for animation)
- No skip button

### 2. ExploreView
**ViewModel:** `ExploreViewModel`

**State:**
- `searchText: String` — debounced 0.3s
- `activeFilter: ExploreFilter` — enum: `.all`, `.lowRisk`, `.highRisk`, `.highPay`, `.noDegree`
- `activeCategory: String?` — nil means all categories

**Layout:**
- Navigation title: "Explore" (large)
- Subtitle: "343 occupations · 143M jobs" (below title, small muted)
- Gear icon (⚙) in top-right toolbar → presents SettingsView as sheet
- Search bar below nav
- Filter chips row: All / Low risk / High risk / $75k+ / No degree
- When search is empty AND no filter active: show two sections
  - "Most at risk" — top 5 occupations by `exposure` descending
  - "Most AI-proof" — top 5 occupations by `exposure` ascending
- When search or filter active: show flat filtered list
- Each row: `OccupationCard`
- Tapping card → pushes `CareerDetailView`

**Filter logic:**
- Low risk: `exposure <= 3`
- High risk: `exposure >= 7`
- $75k+: `pay >= 75000`
- No degree: `education` contains "no degree" or "high school" or "certificate"

### 3. OccupationCard
Reusable card used in ExploreView, FavoritesView, MyRiskView safer alts.

**Contents:**
- Title (bold)
- Category + job count (muted subtitle)
- Risk tier badge (colored pill — see Design System)
- Salary, growth rate, education (3-column stats row)
- Risk bar (thin, full width, color matches tier, fill = exposure/10)

### 4. CategoriesView
Presented as `.sheet` from ExploreView.

- Title: "Browse by category"
- `LazyVGrid` 2 columns
- Each tile: category display name, career count, avg exposure score, mini risk bar
- Tapping a tile: dismisses sheet, sets `activeCategory` filter on ExploreViewModel
- 25 BLS categories — display names should be human-readable (convert slug: "business-and-financial" → "Business & Financial")

### 5. CareerDetailView
**Shared view** — takes `occupation: Occupation` as input. No ViewModel needed.

**Layout (top to bottom):**
- Back button (‹ source view name) + bookmark heart icon in toolbar
- Title (occupation name, large bold)
- Category subtitle (muted)
- Score card:
  - `RiskGauge` arc on left — animates from 0 to score on `.onAppear`
  - Score number (large, color = tier color)
  - "X / 10" below
  - Tier label: "Very high exposure"
  - Percentile: "Top X% of all occupations" (calculate from full dataset)
  - Gradient risk bar (green → red, marker at score position)
- 2×2 stats grid: Median salary / US employment / 10-yr outlook / Education
- "Why high exposure" card — `aiReason` text
- "Safer transitions" section header
  - Horizontal `ScrollView` of alt cards (slug → Occupation lookup)
  - Each alt card: tier badge, title, salary, tapping pushes new CareerDetailView
  - If `saferAlts` is empty: show "This career is already among the most AI-resistant"
- Bookmark heart icon in toolbar toggles `FavoritesViewModel.toggle(slug)`
  - Filled heart = saved, outline = not saved

### 6. RiskGauge
Custom SwiftUI `Shape` component.

- Semicircular arc (180°), bottom-centered
- Track arc: muted background color
- Fill arc: animates from 0 to `score/10` of the semicircle on appear
- Color = tier color for the given score
- Score number rendered as `Text` centered below arc
- Accepts: `score: Int`, `animated: Bool`

### 7. MyRiskView
**ViewModel:** `MyRiskViewModel` (wraps `@AppStorage("selectedSlug")`)

**Two states:**

**Empty state** (no job selected):
- Nav title: "My Risk"
- Subtitle: "What's your occupation?"
- Search bar: "Search your job title…"
- Below search: category grid (same as CategoriesView but inline, not sheet)
- Selecting any occupation → saves slug to `@AppStorage`, shows score state

**Score state** (job selected):
- Nav title: "My Risk"
- "Change" button top-right
- Selected job pill: occupation title + tier badge
- Large score card with `RiskGauge`, tier label, percentile
- `aiReason` text
- "Safer transitions" horizontal scroll (same as CareerDetailView)
- Tapping a safer alt → pushes `CareerDetailView`
- Tapping "Change" → clears selection, returns to empty state

**Persistence:** Selected slug persists across app launches via `@AppStorage`.

### 8. FavoritesView
**ViewModel:** `FavoritesViewModel` (wraps `@AppStorage("savedSlugs")`)

**Two states:**

**Empty state:**
- Heart icon (large, muted)
- "No saved careers"
- Subtitle: "Tap the bookmark icon on any career to save it here."
- "Browse careers" CTA button → switches to Explore tab

**Populated state:**
- Nav title: "Saved"
- Subtitle: "X careers saved"
- `List` of saved occupations (resolved from slugs via `OccupationService`)
- Each row: title, category + salary, tier badge, chevron
- Swipe to delete → removes slug from `@AppStorage` array
- Tapping row → pushes `CareerDetailView`

### 9. SettingsView
Presented as `.sheet` from ExploreView gear icon.

- Sheet handle at top
- Title: "Settings"
- Grouped list style:
  - **About section:**
    - "Methodology" row → pushes `AboutView`
    - "Data sources" row → pushes `DataSourcesView`
  - **App section:**
    - "Share LaborForecast" row → `ShareLink` with app URL
- Version number + data vintage at bottom (muted): "LaborForecast v1.0.0 · Data: BLS OOH 2024–2034"

### 10. AboutView
Pushed from Settings.

- Explains the 0–10 scoring rubric (the 6 anchor points: 0–1 minimal through 10 maximum)
- Explains what AI exposure means
- Data vintage: BLS Occupational Outlook Handbook 2024–2034 projections

### 11. DataSourcesView
Pushed from Settings.

- Bureau of Labor Statistics — Occupational Outlook Handbook
- AI scoring methodology — Gemini Flash via structured rubric
- Link to bls.gov/ooh

---

## ViewModels

### ExploreViewModel
```swift
@Observable
class ExploreViewModel {
    var searchText = ""
    var activeFilter: ExploreFilter = .all
    var activeCategory: String? = nil

    // Computed — filtered + sorted list of occupations
    var filteredOccupations: [Occupation]

    // Default sections (shown when search empty + no filter)
    var mostAtRisk: [Occupation]      // top 5 by exposure desc
    var mostAIProof: [Occupation]     // top 5 by exposure asc

    var isSearching: Bool             // true when text or filter active
}

enum ExploreFilter {
    case all, lowRisk, highRisk, highPay, noDegree
}
```

### MyRiskViewModel
```swift
@Observable
class MyRiskViewModel {
    @AppStorage("selectedSlug") var selectedSlug: String = ""

    var selectedOccupation: Occupation?  // resolved from slug
    var hasSelection: Bool { !selectedSlug.isEmpty }

    func select(_ occupation: Occupation)
    func clear()
}
```

### FavoritesViewModel
```swift
@Observable
class FavoritesViewModel {
    @AppStorage("savedSlugs") var savedSlugsData: String = ""
    // Store as comma-separated string in AppStorage, expose as [String]

    var savedSlugs: [String]
    var savedOccupations: [Occupation]  // resolved from slugs

    func toggle(_ slug: String)
    func isSaved(_ slug: String) -> Bool
    func remove(_ slug: String)
}
```

**Important:** `FavoritesViewModel` should be instantiated once at app level and passed via `@Environment` so the bookmark state stays in sync across all views (ExploreView cards, CareerDetailView toolbar button, FavoritesView list).

---

## Design System

### Colors

```swift
extension Color {
    // Backgrounds
    static let LFDarkBG    = Color(hex: "#090B10")  // dark mode screens
    static let LFLightBG   = Color(hex: "#F5F2EC")  // light mode screens (warm off-white)

    // Brand
    static let LFGreen     = Color(hex: "#22C55E")  // active tab, CTAs, low risk

    // Risk tier colors
    static let riskMinimal  = Color(hex: "#22C55E")  // 0–1
    static let riskLow      = Color(hex: "#5BD87C")  // 2–3
    static let riskModerate = Color(hex: "#EAB308")  // 4–5
    static let riskHigh     = Color(hex: "#F97316")  // 6–7
    static let riskVeryHigh = Color(hex: "#DC2626")  // 8–10
}

func riskColor(for score: Int) -> Color {
    switch score {
    case 0...1: return .riskMinimal
    case 2...3: return .riskLow
    case 4...5: return .riskModerate
    case 6...7: return .riskHigh
    default:    return .riskVeryHigh
    }
}

func tierColor(for tier: String) -> Color {
    switch tier {
    case "minimal":  return .riskMinimal
    case "low":      return .riskLow
    case "moderate": return .riskModerate
    case "high":     return .riskHigh
    default:         return .riskVeryHigh
    }
}
```

### Risk tier badge labels
```swift
func tierLabel(for tier: String) -> String {
    switch tier {
    case "minimal":  return "Minimal"
    case "low":      return "Low"
    case "moderate": return "Moderate"
    case "high":     return "High"
    default:         return "Very High"
    }
}
```

### Typography
- Nav titles: `.largeTitle` bold
- Section headers: `.caption` uppercase, tracking wide, muted opacity
- Card titles: `.subheadline` semibold
- Body: `.body` regular
- Muted text: `.secondary` color or `opacity(0.45)`
- No custom fonts — SF Pro system default throughout

### Spacing & Shape
- Card corner radius: 14
- Sheet corner radius: 24 (top corners only)
- Card background dark: `Color.white.opacity(0.05)`
- Card background light: `Color.white` with subtle shadow
- Card border: `Color.white.opacity(0.09)` on dark, `Color.black.opacity(0.07)` on light
- Tab bar active tint: `#22C55E`
- All screens support dark and light mode — use semantic colors and `.colorScheme` environment

---

## Key Behaviors

### Favorites sync
`FavoritesViewModel` is the single source of truth for saved slugs. It must be:
- Created once in `LaborForecastApp`
- Injected via `.environment(favoritesViewModel)`
- Accessed in `CareerDetailView` and `FavoritesView` via `@Environment`

The bookmark heart in `CareerDetailView` toolbar calls `favoritesViewModel.toggle(occupation.slug)`. The filled/outline state is `favoritesViewModel.isSaved(occupation.slug)`.

### SaferAlts navigation
Tapping an alt card in `CareerDetailView` pushes a **new** `CareerDetailView` with the alt occupation. This creates a navigation stack — user can go back through the chain. Use `NavigationStack` with a path, not nested `NavigationLink` without state.

### Search debounce
`ExploreViewModel.searchText` should debounce updates to `filteredOccupations` by 0.3 seconds to avoid recomputing on every keystroke.

### LaunchView transition
`OccupationService` loads synchronously (JSON from bundle is fast). The launch animation takes ~1.5s. Use a `Task` with `try await Task.sleep(for: .seconds(1.5))` to ensure the animation completes before transitioning, regardless of load time.

### AppStorage for savedSlugs
`[String]` cannot be stored directly in `@AppStorage`. Store as a comma-separated `String` and encode/decode on access. Example:
```swift
@AppStorage("savedSlugs") private var savedSlugsRaw: String = ""
var savedSlugs: [String] {
    get { savedSlugsRaw.isEmpty ? [] : savedSlugsRaw.components(separatedBy: ",") }
    set { savedSlugsRaw = newValue.joined(separator: ",") }
}
```

---

## Known Edge Cases

| Case | Handling |
|---|---|
| `pay` is null (2 occupations: Military, Fishing) | Show " " — never force-unwrap |
| `jobs` is null (1 occupation: Military) | Show " " | OCCUPATION REMOVED FROM JSON
| `saferAlts` is empty (~48 low-risk occupations) | Show message: "This career is already among the most AI-resistant" — no empty scroll view |
| `socCode` is empty string (52 occupations) | Don't display SOC code field if empty |
| Slug not found in OccupationService | Should never happen — all saferAlts slugs are validated at build time — but handle gracefully if it does |
| Very long occupation titles | Use `.lineLimit(2)` on cards, full title on detail view |

---

## App Entry Point

```swift
@main
struct OccForecastApp: App {
    @State private var occupationService = OccupationService()
    @State private var favoritesViewModel = FavoritesViewModel()
    @State private var myRiskViewModel = MyRiskViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(occupationService)
                .environment(favoritesViewModel)
                .environment(myRiskViewModel)
        }
    }
}
```

## ContentView

```swift
struct ContentView: View {
    @Environment(OccupationService.self) var occupationService
    @State private var showLaunch = true

    var body: some View {
        if showLaunch {
            LaunchView {
                showLaunch = false
            }
        } else {
            MainTabView()
        }
    }
}
```

---

## Monetization

**v1: Free, no ads, no paywall.**

v1.1 will introduce an optional Pro tier via StoreKit 2. Pro features (not needed for v1):
- All 5 safer alternatives (free shows first 3)
- Full AI rationale text
- Compare two careers side by side
- Export / share risk report

Do not build any StoreKit infrastructure in v1.

---

## Reference Files

The following files are available in the project root for reference:

- `Labor_forecast_data.json` — the complete data file (drop into Resources/)
- `Labor_Forecast_Build_Plan.docx` — full build plan with phase breakdown
- `Screenshots/` — reference screenshots for all 10 views (dark mode)
- `Labor_Forecast_Icon_Dark.png` — dark mode app icon
- `Labor_Forecast_Icon_Light.png` — light mode app icon

---

*OccForecast · Data: BLS OOH 2024–2034 · AI Scoring: Gemini Flash*
