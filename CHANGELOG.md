## 0.1.0

* Initial standalone release: the core `log_box` package now lives at the repository root.
* Extensions moved to their own repositories:
  * https://github.com/robzimpulse/log_box_dio_logger
  * https://github.com/robzimpulse/log_box_in_app_webview_logger
  * https://github.com/robzimpulse/log_box_navigation_logger
  * https://github.com/robzimpulse/log_box_persistent_storage_drift
* Melos replaced by a `Makefile`; CI adds lint (analyze + format check) and tag-on-version-bump releases.
* **BREAKING:** git dependencies must drop `path: packages/log_box` and pin a tag, e.g. `ref: v0.1.0`.
