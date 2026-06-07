# Flutter Personal Productivity App — AI Generative Prompt
## Task Management · Daily Reminders · Expense Tracking

> **How to use this document:** Feed this entire file verbatim into a generative AI model (Claude, GPT-4o, Gemini, etc.) to receive a fully scaffolded Flutter starter project. Follow the phased milestones to extend the MVP iteratively.

---

## 1. Role & Goals

You are a **senior Flutter architect** with deep expertise in:

- Production-grade Material 3 UI/UX design
- Performance-first mobile development (60 fps, low memory footprint)
- Maintainable clean architecture with clear separation of concerns
- Accessibility (WCAG 2.1 AA), internationalization, and offline-first patterns

**Your mission:** Generate a complete, runnable Flutter MVP for a personal productivity app that covers:

1. Daily task management with time-based local notifications
2. Daily schedule entries with configurable reminders
3. Expense tracking with category breakdown and monthly analytics
4. Optional bill scan / OCR capture (behind a feature flag, stubbed for Phase 1)
5. Fully offline operation backed by local persistence
6. A polished, non-generic UI with smooth animations and accessible design

The output must include **all files necessary** to `flutter run` the project immediately, using static seed data. No remote API calls, no authentication, no paid services required for Phase 1.

---

## 2. MVP Scope (Phase 1)

### 2.1 Tasks Module

| Feature | Detail |
|---|---|
| CRUD | Create, read, update, delete tasks |
| Fields | Title, description, due date, due time, priority (low/medium/high), tags, completion state |
| Reminders | Schedule a local notification at the task's due time |
| Views | Daily checklist (filtered to "due today"), full task list, task detail/edit sheet |
| Actions | Swipe-to-complete, swipe-to-delete with undo snackbar, long-press for bulk actions |

### 2.2 Schedule Module

| Feature | Detail |
|---|---|
| CRUD | Create, read, update, delete schedule entries |
| Fields | Title, start time, end time, repeat (none/daily/weekdays/weekly), color label, notification toggle |
| View | Timeline view for the current day, week strip for navigation |
| Reminders | Local notification X minutes before start time (configurable per entry) |

### 2.3 Expenses Module

| Feature | Detail |
|---|---|
| CRUD | Add, read, update, delete expense records |
| Fields | Amount, category (enum), description, date, payment method, receipt note, optional image path |
| Categories | Food, Fuel, Groceries, Utilities, Transport, Health, Entertainment, Shopping, Other |
| Views | Expense list (grouped by date), monthly summary card |
| Bill Scan | Camera capture or gallery pick → image stored locally → OCR stub populates description field (Phase 1: manual entry only; flag `kOcrEnabled = false`) |

### 2.4 Analytics / Dashboard

| Feature | Detail |
|---|---|
| Home dashboard | Task completion rate today, upcoming reminders, spending this month vs last |
| Monthly view | Total spend, category pie/bar chart, top 3 categories |
| Trend | Month-over-month spend bar chart (last 6 months) |
| Export | Plain text summary to share sheet (Phase 1) |

### 2.5 Data & Persistence

- **Hive** (primary) for typed, schema-versioned local storage
- All CRUD operations wrapped in repository interfaces (easy to swap to SQLite or remote later)
- Offline-first: every operation works without any network access
- Static seed data loaded on first launch (configurable flag `kLoadSeedData = true`)

### 2.6 UI/UX Requirements

- Material 3 design system with dynamic color (user-selectable accent in Settings)
- Smooth hero transitions between list and detail views
- Animated FAB with expandable quick-add panel
- Skeleton loading placeholders (even for local data to avoid layout shifts)
- Dark mode support via `ThemeMode.system`
- Haptic feedback on task completion, swipe actions, and error states
- Responsive layout: phones (primary), large phones / small tablets (adaptive side panel)

---

## 3. Tech Stack & Constraints

```
Framework         : Flutter ≥ 3.22 (Dart ≥ 3.4)
State Management  : Riverpod 2.x (AsyncNotifier + Notifier pattern)
Local Persistence : Hive 2.x with typed HiveObject adapters
                    (HiveField annotations, explicit typeIds)
Notifications     : flutter_local_notifications 17.x
                    + timezone package for correct scheduling
Navigation        : go_router 14.x (declarative, deep-link ready)
Charts            : fl_chart 0.67.x (no heavy dependencies)
Image Picking     : image_picker (OCR stub; behind kOcrEnabled flag)
OCR (Phase 2)     : google_mlkit_text_recognition (do NOT add in Phase 1)
Icons             : Material Symbols (flutter_material_symbols or cupertino_icons)
Linting           : flutter_lints + custom analysis_options.yaml
Testing           : flutter_test, mocktail, riverpod_test
CI                : GitHub Actions workflow stub included
```

**Hard constraints:**

- Zero remote API calls in Phase 1
- No Firebase, no Supabase, no third-party auth in Phase 1
- Minimum external packages — justify every dependency
- All UI must work at 60 fps on a mid-range Android device (Snapdragon 665 class)
- `flutter analyze` must pass with zero warnings on generation

---

## 4. Architecture & Components

### 4.1 Folder Structure

