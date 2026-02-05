# Database Schema Documentation

## Quick Start

```bash
# Initialize the database
psql -U postgres -d itinera -f db/itinera_schema.sql
```

## Tables Overview

| Table | Purpose | Key Relationships |
|-------|---------|-------------------|
| `users` | User accounts | → preferences, accounts, trips |
| `user_preferences` | Travel style preferences (URBAN, FOOD) | ← users |
| `linked_accounts` | OAuth providers (Google, Apple) | ← users |
| `destinations` | Cities/locations with metadata | → attractions, articles |
| `attractions` | POIs within destinations | ← destinations |
| `atlas_articles` | Travel articles/guides | ← destinations (optional) |
| `trips` | User trip plans | ← users, destinations |
| `timeline_days` | Daily itinerary structure | ← trips |
| `activities` | Individual activities | ← timeline_days, attractions |
| `checklist_templates` | Default checklist items | → checklist_items |
| `checklist_items` | Trip-specific checklist | ← trips |
| `budgets` | Trip budget summary | ← trips (1:1) |
| `budget_days` | Daily budget breakdown | ← budgets, timeline_days |
| `expense_items` | Individual expenses | ← budget_days |
| `budget_tips` | AI-generated savings tips | ← budgets, destinations |
| `search_history` | User search queries | ← users, destinations |
| `suggested_destinations` | Personalized suggestions | ← users, destinations |

## ENUM Types

```sql
auth_provider      -- GOOGLE, APPLE, EMAIL
trip_status        -- PLANNED, SCHEDULED, ACTIVE, COMPLETED, CANCELLED
transport_mode     -- WALK, TRAIN, TAXI, BUS, SUBWAY, BIKE, CAR
activity_category  -- SIGHTSEEING, DINING, SHOPPING, CULTURE, NATURE, etc.
expense_category   -- FLIGHT, HOTEL, FOOD, ATTRACTION, SHOPPING, etc.
checklist_category -- TRAVEL, STAY, ESSENTIALS, DOCUMENTS, HEALTH
```

## Key Design Decisions

1. **UUIDs** - All primary keys use `uuid_generate_v4()` for distributed systems
2. **JSONB** - `metadata` columns on `destinations` and `activities` for AI extensibility
3. **Tags** - PostgreSQL `TEXT[]` arrays for flexible tagging
4. **Timestamps** - `created_at` and `updated_at` with automatic triggers
5. **Soft Deletes** - Use `status = 'CANCELLED'` instead of hard deletes
6. **Idempotent** - All `CREATE` statements use `IF NOT EXISTS`

## Spring Boot Integration

Map to JPA entities with:
```java
@Entity
@Table(name = "trips")
public class Trip {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    
    @Enumerated(EnumType.STRING)
    private TripStatus status;
    
    // ...
}
```

## Seed Data Included

- **4 Destinations**: Tokyo, Kyoto, Paris, Bali
- **9 Attractions**: Tokyo landmarks from Flutter UI
- **4 Atlas Articles**: From HomeScreen cards
- **13 Checklist Templates**: Default pre-trip items
