# log_box_persistent_storage_drift Context

## Purpose:
This directory provides a persistent storage backend for the LogBox ecosystem using the Drift (formerly Moor) library. It implements the `PersistentDataStorage` interface from the core package, enabling long-term storage, complex querying, and reactive streaming of log entries using SQLite.

## Key Components:
- **lib/src/drift_persistent_storage.dart**: The primary adapter that connects the LogBox storage interface to the Drift database layer. It handles the serialization/deserialization of `EntryModel` objects to and from the database.
- **lib/src/database/database.dart**: Defines the Drift database schema, including tables for log data and logic for schema migrations.
- **lib/src/dao/data_dao.dart**: The Data Access Object (DAO) containing specific SQL queries for fetching, filtering, and watching log entries.
- **lib/src/table/data_table.dart**: Defines the underlying SQL table structure (e.g., `DataDrift`) used to store JSON-serialized log data and metadata.
- **lib/src/adapter/**: Contains logic for mapping between Drift-specific data types and the domain models used by LogBox.

## Dependencies:
- **drift / drift_flutter**: The primary database framework used for SQLite abstraction and reactive queries.
- **sqlite3 / sqlite3_flutter_libs**: The underlying SQL engine.
- **log_box**: The core internal module that defines the `PersistentDataStorage` contract and `EntryModel` base classes.
- **path_provider**: Used to locate the correct directory on the device for storing the database file.
- **json_annotation**: Used for serializing log entries into the JSON format stored in the database.

## Local Conventions:
- **Schema Decoupling**: Logs are stored as JSON blobs in a generic `DataDrift` table rather than individual columns for every property. This allows the storage layer to remain agnostic of specific log types (Dio, WebView, etc.).
- **Type-Based Decoding**: Uses a `MapObjectDecoder` registry to determine how to reconstruct specific `EntryModel` types from the stored JSON based on a type string.
- **Reactive Queries**: Leverages Drift's `watch` capabilities to provide real-time updates to the UI via the `fetchStream` and `getStream` methods.
- **DAO Pattern**: All SQL logic is encapsulated within DAOs to keep the `DriftPersistentStorage` adapter clean and focused on interface implementation.