```
lib/
├── main.dart                         # App entry, Hive init, ProviderScope
├── app.dart                          # MaterialApp.router, theme, go_router
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart          # All user-visible strings (i18n-ready)
│   │   ├── app_sizes.dart            # Spacing / radius constants
│   │   └── feature_flags.dart        # kOcrEnabled, kLoadSeedData, etc.
│   ├── enums/
│   │   ├── priority.dart
│   │   ├── expense_category.dart
│   │   ├── repeat_mode.dart
│   │   └── payment_method.dart
│   ├── extensions/
│   │   ├── date_time_ext.dart        # isToday, formatDisplay, weekdayName
│   │   ├── double_ext.dart           # toCurrency(), toPercent()
│   │   └── string_ext.dart
│   ├── theme/
│   │   ├── app_theme.dart            # ThemeData light + dark
│   │   └── color_scheme.dart
│   └── utils/
│       ├── currency_formatter.dart
│       ├── notification_service.dart  # Wrapper around flutter_local_notifications
│       └── seed_data.dart            # Static seed JSON/objects
├── data/
│   ├── models/
│   │   ├── task.dart                 # HiveObject, HiveField
│   │   ├── schedule_entry.dart
│   │   ├── expense.dart
│   │   └── bill_note.dart
│   ├── adapters/                     # Generated TypeAdapters (hive_generator)
│   │   ├── task_adapter.dart
│   │   ├── schedule_entry_adapter.dart
│   │   ├── expense_adapter.dart
│   │   └── bill_note_adapter.dart
│   └── repositories/
│       ├── i_task_repository.dart    # Abstract interface
│       ├── i_schedule_repository.dart
│       ├── i_expense_repository.dart
│       ├── hive_task_repository.dart
│       ├── hive_schedule_repository.dart
│       └── hive_expense_repository.dart
├── providers/
│   ├── hive_providers.dart           # Box providers (opened boxes)
│   ├── repository_providers.dart     # Repo providers backed by Hive boxes
│   ├── task_providers.dart           # tasksProvider, todayTasksProvider, etc.
│   ├── schedule_providers.dart
│   ├── expense_providers.dart
│   └── analytics_providers.dart     # Derived/computed providers
├── features/
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       ├── summary_card.dart
│   │       ├── upcoming_reminders_section.dart
│   │       └── quick_add_fab.dart
│   ├── tasks/
│   │   ├── tasks_screen.dart
│   │   ├── task_detail_screen.dart
│   │   └── widgets/
│   │       ├── task_tile.dart
│   │       ├── task_form.dart
│   │       └── priority_chip.dart
│   ├── schedule/
│   │   ├── schedule_screen.dart
│   │   └── widgets/
│   │       ├── timeline_view.dart
│   │       ├── schedule_entry_tile.dart
│   │       └── week_strip.dart
│   ├── expenses/
│   │   ├── expenses_screen.dart
│   │   ├── expense_detail_screen.dart
│   │   └── widgets/
│   │       ├── expense_tile.dart
│   │       ├── expense_form.dart
│   │       ├── category_chip.dart
│   │       └── month_summary_card.dart
│   ├── bill_scanner/
│   │   ├── bill_scanner_screen.dart  # Phase 1: manual note only
│   │   └── widgets/
│   │       └── bill_note_form.dart
│   ├── analytics/
│   │   ├── analytics_screen.dart
│   │   └── widgets/
│   │       ├── category_pie_chart.dart
│   │       ├── monthly_bar_chart.dart
│   │       └── stat_card.dart
│   └── settings/
│       ├── settings_screen.dart
│       └── widgets/
│           └── theme_picker.dart
└── shared/
    ├── widgets/
    │   ├── app_scaffold.dart          # Common scaffold with nav rail / bottom nav
    │   ├── loading_skeleton.dart
    │   ├── empty_state.dart
    │   ├── error_view.dart
    │   ├── confirm_dialog.dart
    │   └── date_time_picker_field.dart
    └── routing/
        └── app_router.dart           # go_router routes + shell route

test/
├── data/
│   ├── repositories/
│   │   ├── task_repository_test.dart
│   │   └── expense_repository_test.dart
├── providers/
│   ├── task_providers_test.dart
│   └── analytics_providers_test.dart
└── features/
    ├── tasks/task_tile_test.dart
    └── expenses/expense_form_test.dart
```

### 4.2 Data Models

Generate all four models as `HiveObject` subclasses with explicit `typeId` values and `HiveField` annotations on every property. Include a named constructor `Task.create(...)` that auto-generates a UUID via the `uuid` package and sets `createdAt` to `DateTime.now()`.

#### Task

```dart
// typeId: 0
class Task extends HiveObject {
  @HiveField(0) late String id;           // UUID v4
  @HiveField(1) late String title;
  @HiveField(2) String? description;
  @HiveField(3) late DateTime createdAt;
  @HiveField(4) DateTime? dueDate;        // nullable = no due date
  @HiveField(5) String? dueTime;          // "HH:mm" 24h format
  @HiveField(6) late int priority;        // 0=low, 1=medium, 2=high (Priority enum)
  @HiveField(7) late bool isCompleted;
  @HiveField(8) DateTime? completedAt;
  @HiveField(9) late List<String> tags;
  @HiveField(10) bool notificationScheduled = false;
}
```

#### ScheduleEntry

```dart
// typeId: 1
class ScheduleEntry extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String title;
  @HiveField(2) String? notes;
  @HiveField(3) late DateTime date;
  @HiveField(4) late String startTime;    // "HH:mm"
  @HiveField(5) late String endTime;
  @HiveField(6) late int repeatMode;      // RepeatMode enum int
  @HiveField(7) late int colorValue;      // Color.value int
  @HiveField(8) late bool notifyEnabled;
  @HiveField(9) late int notifyMinutesBefore; // 5, 10, 15, 30, 60
}
```

#### Expense

