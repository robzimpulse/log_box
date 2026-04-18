# LogBox Workspace Context

## Purpose:
This directory serves as the root of the LogBox monorepo, a Flutter-based logging ecosystem. It coordinates multiple specialized logging packages (Dio, Navigation, WebView, Storage) and an example application using Melos for dependency management and lifecycle orchestration.

## Key Components:
- **packages/**: Contains the sharded logic of the ecosystem, including the core `log_box` package and its specialized extensions.
- **example/**: A demonstration Flutter application that integrates all LogBox packages to showcase real-world usage.
- **melos.yaml**: The monorepo configuration file defining package locations and automation scripts (bootstrap, clean, test, generate).
- **pubspec.yaml**: The workspace-level pubspec, primarily used for Melos and workspace-wide dev dependencies.
- **.fvmrc**: Configuration for Flutter Version Management to ensure consistent SDK usage across the team.

## Dependencies:
- **Melos**: Orchestrates the multi-package repo, handling symlinking and concurrent command execution.
- **Flutter SDK**: The primary framework for all packages and the example app.
- **Internal Package Links**: The `example` and specialized logger packages depend on the core `packages/log_box` module.

## Local Conventions:
- **Monorepo Structure**: Logic is sharded into specialized packages (e.g., `log_box_dio_logger`) to keep the core package lightweight and modular.
- **Melos Automation**: Use `melos run generate` for code generation and `melos run refresh` for dependency synchronization across all modules.
- **Version Management**: All development should be performed using the Flutter version defined in `.fvmrc`.
- **Package Integrity**: Each package in `packages/` is expected to be self-contained with its own tests and analysis options, following the patterns established in the core `log_box` package.

## Integration & Usage:
To integrate LogBox into a project, follow the pattern established in the `example/` module:

1.  **Initialize LogBox**: Create a `LogBox` instance with desired storage configurations (Memory and/or Persistent).
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

2.  **Attach Loggers**: Use specialized logger packages to capture events.
    *   **Network (Dio)**:
        ```dart
        final dio = Dio()..interceptors.add(box.interceptor);
        ```
    *   **Navigation**:
        ```dart
        // Using standard Navigator
        MaterialApp(
          navigatorObservers: [LogBoxNavigatorObserver(onEvent: box.storage.add)],
        );

        // Or using GoRouter (as seen in example)
        GoRouter(
          observers: [box.observer],
          routes: [...],
        );
        ```
    *   **WebView**:
        ```dart
        InAppWebView(
          onLoadStart: (controller, url) => box.inAppWebviewObserver.onLoadStart(uri: url),
          onConsoleMessage: (controller, message) => box.inAppWebviewObserver.onConsoleMessage(message: message.toMap()),
          // ... other callbacks
        );
        ```

3.  **Manual Logging**: Use `box.log('Your message')` for general trace logs.

4.  **UI Integration**: Provide the `box` instance to your widget tree and trigger the dashboard:
    ```dart
    // Triggering the LogBox dashboard (e.g., from a FloatingActionButton)
    FloatingActionButton(
      onPressed: () => box.dashboard(context: context),
      child: const Icon(Icons.bug_report),
    );
    ```
