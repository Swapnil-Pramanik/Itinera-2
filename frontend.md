# Itinera 2: Frontend Architecture & UI Guide

This document provides a detailed technical breakdown of the Itinera 2 Flutter application. It serves as a guide for developers and a study resource for technical viva examinations on mobile application development and system integration.

---

## 1. Framework & Architecture

Itinera 2 is built using the **Flutter** framework, leveraging a **Service-Oriented Architecture (SOA)** for high maintainability and separation of concerns.

### **Key Architectural Patterns**
- **Service Layer (`lib/core`)**: Centralizes logic for API calls, authentication, and data manipulation. This keeps UI components clean and focused solely on presentation.
- **Asynchronous Orchestration**: Extensive use of `Future` and `Stream` for handling real-time AI responses and long-running backend processes.
- **Resiliency Strategy**: 
  - [!IMPORTANT]
  - **Backend-First with Fallback**: The app logic (e.g., `TripService`) always attempts to fetch data from the FastAPI backend first. If the backend is unreachable or returns an error, it seamlessly falls back to querying **Supabase directly**. This ensures the app is always functional even during backend maintenance.

## 2. Directory & Module Mapping

The Flutter frontend is built with a feature-first approach, ensuring that UI components and their corresponding logic are logically separated.

| Directory | Module | Responsibility ("What does it do?") |
|:---|:---|:---|
| `lib/core/` | **Logic Hub** | Contains the service layer and global constants. This is the bridge between the UI and the Backend. |
| `├─ trip_service.dart` | Trip Orchestrator | Handles all trip, itinerary, and checklist logic with backend fallbacks. |
| `├─ destination_service.dart` | Search & AI Chat | Manages destination discovery and the streaming AI chat interface. |
| `└─ notification_service.dart` | Alerts Manager | Synchoronizes in-app notifications with the backend. |
| `lib/screens/` | **UI Modules** | Groups all screens by feature area. |
| `├─ auth/` | Identity | Login, Signup, and Auth state management. |
| `├─ trip/` | Active Trips | Ongoing trip dashboard and destination rating views. |
| `├─ timeline/` | Itinerary Editor | The complex UI for viewing and regenerating AI itineraries. |
| `└─ home/` | Dashboard | The landing area with search, profile, and seasonal suggestions. |
| `lib/widgets/` | **Components** | A library of reusable UI units. |
| `├─ cards/` | Data Display | Destination and Trip cards with high-quality image caching. |
| `├─ overlays/` | Modals | Custom bottom sheets and full-page blurred overlays. |
| `└─ common/` | Utilities | Shared elements like AI input bars, badges, and progress indicators. |
| `lib/theme/` | **Styling** | Centralized Material 3 configuration for a consistent global look. |

---

## 3. Visual Identity & Design System

The app follows a modern, premium aesthetic based on the **Material 3 (M3)** design system.

- **Typography**: Uses `RobotoMono` across the entire application to give a structured, "tech-forward" feel.
- **Color Palette**: Dark Teal/Blue seed color (`#1A1A2E`) with high-contrast surfaces.
- **Premium UI Features**:
  - **Glassmorphism**: Subtle opacity and blur effects in components like `AiInputBar` and `ChecklistItem`.
  - **Micro-Animations**: Uses `AnimatedContainer` and `Hero` widgets for smooth state transitions and dot indicators.
  - **Custom Transitions**: `BlurPageRoute` provides a cohesive, aesthetic navigation experience that blurs the background during page entry.

---

## 3. Core Frontend logic (Viva Topics)

### **Authentication & Token Management**
- Identity is managed via `supabase_flutter`.
- **Token Injection**: The `UserService` ensures that every API request to the FastAPI backend includes a fresh `Authorization: Bearer <JWT>` header, enabling secure stateless verification.

### **AI Integration Patterns**
- **Non-Blocking Generation**: For long-running tasks like "Itinerary Generation", the app uses optimistic UI updates. It triggers the generation and allows the user to explore other features while the checklist/itinerary is populated in the background.
- **Streaming UI**: The Destination Chat feature uses **Dart Streams** to render AI responses chunk-by-chunk (Streaming), providing an interactive, human-like chat experience.

### **Data Flow Example: Search to Trip Creation**
1.  **Search**: `DestinationService` queries backend search (Nominatim + Cache).
2.  **Selection**: Navigates to `DestinationDetailScreen` via `BlurPageRoute`.
3.  **Creation**: User triggers `TripService.createTrip`, which notifies the backend.
4.  **BG Orchestration**: Backend begins generating the AI checklist and itinerary; the frontend pulls updates once available.

---

## 4. Key Security & Performance Optimizations

- **Intelligent Timeouts**: Different timeouts are applied based on the operation (e.g., 2 minutes for AI generation vs. 5 seconds for profile fetching).
- **Asset Optimization**: High-resolution destination images are loaded with caching to ensure fast repeat visits.
- **Error Boundaries**: Fallback UI components are displayed when a specific service (like Weather) is unreachable.

---

## 5. Summary of Key Dependencies

| Package | Purpose |
|---------|---------|
| `supabase_flutter` | Authentication, Real-time Database, and Fallback storage. |
| `http` | Primary communication with the FastAPI backend. |
| `google_fonts` | Rendering the custom `RobotoMono` typography. |
| `intl` | Internationalization and complex date/time formatting. |
| `cachetools` | (Backend optimization mentioned in frontend context for weather). |

---
*Created for Itinera 2 Technical Documentation.*