```dart
// typeId: 2
class Expense extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late double amount;       // always stored in user's local currency
  @HiveField(2) late int category;        // ExpenseCategory enum int
  @HiveField(3) late String description;
  @HiveField(4) late DateTime date;
  @HiveField(5) late int paymentMethod;   // PaymentMethod enum int
  @HiveField(6) String? receiptNote;      // free text from bill scan
  @HiveField(7) String? imagePath;        // local file path (Phase 2)
  @HiveField(8) late DateTime createdAt;
}
```

#### BillNote

```dart
// typeId: 3
class BillNote extends HiveObject {
  @HiveField(0) late String id;
  @HiveField(1) late String rawText;      // OCR output or manual entry
  @HiveField(2) double? parsedAmount;
  @HiveField(3) int? parsedCategory;
  @HiveField(4) late DateTime capturedAt;
  @HiveField(5) String? imagePath;
  @HiveField(6) bool linkedToExpense = false;
  @HiveField(7) String? linkedExpenseId;
}
```

### 4.3 Repository Interfaces

```dart
// i_task_repository.dart
abstract class ITaskRepository {
  Future<List<Task>> getAll();
  Future<List<Task>> getByDate(DateTime date);
  Future<Task?> getById(String id);
  Future<void> add(Task task);
  Future<void> update(Task task);
  Future<void> delete(String id);
  Future<void> toggleComplete(String id);
  Stream<List<Task>> watchAll();        // reactive stream for Riverpod
}

// i_expense_repository.dart
abstract class IExpenseRepository {
  Future<List<Expense>> getAll();
  Future<List<Expense>> getByMonth(int year, int month);
  Future<Map<int, double>> getCategoryTotals(int year, int month);
  Future<List<MonthlyTotal>> getMonthlyTotals(int months); // last N months
  Future<void> add(Expense expense);
  Future<void> update(Expense expense);
  Future<void> delete(String id);
  Stream<List<Expense>> watchAll();
}
```

### 4.4 State Management (Riverpod 2.x)

Use the following provider hierarchy. All providers that expose mutable state use `AsyncNotifier` or `Notifier`; read-only derived state uses `Provider` or `StreamProvider`.

```dart
// providers/task_providers.dart  — illustrative pattern

@riverpod
class TasksNotifier extends _$TasksNotifier {
  @override
  Future<List<Task>> build() async {
    final repo = ref.watch(taskRepositoryProvider);
    return repo.getAll();
  }

  Future<void> add(Task task) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.add(task);
    ref.invalidateSelf();
  }

  Future<void> toggleComplete(String id) async {
    final repo = ref.read(taskRepositoryProvider);
    await repo.toggleComplete(id);
    ref.invalidateSelf();
    // Cancel or reschedule notification accordingly
  }
}

@riverpod
List<Task> todayTasks(TodayTasksRef ref) {
  final allTasksAsync = ref.watch(tasksNotifierProvider);
  return allTasksAsync.when(
    data: (tasks) => tasks.where((t) => t.dueDate?.isToday == true).toList()
      ..sort((a, b) => (a.dueTime ?? '99:99').compareTo(b.dueTime ?? '99:99')),
    loading: () => [],
    error: (_, __) => [],
  );
}

@riverpod
double todayCompletionRate(TodayCompletionRateRef ref) {
  final tasks = ref.watch(todayTasksProvider);
  if (tasks.isEmpty) return 0.0;
  return tasks.where((t) => t.isCompleted).length / tasks.length;
}
```

### 4.5 Notification Service

```dart
// core/utils/notification_service.dart

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(requestAlertPermission: true);
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    await _requestPermissions();
  }

  /// Schedule a task reminder at [scheduledAt].
  /// [id] must be unique and stable (use task id's hash code).
  static Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    final tz = tz_convert.TZDateTime.from(scheduledAt, tz.local);
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for task due times',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancel(int id) => _plugin.cancel(id);

  static void _onNotificationTap(NotificationResponse response) {
    // Navigate via go_router using the payload (task id)
  }
}
```

---

## 5. Seed Data (Static JSON)

Load this on first launch when `kLoadSeedData == true`. Parse with `seed_data.dart`.

