# log_box_navigation_logger Context

## Purpose:
This directory contains a specialized extension for the LogBox ecosystem that provides automated logging for Flutter's Navigator. It tracks route transitions (push, pop, replace, remove) and captures route names and arguments to build a historical timeline of user navigation.

## Key Components:
- **lib/src/observer/log_box_navigator_observer.dart**: The core implementation of a Flutter `NavigatorObserver`. It intercepts navigation events and converts them into `NavigationEntryModel` instances.
- **lib/src/model/navigation_entry_model.dart**: The data structure representing a single navigation event, including the action type, current route, and previous route metadata.
- **lib/src/enum/enum.dart**: Defines the `NavigationAction` enum (push, pop, replace, remove) used to categorize transitions.
- **lib/src/extension/extension.dart**: Provides helper extensions, likely for extracting readable strings from `RouteSettings` or handling arguments safely.

## Dependencies:
- **flutter**: Relies on the core Flutter `NavigatorObserver` and `Route` classes.
- **log_box**: The core internal module (referenced via Git in pubspec.yaml) which provides the base logging infrastructure that this logger feeds into.
- **json_annotation**: Used for generating serialization logic for the navigation models.

## Local Conventions:
- **Observer-Based Integration**: The package is designed to be integrated by adding `LogBoxNavigatorObserver` to the `navigatorObservers` list in a `MaterialApp` or `CupertinoApp`.
- **Callback Pattern**: The `LogBoxNavigatorObserver` uses an `onEvent` callback (ValueSetter) to pass captured navigation data back to the central LogBox storage, allowing for flexible integration.
- **Metadata Capture**: The observer prioritizes capturing both the route name and its arguments, ensuring that dynamic routes are correctly identified in the logs.
- **Automated Serialization**: Standard practice within the monorepo, using `json_serializable` for all data models in the `model/` directory.
