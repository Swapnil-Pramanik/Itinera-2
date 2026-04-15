# Itinera (Version 1.0)
The Intelligent AI Travel Ecosystem

Itinera is a premium, beautifully crafted mobile application that transforms chaotic travel research into an orchestrated, singular timeline. Moving far beyond a static UI prototype, the Version 1 build represents a complete, full-stack application leveraging the power of cloud AI (Google Gemini) for heavy logistics, and Edge-AI (Local Ollama) for ultra-fast, local interactions, all bound by a cinematic Flutter frontend and an asynchronous Python backend.

---

## 🌟 V1 Key Highlights

- **Cinematic Auth & Onboarding:** Multi-step fluid onboarding utilizing responsive design, custom `RobotoMono` typography, and Supabase Authentication.
- **The Home Dashboard:** Your customized travel hub featuring dynamic "Atlas" discovery cards, your upcoming intelligently planned trips, and persistent real-time notifications.
- **AI-Powered Timeline Engine:** One-tap trip generation. Itinera maps out day-by-day activities across your destination. It features **dynamic re-balancing**—if you delete or skip an activity, the AI intelligently bridges the gap so your itinerary stays optimized.
- **Local Edge-AI Destination Chat:** A frictionless, floating streaming chat interface embedded natively in the destination page. Powered by a local Ollama model (`gemma4:e4b`), users experience ChatGPT-like real-time streaming tokens with zero cloud latency and total privacy.
- **Financial Intelligence:** Intelligent budget estimation predicting flights, food, transport, and attractions, supporting dual currencies (Local Destination Currency vs. INR).
- **Context-Aware Pre-Trip Checklists:** Itinera analyzes your itinerary activities, local geography, and fetched weather data to automatically craft and organize a personalized packing checklist.
- **Real-time Notifications Architecture:** A dynamic backend pipeline that instantly notifies users when their AI itinerary generations or checklist setups are complete in the background.

---

## 🛠 Technology Stack

### Frontend (Mobile App)
- **Framework:** Flutter (Dart) — SDK >= 3.0.0
- **Design System:** Custom "Cinematic Glassmorphism" aesthetics built on top of Material 3.
- **State Management & Networking:** Native Flutter asynchronous streams, `http` client handling Server-Sent Events (SSE) for AI typing effects.

### Backend (API Server)
- **Framework:** Python + FastAPI + Uvicorn (Fully Asynchronous backend).
- **State & Concurrency:** Stateless HTTP clients ensuring thread-safe Supabase verification preventing "deque mutated" event-loop crashes.

### Database & Authentication
- **Provider:** Supabase (PostgreSQL database, GoTrue Authentication, Row-Level Security).
- **Architecture:** Persistent trip state syncing and notification table pipelines.

### AI Tooling & External APIs
- **Google Gemini Engine:** Powers the complex logical reasoning for Itinerary Structuring, Transport optimization (arrival/flight skip logic), and dynamic Budgets via strict JSON formatting.
- **Local Ollama Integration:** Edge-computing framework operating `gemma4:e4b` locally for offline, private chat features.
- **Live Travel APIs:** 
  - *Open-Meteo* (Weather forecasting integration)
  - *Nominatim* (Geocoding & coordinate tracking)
  - *Unsplash API* (Dynamic heroic imagery fetching)
  - *Wikipedia API* (Initial Atlas data dumps)

---

## 🗺 System Architecture Flow

```mermaid
graph TD
    %% Services and Devices
    App[Itinera Flutter App]
    FastAPI[FastAPI Python Backend]
    SupabaseDB[(Supabase PostgreSQL)]
    SupabaseAuth[Supabase Auth]
    
    %% AI Models
    Gemini[(Google Gemini AI)]
    Ollama[(Local Ollama Desktop)]

    %% External
    Weather[Open-Meteo / APIs]

    %% App to Auth
    App -- JWT Validation / Login --> SupabaseAuth
    App -- API Requests + HTTP Streaming --> FastAPI

    %% Backend Flows
    FastAPI -- Reads/Writes Itineraries & Data --> SupabaseDB
    FastAPI -- Fetches Image / Weather --> Weather
    
    %% AI Workflows
    FastAPI -- Generates Itineraries & Budgets --> Gemini
    FastAPI -- Proxies Streaming Chat --> Ollama
```

## 📱 Navigation & App Flow

