# Itinera 2: Backend Architecture & Integration Guide

This document provides a comprehensive technical breakdown of the Itinera 2 backend. It is designed for developers, architects, and as a study resource for technical viva examinations.

---

## 1. System Overview & Tech Stack

Itinera 2 follows a **Hybrid Cloud-Local Architecture**. The primary backend logic is hosted on a FastAPI server, while the data persistence and identity management are handled by Supabase (PostgreSQL).

### **Core Stack**
- **Framework**: [FastAPI](https://fastapi.tiangolo.com/) (Python-based, high performance, asynchronous).
- **Database**: [Supabase](https://supabase.com/) (Managed PostgreSQL) for relational data and Realtime updates.
- **Authentication**: Supabase Auth (JWT-based).
- **AI Models**:
  - **Cloud**: [Google Gemini Flash 1.5](https://deepmind.google/technologies/gemini/) (via GenAI SDK) for complex generation.
  - **Local**: [Ollama / Gemma:4b](https://ollama.com/) (Local LLM) for privacy-sensitive and low-latency travel insights.
- **Server/Runtime**: Uvicorn (ASGI server).

## 2. Directory & Module Mapping

The backend is organized into functional modules to ensure clear separation between the API interface, core logic, and data models.

| Directory | Module | Responsibility ("What does it do?") |
|:---|:---|:---|
| `api/` | **Route Handlers** | Defines the REST endpoints and orchestrates high-level flows. |
| `├─ trips.py` | Trip Lifecycle | Manages trip CRUD and triggers AI itinerary/checklist generation. |
| `├─ destinations.py`| Destination Hub | Handles search, detail fetching, and Wikipedia/Nominatim caching. |
| `├─ users.py` | Identity | Manages user profiles and preference storage. |
| `└─ notifications` | Alerts | CRUD operations for in-app notifications. |
| `core/` | **The Brain** | Contains the actual business logic and external integrations. |
| `├─ ai.py` | Orchestrator | The central hub for Gemini (Cloud) and Ollama (Local) AI logic. |
| `├─ weather.py` | Forecasts | Handles Open-Meteo integration and coordinate-based caching. |
| `├─ security.py` | Auth Logic | Implements the stateless JWT verification and fallback logic. |
| `└─ supabase.py` | DB Client | Initializes and provides the singleton Supabase client. |
| `models/` | **Schemas** | Defines Pydantic models for request validation and response serialization. |

---

## 3. Authentication & Security

The system implements a robust, thread-safe authentication layer to satisfy both security and performance requirements.

### **Stateless Auth Verification**
> [!IMPORTANT]
> To avoid "deque mutated" concurrency crashes inherent in the Python Supabase client's stateful nature, we implement **Stateless Network Verification**.

1.  **Process**:
    - The client sends a Bearer Token (JWT).
    - The backend uses an ephemeral `httpx.Client` to verify the token directly against the Supabase Auth endpoint (`/auth/v1/user`).
    - This ensures thread safety and allows multiple concurrent requests without shared state interference.
2.  **Offline Fallback**: If the network verification is unavailable, the system fallbacks to **JWT Offline Decoding** using the `SUPABASE_JWT_SECRET` (HS256 algorithm).

---

## 3. Database Architecture (PostgreSQL)

The database is designed with extensibility and distributed systems in mind.

- **Primary Keys**: All tables use **UUIDs** (`uuid_generate_v4()`) to ensure uniqueness across distributed environments.
- **JSONB Extensibility**: Metadata columns on `destinations` and `activities` utilize PostgreSQL's `JSONB` type for storing AI-generated attributes without schema migrations.
- **Automated Triggers**: 
  - `handle_updated_at`: Automatically updates the `updated_at` timestamp on row modification.
  - `aggregate_ratings`: (Proposed/Implemented) Triggers that recalculate destination scores when a new review is added.
- **Key Tables**:
  - `users`: Core account data.
  - `trips`: Parent record for travel plans (Tracks status: `DRAFT`, `PLANNED`, `ACTIVE`).
  - `timeline_days` / `activities`: Hierarchical structure for the N-day itinerary.
  - `checklist_items`: Trip-specific tasks categorized by `DOCUMENTS`, `HEALTH`, `ESSENTIALS`, etc.

---

## 4. AI Orchestration Strategy

Itinera 2 distinguishes itself with a **Hybrid AI Strategy** that balances cost, latency, and capability.

### **Cloud AI (Gemini Flash 1.5)**
Used for "heavy lifting" where logical reasoning and structured output are critical:
- **Itinerary Generation**: Creates contiguous timelines (Morning to Night) ensuring no "gaps" in the trip day.
- **Budget Insights**: Estimates flight/hotel costs in INR based on budget levels (`STANDARD`, `COMFORT`, `LUXURY`).
- **Checklist Generation**: Context-aware lists (e.g., Passport/Visa for International, Aadhar for Domestic).
- **Transport Estimation**: Real-time logic for Walk/Transit/Taxi durations and pricing.

### **Local AI (Ollama / Gemma:4b)**
Used for repetitive or informative tasks to reduce API costs and latency:
- **Destination Insights**: Quick summaries of attractions and seasonal travel trends.
- **Streaming Chat**: A low-latency conversational experience where users can ask about a destination without cloud round-trips.

### **Reliability Patterns**
- **Retry Logic**: Implemented via the `tenacity` library with **Exponential Backoff**. It specifically skips retries for 429 (Quota Exhausted) errors to prevent useless hammering.
- **Structured Parsing**: Prompts strictly enforce JSON output. Post-processing cleans up common AI hallucinatory artifacts like markdown code blocks (````json ... ````).

---

## 5. Key Optimizations

### **Weather Caching & Performance**
- **Open-Meteo Integration**: A free, keyless API for weather data.
- **TTLCache**: High-performance in-memory cache (`TTL = 2 hours`).
- **Coordinate Rounding**:
  - [!TIP]
  - GPS coordinates are rounded to **2 decimal places** (~1.1km resolution). This significantly increases cache hits for users in the same neighborhood while maintaining sufficient accuracy for weather.

### **Background Task Processing**
- **Post-Response Generation**: When a user marks a trip as `PLANNED`, the **AI Checklist Generation** is kicked off as a FastAPI `BackgroundTasks`. 
- **User Experience**: The user receives a "Success" response immediately, while the AI works in the background to populate their checklist, preventing UI hang.

---

## 6. API Sequence & Data Flow (Viva Topic)

**Example: Generating a Trip Itinerary**
1.  **Frontend**: POST `/api/trips/{id}/generate`
2.  **Backend (Fetch Context)**: Retrieves Trip timing, User Preferences (e.g., "Culture", "Food"), and Weather Forecast.
3.  **AI Orchestrator**: Sends a multi-stage prompt to Gemini including "Key Anchors" (major attractions already in DB).
4.  **Parsing**: Converts AI JSON into `timeline_days` and `activities` records.
5.  **Time Normalization**: Backend converts AI-formatted times (e.g., "09:00 AM") into PostgreSQL `TIME` format (`09:00:00`) for precise sorting and UI display.

---

## 7. Troubleshooting & Debugging
- Logs are tagged with `[AI]`, `[Weather]`, `[Security]`, and `[BG]` for easy filtering.
- AI failure fallbacks provide static "Safe Defaults" so the app remains functional even if an LLM is unreachable.

---
*Created for Itinera 2 Technical Documentation.*
