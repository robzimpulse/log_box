# LogBox

LogBox is a powerful, modular logging framework for Flutter applications, designed to help developers capture, store, and visualize application logs efficiently. It follows a modular monorepo architecture, allowing you to include only the loggers you need.

## Core Features
- **Modular Design:** Keep your core app lightweight by choosing only necessary extensions.
- **Persistent Storage:** Built-in support for persistent logging using [Drift](https://drift.simonbinder.eu/).
- **Network Logging:** Specialized extension for capturing [Dio](https://pub.dev/packages/dio) traffic.
- **Navigation Logging:** Track [Navigator](https://api.flutter.dev/flutter/widgets/Navigator-class.html) and [GoRouter](https://pub.dev/packages/go_router) events.
- **WebView Logging:** Capture events from [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview).
- **In-App Dashboard:** Built-in UI to view and filter logs directly within your application.

---

## 🏗 Architecture

The project is managed as a monorepo using [Melos](https://melos.invertase.dev/).

- **`packages/log_box`**: The core framework. Defines storage interfaces, base models, and the UI dashboard.
- **`packages/log_box_dio_logger`**: Extension for capturing Dio network traffic.
- **`packages/log_box_navigation_logger`**: Extension for capturing Navigator/GoRouter events.
- **`packages/log_box_in_app_webview_logger`**: Extension for capturing `flutter_inappwebview` events.
- **`packages/log_box_persistent_storage_drift`**: Implementation of persistent storage using Drift.
- **`example/`**: Integration project showcasing all loggers and storage configurations.

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **FVM (Flutter Version Management):** Recommended for managing Flutter versions.
- **Flutter SDK:** ^3.32.8 (managed via FVM).
- **Dart SDK:** ^3.8.0.
- **Melos:** Required for monorepo management. Install via:
  ```bash
  dart pub global activate melos
  ```

---

## 🚀 Local Development Setup

Follow these steps to get your development environment ready:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/robzimpulse/log_box.git
   cd log_box
   ```

2. **Install Flutter version (if using FVM):**
   ```bash
   fvm install
   ```

3. **Bootstrap the project:**
   This will link all local packages and install dependencies.
   ```bash
   melos bs
   ```

4. **Generate code:**
   Many packages use `build_runner` for JSON serialization and Drift table generation.
   ```bash
   melos run generate
   ```

5. **Run the example app:**
   ```bash
   cd example
   fvm flutter run
   ```

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
If you modify Drift tables in `packages/log_box_persistent_storage_drift`, you need to generate migrations:
```bash
melos run generate:migration
```

### Melos/FVM Sync Issues
If local symlinks or Flutter versions get desynced, run the refresh script:
```bash
melos run refresh
```

### Extension Type Usage
The project leverages Dart 3.x Extension Types. Ensure your IDE is using the Flutter version specified in `.fvmrc` to avoid syntax errors.

---

## 🧪 Testing

Run all tests across the monorepo:
```bash
melos run test
```
