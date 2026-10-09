# AI SYSTEM CONTEXT

## 1. Tech Stack & Environment
- **Language:** Dart (SDK >=3.8.0)
- **Framework:** Flutter (>=3.29.3)
- **Task Runner:** GNU Make (`Makefile`; run `make` to list targets)
- **Persistence:** [Drift](https://drift.simonbinder.eu/) (SQLite)
- **Networking:** [Dio](https://pub.dev/packages/dio)
- **Environment Management:** FVM (Flutter Version Management)

## 2. Architecture & Directory Structure
This repository holds the **core** `log_box` package at its root plus an integration app. Logger extensions live in their own repositories and depend on core via a git tag.

- **`lib/`, `test/`**: The core framework. Defines storage interfaces, base models, and the UI dashboard.
- **`example/`**: Integration project showcasing all loggers and storage configurations. Depends on core via `path: ..` (forced with `dependency_overrides`) and on each extension via git tag.
- **Extension repositories:**
  - [log_box_dio_logger](https://github.com/robzimpulse/log_box_dio_logger): Capturing Dio network traffic.
  - [log_box_navigation_logger](https://github.com/robzimpulse/log_box_navigation_logger): Capturing Navigator/GoRouter events.
  - [log_box_in_app_webview_logger](https://github.com/robzimpulse/log_box_in_app_webview_logger): Capturing `flutter_inappwebview` events.
  - [log_box_persistent_storage_drift](https://github.com/robzimpulse/log_box_persistent_storage_drift): Persistent storage using Drift.

## 3. Implementation Rules
- **Modularity:** Do not add specialized dependencies (like Dio or WebView) to the core `log_box` package. Create a new extension repository or use an existing one.
- **Code Generation:** Many packages use `build_runner`. Always run `make generate` after modifying classes annotated with `@JsonSerializable`. `build.yaml` restricts generation to `lib/`.
- **Dependency Management:** Run `make get` (fetches core and `example/`). There is no workspace tool; cross-repo dependencies are git tags.
- **Style:** Follow standard Flutter/Dart linting rules as defined in `analysis_options.yaml`. `make analyze` and `make format-check` must pass (CI enforces both; infos are fatal).
- **Releasing:** Bump `version:` in `pubspec.yaml` and add a matching `## <version>` section to `CHANGELOG.md` in the same PR; merging creates tag `v<version>` via `release.yaml`.

## 4. Testing Conventions
- **Unit Tests:** Located in `test/`.
- **Execution:** Run `make test` (or `make coverage`).
- **CI/CD:** `.github/workflows/unit-test.yaml` runs tests, coverage diff (PR comment) and lint on every PR and push to `master`; `.github/workflows/release.yaml` tags releases on version bump.

## 5. Known Blockers & Troubleshooting (Self-Learning)
> **⚠️ DIRECTIVE FOR ALL FUTURE AI AGENTS:** If you encounter a new architectural blocker, undocumented workaround, or persistent bug while working in this codebase, you MUST append it to this section with troubleshooting steps before completing your task.

- **Manual Model Registration (Persistence)**
  - **Location:** `DriftPersistentStorage` initialization.
  - **Context:** Drift storage requires a `decoder` map to deserialize JSON blobs back into Dart models.
  - **Troubleshooting:** When adding a new loggable model, ensure you add its `fromJson` factory to the `decoder` map in the `LogBox` initialization:
    ```dart
    final box = LogBox(
      storage: Storage(
        liveDataStorage: MemoryStorage(capacity: 100),
        persistentDataStorage: DriftPersistentStorage(
          executor: NativeDatabaseExecutor(), // or MemoryExecutor
          decoder: {
            (LogEntryModel).toString(): LogEntryModel.fromJson,
            (NetworkEntryModel).toString(): NetworkEntryModel.fromJson,
            // Add other models as needed
          },
        ),
      ),
    );
    ```

- **Drift Schema Migrations**
  - **Location:** [log_box_persistent_storage_drift](https://github.com/robzimpulse/log_box_persistent_storage_drift) repository
  - **Context:** Changes to Drift tables require explicit migration generation.
  - **Troubleshooting:** In that repository, run `make generate-migration` to update the schema and generate the necessary migration code.

- **FVM / Dependency Sync Issues**
  - **Location:** Repository root
  - **Context:** Sometimes cached dependencies or Flutter versions get desynced.
  - **Troubleshooting:** Run `make refresh` to clean and re-fetch core and `example/` dependencies. Use `FLUTTER="fvm flutter"` to force the pinned SDK.

- **Extension Type Usage**
  - **Location:** Various models
  - **Context:** The project uses high SDK constraints, likely leveraging Dart 3.x features like Extension Types for performance or API ergonomics.
  - **Troubleshooting:** Ensure your IDE is using the Flutter version specified in `.fvmrc` to avoid syntax errors.

- **Cross-Repo Dependency Bumps**
  - **Location:** Extension repositories' `pubspec.yaml` + this repository's `example/pubspec.yaml`
  - **Context:** Extensions depend on core via `git: {url: https://github.com/robzimpulse/log_box.git, ref: v<version>}`, so their CI always resolves a released tag of core — never a PR branch. A shared-constraint bump (e.g. rxdart `^0.27.7` → `^0.28.0`) in core and an extension therefore cannot land in one step: pre-1.0 caret ranges are disjoint and version solving fails. `example/` is shielded because it forces `log_box: path: ..` via `dependency_overrides`.
  - **Troubleshooting:** Land the bump in core first and release it (bump `version:` + CHANGELOG → new tag). Then, in each extension repository, update the `ref:` to the new tag and bump the constraint in its own PR, release it, and finally update the extension tags in `example/pubspec.yaml`.

- **build_runner Scanning `example/`**
  - **Location:** `build.yaml` (repository root)
  - **Context:** With core at the repository root, build_runner treats `example/` (including `example/ios/.symlinks/plugins/*`) as core sources and fails on third-party annotations (`@HostApi`, `@GenerateMocks`).
  - **Troubleshooting:** Keep `build.yaml`'s `sources` restricted to `$package$`, `pubspec.yaml` and `lib/**`. If a generator ever needs `test/` inputs, add `test/**` explicitly — never widen to the whole directory.

## 6. Core Package Context

### Purpose:
This repository contains the core logic for the LogBox logging system. It defines the base data models, storage abstractions (memory and persistent), and the primary `LogBox` controller that orchestrates data flow between loggers and the UI.

### Key Components:
- **lib/src/log_box.dart**: The main entry point and controller for the package, managing storage and route tracking.
- **lib/src/model/**: Contains the sharded data models for different types of logs, including `LogEntryModel` and `TraceLogEntryModel`, utilizing `json_annotation` for serialization.
- **lib/src/storage/**: Implements the storage layer, providing a unified `Storage` class that handles both live data (via `MemoryStorage`) and potential persistent backends.
- **lib/src/widget/**: Provides reusable UI components like `HumanReadableWidget` for displaying log data in a user-friendly format.
- **lib/src/extension/**: Contains helper extensions for JSON processing, navigation tracking, and text manipulation to enhance the logging experience.

### Dependencies:
- **uuid**: Used for generating unique identifiers for log entries.
- **json_annotation / json_serializable**: Used for structured data serialization and deserialization.
- **rxdart**: Used for reactive data handling within the storage and UI layers.
- **super_paging**: An internal dependency used for efficient list rendering and pagination of logs.
- **flutter**: The core framework for UI components and basic types.

### Local Conventions:
- **Sharded Storage**: Separates "Live Data" (ephemeral/in-memory) from "Persistent Data" using base abstract classes in `lib/src/storage/base/`.
- **Model Generation**: Uses `build_runner` with `json_serializable` for all log models; ensure `.g.dart` files are kept in sync.
- **Controller Pattern**: The `LogBox` class acts as a central singleton or provided instance that components interact with to access logs.
- **Extension-Heavy Design**: Much of the specialized logic (like navigation or JSON formatting) is moved into extensions to keep the core models clean.
