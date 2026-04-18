# log_box Context

## Purpose:
This directory contains the core logic for the LogBox logging system. It defines the base data models, storage abstractions (memory and persistent), and the primary `LogBox` controller that orchestrates data flow between loggers and the UI.

## Key Components:
- **lib/src/log_box.dart**: The main entry point and controller for the package, managing storage and route tracking.
- **lib/src/model/**: Contains the sharded data models for different types of logs, including `LogEntryModel` and `TraceLogEntryModel`, utilizing `json_annotation` for serialization.
- **lib/src/storage/**: Implements the storage layer, providing a unified `Storage` class that handles both live data (via `MemoryStorage`) and potential persistent backends.
- **lib/src/widget/**: Provides reusable UI components like `HumanReadableWidget` for displaying log data in a user-friendly format.
- **lib/src/extension/**: Contains helper extensions for JSON processing, navigation tracking, and text manipulation to enhance the logging experience.

## Dependencies:
- **uuid**: Used for generating unique identifiers for log entries.
- **json_annotation / json_serializable**: Used for structured data serialization and deserialization.
- **rxdart**: Used for reactive data handling within the storage and UI layers.
- **super_paging**: An internal dependency used for efficient list rendering and pagination of logs.
- **flutter**: The core framework for UI components and basic types.

## Local Conventions:
- **Sharded Storage**: Separates "Live Data" (ephemeral/in-memory) from "Persistent Data" using base abstract classes in `lib/src/storage/base/`.
- **Model Generation**: Uses `build_runner` with `json_serializable` for all log models; ensure `.g.dart` files are kept in sync.
- **Controller Pattern**: The `LogBox` class acts as a central singleton or provided instance that components interact with to access logs.
- **Extension-Heavy Design**: Much of the specialized logic (like navigation or JSON formatting) is moved into extensions to keep the core models clean.
