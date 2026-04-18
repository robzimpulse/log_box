# log_box_dio_logger Context

## Purpose:
This directory contains a specialized plugin for the LogBox ecosystem that provides automated network logging for the Dio HTTP client. It intercepts requests, responses, and errors, converting them into structured `NetworkEntryModel` data for display and storage.

## Key Components:
- **lib/src/interceptor/log_box_network_interceptor.dart**: The core logic of the package. It implements a Dio `Interceptor` to capture network traffic and send it to the LogBox storage.
- **lib/src/model/network_entry_model.dart**: Defines the top-level structure for a network log, linking requests, responses, and potential errors.
- **lib/src/model/http_request_model.dart & http_response_model.dart**: Specialized data models that capture headers, query parameters, body content, and metadata for HTTP transactions.
- **lib/src/model/form_data_field_model.dart & form_data_file_model.dart**: Handle the complexity of multi-part form data requests, ensuring files and fields are correctly represented in logs.
- **lib/src/extension/**: Contains helper methods for internal data manipulation, such as formatting Dio headers or processing stream data.

## Dependencies:
- **dio**: The primary external dependency this package extends.
- **log_box**: The core internal module used for its `Storage` and base log abstractions.
- **rxdart**: Used for handling stream-based response bodies (`ResponseBody`) within the interceptor.
- **json_annotation**: Used for generating serialization logic for the network models.
- **equatable**: Used to simplify equality checks in the data models.

## Local Conventions:
- **Interceptor-Centric Design**: The primary way to use this package is by adding `LogBoxNetworkInterceptor` to a Dio instance's interceptor list.
- **Reactive Stream Handling**: When dealing with `ResponseBody` streams in Dio, the interceptor uses `ReplaySubject` from RxDart to capture data without consuming the stream for the original caller.
- **Model Partitioning**: Detailed HTTP data is sharded into `HttpRequestModel`, `HttpResponseModel`, and `HttpErrorModel` to maintain clean separation of concerns within a `NetworkEntryModel`.
- **Automated Serialization**: All models in `lib/src/model/` must use `json_serializable` and have corresponding `.g.dart` files generated.
