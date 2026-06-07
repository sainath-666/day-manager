# DailyFlow

Personal productivity app for task management, daily schedule reminders, and expense tracking. Fully offline with Hive local storage.

## Features

- **Tasks** — CRUD, priorities, due dates/times, swipe actions, local notifications
- **Schedule** — Timeline view, week strip, repeating entries, reminder alerts
- **Expenses** — Category tracking, monthly summaries, grouped list
- **Analytics** — Pie/bar charts, top categories, export summary
- **Bill Scanner** — Manual entry + image pick (OCR stubbed for Phase 2)
- **Settings** — Accent color picker, light/dark/system theme

## Prerequisites

- Flutter ≥ 3.22.0
- Dart ≥ 3.4.0

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Tests

```bash
flutter test
flutter analyze
```

## Project Structure

```
lib/
├── core/         # Constants, enums, theme, utils
├── data/         # Hive models, repositories
├── providers/    # Riverpod state
├── features/     # Screens by module
└── shared/       # Routing, common widgets
```

Seed data loads automatically on first launch (`kLoadSeedData = true`).
