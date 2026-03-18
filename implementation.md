# Backend Implementation Plan for Itinera

This document outlines the backend implementation strategy for the Itinera travel planning app. The focus is on local development, using **free and open-source models/APIs**, and self-hosting services where possible before any public deployment.

## Architecture & Tech Stack

The backend will act as a RESTful API provider for the Flutter frontend, running locally for the current development phase.

*   **Backend Framework:** **Python FastAPI** - Ideal for rapid development and natively excellent for AI integrations and data processing.
*   **Database:** PostgreSQL.
*   **Hosting:**
    *   **Backend API:** Running locally on the machine for now (no cloud backend API deployment).
    *   **Database:** **Supabase** (Free PostgreSQL database tier).

## API Integration Strategy (Free & Open Source)

To power the core features locally and effectively without heavy API costs:

### 1. Authentication (User Accounts & OAuth)
*   **Service:** **Supabase Auth**.
*   **Implementation:**
    *   Handle Email/Password, Google, and Apple Sign-In seamlessly.
    *   The Flutter app authenticates directly with Supabase.
    *   FastAPI backend validates the JWT token provided by the frontend.
    *   When a user signs up, the corresponding user record is synced/created in the `users` table.

### 2. Destination & Attraction Data (The Atlas)
*   **Service:** **OpenStreetMap (OSM)** (Nominatim/Overpass API) for location search and mapping, and **Wikipedia API** for rich text details.
*   **Implementation Map:**
    *   `SearchBottomSheet`: Hits FastAPI backend -> backend queries Nominatim for city names/locations.
    *   `DestinationDetailScreen`: Pulls from our database. If not present, fetches detailed descriptions, history, and summaries from the **Wikipedia API** + Unsplash/Wikimedia (images) and caches it.
    *   Overpass API can be used to pull specific attractions (temples, parks, local spots) around the destination.