```json
{
  "tasks": [
    {
      "id": "task-001",
      "title": "Morning workout",
      "description": "30 min run + stretching",
      "dueDate": "TODAY",
      "dueTime": "07:00",
      "priority": 1,
      "isCompleted": false,
      "tags": ["health", "daily"]
    },
    {
      "id": "task-002",
      "title": "Review Q3 report",
      "description": "Summarize findings for team meeting",
      "dueDate": "TODAY",
      "dueTime": "09:30",
      "priority": 2,
      "isCompleted": true,
      "tags": ["work"]
    },
    {
      "id": "task-003",
      "title": "Buy groceries",
      "description": "Milk, eggs, bread, vegetables",
      "dueDate": "TODAY",
      "dueTime": "18:00",
      "priority": 0,
      "isCompleted": false,
      "tags": ["errands"]
    },
    {
      "id": "task-004",
      "title": "Doctor appointment",
      "dueDate": "TOMORROW",
      "dueTime": "11:00",
      "priority": 2,
      "isCompleted": false,
      "tags": ["health"]
    },
    {
      "id": "task-005",
      "title": "Pay electricity bill",
      "dueDate": "IN_3_DAYS",
      "dueTime": "17:00",
      "priority": 1,
      "isCompleted": false,
      "tags": ["finance"]
    }
  ],
  "schedule_entries": [
    {
      "id": "sched-001",
      "title": "Team standup",
      "startTime": "09:00",
      "endTime": "09:20",
      "repeatMode": 2,
      "colorValue": 4284955319,
      "notifyEnabled": true,
      "notifyMinutesBefore": 5
    },
    {
      "id": "sched-002",
      "title": "Lunch break",
      "startTime": "13:00",
      "endTime": "14:00",
      "repeatMode": 1,
      "colorValue": 4294940160,
      "notifyEnabled": false,
      "notifyMinutesBefore": 10
    },
    {
      "id": "sched-003",
      "title": "Evening jog",
      "startTime": "18:30",
      "endTime": "19:15",
      "repeatMode": 1,
      "colorValue": 4283215696,
      "notifyEnabled": true,
      "notifyMinutesBefore": 15
    }
  ],
  "expenses": [
    { "id": "exp-001", "amount": 850.00, "category": 2, "description": "Weekly groceries", "daysAgo": 0, "paymentMethod": 0 },
    { "id": "exp-002", "amount": 2200.00, "category": 4, "description": "Uber ride to office", "daysAgo": 1, "paymentMethod": 1 },
    { "id": "exp-003", "amount": 450.00, "category": 0, "description": "Lunch at Subway", "daysAgo": 1, "paymentMethod": 1 },
    { "id": "exp-004", "amount": 3500.00, "category": 5, "description": "Electricity bill", "daysAgo": 3, "paymentMethod": 0 },
    { "id": "exp-005", "amount": 1200.00, "category": 1, "description": "Petrol fill-up", "daysAgo": 3, "paymentMethod": 0 },
    { "id": "exp-006", "amount": 699.00, "category": 6, "description": "Movie tickets", "daysAgo": 5, "paymentMethod": 1 },
    { "id": "exp-007", "amount": 5400.00, "category": 7, "description": "Clothes shopping", "daysAgo": 7, "paymentMethod": 1 },
    { "id": "exp-008", "amount": 2800.00, "category": 2, "description": "Grocery run", "daysAgo": 10, "paymentMethod": 0 },
    { "id": "exp-009", "amount": 600.00, "category": 0, "description": "Dinner out", "daysAgo": 12, "paymentMethod": 1 },
    { "id": "exp-010", "amount": 8000.00, "category": 4, "description": "Monthly rent split", "daysAgo": 15, "paymentMethod": 0 }
  ]
}
```

**Notes on seed data resolution:**
- `"TODAY"` resolves to `DateTime.now()` at load time (same for `TOMORROW`, `IN_3_DAYS`)
- `daysAgo` for expenses resolves to `DateTime.now().subtract(Duration(days: n))`
- Category int values map to `ExpenseCategory` enum ordinal (0=Food, 1=Fuel, 2=Groceries, 3=Utilities, 4=Transport, 5=Health/Utilities, 6=Entertainment, 7=Shopping, 8=Other)

---

## 6. Core Screens — Wireframes & Pseudo-Code

### 6.1 Home / Dashboard Screen

```
┌─────────────────────────────────────┐
│  [Avatar] Good morning, Rahul  ⚙️   │  ← Greeting with time of day
├─────────────────────────────────────┤
│  ┌──────────────────────────────┐   │
│  │  TODAY'S PROGRESS            │   │
│  │  ████████░░  3/5 tasks done  │   │  ← Animated LinearProgressIndicator
│  └──────────────────────────────┘   │
│                                     │
│  UPCOMING (next 3)                  │
│  ├ 🔵 09:00 Team standup            │
│  ├ 🟡 11:00 Doctor appt            │
│  └ 🔴 13:00 Buy groceries          │
│                                     │
│  THIS MONTH'S SPEND                 │
│  ┌───────────────────────────────┐  │
│  │  ₹24,499   vs ₹31,200 last   │  │  ← Spend card with trend arrow
│  │  [Food] [Transport] [+more]   │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
    [🏠 Home] [✅ Tasks] [📅 Sched] [💸 Expenses]
```

**Key widget:** `HomeScreen` consumes `todayCompletionRateProvider`, `upcomingRemindersProvider` (next 3 tasks/entries by time), `currentMonthSpendProvider`.

### 6.2 Tasks Screen

```
┌─────────────────────────────────────┐
│  Tasks                    [🔍] [⋯]  │
│  ┌─ Today ─────── Upcoming ─ All ─┐ │  ← TabBar
│  │                                │ │
│  │  □ Morning workout    07:00 🔔  │ │  ← Dismissible tile
│  │  ✓ Review Q3 report   09:30 ✓  │ │  ← Completed (strikethrough)
│  │  □ Buy groceries      18:00 🔔  │ │
│  │                                │ │
│  │  [No more tasks today]         │ │
│  └────────────────────────────────┘ │
│                                     │
│                             [  +  ] │  ← FAB (expandable)
└─────────────────────────────────────┘
```

**Task Tile pseudo-code:**

```dart
class TaskTile extends ConsumerWidget {
  final Task task;

  Widget build(BuildContext ctx, WidgetRef ref) {
    return Dismissible(
      key: Key(task.id),
      background: _buildCompleteBackground(),    // swipe right = complete
      secondaryBackground: _buildDeleteBackground(), // swipe left = delete
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          ref.read(tasksNotifierProvider.notifier).toggleComplete(task.id);
          _showUndoSnackbar(ctx, ref);
        } else {
          _showDeleteConfirmation(ctx, ref);
        }
      },
      child: ListTile(
        leading: _PriorityIndicator(priority: task.priority),
        title: Text(task.title,
          style: task.isCompleted
            ? TextStyle(decoration: TextDecoration.lineThrough)
            : null),
        subtitle: task.dueTime != null ? Text(task.dueTime!) : null,
        trailing: _NotificationBadge(scheduled: task.notificationScheduled),
        onTap: () => context.push('/tasks/${task.id}'),
      ),
    );
  }
}
```

