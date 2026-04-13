import re

with open("diagrams.md", "r") as f:
    content = f.read()

# 1. Update TOC
toc_old = """1. [High-Level Architecture Diagram](#1-high-level-architecture-diagram)
2. [Solution Diagram](#2-solution-diagram)
3. [Use-Case Diagram](#3-use-case-diagram)
4. [Component Diagram — Flutter Layer](#4-component-diagram--flutter-layer)
5. [Navigation & Activity Diagram](#5-navigation--activity-diagram)
6. [Trip Planning Activity Diagram](#6-trip-planning-activity-diagram)
7. [Entity-Relationship Diagram](#7-entity-relationship-diagram)
8. [Widget Architecture Diagram](#8-widget-architecture-diagram)
9. [Deployment Diagram](#9-deployment-diagram)"""

toc_new = """1. [High-Level Architecture Diagram](#1-high-level-architecture-diagram)
2. [Solution Diagram](#2-solution-diagram)
3. [Use-Case Diagram](#3-use-case-diagram)
4. [Component Diagram — Flutter Layer](#4-component-diagram--flutter-layer)
5. [Navigation & Activity Diagram](#5-navigation--activity-diagram)
6. [Trip Planning Activity Diagram](#6-trip-planning-activity-diagram)
7. [Entity-Relationship Diagram](#7-entity-relationship-diagram)
8. [Widget Architecture Diagram](#8-widget-architecture-diagram)
9. [Deployment Diagram](#9-deployment-diagram)
10. [Class Diagram — Backend Models](#10-class-diagram--backend-models)
11. [Sequence Diagram — Core Executions](#11-sequence-diagram--core-executions)
12. [Data Architecture Diagram](#12-data-architecture-diagram)"""

content = content.replace(toc_old, toc_new)

# 2. Update Use Case Diagram
uc_add = """    subgraph ExtraUC["New Features"]
        UC26["View Live Weather"]
        UC27["Read In-App Notifications"]
        UC28["Interact with AI Chat"]
    end
"""
# insert before "Traveler --> UC1 & UC2 & UC3 & UC4"
content = content.replace("    Traveler --> UC1 & UC2 & UC3 & UC4", uc_add + "\n    Traveler --> UC26 & UC27 & UC28\n    Traveler --> UC1 & UC2 & UC3 & UC4")

uc_style = "    style ExtraUC fill:#E0F7FA,stroke:#006064,stroke-width:1px"
content = content.replace("    style ProfileUC fill:#FCE4EC,stroke:#AD1457,stroke-width:1px", "    style ProfileUC fill:#FCE4EC,stroke:#AD1457,stroke-width:1px\n" + uc_style)

# 3. Add Activity for new features
# In Navigation & Activity Diagram
nav_update = """    %% Home Screen Interactions
    Home -- "Profile Icon" --> Profile["ProfileScreen"]
    Profile -- "Logout" --> Auth
    Home -- "FAB" --> Search["SearchBottomSheet"]
    Home -- "Weather Widget" --> Home
    Home -- "Notification Icon" --> Notif["NotificationsBottomSheet"]
    DestDetail -- "AI Chat" --> AiChat["AIChatBottomSheet"]"""

content = content.replace("""    %% Home Screen Interactions
    Home -- "Profile Icon" --> Profile["ProfileScreen"]
    Profile -- "Logout" --> Auth
    Home -- "FAB" --> Search["SearchBottomSheet"]""", nav_update)

# 4. Append new diagrams before "## ENUM Types Reference"
new_sections = """---

## 10. Class Diagram — Backend Models

Shows the Pydantic data models used in the FastAPI application for requests and responses.

```mermaid
classDiagram
    class TripCreate {
        +UUID destination_id
        +String title
        +Date start_date
        +Date end_date
        +String departure_city
        +List~String~ tags
        +String notes
        +String budget_level
        +int target_budget
    }

    class TripUpdate {
        +String title
        +Date start_date
        +Date end_date
        +List~String~ tags
        +String notes
        +String status
        +String budget_level
        +int target_budget
    }

    class TripResponse {
        +UUID id
        +UUID user_id
        +UUID destination_id
        +String status
        +String title
        +Date start_date
        +Date end_date
        +List~String~ tags
        +int places_visited
        +int activities_done
        +String notes
        +String budget_level
        +int target_budget
        +String created_at
        +String updated_at
    }

    class NotificationResponse {
        +UUID id
        +UUID user_id
        +String type
        +String title
        +String message
        +String action_label
        +String action_route
        +bool is_read
        +datetime created_at
    }

    TripCreate ..> TripResponse : Creates
    TripUpdate ..> TripResponse : Updates
```

---

## 11. Sequence Diagram — Core Executions

Illustrates the flow between the Flutter client, FastAPI backend, and Supabase during an AI Trip generation and Auth.

```mermaid
sequenceDiagram
    actor User
    participant App as Flutter App
    participant Auth as Supabase Auth (OOTB)
    participant API as FastAPI Backend
    participant Gemini as Google Gemini AI
    participant DB as Supabase DB (PostgreSQL)

    %% Authentication Flow
    User->>App: Login with Email
    App->>Auth: Authenticate Request
    Auth-->>App: JWT Token
    App->>API: Verify Token via Thread-Safe Cache logic
    API-->>App: Token Valid
    
    %% AI Trip Checklist Generation
    User->>App: Generate Pre-Trip Checklist
    App->>API: POST /trips/{id}/checklist (with JWT)
    API->>DB: Fetch Trip & Destination Details
    DB-->>API: Destination Data + Weather
    API->>Gemini: Generate Packing List (Context: Dest, Weather, Time)
    Gemini-->>API: AI Checklist JSON
    API->>DB: Save Template Items
    DB-->>API: Saved
    API-->>App: 200 OK + Checklist Items
    App-->>User: Render Interactive Checklist
```

---

## 12. Data Architecture Diagram

Demonstrates how data systems, queues, state, and external data sources interact across the platform.

```mermaid
graph TB
    subgraph ClientData["📱 Client State Management"]
        Provider["Provider / Riverpod State"]
        LocalCache["Hive / SharedPrefs (Offline Data)"]
    end

    subgraph API Gateway["⚡ API Layer (FastAPI)"]
        Router["Endpoints (Auth, Trips, AI, Notifs)"]
        Validation["Pydantic Schemas"]
        TokenVer["Stateless Authentication"]
    end

    subgraph SupabasePlatform["Supabase Managed Services"]
        PG["PostgreSQL Database"]
        AuthDB["Supabase Auth"]
        Storage["Storage Buckets"]
        Realtime["Realtime Engine (WebSockets)"]
    end
    
    subgraph ExternalSources["☁️ External Sources"]
        Gemini["Google Gemini API (LLM)"]
        IPAPI["IP Geolocation / Weather API"]
    end

    Provider <--> API Gateway
    LocalCache --> Provider
    API Gateway <--> PG
    API Gateway --> Gemini
    Provider <--> Realtime
    API Gateway --> IPAPI
    API Gateway <--> AuthDB

    style ClientData fill:#E3F2FD,stroke:#1565C0,stroke-width:2px
    style API Gateway fill:#FFF3E0,stroke:#E65100,stroke-width:2px
    style SupabasePlatform fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px
    style ExternalSources fill:#F3E5F5,stroke:#7B1FA2,stroke-width:2px
```

"""

content = content.replace("## ENUM Types Reference", new_sections + "\n## ENUM Types Reference")

with open("diagrams.md", "w") as f:
    f.write(content)

print("Done")