### 3. AI Timeline & Itinerary Generation (Local AI)
Instead of relying on paid cloud APIs, the core "Generate My Itinerary" feature will leverage local AI.
*   **Service:** **Gemma 3 (Google's Open Model)** running locally.
*   **Variant Recommendation (MacBook Air M4):**
    *   **Gemma 3 4B (4 Billion parameters):** Highly recommended for the M4 chip. It will run extremely fast, consuming minimal unified memory (RAM) while providing strong reasoning for itinerary and JSON generation.
    *   **Gemma 3 12B (Quantized):** If you need higher reasoning quality and have 16GB+ RAM, a quantized 12B model will also run smoothly via tools like **Ollama** or **MLX**.
*   **Implementation Map:**
    *   **Local Server:** Run Gemma 3 via Ollama (`ollama run gemma3:4b`). FastAPI will send local HTTP requests to the Ollama API endpoint (`localhost:11434`).
    *   **Prompt Engineering:** The backend constructs a system prompt for the itinerary, forcing JSON output: `[Array of Days, each with Array of Activities...]`
    *   **Processing:** Parse the JSON response in FastAPI and map it to `timeline_days` and `activities` tables.

### 4. Weather Integration (Decision Making & Alerts)
Weather context is crucial for practical itineraries and safety.
*   **Service:** **Open-Meteo API** (Free, open-source weather API requiring no API key for non-commercial use).
*   **Implementation Map:**
    *   **Planning:** During AI itinerary generation, FastAPI fetches the seasonal/forecasted weather for the destination and passes it to Gemma 3 to influence activity choices (e.g., suggesting indoor activities on rainy days).
    *   **Alerts:** Check immediate weather forecasts for the ongoing trip dates to issue priority alerts in the app (e.g., "Heavy rain expected tomorrow afternoon, consider swapping your beach visit with the museum").

### 5. Budget Estimation & Tips
*   **Service:** **Currency API (e.g., Frankfurter API)** for currency conversion (Open Source, Free).
*   **AI Service:** Local **Gemma 3**.
*   **Implementation Map:**
    *   Query Gemma 3 with the generated timeline to estimate costs based on typical regional pricing and suggest 3 contextual money-saving tips.
    *   Store results in `budgets` and `budget_tips` tables.

### 6. Images (Destinations & Attractions)
*   **Service:** **Unsplash API** (Free tier) or **Wikimedia Commons API**.
*   **Quality & Sizing Strategy:**
    *   **Backend Optimization:** When fetching from Unsplash, the FastAPI backend will construct image URLs with dynamic parameters (e.g., `?w=1080&q=80&fit=crop`) to ensure high-resolution delivery without downloading unnecessarily massive files.
    *   **Frontend Rendering (Flutter):** The app will render these images using the `cached_network_image` package. To ensure the images fit perfectly into their UI windows (like hero headers or grid cards) without distortion, we will use the `fit: BoxFit.cover` property. This dynamically scales the image to fill its container while preserving its original aspect ratio, smoothly cropping the edges if necessary.

## Feature-by-Feature Backend Mapping

| Flutter UI Feature | Backend Endpoint / Action | External/Local Service Used |
| :--- | :--- | :--- |
| **Login/Signup** | Validate token, Create/Get `users` record. | Supabase Auth |
| **Onboarding** | `POST /api/users/{id}/preferences` | FastAPI |
| **Home Dashboard** | `GET /api/users/{id}/dashboard` | FastAPI + DB Query |
| **Search Destination** | `GET /api/destinations/search?q={query}` | OSM Nominatim |
| **Destination Detail** | `GET /api/destinations/{id}` | Wikipedia, Unsplash |
| **Plan Trip (Dates)** | Base step to create `trips` record. | FastAPI |
| **Generate Timeline** | `POST /api/trips/{id}/timeline/generate` | Local **Gemma 3** + Open-Meteo |
| **Edit Timeline** | `PUT /api/activities/{id}` | FastAPI |
| **Timeline Preview** | `GET /api/trips/{id}/timeline` | FastAPI |
| **Estimate Budget** | `POST /api/trips/{id}/budget/generate` | Local **Gemma 3** |
| **Weather Alerts** | `GET /api/trips/{id}/weather-alerts` | Open-Meteo |

## 2-Week Implementation Schedule (Mar 18, 2026 - Mar 31, 2026)

### Week 1: Infrastructure, Data, & Core APIs (Mar 18 - Mar 24)

*   **Day 1 (Mar 18): Database Setup & Project Init**
    *   Set up Supabase Project for database and Auth.
    *   Initialize Python FastAPI backend project locally.
    *   Run the provided `db/itinera_schema.sql` script on Supabase.
*   **Day 2-3 (Mar 19-20): Authentication & User Profile**
    *   Integrate Supabase Auth in the Flutter frontend.
    *   Create FastAPI middleware to validate Supabase JWTs.
    *   Implement base user profile creation and fetch logic.
*   **Day 4-5 (Mar 21-22): Destinations & Mapping Integration**
    *   Implement OSM/Nominatim for location search endpoint (`GET /api/destinations/search`).
    *   Integrate Wikipedia API & Unsplash API for rich destination details (`GET /api/destinations/{id}`).
*   **Day 6-7 (Mar 23-24): Weather Integration & Base Trip Logic**
    *   Integrate Open-Meteo to fetch weather data.
    *   Build base trip creation endpoints (saving dates and selected locations).

### Week 2: AI Integrations, Budgeting, & Polish (Mar 25 - Mar 31)

*   **Day 8-9 (Mar 25-26): Local AI Setup & Prompt Engineering**
    *   Install Ollama and pull the Gemma 3 model.
    *   Design and test prompt structures in FastAPI for itinerary generation, ensuring reliable JSON output.
*   **Day 10-11 (Mar 27-28): AI Itinerary Engine (Core)**
    *   Develop FastAPI endpoint (`POST /api/trips/{id}/timeline/generate`) to query Gemma 3 with location, dates, and weather context.
    *   Parse the itinerary output and save to `timeline_days` and `activities` tables.
*   **Day 12 (Mar 29): Budget Engine**
    *   Use Gemma 3 to evaluate generated timelines for budget estimates (`POST /api/trips/{id}/budget/generate`).
    *   Integrate Frankfurter API for currency conversion if necessary.
*   **Day 13 (Mar 30): Trip Management & Alerts**
    *   Implement checklist generation and standard CRUD operations for trips.
    *   Set up priority weather alerts checking for active trips.
*   **Day 14 (Mar 31): Final Polish & End-to-End Testing**
    *   Conduct end-to-end testing of the Flutter frontend with the local FastAPI backend.
    *   Fix bugs, optimize prompt execution latency, and finalize API documentation.

