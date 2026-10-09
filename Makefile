# Makefile — development and CI entry points for the log_box core package.
#
# Purpose: single entry point for local dev and CI. Every target runs against the
# core package at the repo root; get/upgrade/clean/refresh also cover the
# example/ app. CI calls `make get`, `make coverage`, `make analyze`,
# `make format-check` and `make test`.
#
# Usage:
#   make                              # list targets
#   make test                         # uses `flutter` from PATH
#   make test FLUTTER="fvm flutter"   # use the FVM-pinned SDK (see .fvmrc)
#   make format DART="fvm dart"

FLUTTER ?= flutter
DART ?= dart

.DEFAULT_GOAL := help
.PHONY: help get upgrade clean refresh test coverage analyze format format-check generate

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

get: ## Fetch dependencies (core + example)
	$(FLUTTER) pub get
	cd example && $(FLUTTER) pub get

upgrade: ## Upgrade dependencies (core + example)
	$(FLUTTER) pub upgrade
	cd example && $(FLUTTER) pub upgrade

clean: ## Remove build artifacts (core + example)
	$(FLUTTER) clean
	cd example && $(FLUTTER) clean

refresh: clean get ## Clean, then fetch dependencies again

test: ## Run unit tests
	$(FLUTTER) test

coverage: ## Run unit tests with coverage (coverage/lcov.info)
	$(FLUTTER) test --coverage

analyze: ## Static analysis (core + example)
	$(FLUTTER) analyze

format: ## Format all Dart files in place
	$(DART) format .

format-check: ## Fail if any Dart file is not formatted
	$(DART) format --output=none --set-exit-if-changed .

generate: ## Run build_runner code generation
	$(DART) run build_runner build --delete-conflicting-outputs
