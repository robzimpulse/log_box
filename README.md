# LogBox

LogBox is a powerful, modular logging framework for Flutter applications, designed to help developers capture, store, and visualize application logs efficiently. The core package lives in this repository; each logger extension lives in its own repository, so you include only the loggers you need.

## Core Features
- **Modular Design:** Keep your core app lightweight by choosing only necessary extensions.
- **Persistent Storage:** Built-in support for persistent logging using [Drift](https://drift.simonbinder.eu/).
- **Network Logging:** Specialized extension for capturing [Dio](https://pub.dev/packages/dio) traffic.
- **Navigation Logging:** Track [Navigator](https://api.flutter.dev/flutter/widgets/Navigator-class.html) and [GoRouter](https://pub.dev/packages/go_router) events.
- **WebView Logging:** Capture events from [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview).
- **In-App Dashboard:** Built-in UI to view and filter logs directly within your application.

---

## 🏗 Architecture

This repository contains the **core** `log_box` package (at the repo root) and an `example/` app.

- **`lib/`**: The core framework. Defines storage interfaces, base models, and the UI dashboard.
- **`example/`**: Integration project showcasing all loggers and storage configurations.

### Related repositories

| Package | Repository | Purpose |
| :--- | :--- | :--- |
| `log_box_dio_logger` | https://github.com/robzimpulse/log_box_dio_logger | Captures Dio network traffic |
| `log_box_navigation_logger` | https://github.com/robzimpulse/log_box_navigation_logger | Captures Navigator/GoRouter events |
| `log_box_in_app_webview_logger` | https://github.com/robzimpulse/log_box_in_app_webview_logger | Captures `flutter_inappwebview` events |
| `log_box_persistent_storage_drift` | https://github.com/robzimpulse/log_box_persistent_storage_drift | Persistent storage using Drift |

---

## 📦 Installation

Packages are not published to pub.dev; depend on them via git tags:

```yaml
dependencies:
  log_box:
    git:
      url: https://github.com/robzimpulse/log_box.git
      ref: v0.1.0
  log_box_dio_logger:
    git:
      url: https://github.com/robzimpulse/log_box_dio_logger.git
      ref: v0.0.1
```

> **Migrating from the monorepo:** `log_box` moved from `packages/log_box` to the repository root. Remove `path: packages/log_box` from your git dependency and pin a tag instead of `master`.

---

## 📋 Prerequisites

- **FVM (Flutter Version Management):** Recommended for managing Flutter versions.
- **Flutter SDK:** 3.32.8 (pinned in `.fvmrc`).
- **Dart SDK:** ^3.8.0.
- **make**

---

## 🚀 Local Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/robzimpulse/log_box.git
   cd log_box
   ```

2. **Install Flutter version (if using FVM):**
   ```bash
   fvm install
   ```

3. **Fetch dependencies** (core + example):
   ```bash
   make get
   ```

4. **Generate code** (JSON serialization):
   ```bash
   make generate
   ```

5. **Run the example app:**
   ```bash
   cd example
   fvm flutter run
   ```

Run `make` to list all targets. Pass `FLUTTER="fvm flutter"` / `DART="fvm dart"` to use the FVM-pinned SDK, e.g. `make test FLUTTER="fvm flutter"`.

---

## 📖 How to Use

### 1. Initialization

Initialize `LogBox` in your `main.dart`. If you want persistent storage, use `DriftPersistentStorage`.

```dart
final box = LogBox(
  storage: Storage(
    liveDataStorage: MemoryStorage(capacity: 100),
    persistentDataStorage: DriftPersistentStorage(
      executor: NativeDatabaseExecutor(), // Use MemoryExecutor for testing
      decoder: {
        (LogEntryModel).toString(): LogEntryModel.fromJson,
        (NetworkEntryModel).toString(): NetworkEntryModel.fromJson,
        // Add other models as needed
      },
    ),
  ),
);
```

### 2. Integration with Dio

```dart
final dio = Dio()..interceptors.add(box.interceptor);
```

### 3. Manual Logging

```dart
box.log('User performed an action');
```

### 4. Show Dashboard

LogBox includes a built-in dashboard to view your logs.

```dart
box.dashboard(context: context);
```

---

## 🛠 Troubleshooting

### Manual Model Registration
Drift storage requires a `decoder` map to deserialize JSON blobs back into Dart models. If you add a new loggable model, you **must** add its `fromJson` factory to the `decoder` map during `LogBox` initialization.

### Drift Schema Migrations
Drift tables live in [log_box_persistent_storage_drift](https://github.com/robzimpulse/log_box_persistent_storage_drift). Generate migrations there with:
```bash
make generate-migration
```

### FVM Sync Issues
If dependencies or Flutter versions get desynced, clean and re-fetch:
```bash
make refresh
```

### Extension Type Usage
The project leverages Dart 3.x Extension Types. Ensure your IDE is using the Flutter version specified in `.fvmrc` to avoid syntax errors.

---

## 🧪 Testing

```bash
make test           # unit tests
make coverage       # unit tests with coverage/lcov.info
make analyze        # static analysis (core + example)
make format-check   # formatting check
```

CI (`.github/workflows/unit-test.yaml`) runs tests, coverage diff and lint on every PR and push to `master`.

---

## 🏷 Releasing

1. In a PR, bump `version:` in `pubspec.yaml` and add a matching `## <version>` section to `CHANGELOG.md`.
2. Merge it. `.github/workflows/release.yaml` runs the release gate (analyze, format check, tests) and creates the `v<version>` tag and GitHub Release.

The release fails if `CHANGELOG.md` has no section for the new version.
