## Product Requirements & Architecture Document

Expense tracking and financial planning app built with Flutter 3.x and Firebase

### 1) Product overview

- **Vision**: Help individuals and groups effortlessly record daily expenses, plan toward financial goals, and gain insights via powerful analytics and AI coaching.
- **Design**: Modern, Material 3 UI with light/dark themes. Zero-friction UX—users should act by instinct without reading docs.
- **Platforms**: Android and iOS (Flutter 3.x).

### 2) Goals and non-goals

- **Goals**
  - **Instant capture**: Record an expense in ≤5 seconds with as few taps as possible.
  - **Financial planning**: Set and track personal or group goals; align expenses and income.
  - **Collaboration**: Groups with shared goals, real-time updates, fair splits, and permissions.
  - **Insights**: Analytics for spend, cashflow, trends, anomalies. AI-assist planning and suggestions.
  - **Trust & privacy**: Strong security model, transparent data use, and role-based access controls.
- **Non-goals**
  - Full accounting suite (e.g., double-entry bookkeeping).
  - In-app bank connections at MVP.

### 3) Target users and personas

- **Solo saver**: Tracks personal spending, wants quick capture and weekly insights.
- **Budget planner**: Plans monthly budgets and goals (e.g., emergency fund, travel).
- **Group collaborators**: Friends/family/teams tracking joint goals with expense sharing and notifications.

### 4) UX principles

- **Zero-friction entry**: Floating “+” button; smart defaults; last-used values; one-handed use.
- **Clear hierarchy**: Prominent daily total, month-to-date spend, and next upcoming goal milestone.
- **Predictable navigation**: Bottom nav for Home, Add, Analytics, Goals, Groups.
- **Progressive disclosure**: Show essentials first; advanced options (tags, splits, attachments) tucked away.
- **Accessible**: Large touch targets, color contrast, dynamic type, and VoiceOver/TalkBack support.
- **Invites to collaborate**: Human-readable group names, avatars, emoji, friendly empty states.

### 5) Core features

- **Expense capture**
  - Quick-add sheet with amount keypad, category, notes, optional photo receipt, tags, location, wallet.
  - Recurring expenses and templates.
  - Smart suggestions: auto-category from description or retailer.
- **Goals**
  - Personal and group goals with target amount/date; progress from income minus expenses in linked categories.
  - Recommendations to adjust budget or increase income.
- **Groups**
  - Create groups, invite members, assign roles, shared expenses/goals.
  - Expense splits (equal, weighted, itemized), settle-up tracking.
- **Analytics**
  - Time series spend/income, category breakdowns, cashflow, savings rate, burn rate.
  - Anomaly detection, monthly comparisons, top merchants/tags.
- **AI coach**
  - Personalized insights: “You overspent by 18% on dining this month.”
  - Goal tuning: adjust sub-budgets or suggest side-income ideas based on patterns.
  - “Ask AI” chat: financial Q&A using user’s spend context.

### 6) Information architecture and navigation

- **Bottom navigation**
  - Home, Add, Analytics, Goals, Groups
- **Global actions**
  - Floating “+” for expense/income/log transfer.
  - Profile/Settings from Home top-right.
- **Search and filters**
  - Search across transactions; filters for category, tag, date, amount, wallet, group.

### 7) Screen specifications

- **Onboarding**
  - Brief carousel; sign in with Google/Apple/Email; pick base currency and country; optional initial categories.
- **Home (Dashboard)**
  - Today’s spend, month-to-date spend vs budget, upcoming recurring charges, next goal milestone.
  - Quick-add and recent transactions.
- **Add transaction sheet**
  - Amount keypad, category chips, wallet selector, date/time, notes, tags, receipt photo, group toggle, split options.
  - Save and “Save & add another.”
- **Transaction detail**
  - Full info, attachments, split view (if group), edit/duplicate/delete.
- **Categories & budgets**
  - Default set (Food, Transport, etc.); create custom; per-category monthly budgets; color and emoji pickers.
- **Goals**
  - List and detail pages; progress bar; expected timeline; recommended actions; link to related categories or group.
- **Groups**
  - List user’s groups; group detail with members, shared expenses, settle-up, group goal(s); invite via link/QR.
- **Analytics**
  - Charts: spend over time, category distribution, cashflow, savings; comparisons; anomalies; export CSV/PDF.
- **AI coach**
  - Chat with AI using saved context and financial goals. Provide actionable suggestions and explain trade-offs.
- **Settings**
  - Profile, currency, wallets, reminders, theme (system/light/dark), security, data export, privacy controls.

### 8) Data model (Firestore)