### 6.3 Schedule Screen

```
┌─────────────────────────────────────┐
│  Schedule              Sun 8 Jun    │
│  ┌─Mon─┬─Tue─┬─Wed─┬─Thu─┬─Fri─┐  │  ← Week strip, scroll horizontal
│  │  7  │  8● │  9  │ 10  │ 11  │  │  ← ● = today
│  └─────┴─────┴─────┴─────┴─────┘  │
│                                     │
│  08:00 │                            │
│  09:00 │ ▐▌ Team standup  (20 min)  │  ← Color-coded pill
│  10:00 │                            │
│  11:00 │                            │
│  12:00 │                            │
│  13:00 │ ▐▌ Lunch break   (1 hr)    │
│  14:00 │                            │
│  ...   │                            │
│  18:30 │ ▐▌ Evening jog   (45 min)  │
│                               [  +]  │
└─────────────────────────────────────┘
```

### 6.4 Expenses Screen

```
┌─────────────────────────────────────┐
│  Expenses           June 2026  [⋯]  │
│  ┌─────────────────────────────────┐│
│  │  Total: ₹24,499                 ││  ← Month summary card
│  │  [Food 🍔] [Transport 🚗] ...   ││
│  └─────────────────────────────────┘│
│                                     │
│  Today                              │
│  ├ 🛒 Groceries    ₹850      Cash   │
│                                     │
│  Yesterday                          │
│  ├ 🚗 Uber ride    ₹2,200    UPI    │
│  └ 🍔 Lunch        ₹450      UPI    │
│                                     │
│  3 days ago                         │
│  ├ ⚡ Electricity  ₹3,500    Cash   │
│  └ ⛽ Petrol       ₹1,200    Cash   │
│                               [  +]  │
└─────────────────────────────────────┘
```

### 6.5 Bill Scanner Screen

```
┌─────────────────────────────────────┐
│  ← Scan / Add Bill                  │
│                                     │
│  [ 📷 Take Photo ]  [ 🖼 Gallery ]  │  ← Phase 1: picks image, no OCR
│                                     │
│  ┌─── Bill Details ───────────────┐ │
│  │  Description  [______________ ]│ │
│  │  Amount       [₹ ____________]│ │
│  │  Category     [ Food        ▼]│ │
│  │  Date         [ 08 Jun 2026 ] │ │
│  └────────────────────────────────┘ │
│                                     │
│  ℹ️ OCR auto-fill coming in v2.0    │  ← Feature flag hint
│                                     │
│         [ Save as Expense ]         │
└─────────────────────────────────────┘
```

### 6.6 Analytics Screen

```
┌─────────────────────────────────────┐
│  Analytics          [Month ▼]       │
│                                     │
│  ┌── Category Breakdown ──────────┐ │
│  │     🥧 Pie chart               │ │  ← fl_chart PieChart
│  │  Food 34% · Groceries 22% ...  │ │
│  └────────────────────────────────┘ │
│                                     │
│  ┌── Month-over-Month ────────────┐ │
│  │  Jan Feb Mar Apr May Jun       │ │  ← fl_chart BarChart
│  │  ▐ ▐ ▐ ▐▐  ▐▐  ▐▐            │ │
│  └────────────────────────────────┘ │
│                                     │
│  ┌── Top Spending ────────────────┐ │
│  │  1. Shopping      ₹5,400       │ │
│  │  2. Electricity   ₹3,500       │ │
│  │  3. Transport     ₹2,200       │ │
│  └────────────────────────────────┘ │
│                                     │
│              [ Export Summary ]     │
└─────────────────────────────────────┘
```

---

## 7. Sample Code Snippets

### 7.1 Hive Initialization (`main.dart`)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive setup
  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);

  // Register adapters (generated by hive_generator)
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(ScheduleEntryAdapter());
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(BillNoteAdapter());

  // Open boxes
  await Future.wait([
    Hive.openBox<Task>('tasks'),
    Hive.openBox<ScheduleEntry>('schedule'),
    Hive.openBox<Expense>('expenses'),
    Hive.openBox<BillNote>('bill_notes'),
  ]);

  // Notification init
  await NotificationService.init();
  await tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(await FlutterTimezone.getLocalTimezone()));

  // Seed static data on first launch
  if (kLoadSeedData) await SeedData.load();

  runApp(const ProviderScope(child: MyApp()));
}
```

### 7.2 Hive CRUD Repository (`hive_task_repository.dart`)

```dart
class HiveTaskRepository implements ITaskRepository {
  final Box<Task> _box;
  HiveTaskRepository(this._box);

  @override
  Future<List<Task>> getAll() async =>
      _box.values.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  @override
  Future<List<Task>> getByDate(DateTime date) async =>
      _box.values.where((t) => t.dueDate?.isSameDay(date) == true).toList();

  @override
  Future<void> add(Task task) async {
    await _box.put(task.id, task);
    if (task.dueDate != null && task.dueTime != null) {
      await _scheduleNotification(task);
    }
  }

  @override
  Future<void> update(Task task) async {
    await _box.put(task.id, task);
    await NotificationService.cancel(task.id.hashCode);
    if (!task.isCompleted && task.dueDate != null && task.dueTime != null) {
      await _scheduleNotification(task);
    }
  }

