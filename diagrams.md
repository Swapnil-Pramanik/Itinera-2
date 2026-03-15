# Itinera — Project Diagrams

> A comprehensive visual documentation of the Itinera travel-planning application covering system architecture, user interactions, data flow, and component design.

---

## Table of Contents

1. [High-Level Architecture Diagram](#1-high-level-architecture-diagram)
2. [Solution Diagram](#2-solution-diagram)
3. [Use-Case Diagram](#3-use-case-diagram)
4. [Component Diagram — Flutter Layer](#4-component-diagram--flutter-layer)
5. [Navigation & Activity Diagram](#5-navigation--activity-diagram)
6. [Trip Planning Activity Diagram](#6-trip-planning-activity-diagram)
7. [Entity-Relationship Diagram](#7-entity-relationship-diagram)
8. [Widget Architecture Diagram](#8-widget-architecture-diagram)
9. [Deployment Diagram](#9-deployment-diagram)

---

## 1. High-Level Architecture Diagram

Shows the overall system architecture with the three major tiers: Presentation (Flutter), Application Logic, and Data Persistence.

```mermaid
graph TB
    subgraph Client["📱 Presentation Layer — Flutter App"]
        direction TB
        UI["UI Screens<br/>(28 Dart widgets)"]
        Widgets["Reusable Widget Library<br/>(AppBars · Buttons · Cards · Common)"]
        Theme["Material 3 Theme Engine<br/>(AppTheme · RobotoMono · Color System)"]
        Nav["Navigator<br/>(MaterialPageRoute · BlurPageRoute)"]
    end

    subgraph Logic["⚙️ Application Logic Layer"]
        direction TB
        Auth["Authentication Module<br/>(Email · Google · Apple OAuth)"]
        Onboard["Onboarding Engine<br/>(Preferences Collector)"]
        TripMgr["Trip Manager<br/>(CRUD · Status Transitions)"]
        TimelineGen["Timeline Generator<br/>(AI-Powered Itinerary)"]
        BudgetEst["Budget Estimator<br/>(Cost Breakdown · Tips)"]
        Search["Discovery & Search<br/>(Atlas · Suggestions)"]
    end

    subgraph Data["🗄️ Data & Persistence Layer"]
        direction TB
        PG["PostgreSQL 15+<br/>(17 Tables · 6 ENUM Types)"]
        Extensions["Extensions<br/>(uuid-ossp · pgcrypto)"]
        Indexes["Performance Indexes<br/>(15+ Indexed Columns)"]
        Triggers["Auto-Update Triggers<br/>(updated_at columns)"]
        Seed["Seed Data<br/>(Destinations · Attractions · Templates)"]
    end

    UI --> Widgets
    UI --> Theme
    UI --> Nav
    Nav --> Auth
    Nav --> Onboard
    Nav --> TripMgr
    Nav --> TimelineGen
    Nav --> BudgetEst
    Nav --> Search
    Auth --> PG
    TripMgr --> PG
    TimelineGen --> PG
    BudgetEst --> PG
    Search --> PG
    Onboard --> PG
    PG --> Extensions
    PG --> Indexes
    PG --> Triggers
    PG --> Seed

    style Client fill:#E3F2FD,stroke:#1565C0,stroke-width:2px
    style Logic fill:#FFF3E0,stroke:#E65100,stroke-width:2px
    style Data fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px
```

---

## 2. Solution Diagram

End-to-end flow showing how a user request travels through the system to produce a complete trip plan.

```mermaid
graph LR
    subgraph Input["🧑 User Input"]
        U1["Select Destination"]
        U2["Choose Dates"]
        U3["Set Preferences<br/>(Budget · Interests · Pace)"]
    end

    subgraph Processing["⚙️ Processing Pipeline"]
        P1["Validate Input"]
        P2["Generate Timeline<br/>(AI Engine)"]
        P3["Estimate Budget<br/>(Per-Day Breakdown)"]
        P4["Generate Checklist<br/>(From Templates)"]
        P5["Produce Budget Tips<br/>(AI-Generated Savings)"]
    end

    subgraph Output["📋 Deliverables"]
        O1["Day-by-Day Itinerary"]
        O2["Activity Schedule<br/>(Time · Place · Transport)"]
        O3["Budget Report<br/>(Estimated vs Actual)"]
        O4["Pre-Trip Checklist"]
        O5["Smart Savings Tips"]
    end

    U1 --> P1
    U2 --> P1
    U3 --> P1
    P1 --> P2
    P2 --> P3
    P2 --> P4
    P3 --> P5
    P2 --> O1
    P2 --> O2
    P3 --> O3
    P4 --> O4
    P5 --> O5

    style Input fill:#F3E5F5,stroke:#7B1FA2,stroke-width:2px
    style Processing fill:#FFF8E1,stroke:#F57F17,stroke-width:2px
    style Output fill:#E0F7FA,stroke:#00695C,stroke-width:2px
```

---

## 3. Use-Case Diagram

All primary actors and their interactions with the system.

```mermaid
graph TB
    subgraph Actors
        Traveler["🧳 Traveler"]
        AI["🤖 AI Engine"]
        Admin["🛠️ System Admin"]
    end

    subgraph AuthUC["Authentication"]
        UC1["Sign Up with Email"]
        UC2["Log In"]
        UC3["OAuth Login<br/>(Google / Apple)"]
        UC4["Log Out"]
    end

    subgraph OnboardUC["Onboarding"]
        UC5["Set Travel Persona"]
        UC6["Select Interests<br/>(Culture · Food · Nature · ...)"]
        UC7["Choose Travel Pace"]
    end

    subgraph TripUC["Trip Management"]
        UC8["Browse Destinations<br/>(Atlas Discovery)"]
        UC9["Search Destinations"]
        UC10["View Destination Details"]
        UC11["Plan a New Trip"]
        UC12["View Scheduled Trip"]
        UC13["Track Current Trip"]
        UC14["Review Completed Trip"]
        UC15["Manage Checklist"]
    end

    subgraph TimelineUC["Timeline Planning"]
        UC16["Select Travel Dates"]
        UC17["Generate Itinerary"]
        UC18["Preview Timeline"]
        UC19["Edit Activities"]
        UC20["Finalize Timeline"]
    end

    subgraph BudgetUC["Budget Estimation"]
        UC21["View Budget Breakdown"]
        UC22["Get Savings Tips"]
    end

    subgraph ProfileUC["Profile"]
        UC23["View Profile & Stats"]
        UC24["Manage Linked Accounts"]
        UC25["Update Preferences"]
    end

    Traveler --> UC1 & UC2 & UC3 & UC4
    Traveler --> UC5 & UC6 & UC7
    Traveler --> UC8 & UC9 & UC10 & UC11 & UC12 & UC13 & UC14 & UC15
    Traveler --> UC16 & UC17 & UC18 & UC19 & UC20
    Traveler --> UC21 & UC22
    Traveler --> UC23 & UC24 & UC25

    AI --> UC17
    AI --> UC21 & UC22

    Admin --> UC8

    style Actors fill:#FFEBEE,stroke:#C62828,stroke-width:2px
    style AuthUC fill:#E8EAF6,stroke:#283593,stroke-width:1px
    style OnboardUC fill:#F3E5F5,stroke:#6A1B9A,stroke-width:1px
    style TripUC fill:#E0F2F1,stroke:#00695C,stroke-width:1px
    style TimelineUC fill:#FFF3E0,stroke:#E65100,stroke-width:1px
    style BudgetUC fill:#FFF9C4,stroke:#F57F17,stroke-width:1px
    style ProfileUC fill:#FCE4EC,stroke:#AD1457,stroke-width:1px
```

---

## 4. Component Diagram — Flutter Layer

Detailed breakdown of the Flutter `lib/` directory and inter-module dependencies.

```mermaid
graph TB
    Main["main.dart<br/>(Entry Point)"] --> ThemeMod
    Main --> AuthMod

    subgraph ThemeMod["theme/"]
        Theme["material3_theme.dart<br/>(AppTheme · ColorScheme · Typography)"]
    end

    subgraph WidgetLib["widgets/"]
        AppBars["appbars/<br/>HomeAppBar · DetailAppBar · TripAppBar"]
        Buttons["buttons/<br/>PrimaryButton · SecondaryButton · ChipButton<br/>SocialButton · PillToggle · PaperPlaneIcon"]
        Cards["cards/<br/>TripCard · AtlasCard · ActivityCard · DaySummaryCard"]
        Common["common/<br/>ProgressDots · SectionHeader · ChecklistItem<br/>AiInputBar · FeatureItem · StatusBadge · LoadingStatusItem"]
        BlurRoute["blur_page_route.dart<br/>(Custom Page Transition)"]
    end

    subgraph AuthMod["screens/auth/"]
        Login["login_signup_screen.dart"]
    end

    subgraph OnboardMod["screens/onboarding/"]
        Onb1["onboarding_1_screen.dart<br/>(Travel Persona)"]
        Onb2["onboarding_2_screen.dart<br/>(Interest Selection)"]
        Onb3["onboarding_3_screen.dart<br/>(Travel Pace)"]
        OnbComp["onboarding_completion_screen.dart"]
    end

    subgraph HomeMod["screens/home/"]
        Home["home_screen.dart<br/>(Dashboard)"]
        Profile["profile_screen.dart"]
        SearchSheet["search_bottom_sheet.dart"]
    end

    subgraph TripMod["screens/trip/"]
        DestDetail["destination_detail_screen.dart"]
        TripSched["trip_scheduled_screen.dart"]
        TripCurr["trip_current_screen.dart"]
        TripComp["trip_completed_screen.dart"]
        TripCheck["trip_checklist_screen.dart"]
    end

    subgraph TimelineMod["screens/timeline/"]
        TimeSel["timeline_selector_screen.dart"]
        TimeGenLoad["timeline_generation_loading_screen.dart"]
        TimeInitPrev["timeline_initial_preview_screen.dart"]
        TimeEditor["timeline_editor_screen.dart"]
        TimeUpdatePrev["timeline_update_preview_screen.dart"]
        TimeFinalPrev["timeline_final_preview_screen.dart"]
    end

    subgraph BudgetMod["screens/budget/"]
        BudgetLoad["budget_loading_screen.dart"]
        BudgetEst["budget_estimation_screen.dart"]
    end

    AuthMod -->|Signup| OnboardMod
    AuthMod -->|Login| HomeMod
    OnboardMod --> HomeMod
    HomeMod --> TripMod
    HomeMod --> SearchSheet
    TripMod --> TimelineMod
    TimelineMod --> BudgetMod
    BudgetMod --> HomeMod

    HomeMod -.->|uses| WidgetLib
    TripMod -.->|uses| WidgetLib
    TimelineMod -.->|uses| WidgetLib
    BudgetMod -.->|uses| WidgetLib
    AuthMod -.->|uses| WidgetLib
    OnboardMod -.->|uses| WidgetLib

    WidgetLib -.->|themed by| ThemeMod

    style ThemeMod fill:#FFF9C4,stroke:#F9A825,stroke-width:2px
    style WidgetLib fill:#E8EAF6,stroke:#3F51B5,stroke-width:2px
    style AuthMod fill:#FFCDD2,stroke:#C62828,stroke-width:1px
    style OnboardMod fill:#F3E5F5,stroke:#7B1FA2,stroke-width:1px
    style HomeMod fill:#C8E6C9,stroke:#2E7D32,stroke-width:1px
    style TripMod fill:#B3E5FC,stroke:#0277BD,stroke-width:1px
    style TimelineMod fill:#FFE0B2,stroke:#E65100,stroke-width:1px
    style BudgetMod fill:#DCEDC8,stroke:#558B2F,stroke-width:1px
```

---

## 5. Navigation & Activity Diagram

Complete screen-to-screen navigation flow showing every route in the application.

```mermaid
graph TD
    Entry["main.dart"] --> Auth["LoginSignupScreen"]

    %% Authentication Flow
    Auth -- "Login" --> Home["HomeScreen"]
    Auth -- "Signup" --> Onb1["Onboarding1Screen<br/>(Travel Persona)"]

    %% Onboarding Flow
    Onb1 --> Onb2["Onboarding2Screen<br/>(Select Interests)"]
    Onb2 --> Onb3["Onboarding3Screen<br/>(Travel Pace)"]
    Onb3 --> OnbComp["OnboardingCompletionScreen<br/>(Profile Setup Loading)"]
    OnbComp --> Home

    %% Home Screen Interactions
    Home -- "Profile Icon" --> Profile["ProfileScreen"]
    Profile -- "Logout" --> Auth
    Home -- "FAB" --> Search["SearchBottomSheet"]

    %% Trip Management
    Home -- "Planned Trip Card" --> TripSched["TripScheduledScreen"]
    Home -- "Current Trip Card" --> TripCurr["TripCurrentScreen"]
    Home -- "Completed Trip Card" --> TripComp["TripCompletedScreen"]
    TripSched -- "Checklist" --> TripCheck["TripChecklistScreen"]

    %% New Trip Planning (The Atlas)
    Home -- "Atlas Card" --> DestDetail["DestinationDetailScreen"]
    DestDetail -- "Plan this trip" --> TimeSel["TimelineSelectorScreen"]
    TimeSel -- "Generate" --> TimeLoad["TimelineGenerationLoadingScreen"]
    TimeLoad -- "(Delay)" --> TimeInit["TimelineInitialPreviewScreen"]

    %% Timeline Editing
    TimeInit -- "Edit" --> TimeEdit["TimelineEditorScreen"]
    TimeEdit -- "Preview Updates" --> TimeUpdate["TimelineUpdatePreviewScreen"]
    TimeUpdate -- "Accept" --> TimeInit
    TimeInit -- "Complete" --> TimeFinal["TimelineFinalPreviewScreen"]

    %% Budget Estimation
    TimeFinal -- "Confirm" --> BudgetLoad["BudgetLoadingScreen"]
    BudgetLoad -- "(Delay)" --> Budget["BudgetEstimationScreen"]
    Budget -- "Done" --> Home

    style Auth fill:#FFCDD2,stroke:#C62828
    style Onb1 fill:#F3E5F5,stroke:#7B1FA2
    style Onb2 fill:#F3E5F5,stroke:#7B1FA2
    style Onb3 fill:#F3E5F5,stroke:#7B1FA2
    style OnbComp fill:#F3E5F5,stroke:#7B1FA2
    style Home fill:#C8E6C9,stroke:#2E7D32
    style Profile fill:#C8E6C9,stroke:#2E7D32
    style Search fill:#C8E6C9,stroke:#2E7D32
    style TripSched fill:#B3E5FC,stroke:#0277BD
    style TripCurr fill:#B3E5FC,stroke:#0277BD
    style TripComp fill:#B3E5FC,stroke:#0277BD
    style TripCheck fill:#B3E5FC,stroke:#0277BD
    style DestDetail fill:#B3E5FC,stroke:#0277BD
    style TimeSel fill:#FFE0B2,stroke:#E65100
    style TimeLoad fill:#FFE0B2,stroke:#E65100
    style TimeInit fill:#FFE0B2,stroke:#E65100
    style TimeEdit fill:#FFE0B2,stroke:#E65100
    style TimeUpdate fill:#FFE0B2,stroke:#E65100
    style TimeFinal fill:#FFE0B2,stroke:#E65100
    style BudgetLoad fill:#DCEDC8,stroke:#558B2F
    style Budget fill:#DCEDC8,stroke:#558B2F
```

---

## 6. Trip Planning Activity Diagram

Detailed activity/state flow for the complete trip planning lifecycle — from discovery to completion.

```mermaid
stateDiagram-v2
    [*] --> Discovery

    state Discovery {
        [*] --> BrowseAtlas
        BrowseAtlas --> SearchDestination
        SearchDestination --> BrowseAtlas
        BrowseAtlas --> ViewDestinationDetail
        SearchDestination --> ViewDestinationDetail
    }

    Discovery --> DateSelection : Plan This Trip

    state DateSelection {
        [*] --> ChooseStartDate
        ChooseStartDate --> ChooseEndDate
        ChooseEndDate --> ReviewDates
    }

    DateSelection --> TimelineGeneration : Generate

    state TimelineGeneration {
        [*] --> AIProcessing
        AIProcessing --> LoadingAnimation
        LoadingAnimation --> TimelineReady
    }

    TimelineGeneration --> TimelineReview

    state TimelineReview {
        [*] --> PreviewItinerary
        PreviewItinerary --> EditActivities
        EditActivities --> PreviewUpdates
        PreviewUpdates --> PreviewItinerary : Accept Changes
        PreviewItinerary --> FinalizeTimeline
    }

    TimelineReview --> BudgetPhase : Confirm Timeline

    state BudgetPhase {
        [*] --> CalculatingBudget
        CalculatingBudget --> BudgetBreakdown
        BudgetBreakdown --> ViewDayExpenses
        ViewDayExpenses --> BudgetBreakdown
        BudgetBreakdown --> ViewSavingsTips
        ViewSavingsTips --> BudgetBreakdown
    }

    BudgetPhase --> TripCreated : Done

    state TripCreated {
        [*] --> PLANNED
        PLANNED --> SCHEDULED : Dates Confirmed
        SCHEDULED --> ACTIVE : Trip Starts
        ACTIVE --> COMPLETED : Trip Ends
        SCHEDULED --> CANCELLED : User Cancels
        PLANNED --> CANCELLED : User Cancels
    }

    TripCreated --> [*]
```

---

## 7. Entity-Relationship Diagram

Complete database schema with all 17 tables, relationships, and key ENUM types.

```mermaid
erDiagram
    users {
        UUID id PK
        VARCHAR email UK
        VARCHAR password_hash
        VARCHAR display_name
        TEXT avatar_url
        INTEGER explorer_level
        INTEGER total_trips_completed
        INTEGER total_places_visited
        TIMESTAMPTZ created_at
        TIMESTAMPTZ updated_at
    }

    user_preferences {
        UUID id PK
        UUID user_id FK
        VARCHAR preference_key
        VARCHAR preference_value
        TIMESTAMPTZ created_at
    }

    linked_accounts {
        UUID id PK
        UUID user_id FK
        auth_provider provider
        VARCHAR provider_user_id
        VARCHAR provider_email
        BOOLEAN is_connected
        TIMESTAMPTZ connected_at
    }

    destinations {
        UUID id PK
        VARCHAR name
        VARCHAR country
        TEXT description
        DECIMAL rating
        INTEGER review_count
        VARCHAR best_season
        INTEGER ideal_duration_min_days
        INTEGER ideal_duration_max_days
        DECIMAL estimated_daily_cost_usd
        DECIMAL latitude
        DECIMAL longitude
        VARCHAR timezone
        VARCHAR currency_code
        TEXT image_url
        TEXT_ARRAY tags
        JSONB metadata
    }

    attractions {
        UUID id PK
        UUID destination_id FK
        VARCHAR name
        VARCHAR location_area
        TEXT description
        VARCHAR category
        DECIMAL typical_duration_hours
        DECIMAL admission_fee_usd
        BOOLEAN is_popular
    }

    atlas_articles {
        UUID id PK
        UUID destination_id FK
        VARCHAR title
        TEXT description
        TEXT content
        VARCHAR read_duration
        VARCHAR category
        BOOLEAN is_featured
        TIMESTAMPTZ published_at
    }

    trips {
        UUID id PK
        UUID user_id FK
        UUID destination_id FK
        trip_status status
        VARCHAR title
        DATE start_date
        DATE end_date
        TEXT_ARRAY tags
        INTEGER places_visited
        INTEGER activities_done
        TEXT notes
    }

    timeline_days {
        UUID id PK
        UUID trip_id FK
        INTEGER day_number
        DATE date
        VARCHAR theme
        BOOLEAN is_day_off
        TEXT notes
    }

    activities {
        UUID id PK
        UUID timeline_day_id FK
        UUID attraction_id FK
        VARCHAR title
        TEXT description
        TIME start_time
        TIME end_time
        DECIMAL duration_hours
        activity_category category
        transport_mode transport_mode
        INTEGER transport_duration_min
        BOOLEAN is_completed
        BOOLEAN is_skipped
        INTEGER sort_order
        JSONB metadata
    }

    checklist_templates {
        UUID id PK
        checklist_category category
        VARCHAR label
        TEXT description
        BOOLEAN is_default
        INTEGER sort_order
    }

    checklist_items {
        UUID id PK
        UUID trip_id FK
        UUID template_id FK
        checklist_category category
        VARCHAR label
        BOOLEAN is_completed
        TIMESTAMPTZ completed_at
        INTEGER sort_order
    }

    budgets {
        UUID id PK
        UUID trip_id FK
        DECIMAL total_estimated_usd
        DECIMAL total_actual_usd
        VARCHAR currency
        BOOLEAN is_within_budget
        DECIMAL user_budget_limit_usd
    }

    budget_days {
        UUID id PK
        UUID budget_id FK
        UUID timeline_day_id FK
        INTEGER day_number
        VARCHAR subtitle
        DECIMAL estimated_total_usd
        DECIMAL actual_total_usd
    }

    expense_items {
        UUID id PK
        UUID budget_day_id FK
        UUID activity_id FK
        expense_category category
        VARCHAR label
        DECIMAL estimated_amount_usd
        DECIMAL actual_amount_usd
        BOOLEAN is_free
        BOOLEAN is_paid
    }

    budget_tips {
        UUID id PK
        UUID budget_id FK
        UUID destination_id FK
        INTEGER tip_number
        TEXT content
        DECIMAL potential_savings_usd
        BOOLEAN is_ai_generated
    }

    search_history {
        UUID id PK
        UUID user_id FK
        UUID destination_id FK
        VARCHAR query
        TIMESTAMPTZ searched_at
    }

    suggested_destinations {
        UUID id PK
        UUID user_id FK
        UUID destination_id FK
        VARCHAR reason
        DECIMAL score
        BOOLEAN is_active
    }

    users ||--o{ user_preferences : "has"
    users ||--o{ linked_accounts : "connects"
    users ||--o{ trips : "creates"
    users ||--o{ search_history : "searches"
    users ||--o{ suggested_destinations : "receives"

    destinations ||--o{ attractions : "contains"
    destinations ||--o{ atlas_articles : "featured in"
    destinations ||--o{ trips : "visited in"
    destinations ||--o{ suggested_destinations : "suggested as"
    destinations ||--o{ budget_tips : "tip for"
    destinations ||--o{ search_history : "searched"

    trips ||--o{ timeline_days : "has"
    trips ||--|| budgets : "has"
    trips ||--o{ checklist_items : "requires"

    timeline_days ||--o{ activities : "includes"
    timeline_days ||--o{ budget_days : "has budget"

    activities }o--o| attractions : "at"

    budgets ||--o{ budget_days : "breakdown"
    budgets ||--o{ budget_tips : "suggests"

    budget_days ||--o{ expense_items : "contains"

    expense_items }o--o| activities : "for"

    checklist_items }o--o| checklist_templates : "from"
```

---

## 8. Widget Architecture Diagram

Reusable widget library taxonomy and which screens consume each widget.

```mermaid
graph LR
    subgraph WidgetLibrary["🧩 Widget Library"]
        direction TB

        subgraph AB["AppBars"]
            HAB["HomeAppBar<br/>• Logo · Weather · Profile"]
            DAB["DetailAppBar<br/>• Back · Title · Actions"]
            TAB["TripAppBar<br/>• Location · Dates · Status"]
        end

        subgraph BT["Buttons"]
            PB["PrimaryButton<br/>• Arrow · Loading State"]
            SB["SecondaryButton<br/>• Outlined · Icon"]
            CB["ChipButton<br/>• Selectable · Themed"]
            SOB["SocialButton<br/>• Google · Apple"]
            PT["PillToggle<br/>• Login/Signup Tabs"]
            PPI["PaperPlaneIcon<br/>• Custom Canvas Art"]
        end

        subgraph CD["Cards"]
            TC["TripCard<br/>• Map Pattern · Tags"]
            AC["AtlasCard<br/>• Image · Duration · Plan"]
            AcC["ActivityCard<br/>• Time · Icon · Alert"]
            DSC["DaySummaryCard<br/>• Day Timeline · Quotes"]
        end

        subgraph CM["Common"]
            PD["ProgressDots<br/>• Animated · Onboarding"]
            SH["SectionHeader<br/>• Title · Action Link"]
            CL["ChecklistItem<br/>• Checkbox · Strikethrough"]
            AI["AiInputBar<br/>• Ask Itinera Prompt"]
            FI["FeatureItem<br/>• Icon · Title · Description"]
            STB["StatusBadge<br/>• Colored Chip"]
            LSI["LoadingStatusItem<br/>• Progress Indicator"]
        end
    end

    subgraph Consumers["📱 Screen Consumers"]
        AuthS["Auth Screens"]
        OnbS["Onboarding Screens"]
        HomeS["Home Screen"]
        TripS["Trip Screens"]
        TimeS["Timeline Screens"]
        BudgS["Budget Screens"]
    end

    AuthS --> PB & SB & SOB & PT
    OnbS --> PB & CB & PD & FI & LSI & PPI
    HomeS --> HAB & TC & AC & SH & AI
    TripS --> TAB & DAB & AcC & CL & STB & DSC
    TimeS --> DAB & AcC & PB & SB & CB
    BudgS --> DAB & PB

    style WidgetLibrary fill:#F5F5F5,stroke:#616161,stroke-width:2px
    style AB fill:#E3F2FD,stroke:#1565C0
    style BT fill:#FFF3E0,stroke:#E65100
    style CD fill:#E8F5E9,stroke:#2E7D32
    style CM fill:#F3E5F5,stroke:#7B1FA2
    style Consumers fill:#FFEBEE,stroke:#C62828,stroke-width:2px
```

---

## 9. Deployment Diagram

Target deployment architecture for production readiness.

```mermaid
graph TB
    subgraph UserDevices["👤 User Devices"]
        iOS["📱 iOS<br/>(iPhone / iPad)"]
        Android["📱 Android<br/>(Phone / Tablet)"]
        Web["🌐 Web Browser<br/>(Chrome / Safari)"]
        Desktop["🖥️ Desktop<br/>(macOS / Windows / Linux)"]
    end

    subgraph FlutterApp["📦 Flutter Application Bundle"]
        DartRuntime["Dart Runtime"]
        M3Theme["Material 3 Theme"]
        Screens["28 Screen Widgets"]
        WidgetLib2["Reusable Widget Library"]
        Assets["Assets<br/>(Images · Fonts · Lottie)"]
    end

    subgraph Backend["☁️ Backend Services"]
        API["REST / GraphQL API<br/>(Future Integration)"]
        AIService["AI Service<br/>(Timeline & Budget Generation)"]
        AuthService["Auth Provider<br/>(Google · Apple · Email)"]
    end

    subgraph Database["🗄️ Database Tier"]
        PGPrimary["PostgreSQL 15+ Primary<br/>(17 Tables · 6 ENUMs)"]
        PGReplica["PostgreSQL Read Replica<br/>(Indexed Queries)"]
    end

    subgraph Storage["📁 Object Storage"]
        Images["Destination Images"]
        Avatars["User Avatars"]
        ArticleMedia["Atlas Article Media"]
    end

    iOS & Android & Web & Desktop --> FlutterApp
    FlutterApp --> API
    API --> AIService
    API --> AuthService
    API --> PGPrimary
    PGPrimary --> PGReplica
    API --> Storage

    style UserDevices fill:#E3F2FD,stroke:#1565C0,stroke-width:2px
    style FlutterApp fill:#FFF3E0,stroke:#E65100,stroke-width:2px
    style Backend fill:#F3E5F5,stroke:#7B1FA2,stroke-width:2px
    style Database fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px
    style Storage fill:#FFF9C4,stroke:#F57F17,stroke-width:2px
```

---

## ENUM Types Reference

| ENUM Name | Values |
|-----------|--------|
| `auth_provider` | GOOGLE · APPLE · EMAIL |
| `trip_status` | PLANNED · SCHEDULED · ACTIVE · COMPLETED · CANCELLED |
| `transport_mode` | WALK · TRAIN · TAXI · BUS · SUBWAY · BIKE · CAR |
| `activity_category` | SIGHTSEEING · DINING · SHOPPING · CULTURE · NATURE · ENTERTAINMENT · RELAXATION · ADVENTURE · TRANSPORT · ACCOMMODATION |
| `expense_category` | FLIGHT · TRAIN · TRANSPORT · HOTEL · ACCOMMODATION · FOOD · DINING · ATTRACTION · SHOPPING · INSURANCE · OTHER |
| `checklist_category` | TRAVEL · STAY · ESSENTIALS · DOCUMENTS · HEALTH |

---

## Key Statistics

| Metric | Count |
|--------|-------|
| **Dart Source Files** | 28 |
| **Screen Modules** | 6 (Auth · Onboarding · Home · Trip · Timeline · Budget) |
| **Reusable Widgets** | 17 (across 4 categories) |
| **Database Tables** | 17 |
| **ENUM Types** | 6 |
| **Performance Indexes** | 15+ |
| **Seed Destinations** | 4 (Tokyo · Kyoto · Paris · Bali) |
| **Seed Attractions** | 9 (Tokyo) |
| **Checklist Templates** | 13 (across 5 categories) |

---

*Generated for the Itinera project — an intelligent Flutter travel-planning application.*
