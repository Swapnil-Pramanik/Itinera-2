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

### 1. Backend Setup
1. Open the terminal and navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Set up your Python virtual environment and install dependencies:
   ```bash
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```
3. Provide your API Keys in `backend/.env`:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `GEMINI_API_KEY`
   - `UNSPLASH_ACCESS_KEY` & `UNSPLASH_SECRET_KEY`
4. Run the API Server:
   ```bash
   python main.py
   ```
*(Note: Ensure your local Ollama Desktop application is running in the background for the Destination Chat feature to operate).*

### 2. Frontend Setup
1. Ensure your Flutter SDK is installed and configured.
2. From the root directory:
   ```bash
   flutter pub get
   ```
3. Run the application on an emulator or real device:
   ```bash
   flutter run
   ```

---
*Built intricately with modern architecture standards, defining the next generation of mobile travel experiences.*
