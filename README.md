# Notification Center Module

## Overview

This is a standalone Notification Center module for a dating app.  
It displays incoming likes and includes **“Unblur All”** feature.

The module is fully self-contained and can be run as a mini-app with its own entry point.  
It demonstrates modular architecture, real-time updates handling, cursor-based pagination, and state persistence.

---

## Architecture Overview

- **UIKit-based MVVM**  
  Clear separation between UI (ViewController), presentation logic (ViewModel), and business/services layer.

- **Coordinator Pattern**  
  The entry point is managed by a Coordinator to support modular navigation and clean initialization.

- **Service Abstraction (Protocol-Oriented)**  
  All backend interactions are abstracted via protocols.  
  The current implementation uses a mock service for local testing.

- **Cursor-Based Pagination**  
  Pagination is implemented using opaque cursors (based on creation time) to ensure consistency during real-time insertions and removals.

- **Real-Time Updates**  
  Insertions and removals are delivered via a service callback (`onUpdate`) and applied using Diffable Data Source.

- **Timer Service**  
  The   “Unblur All” feature is managed by a dedicated timer service.  
  The timer state is persisted in `UserDefaults` to survive backgrounding and app restarts.

- **Diffable Data Source**  
  Used for predictable, animated, and consistent UI updates.

---

## Main Components

- **LikesViewController**  
  Displays the list of likes, timer label, and user interaction controls.

- **LikesViewModel**  
  Handles presentation logic, pagination, timer binding, and real-time updates.

- **UnblurTimerService**  
  Manages countdown logic and blur/unblur state persistence.

- **LikesService (Protocol)**  
  Defines API contract for fetching and updating likes.

- **MockLikesService**  
  Simulates backend behavior, including:
  - Cursor-based pagination  
  - Real-time insertions/removals  
  - Match simulation  

- **LikeUserCell**  
  Displays individual like cards (blurred/unblurred state handled per cell).

---

## Setup Instructions   

Clone the repository:

```bash
git clone https://github.com/ITretiakovaIT/NotificationCenter.git
cd NotificationCenter
```

Open NotificationCenter.xcodeproj.

Build and run the app.
No additional dependencies or configuration required.

## API Contracts & Data Flow

**LikesService Protocol**

```swift
func fetchLikes(after cursor: LikesCursor?) async throws -> LikesPage
func skip(id: String)
func like(id: String)
var onUpdate: ((LikesUpdate) -> Void)? { get set }
```

## Responsibilities

- **fetchLikes(after:)**  
  Returns a paginated list of likes using a cursor-based approach.

- **skip(id:)**  
  Removes a like (user skipped).

- **like(id:)**  
  Removes a like and triggers a match event.

- **onUpdate**  
  Delivers real-time updates (insert/remove/match).

---

## LikesPage

- `items: [LikeItem]`
- `nextCursor: LikesCursor?`

The cursor represents the creation timestamp of the last element in the page.

---

## LikesUpdate

- `.inserted(LikeItem, at: Int)`
- `.removed(id: String)`
- `.matched(LikeItem)`

Used for real-time synchronization of UI state.

---

## Data Flow

1. **Initial Load**  
   `LikesViewModel` calls `fetchLikes(after: nil)` and applies results via Diffable Data Source.

2. **Pagination**  
   When reaching the bottom, the ViewModel requests the next page using the latest cursor.

3. **User Actions**
   - Skip → item removed  
   - Like → item removed + match event triggered  

   The service emits updates via `onUpdate`, and the UI reflects changes immediately.

4. **Unblur All**
   - User taps **Unblur All**
   - `UnblurTimerService` starts countdown
   - Cards are unblurred
   - State persists across backgrounding and app restarts
   - When the timer expires, blur is restored automatically

5. **Real-Time Simulation**  
   The mock service simulates insertions and removals at arbitrary positions to test consistency of pagination and UI updates.

---

## Design Decisions

- Cursor-based pagination prevents duplication or skipping during real-time updates.
- Blur state is managed at the cell level, while timer state is managed globally.
- Timer persistence relies on `UserDefaults`.
- Diffable Data Source ensures stable animated updates.
- The service layer is protocol-based to allow easy replacement with a real backend implementation.