```mermaid
graph TD
    Entry(main.dart) --> Auth[Login / Signup]

    %% Authentication Flow
    Auth -- Login --> Home[Home Dashboard]
    Auth -- Signup --> Onb1[Onboarding Screens]
    Onb1 --> Home

    %% Home Screen Interactions
    Home -- FAB Search --> Search[Global Search Sheet]
    Home -- Notification Icon --> Notifications[In-App Notifications Panel]

    %% Trip Management
    Home -- Planned Trip Card --> TripSched[Trip Dashboard]
    TripSched -- Generates / Edits --> TripCheck[AI Pre-Trip Checklist]

    %% New Trip Planning (The Atlas)
    Home -- Atlas Card --> DestDetail[Destination Details]
    DestDetail -- "Want to know more?" --> ChatSheet[Local AI Chat Stream]
    DestDetail -- Plan this trip --> TimeSel[Timeline Configurator]
    TimeSel -- Generate --> TimeLoad[AI Processing Screen]
    
    %% Timeline Editing
    TimeLoad --> TimeInit[Initial Timeline Preview]
    TimeInit -- Edit Activity --> TimeEdit[Timeline Live Re-Balancing]
    TimeInit -- Complete --> TimeFinal[Final Confirmation]

    %% Budget Estimation
    TimeFinal -- AI Budget Request --> Budget[Smart Budget Breakdown]
    Budget -- Done --> Home
```

---

## 🗄 Database Schema (ERD)

The PostgreSQL schema integrates AI outputs intrinsically into standard relational constraints.

```mermaid
erDiagram
    users ||--o{ trips : creates
    users ||--o{ notifications : receives
    users ||--o{ search_history : searches
    
    destinations ||--o{ attractions : contains
    destinations ||--o{ atlas_articles : featured_in
    destinations ||--o{ trips : visited_in
    
    trips ||--o{ timeline_days : has
    trips ||--|| budgets : has
    trips ||--o{ checklist_items : requires
    
    timeline_days ||--o{ activities : includes
    timeline_days ||--o{ budget_days : has_budget
    
    budgets ||--o{ budget_days : breakdown
    budgets ||--o{ budget_tips : suggests
    
    budget_days ||--o{ expense_items : contains
```

---

## 🚀 Getting Started

### 1. Prerequisites
Before setting up Itinera, ensure you have the following installed:
- **Flutter SDK** (>= 3.0.0)
- **Python** (3.9+)
- **Ollama** (For local edge-AI)
- **Supabase Account** (For database and auth)

---

### 2. Database Initialization (Supabase)
Itinera uses Supabase as its primary data store. Follow these steps to set up your database:

1. Create a new project in the **Supabase Dashboard**.
2. Open the **SQL Editor** in the side navigation.
3. Execute the following SQL scripts (found in the `db/` directory) in this order:
   - `db/itinera_schema.sql`: Core relational structure.
   - `db/sync_auth_users.sql`: Triggers to sync Supabase Auth users with our native profiles.
   - `db/rating_schema.sql`: Interactive destination rating feature logic.

---

### 3. AI Setup
Itinera leverages a hybrid AI model architecture.

#### Cloud AI (Gemini)
1. Go to **Google AI Studio** and generate a free API key for **Gemini 1.5 Flash**.
2. Add this to your `backend/.env` file.

#### Edge AI (Local Ollama)
1. Download [Ollama](https://ollama.com).
2. From your terminal, pull the required model:
   ```bash
   ollama pull gemma:2b
   ```
3. Keep the Ollama application running in the background while using the app.

---

### 4. Backend Configuration
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Set up a virtual environment and install dependencies:
   ```bash
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```
3. Create/Edit `backend/.env` with your credentials:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_anon_key
   GEMINI_API_KEY=your_gemini_key
   UNSPLASH_ACCESS_KEY=your_unsplash_key
   ```
4. Start the server:
   ```bash
   python main.py
   ```
   *Note: The server is configured to bind to `0.0.0.0`, allowing connections from physical devices on your network.*

---

### 5. Wireless Hosting & Mobile App
To run Itinera on a **physical phone** while hosting the backend on your computer:

1. **Find your local IP**: Run `ipconfig getifaddr en0` on your Mac.
2. **Update Pointer**: In `lib/core/constants.dart`, update the `backendUrl` to your Mac's IP (e.g., `http://192.168.1.5:8000`).
3. **Build APK**:
   ```bash
   flutter build apk --debug
   ```
4. **Share wirelessly**: Run `python3 -m http.server 8080` in the build output directory and visit that address on your phone's browser to download.

---

*Built with ❤️ for the next generation of travelers.*