- **Collections**
  - `users/{userId}`
    - `displayName`, `photoUrl`, `email`, `currency`, `country`, `settings`, `createdAt`, `appVersion`
  - `wallets/{walletId}` (subcollection under `users/{userId}`)
    - `name`, `type`, `currency`, `balance`, `isDefault`
  - `categories/{categoryId}` (subcollection under `users/{userId}`)
    - `name`, `emoji`, `color`, `type` ("expense" | "income"), `budgetMonthly`
  - `transactions/{txId}` (subcollection under `users/{userId}`) [Personal]
    - `amount`, `currency`, `type` ("expense" | "income" | "transfer"), `categoryId`, `walletId`, `note`, `tags[]`, `date`, `location`, `attachments[]`, `recurringRuleId?`, `aiCategoryConfidence?`
  - `recurringRules/{ruleId}` (subcollection under `users/{userId}`)
    - `interval` ("daily" | "weekly" | "monthly" | "custom"), `nextRunAt`, `templateTx` (partial transaction)
  - `goals/{goalId}` (subcollection under `users/{userId}`)
    - `name`, `targetAmount`, `targetDate`, `linkedCategories[]`, `currentProgress`, `autoCompute` (bool)
  - `groups/{groupId}` [Top-level]
    - `name`, `photoUrl`, `ownerId`, `currency`, `createdAt`
  - `groups/{groupId}/members/{userId}`
    - `role` ("owner" | "admin" | "member"), `joinedAt`
  - `groups/{groupId}/transactions/{txId}` [Shared]
    - `amount`, `currency`, `category`, `note`, `date`, `attachments[]`, `split` ({userId: share}), `createdBy`
  - `groups/{groupId}/goals/{goalId}`
    - `name`, `targetAmount`, `targetDate`, `currentProgress`, `linkedCategories[]`
  - `aiSessions/{sessionId}` (subcollection under `users/{userId}`)
    - `messages[]` (role, content, timestamp), `summary`, `lastUsedAt`
  - `insights/{insightId}` (subcollection under `users/{userId}`)
    - `type`, `message`, `severity`, `createdAt`, `data`
- **Indexes (examples)**
  - `users/*/transactions`: composite on `date DESC, categoryId` and single-field on `date`, `categoryId`, `tags`.
  - `groups/*/transactions`: composite on `date DESC` and single-field on `createdBy`.
- **Derived data**
  - Denormalized rollups per month for performance: `users/{userId}/rollups/{YYYY-MM}` with sums per category.

### 9) Firebase services

- **Authentication**: Email/Password, Google, Apple. App Check enabled.
- **Firestore**: Primary store; offline persistence enabled in client.
- **Storage**: Receipt images under `users/{userId}/receipts/{txId}` and `groups/{groupId}/receipts/{txId}`.
- **Cloud Functions**
  - Securely compute monthly rollups, goal progress, recurring job materialization, AI requests proxy, currency FX sync.
- **Cloud Scheduler + Pub/Sub**
  - Nightly rollups, recurring executions, weekly AI digest.
- **FCM**
  - Reminders (add expense, pay day, recurring due), group updates, goal milestones.
- **Remote Config**
  - Feature flags (e.g., AI coach on/off, experiment variants).
- **Analytics + BigQuery export**
  - Event funnels (tx_created, goal_created); cohorts; retention; A/B testing.
- **Crashlytics + Performance Monitoring**
  - Stability, cold start times, network traces.

### 10) Security & privacy

- **Principles**: Least privilege, server-side verification, data minimization for AI.
- **Firestore rules (sketch)**

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    function isSignedIn() { return request.auth != null; }
    function isUser(userId) { return isSignedIn() && request.auth.uid == userId; }

    match /users/{userId} {
      allow read, write: if isUser(userId);
      match /{sub=**} { allow read, write: if isUser(userId); }
    }

    match /groups/{groupId} {
      allow read: if isSignedIn() && exists(/databases/$(db)/documents/groups/$(groupId)/members/$(request.auth.uid));
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn() &&
        get(/databases/$(db)/documents/groups/$(groupId)/members/$(request.auth.uid)).data.role in ['owner','admin'];

      match /members/{memberId} {
        allow read: if isSignedIn();
        allow write: if isSignedIn() &&
          get(/databases/$(db)/documents/groups/$(groupId)/members/$(request.auth.uid)).data.role == 'owner';
      }

      match /transactions/{txId} {
        allow read, create: if isSignedIn() &&
          exists(/databases/$(db)/documents/groups/$(groupId)/members/$(request.auth.uid));
        allow update, delete: if isSignedIn() &&
          get(/databases/$(db)/documents/groups/$(groupId)/members/$(request.auth.uid)).data.role in ['owner','admin'];
      }

      match /goals/{goalId} {
        allow read, write: if isSignedIn() &&
          exists(/databases/$(db)/documents/groups/$(groupId)/members/$(request.auth.uid));
      }
    }
  }
}
```

- **Storage rules (sketch)**: Mirror Firestore permissions per path.
- **PII and AI**: Strip/remove direct identifiers; summarize data ranges instead of raw amounts when feasible; user consent and opt-out; data retention policy.

### 11) Architecture (Flutter)

- **Pattern**: Clean Architecture + BLoC, dependency injection via `GetIt`, routing via `GoRouter`.
- **Modules**
  - `core`: constants, theme, utils, widgets.
  - `features`: `transactions`, `goals`, `groups`, `analytics`, `ai`, `auth`, each split into `data/domain/presentation`.
  - **Project structure** (align with workspace guidance)
    - `lib/core/{constants,theme,utils,widgets}`
    - `lib/features/<feature>/{data,domain,presentation/{bloc,pages,widgets}}`
    - `lib/l10n/`, `lib/main.dart`
- **State management**: `flutter_bloc` for feature BLoCs; `hydrated_bloc` for UI state where appropriate.
- **Error handling**: Functional `Either<Failure, T>` for use cases and repositories.
- **Routing**: `GoRouter` with guarded routes for auth.

```dart
final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (c, s) => const HomePage()),
    GoRoute(path: '/add', builder: (c, s) => const AddTransactionPage()),
    GoRoute(path: '/analytics', builder: (c, s) => const AnalyticsPage()),
    GoRoute(path: '/goals', builder: (c, s) => const GoalsPage()),
    GoRoute(path: '/groups', builder: (c, s) => const GroupsPage()),
  ],
  redirect: (c, s) => isLoggedIn ? null : '/login',
);
```

- **DI example**

```dart
final sl = GetIt.instance;