  @override
  Future<void> delete(String id) async {
    await NotificationService.cancel(id.hashCode);
    await _box.delete(id);
  }

  @override
  Future<void> toggleComplete(String id) async {
    final task = _box.get(id);
    if (task == null) return;
    task.isCompleted = !task.isCompleted;
    task.completedAt = task.isCompleted ? DateTime.now() : null;
    await task.save();
    HapticFeedback.lightImpact();
    if (task.isCompleted) {
      await NotificationService.cancel(id.hashCode);
    }
  }

  @override
  Stream<List<Task>> watchAll() =>
      _box.watch().map((_) => _box.values.toList());

  Future<void> _scheduleNotification(Task task) async {
    final timeParts = task.dueTime!.split(':');
    final scheduledAt = task.dueDate!.copyWith(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );
    if (scheduledAt.isAfter(DateTime.now())) {
      await NotificationService.scheduleTaskReminder(
        id: task.id.hashCode,
        title: '⏰ ${task.title}',
        body: task.description ?? 'Task is due now',
        scheduledAt: scheduledAt,
      );
      task.notificationScheduled = true;
      await task.save();
    }
  }
}
```

### 7.3 Analytics Provider (derived state)

```dart
// providers/analytics_providers.dart

@riverpod
Future<Map<ExpenseCategory, double>> currentMonthCategoryTotals(
  CurrentMonthCategoryTotalsRef ref,
) async {
  final repo = ref.watch(expenseRepositoryProvider);
  final now = DateTime.now();
  final rawMap = await repo.getCategoryTotals(now.year, now.month);
  return rawMap.map((key, value) =>
    MapEntry(ExpenseCategory.values[key], value));
}

@riverpod
Future<List<MonthlyTotal>> lastSixMonthTotals(
  LastSixMonthTotalsRef ref,
) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getMonthlyTotals(6);
}

