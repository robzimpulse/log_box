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