void setup() {
  sl.registerLazySingleton<TransactionsRepository>(() => FirestoreTransactionsRepository(sl()));
  sl.registerFactory(() => AddTransactionUseCase(sl()));
  sl.registerFactory(() => TransactionsBloc(sl(), sl()));
}
```

- **Theme and dark mode**

```dart
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);
  void set(ThemeMode mode) => emit(mode);
}
```

### 12) Offline-first and sync

- Enable Firestore offline persistence; queue writes locally; reconcile on reconnect.
- Local caching of categories, wallets, and templates.
- Merge strategy: last-write-wins for transactions; functional reconciliation for splits.

### 13) Performance & scalability

- Use composite indexes for common queries; paginate via `limit/startAfter`.
- Memoize heavy chart computations; precompute monthly rollups in Functions.
- Image compression for receipts; lazy-load images; cache network images.
- Avoid rebuilding entire lists; use `ListView.builder`/`SliverList`, `AutomaticKeepAliveClientMixin` for tabs.

### 14) Internationalization and currency

- **i18n**: ARB localization files in `lib/l10n/`; RTL support.
- **Currency**
  - Store transactional amounts in minor units; store currency code per tx.
  - Convert to user’s base currency for analytics via daily FX rates cached in Firestore by Functions.

### 15) Notifications

- Reminder to log expenses (smart: post-transaction times, commute end, etc.).
- Recurring payment reminders, group expense added, goal milestone reached.
- Deep links to related screen.

### 16) AI integration

- **Architecture**
  - Cloud Function proxy for AI provider (e.g., Vertex AI, or OpenAI through GCP). Never call model directly from client.
  - Input: user’s anonymized aggregates/rollups + user question/intent.
  - Tools/function-calling for calculations: budget adjustment, projection, “what-if.”
- **Use cases**
  - Monthly insights digest, anomaly reasons, personalized saving opportunities.
  - Goal tuning (adjust per-category budgets with rationale).
- **Cost control**
  - Truncate context to aggregates; cache previous answers; Remote Config to throttle.

### 17) Cloud Functions (examples)

- **Monthly rollup**

```ts
export const onTxWrite = functions.firestore
	.document("users/{userId}/transactions/{txId}")
	.onWrite(async (change, ctx) => {
		// Recompute monthly totals and category breakdowns
	});
```

- **Recurring materializer**

```ts
export const materializeRecurring = functions.pubsub
	.schedule("every 24 hours")
	.onRun(async () => {
		// Find due rules and create transactions
	});
```

- **AI proxy**

```ts
export const aiSuggest = functions.https.onCall(async (data, ctx) => {
	// Verify auth, fetch aggregates, call model, return suggestions
});
```

### 18) Testing strategy

- **Unit**: Use-cases, repositories with Firebase emulator and mocks.
- **Widget**: Add-sheet flows, charts render, accessibility semantics.
- **Integration**: Sign-in, add transaction, group invite, goal progress update.
- **Golden tests**: Critical UI states for light/dark themes.
- **Performance**: Frame build budget and cold start benchmarks.

### 19) CI/CD and quality

- **CI**: Static analysis (`flutter analyze`), tests, coverage gates, formatting.
- **CD**: Build pipelines, Firebase App Distribution for internal QA, staged rollout.
- **Feature flags**: Rollout risky features (AI, anomalies) via Remote Config.

### 20) Analytics (product)

- **Key events**: `tx_add`, `tx_edit`, `goal_create`, `goal_complete`, `group_create`, `split_settle`, `ai_chat_open`, `ai_reply_useful`.
- **KPIs**
  - D1/D7 retention, WAU/MAU
  - Median time-to-add (target <5s)
  - Monthly active goal users
  - % transactions categorized automatically
  - AI engagement and satisfaction (thumbs up/down)

### 21) Accessibility and compliance

- WCAG AA contrast, scalable text, semantic labels, focus order.
- Privacy policy and consent for analytics and AI data use.
- Data export and account deletion flows.

### 22) Monetization (optional)

- Free core; Premium: advanced analytics, unlimited groups, custom reports, priority AI. Use Play/App Store billing or `RevenueCat`.

### 23) Release plan

- **MVP**: Auth, quick-add, categories, basic analytics, goals, single group, dark/light mode.
- **V1**: Recurring expenses, advanced analytics, AI coach (beta), settle-up.
- **V2**: Multi-currency analytics, anomaly detection, CSV import/export, more AI tools.

### 24) Visual and interaction design notes

- **Material 3**: Use dynamic color (Android 12+); custom seed color otherwise.
- **Light/Dark**: Toggle in `Settings`; default to system theme.
- **Micro-interactions**: Haptic feedback on save, Lottie animation celebration on goal milestones.
- **Charts**: Smooth, interactive; tap-to-drill down; consistent color mapping per category.

### 25) Example Flutter theming setup

```dart
final lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6), brightness: Brightness.light),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

final darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3B82F6), brightness: Brightness.dark),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
```

### 26) Example BLoC for quick-add transaction

```dart
class AddTxState {
  final int amountMinor;
  final String categoryId;
  final String? note;
  final DateTime date;
  final bool isSaving;
  final Option<Failure> failure;
  AddTxState({required this.amountMinor, required this.categoryId, this.note, required this.date, this.isSaving = false, this.failure = const None()});
}

class AddTxCubit extends Cubit<AddTxState> {
  AddTxCubit() : super(AddTxState(amountMinor: 0, categoryId: '', date: DateTime.now()));
  void setAmount(int minor) => emit(AddTxState(amountMinor: minor, categoryId: state.categoryId, note: state.note, date: state.date));
  // ...
  Future<void> save() async {
    emit(AddTxState(amountMinor: state.amountMinor, categoryId: state.categoryId, note: state.note, date: state.date, isSaving: true));
    // call usecase -> repo -> Firestore
  }
}
```

### 27) Example Firestore query patterns

- **Latest transactions**: order by `date` desc, `limit(20)`, paginate with `startAfter`.
- **Monthly category totals**: read `rollups/{YYYY-MM}`; fallback to client compute if missing.
- **Group feed**: listen to `groups/{id}/transactions` with `orderBy('date', descending: true)`.

### 28) Risks and mitigations

- **AI hallucinations**: Keep suggestions advisory with confidence notes; allow user feedback and flagging; evaluate with guardrails.
- **Costs (AI/Firestore)**: Rollups to reduce reads; cache; throttle; Remote Config kill-switch.
- **Privacy**: Default AI off for minors or sensitive locales; explicit opt-in; never expose raw PII to models.

---

### Deliverables checklist

- **Design system**: M3 tokens, light/dark themes, components.
- **Feature specs**: All screens and flows above.
- **Data contracts**: Firestore collections/fields, Storage paths, Functions I/O.
- **Security**: Firestore and Storage rules.
- **CI/CD**: Pipelines with analyzers, tests, distributions.
- **Telemetry**: Analytics events and KPIs.
- **Docs**: Privacy, consent, data export/delete, support.

---

### Phased Development Checklist (from zero to MVP and beyond)

#### Phase 0 — Foundations and Project Setup

- [ ] Create product backlog aligned to `scope.md` features; prioritize MVP items
- [ ] Name the app/bundle IDs; reserve app icons, branding assets
- [x] Initialize Flutter 3.x project; enforce analysis options and formatting
- [x] Set up package structure: `core/`, `features/`, `l10n/`, `main.dart`
- [x] Add core dependencies: `flutter_bloc`, `go_router`, `get_it`, `intl`, `equatable`, `firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage`, `firebase_messaging`, `firebase_crashlytics`, `firebase_analytics`, `hydrated_bloc`, `freezed`/`json_serializable` (if used)
- [ ] Configure Firebase projects: dev/staging/prod with distinct configs
- [x] Add Firebase Emulators; scripts for `emulators:start` and test data seeding
- [x] CI bootstrap: build, `flutter analyze`, tests; artifact caching
- [x] Define coding standards and PR checklist; add templates
- [ ] Create initial Firestore/Storage rules placeholders (locked down) and enable App Check

Definition of Done:

- [ ] Repository builds green on CI for `main`
- [ ] Firebase projects created and linked; emulators working locally
- [ ] Linting/formatting and pre-commit hooks active

#### Phase 1 — Design System & App Shell

- [x] Implement Material 3 light/dark themes with seed color
- [x] Theme toggle: system/light/dark via `ThemeCubit`; persist choice
- [ ] Typography, spacing, elevation, iconography tokens
- [ ] Base widgets: primary button, form field, sheet, list tile, chart container
- [x] Navigation shell: bottom nav (Home, Add, Analytics, Goals, Groups)
- [x] `GoRouter` routes and guarded placeholders
- [x] Localization scaffold: `lib/l10n/*.arb`, English strings, locale switch
- [ ] Accessibility defaults: contrast, text scale, touch target sizes

Definition of Done:

- [x] Navigable shell with themed components in light/dark
- [x] Localization compiles with at least one ARB file
- [ ] Accessibility checks pass for base screens

#### Phase 2 — Authentication & User Profile

- [x] Integrate Firebase Auth (Email/Password, Google; Apple for iOS when provisioning ready)
- [x] Onboarding: sign-in + base currency/country; optional default categories
- [x] Create `users/{uid}` doc on first login; persist settings
- [x] App Check enabled across services (Debug for dev; Play Integrity/App Attest for release)
- [x] Auth-guarded routes; sign-out flow; session handling
- [x] Crashlytics set up with user identifiers (privacy-safe)
- [x] Analytics core events: `login`, `sign_up`, `app_open`

Definition of Done:

- [x] Users can sign in/out; profile persisted with currency/country
- [x] Auth guards redirect properly; App Check enforced

#### Phase 3 — Data Model & Rules (MVP scope)

- [ ] Finalize MVP Firestore structures: users, categories, wallets, transactions, goals
- [x] Write Firestore rules for `users/{uid}` subcollections
- [x] Create initial composite indexes (transactions by date, etc.)
- [x] Storage paths and rules for receipt images
- [ ] Add typed models, JSON mappers, validators
- [x] Repository interfaces + Firestore implementations (Transactions, Categories)
- [ ] Emulator tests for CRUD + security rules

Definition of Done:

- [ ] CRUD works locally and passes emulator-based tests
- [ ] Rules deny unauthorized cross-user access

#### Phase 4 — Expense Capture (MVP Core)

- [x] Quick-add sheet: amount, type, category, note (initial)
- [x] Save & “Save another” flow (initial)
- [x] Recent transactions list (initial stream)
- [x] Edit transaction screen; duplicate transaction
- [ ] Tags support (simple string list)
- [ ] Offline write queue; reconcile on reconnect
- [ ] Unit/widget tests: add/edit/delete flows; time-to-add budget

Definition of Done:

- [ ] Add/edit/delete in ≤5 seconds for average user; tests cover core paths

#### Phase 5 — Categories & Budgets

- [ ] Default category seed; custom categories CRUD
- [ ] Per-category monthly budget setting
- [ ] Home tiles: Today, Month-to-Date vs Budget, Over/Under indicators
- [ ] Color/emoji pickers and consistent category color mapping
- [ ] Tests for budget calculations and category CRUD

Definition of Done:

- [ ] Category budgets reflected on Home; over/under budget states accurate

#### Phase 6 — Goals (Personal)

- [ ] Create goal: target amount/date; link categories
- [ ] Progress computation from income minus expenses in linked categories
- [ ] Goal detail view: progress bar, ETA, milestone state
- [ ] Basic recommendations placeholder (non-AI): “Reduce dining by X%”
- [ ] Tests for goal math and state transitions

Definition of Done:

- [ ] Users can create goals and see accurate progress and ETA

#### Phase 7 — Analytics (Basic)

- [ ] Charts: spend over time (month), category breakdown
- [ ] Summary KPIs: total spend, avg/day, top category
- [ ] CSV export for transactions (current month)
- [ ] Memoization/caching for charts; pagination-friendly queries
- [ ] Widget tests: chart renders; data states (empty/loading/error)

Definition of Done:

- [ ] Analytics page loads under 500ms after data cached; export works

#### Phase 8 — Groups (MVP-Lite)

- [ ] Create group; invite via link/QR (basic links; deep link optional)
- [ ] Roles: owner/admin/member; membership management
- [ ] Add shared transaction to group; equal split
- [ ] Group feed and totals; badge for unsettled balance (no full settle engine yet)
- [ ] Firestore rules for group access; emulator tests

Definition of Done:

- [ ] Members can add/view group transactions; access controlled by membership

#### Phase 9 — Notifications & Reminders

- [ ] FCM setup; device token registration
- [ ] Local reminder nudge (daily/weekly custom)
- [ ] Deep links to Add sheet and Group detail
- [ ] Notification permission prompts and settings

Definition of Done:

- [ ] Users receive reminders and can open directly to target screens

#### Phase 10 — Quality, Accessibility, Performance

- [ ] Empty/error/loading states across all screens
- [ ] Accessibility pass (TalkBack/VoiceOver labels, focus order, semantic actions)
- [ ] Performance: list virtualization, image compression, chart throttling
- [ ] Crash-free rate > 99.5% in internal testing
- [ ] Log KPIs: `tx_add`, `goal_create`, nav events

Definition of Done:

- [ ] Meets accessibility targets; smooth 60fps in typical interactions

#### Phase 11 — CI/CD & Distribution

- [ ] CI gates: format, analyze, tests, coverage threshold
- [ ] Build variants: dev/staging/prod; flavors configured
- [ ] Firebase App Distribution: internal testers channel
- [ ] Versioning, changelog, release checklist template

Definition of Done:

- [ ] One-click pipeline produces signed builds and distributes to testers

#### Phase 12 — MVP Gate & Launch Prep

- [ ] MVP acceptance review against `scope.md` MVP list
- [ ] Privacy policy, data export/delete instructions
- [ ] Store listing assets; screenshots (light/dark), descriptions, keywords
- [ ] Internal and closed testing submissions (Play/App Store)

Definition of Done:

- [ ] MVP released to closed testing; feedback loop active

---

### Post-MVP (V1) — Depth and Intelligence

- [ ] Recurring Transactions
  - [ ] UI to create recurring rules; preview upcoming occurrences
  - [ ] Cloud Scheduler job to materialize due transactions
  - [ ] Tests for schedule edge cases and timezone handling
- [ ] Monthly Rollups (Functions)
  - [ ] On-write trigger to update `rollups/{YYYY-MM}` per user
  - [ ] Backfill function for historical months
  - [ ] Analytics page reads rollups primarily
- [ ] Advanced Analytics
  - [ ] Cashflow and savings rate; monthly comparisons
  - [ ] Top merchants/tags; filters/segments
  - [ ] Export PDF summary report
- [ ] AI Coach (beta)
  - [ ] Consent UI; AI toggle in Settings; Remote Config kill switch
  - [ ] Callable function proxy; context limited to aggregates
  - [ ] Goal tuning suggestions with rationale and confidence
  - [ ] Throttling and caching; cost monitoring
  - [ ] Feedback loop: thumbs up/down events
- [ ] Group Settlements (phase 1)
  - [ ] Balance calculation per member; suggested minimal payments
  - [ ] Mark as settled; activity log
  - [ ] Optional reminders to settle
- [ ] Data Import/Export
  - [ ] CSV import with mapping to categories
  - [ ] Full export of user data (ZIP) from Settings
- [ ] Settings Polish
  - [ ] Wallets CRUD; default wallet choice
  - [ ] More reminders and quiet hours
  - [ ] Theme and accessibility preferences persistence

Definition of Done:

- [ ] AI insights available (opt-in), recurring/rollups stable, settlements usable end-to-end

### V2 — Scale, Multi-Currency, and Monetization

- [ ] Multi-Currency Analytics
  - [ ] FX daily rates updater (Function) and caching
  - [ ] Convert analytics to base currency; per-wallet currency support
- [ ] Anomaly Detection
  - [ ] Heuristics to flag unusual spikes; explainable reasons
  - [ ] User controls to mute categories or merchants
- [ ] Advanced Splits & Receipts
  - [ ] Weighted and itemized splits; OCR for receipts (optional)
  - [ ] Attachment gallery; offline receipt queue
- [ ] Group Management & Audit
  - [ ] Invitations with expiry; role promotion/demotion
  - [ ] Audit log for sensitive actions
- [ ] Offline-first & Conflict Resolution Polish
  - [ ] Conflict UI for edits; merge strategies for splits
- [ ] Experiments & Feature Flags
  - [ ] Remote Config experiments on add-flow variants
  - [ ] BigQuery export analysis dashboards
- [ ] Monetization
  - [ ] RevenueCat (or StoreKit/Billing) integration
  - [ ] Premium gating: advanced analytics, unlimited groups, AI quota
  - [ ] Paywall, restore purchases, entitlements sync
- [ ] Compliance & Support
  - [ ] In-app data deletion/export flows automated
  - [ ] Updated privacy terms; regional consent modules
  - [ ] Support center links; contact form

Definition of Done:

- [ ] Premium tier live; multi-currency analytics and anomalies shipped

### Continuous Workstreams

- [ ] QA automation: widget tests for critical flows; golden tests light/dark
- [ ] Observability: performance traces, error budgets, crash monitoring
- [ ] Security posture: dependency updates, rules reviews, secrets rotation
- [ ] Product analytics: dashboards for KPIs; retention and engagement

### MVP Acceptance Criteria (quick checklist)

- [ ] Auth with onboarding (currency/country) and profile saved
- [ ] Quick-add/edit/delete expense in ≤5s; offline capable
- [ ] Categories with budgets; Home shows MTD vs budget
- [ ] Personal goals with progress and ETA
- [ ] Basic analytics (time series + category breakdown) and CSV export
- [ ] Groups (create, invite, add shared tx, equal split, access control)
- [ ] Notifications for reminders; deep links to Add/Group
- [ ] Light/dark theme; accessible UI
- [ ] CI/CD pipeline; internal distribution; crash-free rate ≥99.5%

---

### Pre‑Kickoff Addendum: Guardrails and Zero‑Cost MVP Constraints

#### Non‑Functional Requirements (NFRs)

- Performance: cold start ≤ 2.5s on mid‑range devices; frame budget ≤ 16ms; charts render < 300ms after data cached.
- Reliability: crash‑free sessions ≥ 99.5% (internal testing); offline correctness for add/edit/delete transactions.
- Size: initial APK/IPA ≤ 25 MB target; images and assets optimized.
- Accessibility: WCAG AA contrast; dynamic type; semantics for major controls; focus order verified.
- Offline guarantees: add/edit/delete transactions, browse cached lists, create categories, and set budgets fully offline; sync within 10s of reconnect; last‑write‑wins for transactions; per‑member reconciliation for group splits in v1.

#### Domain & Finance Rules

- Amounts stored in minor units (e.g., cents) as integers; UI formats via currency code.
- Timezone: store timestamps in UTC; display in device timezone; month boundaries from user locale.
- Fiscal months: MVP uses calendar months; optional fiscal start day in later versions.
- Transaction types: `expense`, `income`, `transfer`; transfers require source and destination wallet IDs; excluded from net spend.
- Rounding: round half‑up to nearest minor unit; split remainders distributed to earliest members by UID (deterministic).
- Categories: single depth; rename allowed; merging creates alias mapping; historical reassignment tool post‑MVP.
- Budgets: monthly; no rollover in MVP; proration when joining mid‑month (days remaining / total days).

#### Groups & Settlements

- Roles: `owner`, `admin`, `member`. Owner can transfer ownership; admins manage members/content; members add/view content.
- Invitations: link with 7‑day expiry; regenerating invalidates old links; client‑side rate limiting per group.
- Splits: MVP equal splits only; rounding handled as above; itemized/weighted splits post‑MVP.
- Settlements: tracked as special records (no funds movement); minimal cash‑flow algorithm targeted for V1; activity log per action.
- Deletion: soft delete via `deletedAt`; clients filter; hard delete available via export/delete flow.

#### AI Integration (Zero‑Cost MVP)

- MVP uses a client‑side heuristic “Insight Engine” (rule‑based): overspend vs budget, trending categories, month‑end risk, savings tips.
- Architecture: `AiCoach` interface with `HeuristicAiCoach` (offline, default) and `CloudAiCoach` (post‑MVP, behind flag).
- Optional local model adapter (advanced users): on‑device inference via platform channels; disabled by default.
- Cost controls: AI defaults OFF; when ON, runs offline only; no external API calls in MVP.
- Safety: redact PII in generated text by default; user can opt‑in to include merchant names.

#### Security, Privacy, Compliance

- Data classification: email/displayName (PII), transactions (financial), receipts (sensitive images).
- Encryption: in transit (TLS) and at rest (Firebase defaults); device at‑rest relies on OS encryption; no custom KMS in MVP.
- Access control: Firestore Rules enforce per‑user and per‑group access; App Check enabled; client throttling for invites/joins.
- Privacy: consent for analytics/notifications in onboarding; in‑app account deletion and data export stubs in MVP.
- Platform compliance: Sign in with Apple when Apple sign‑in is offered; store account‑deletion policy satisfied.

#### Analytics & Observability (Free‑Only)

- Use Firebase Analytics (free) for events; no BigQuery export in MVP.
- Event taxonomy: `snake_case` names, typed params; user properties include `app_version`, `spec_version`.
- Crashlytics and Performance Monitoring (free) for stability/cold start/network traces.
- In‑app debug console (dev builds) to inspect recent analytics events.

#### Design System Expansion

- Tokens: color (light/dark), type scale, spacing, radii, elevation, motion (durations/easing).
- Components: buttons, chips, inputs, list tiles, cards, banners, charts with state specs.
- Motion & haptics map: save success, budget warning, goal celebration.
- Parity: golden tests for light/dark on Home, Add, Analytics, Goals, Groups.

#### Localization & Currency

- MVP language: English; ARB scaffolding ready; RTL smoke tests on key screens.
- Formatting via `intl`: currency/number/date; configurable week start in Settings.

#### Testing Strategy Gates

- Coverage: unit ≥ 70% (domain/usecases); widget ≥ 60% (critical flows).
- CI emulator tests: Firestore rules and repository CRUD with seeded fixtures.
- Performance checks: scroll jank budget; chart render under load; accessibility audits in CI.

#### Release & Environment Management (Free‑Friendly)

- Flavors: `dev`, `staging`, `prod` using `--dart-define` for Firebase configs.
- Firebase plan: Spark (free) for MVP; avoid Cloud Functions/Scheduler/BigQuery in production MVP.
- Client‑side compute: monthly rollups and recurring reminders run on device; background tasks where allowed by platform.
- Secrets: none stored in repo; only public Firebase configs; no AI API keys in MVP.
- Rollback: staged internal distribution; revert by version.

#### Monetization (Post‑MVP)

- MVP entirely free. Post‑MVP: define entitlements for advanced analytics, unlimited groups, AI quota; integrate store billing later.

#### Notifications Policy

- Channels: reminders (expenses), group updates, goal milestones; user‑toggle per channel.
- Quiet hours: default 22:00–07:00 local; configurable.
- Frequency caps: max 1 reminder/day; batch group updates when possible.

#### Cost‑Avoidance Summary for MVP

- No paid cloud compute: omit Cloud Functions/Scheduler/BigQuery.
- Use only free Firebase tiers: Auth, Firestore, Storage, Analytics, Crashlytics, Performance, FCM.
- Perform heavy compute locally; cache/memoize to reduce reads/writes and chart cost.

---

### Decision Log

- Branding/name: App name is "OMNI". Logo: minimalist circle mark in black and white, formal/tech tone, modern and clean.
- Platforms: Target latest widely available Android and iOS releases; primary design for phone screens with adaptive layouts for larger devices.
- Regions/currency: Initial launch in Indonesia/Malaysia. Default currency detected from locale/store region if possible, otherwise `IDR`. Users can change currency; multi‑currency analytics can be deferred if complex at MVP.
- Categories/taxonomy: Use a popular default taxonomy (Food, Transport, Bills, Housing, Groceries, Dining, Shopping, Entertainment, Health, Education, Travel, Utilities, Others). Include essential tags; no strict tag list.
- Budgets/goals defaults: Budgets ON by default; fully user‑customizable later.
- Groups: Max 12 members; invite via link code acceptable for MVP.
- AI: MVP uses rule‑based, on‑device insights only. Show “not financial advice” disclaimer.
- Analytics/privacy: Analytics ON by default with in‑app toggle.
- Notifications: Daily reminders if user missed logging; quiet hours default 22:00–07:00 local (configurable).
- Legal/compliance: Use standard store compliance; include privacy policy and “not financial advice” copy; no bespoke legal text required.
- CI/CD & accounts: Developer has Apple/Google accounts; prioritize guidance for prototyping and deployment; iPhone available for testing.
- Environments/regions: Firebase projects for dev/staging/prod in Southeast Asia region (`asia-southeast1` preferred).
- Data export/delete: CSV export and account deletion request sufficient at MVP.
- Performance targets: Defaults in NFRs accepted.
- Design references: Aim for minimalist, clear, complete UI similar in spirit to shadcn/ui; avoid clutter; keep intuitive and purposeful.

---

### Environment Setup Plan (Zero‑Cost MVP, SEA)

#### 1) Local prerequisites

- Install Flutter 3.x (stable), Android Studio (SDK + platform tools), Xcode (for iOS on macOS), CocoaPods, and Java 17.
- Install VS Code or Android Studio plugins for Flutter/Dart.
- Verify: `flutter doctor -v` is green.

#### 2) Repository structure and flavors

- Single app repository with flavors: `dev`, `staging`, `prod` using `--dart-define ENV={dev|staging|prod}`.
- Directory layout after init:
  - `lib/` with `core/`, `features/`, `l10n/`, `main.dart`.
  - `assets/` for icons, images, lottie; `fonts/` if needed.
  - `analysis_options.yaml`, `.vscode/` tasks/launch configs.

#### 3) Firebase projects (Spark/free plan)

- Create 3 projects in SEA: `omni-dev`, `omni-staging`, `omni-prod` (region `asia-southeast1`).
- Register Android app (package `app.omni.dev|staging|prod`) and iOS bundle IDs (`app.omni.dev|staging|prod`).
- Enable services: Auth (Email, Google, Apple later), Firestore (native mode), Storage, Analytics, Crashlytics, FCM, App Check.
- Download and place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) into platform folders per flavor (added later).
- MVP avoids Cloud Functions/Scheduler/BigQuery to stay free.

#### 4) Flutter + Firebase integration

- Use FlutterFire CLI to generate `firebase_options.dart` per environment (requires `firebase-tools` + CLI login).
- For now, code reads `ENV` via `const String.fromEnvironment('ENV')` to select options; default `dev` if absent.
- App Check: enable Debug provider for dev; Play Integrity/DeviceCheck for prod (both free).

#### 5) Packages (initial)

- Runtime: `flutter_bloc`, `hydrated_bloc`, `go_router`, `get_it`, `intl`, `equatable`.
- Firebase: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_analytics`, `firebase_crashlytics`, `firebase_messaging`.
- Modeling/build: `freezed_annotation`, `json_annotation`; dev: `build_runner`, `freezed`, `json_serializable`.

#### 6) Theming, routing, localization

- Implement Material 3 themes (light/dark) with `ThemeCubit`; system default.
- Setup `GoRouter` with guarded routes and bottom navigation shell.
- Add `lib/l10n/` with `en.arb`; wire `Intl`.

#### 7) Emulators and local testing

- Use Firebase Emulators (Auth, Firestore, Storage, Functions placeholder) for local dev.
- Seed test data scripts for categories, transactions, and a sample group.

#### 8) CI/CD (free tiers)

- GitHub Actions: build, `flutter analyze`, tests on push/PR; cache pub artifacts.
- Optional: Firebase App Distribution (free) for internal testing builds (Android/iOS when signing ready).

#### 9) Branding and icons

- Start with minimalist black/white circle icon from an open library; replace later with designer asset.
- Generate adaptive icons using `flutter_launcher_icons` (dev tool run locally).

#### 10) Defaults per Decision Log

- Locale → currency default (IDR fallback), budgets ON by default, groups capped at 12, analytics + daily reminders ON with quiet hours (22:00–07:00), AI heuristic engine OFF by default but available offline.