// MonthlyTotal is a simple data class:
class MonthlyTotal {
  final int year;
  final int month;
  final double total;
  const MonthlyTotal({required this.year, required this.month, required this.total});
}
```

### 7.4 go_router Configuration

```dart
// shared/routing/app_router.dart

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (ctx, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(path: '/home',     builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/tasks',    builder: (_, __) => const TasksScreen()),
          GoRoute(
            path: '/tasks/:id',
            builder: (_, state) => TaskDetailScreen(taskId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/schedule', builder: (_, __) => const ScheduleScreen()),
          GoRoute(path: '/expenses', builder: (_, __) => const ExpensesScreen()),
          GoRoute(
            path: '/expenses/:id',
            builder: (_, state) => ExpenseDetailScreen(expenseId: state.pathParameters['id']!),
          ),
          GoRoute(path: '/analytics', builder: (_, __) => const AnalyticsScreen()),
          GoRoute(path: '/scan',     builder: (_, __) => const BillScannerScreen()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
}
```

### 7.5 Category Pie Chart Widget

```dart
// features/analytics/widgets/category_pie_chart.dart

class CategoryPieChart extends ConsumerWidget {
  const CategoryPieChart({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final totalsAsync = ref.watch(currentMonthCategoryTotalsProvider);

    return totalsAsync.when(
      loading: () => const LoadingSkeleton(height: 200),
      error: (e, _) => ErrorView(message: e.toString()),
      data: (totals) {
        if (totals.isEmpty) {
          return const EmptyState(message: 'No expenses this month');
        }
        final grandTotal = totals.values.fold(0.0, (a, b) => a + b);
        return PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 48,
            sections: totals.entries.map((entry) {
              final pct = entry.value / grandTotal;
              return PieChartSectionData(
                value: entry.value,
                title: '${(pct * 100).toStringAsFixed(0)}%',
                color: entry.key.color,
                radius: 80,
                titleStyle: Theme.of(ctx).textTheme.labelSmall!
                    .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
```

### 7.6 Bill Scan Flow (Phase 1 — stub)

```dart
// features/bill_scanner/bill_scanner_screen.dart

class BillScannerScreen extends ConsumerStatefulWidget { ... }

class _BillScannerScreenState extends ConsumerState<BillScannerScreen> {
  File? _pickedImage;
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.other;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    setState(() => _pickedImage = File(picked.path));

    if (kOcrEnabled) {
      // Phase 2: call ML Kit here
      // final ocrResult = await OcrService.extractText(_pickedImage!);
      // _descController.text = ocrResult.rawText;
      // _amountController.text = ocrResult.parsedAmount?.toString() ?? '';
    }
    // Phase 1: user fills manually — image is stored for reference only
  }

  Future<void> _saveExpense() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')));
      return;
    }
    final expense = Expense.create(
      amount: amount,
      category: _category,
      description: _descController.text,
      date: DateTime.now(),
      imagePath: _pickedImage?.path,
    );
    await ref.read(expensesNotifierProvider.notifier).add(expense);
    if (mounted) context.pop();
  }

  // ... build() with form UI
}
```

---

## 8. `pubspec.yaml`

```yaml
name: dailyflow
description: Personal task management, reminders, and expense tracking.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'
  flutter: '>=3.22.0'

dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Local persistence
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.3

  # Navigation
  go_router: ^14.2.0

  # Notifications
  flutter_local_notifications: ^17.2.1
  flutter_timezone: ^1.0.4
  timezone: ^0.9.4

  # Charts
  fl_chart: ^0.67.0

  # Utilities
  uuid: ^4.4.0
  intl: ^0.19.0
  image_picker: ^1.1.2   # Bill scan image picking

  # UI
  flutter_animate: ^4.5.0  # Smooth, declarative animations

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  hive_generator: ^2.0.1
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.3
  mocktail: ^1.0.4
  riverpod_test: ^1.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/seed_data.json
    - assets/images/

# Generate Hive adapters:
# flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 9. Theme & Design System

```dart
// core/theme/app_theme.dart

class AppTheme {
  static ThemeData light(Color seedColor) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light),
    typography: Typography.material2021(),
    cardTheme: const CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0, scrolledUnderElevation: 1),
  );

  static ThemeData dark(Color seedColor) => light(seedColor).copyWith(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark),
  );
}

// Expense category colors (accessible, WCAG AA contrast on white/dark bg)
extension ExpenseCategoryX on ExpenseCategory {
  Color get color => const [
    Color(0xFFE53935),  // Food — red
    Color(0xFF6D4C41),  // Fuel — brown
    Color(0xFF43A047),  // Groceries — green
    Color(0xFF1E88E5),  // Utilities — blue
    Color(0xFF8E24AA),  // Transport — purple
    Color(0xFF00ACC1),  // Health — teal
    Color(0xFFFB8C00),  // Entertainment — orange
    Color(0xFF3949AB),  // Shopping — indigo
    Color(0xFF757575),  // Other — grey
  ][index];

  String get label => const [
    'Food', 'Fuel', 'Groceries', 'Utilities',
    'Transport', 'Health', 'Entertainment', 'Shopping', 'Other',
  ][index];

  String get emoji => const [
    '🍔', '⛽', '🛒', '⚡', '🚗', '💊', '🎬', '🛍️', '📦',
  ][index];
}
```

---

## 10. Non-Functional Requirements

### 10.1 Performance

| Target | Implementation |
|---|---|
| 60 fps UI | Use `const` constructors everywhere possible; avoid rebuilding parent widgets for child state changes |
| Startup < 2s | Open Hive boxes in parallel (`Future.wait`); lazy-load screens |
| List performance | `ListView.builder` with `itemExtent` or `prototypeItem` for fixed-height rows |
| Animation budget | Use `flutter_animate` with durations ≤ 300ms; respect `MediaQuery.disableAnimations` |
| Memory | Dispose `TextEditingController`, `AnimationController`, and stream subscriptions in `dispose()` |

### 10.2 Accessibility

- All interactive elements have `Semantics` labels (use `Semantics` widget or `semanticLabel` property)
- Minimum touch target: 48×48 dp (enforce with `ConstrainedBox` or `SizedBox`)
- Color is never the sole conveyor of meaning (always pair with text or icon)
- Text scales correctly: avoid `textScaleFactor` overrides; test at 200% font size
- Screen reader order matches visual order; use `ExcludeSemantics` for decorative icons
- Sufficient contrast: verify with `Color Contrast Analyzer` — minimum 4.5:1 for normal text

### 10.3 Internationalization

- All user-visible strings extracted to `AppStrings` class (later: `flutter_localizations` + ARB files)
- Currency symbol and number formatting via `NumberFormat` from `intl` package
- Date formatting via `DateFormat` — no hardcoded locale strings
- Layout tested with longer strings (German-length simulation)
- RTL layout supported via `Directionality` — avoid hardcoded `left`/`right` padding; use `start`/`end`

### 10.4 Security (Phase 1 notes, implement in Phase 3+)

- Hive encryption with `HiveAesCipher` using a key stored in `FlutterSecureStorage`
- No sensitive data in logs (`debugPrint` stripped in release builds)
- Image files stored in app-private directory (not accessible to other apps on Android)
- Consider `BiometricStorage` for locking the app

---

## 11. Testing Plan & Acceptance Criteria

### 11.1 Unit Tests

| Test | Assertion |
|---|---|
| `HiveTaskRepository.add` | Task appears in `getAll()`, notification scheduled if due time set |
| `HiveTaskRepository.toggleComplete` | `isCompleted` flips; `completedAt` set; notification cancelled |
| `HiveExpenseRepository.getCategoryTotals` | Returns correct sum per category for given month |
| `HiveExpenseRepository.getMonthlyTotals` | Returns correct list for last N months, sorted descending |
| `todayTasksProvider` | Returns only tasks with `dueDate == today`, sorted by time |
| `currentMonthCategoryTotalsProvider` | Returns same result as repository method |
| `SeedData.load` | All 5 tasks, 3 schedule entries, 10 expenses loaded into Hive |

### 11.2 Widget Tests

| Test | Assertion |
|---|---|
| `TaskTile` | Shows title, due time, priority indicator; tapping navigates to detail |
| `TaskTile swipe right` | `toggleComplete` called; undo snackbar appears |
| `TaskTile swipe left` | Delete confirmation shown |
| `ExpenseForm` | Cannot submit with empty amount; submits with valid data |
| `CategoryPieChart` | Renders sections for each category with non-zero spend |
| `HomeScreen` | Shows correct task completion rate from provider |

### 11.3 Acceptance Criteria (Phase 1 Done)

- [ ] App launches in < 2 seconds on mid-range Android (cold start with seed data)
- [ ] CRUD works for tasks, schedule entries, and expenses (data persists across app restarts)
- [ ] Local notification fires within 60 seconds of scheduled time on both Android and iOS
- [ ] Home dashboard reflects actual data (not hardcoded)
- [ ] Analytics pie chart and bar chart render correctly with seed data
- [ ] Bill scanner screen accepts manual entry and saves as expense
- [ ] Dark mode applies correctly on all screens
- [ ] `flutter analyze` reports zero issues
- [ ] All unit and widget tests pass (`flutter test`)
- [ ] App runs on Android API 26+ and iOS 13+

---

## 12. Milestones & Phased Plan

### Phase 1 — Core MVP (Weeks 1–3)

**Goal:** Fully functional offline app with static seed data.

- [ ] Project scaffold with all folders, pubspec, analysis_options
- [ ] Hive models + generated adapters for all 4 entities
- [ ] Repository implementations (Hive-backed)
- [ ] Riverpod providers for tasks, schedule, expenses, analytics
- [ ] Notification service with task and schedule reminders
- [ ] go_router setup with shell route (bottom nav)
- [ ] All 7 screens: Home, Tasks, Schedule, Expenses, BillScanner (stub), Analytics, Settings
- [ ] Seed data loader
- [ ] Light + dark theme
- [ ] Core widget library (skeletons, empty states, error views)
- [ ] Unit tests for repositories and providers
- [ ] Widget tests for core tiles and forms
- [ ] README with setup instructions

**Deliverable:** `flutter run` works end-to-end; all acceptance criteria pass.

### Phase 2 — OCR, Search & Richer Analytics (Weeks 4–6)

- [ ] Enable OCR via `google_mlkit_text_recognition` behind `kOcrEnabled = true`
- [ ] Parse OCR output: amount extraction with regex, category suggestion
- [ ] Full-text search across tasks and expenses (`SearchDelegate` or custom)
- [ ] Filter panel: tasks by priority/tag/date range; expenses by category/date range
- [ ] Analytics: daily spend breakdown, running monthly budget vs actual
- [ ] Export: CSV export for expenses; plain text summary share

### Phase 3 — UI Polish, Accessibility & Performance (Weeks 7–8)

- [ ] Accessibility audit: semantic labels, contrast ratios, touch targets
- [ ] Animation pass: hero transitions, FAB morph, shared element for expense detail
- [ ] i18n: extract all strings to ARB, add one additional locale (Hindi as first target)
- [ ] Hive AES encryption with `flutter_secure_storage` key
- [ ] Performance profiling (DevTools): eliminate jank, reduce widget rebuilds
- [ ] Onboarding flow (3-screen carousel on first launch)
- [ ] App icon, splash screen, adaptive icon

### Phase 4 — Optional Sync & Cloud (Future)

- [ ] Evaluate Supabase vs Firebase Firestore for sync
- [ ] Conflict resolution strategy (last-write-wins for MVP)
- [ ] Google Sign-In for identity
- [ ] Backup/restore from cloud
- [ ] Multi-device sync
- [ ] Budget goal setting with push notifications for overruns

---

## 13. Setup & Run Instructions

### Prerequisites

```bash
flutter --version   # Must be ≥ 3.22.0
dart --version      # Must be ≥ 3.4.0
```

Android: Android Studio with SDK 26+, emulator or physical device
iOS: Xcode 15+, iOS Simulator or device (iOS 13+)

### Setup

```bash
# 1. Get dependencies
flutter pub get

# 2. Generate Hive adapters and Riverpod code
dart run build_runner build --delete-conflicting-outputs

# 3. Android: add notification permissions to AndroidManifest.xml
#    (see android/app/src/main/AndroidManifest.xml instructions below)

# 4. iOS: add permissions to Info.plist
#    (see ios/Runner/Info.plist instructions below)

# 5. Run
flutter run

# 6. Run tests
flutter test

# 7. Analyze
flutter analyze
```

### Android Manifest additions (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Inside <application> tag: -->
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
  </intent-filter>
</receiver>
```

### iOS Info.plist additions

```xml
<key>NSCameraUsageDescription</key>
<string>Used to scan receipts and bills</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Used to pick receipt images from your gallery</string>
```

---

## 14. GitHub Actions CI Stub

```yaml
# .github/workflows/ci.yml
name: Flutter CI

on: [push, pull_request]

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          channel: 'stable'
      - run: flutter pub get
      - run: dart run build_runner build --delete-conflicting-outputs
      - run: flutter analyze
      - run: flutter test --coverage
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info
```

---

## 15. Prompt Execution Instructions for the AI Model

When this document is fed to an AI code generation model, the model must:

1. **Generate ALL files** in the folder structure defined in Section 4.1 — no placeholders, no `// TODO` stubs (except explicitly noted OCR stubs)
2. **Make the project immediately runnable** — `flutter run` must succeed without code changes
3. **Populate all screens** with real widgets connected to providers — no lorem ipsum screens
4. **Include seed data loading** that works on first launch
5. **Write all tests** specified in Section 11 — they must all pass
6. **Follow Dart best practices:** named constructors, `const` where possible, `final` fields, proper `dispose()` patterns
7. **Use Material 3 components** throughout — no deprecated Material 2 widgets
8. **Respect the feature flag** `kOcrEnabled = false` — bill scanner must work without OCR in Phase 1
9. **Handle async errors gracefully** — every `AsyncValue` must handle loading, data, and error states
10. **Add dartdoc comments** to all public classes and methods

Output the files in this order:
`pubspec.yaml` → `analysis_options.yaml` → `lib/core/**` → `lib/data/**` → `lib/providers/**` → `lib/features/**` → `lib/shared/**` → `lib/app.dart` → `lib/main.dart` → `test/**` → `android/` patches → `ios/` patches → `README.md`

---

*End of prompt. Version 1.0 — Phase 1 MVP. Maintained by project team.*
