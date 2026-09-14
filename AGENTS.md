# AI SYSTEM CONTEXT

## 1. Tech Stack & Environment
- **Language:** Dart (SDK >=3.8.0)
- **Framework:** Flutter (>=3.29.3)
- **Monorepo Management:** [Melos](https://melos.invertase.dev/)
- **Persistence:** [Drift](https://drift.simonbinder.eu/) (SQLite)
- **Networking:** [Dio](https://pub.dev/packages/dio)
- **Environment Management:** FVM (Flutter Version Management)

## 2. Architecture & Directory Structure
The project follows a **Modular Monorepo Architecture** sharded by functionality to maintain a lightweight core.

- **`packages/log_box`**: The core framework. Defines storage interfaces, base models, and the UI dashboard.
- **`packages/log_box_dio_logger`**: Extension for capturing Dio network traffic.
- **`packages/log_box_navigation_logger`**: Extension for capturing Navigator/GoRouter events.
- **`packages/log_box_in_app_webview_logger`**: Extension for capturing `flutter_inappwebview` events.
- **`packages/log_box_persistent_storage_drift`**: Implementation of persistent storage using Drift.
- **`example/`**: Integration project showcasing all loggers and storage configurations.

## 3. Implementation Rules
- **Modularity:** Do not add specialized dependencies (like Dio or WebView) to the core `log_box` package. Create a new package or use an existing extension package.
- **Code Generation:** Many packages use `build_runner`. Always run `melos run generate` after modifying classes annotated with `@JsonSerializable` or Drift tables.
- **Dependency Management:** Use `melos bs` (bootstrap) to link local packages. Do not use standard `flutter pub get` in individual folders manually if dependencies between local packages have changed.
- **Style:** Follow standard Flutter/Dart linting rules as defined in `analysis_options.yaml`.

## 4. Testing Conventions
- **Unit Tests:** Located in the `test/` directory of each package.
- **Execution:** Run `melos run test` to execute all tests across the monorepo.
- **CI/CD:** GitHub Actions are configured to run tests independently for each package upon PR/Push.

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
  - **Location:** `packages/log_box_persistent_storage_drift`
  - **Context:** Changes to Drift tables require explicit migration generation.
  - **Troubleshooting:** Run `melos run generate:migration` to update the schema and generate the necessary migration code.

- **Melos/FVM Sync Issues**
  - **Location:** Root workspace
  - **Context:** Sometimes local symlinks or Flutter versions get desynced.
  - **Troubleshooting:** Run `melos run refresh` to clean all caches, bootstrap dependencies, and re-fetch all packages.

- **Extension Type Usage**
  - **Location:** Various models
  - **Context:** The project uses high SDK constraints, likely leveraging Dart 3.x features like Extension Types for performance or API ergonomics.
  - **Troubleshooting:** Ensure your IDE is using the Flutter version specified in `.fvmrc` to avoid syntax errors.

- **Intra-Repo Git Dependencies vs. CI on Version-Bump PRs**
  - **Location:** `packages/*/pubspec.yaml` (all extension packages) + `.github/workflows/unit-test-*.yaml`
  - **Context:** Extension packages (e.g. `log_box_dio_logger`) declare `log_box` as a git dependency pinned to `ref: master` of this same repository. Per-package CI runs plain `flutter pub get`, which resolves `log_box` from git `master` — NOT the PR branch. A single PR that bumps a shared dependency constraint (e.g. rxdart `^0.27.7` → `^0.28.0`) in both `log_box` and an extension package therefore fails version solving until it merges, because pre-1.0 caret ranges are disjoint. Local dev is unaffected: `melos bs`/`melos run refresh` overrides the git dep with a path dep via `pubspec_overrides.yaml`.
  - **Troubleshooting:** Split shared-dependency bumps into per-module PRs merged sequentially: bump `log_box` first, then the extension packages (their CI resolves against the updated master). Between the two merges, the extension workflow's `baseline` job (which checks out master) is red — merge anyway; push-triggered runs have no baseline job. Also note: on a fresh clone, `dart pub get` at the repo root fails because pub also resolves `example/`, which mixes path deps on the extension packages with their git deps on `log_box`. Run `melos bs` or `melos run refresh` first to generate the path overrides.
