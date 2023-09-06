default: check

.PHONY: tasks install format test check

tasks: ## Print available tasks
	@printf "\nUsage: make [target]\n\n"
	@grep -E '^[a-z][^:]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Fetch dependencies for cyclic_dependency_checks
	dart pub get

format: ## Format cyclic_dependency_checks code
	dart format lib --line-length 100 --set-exit-if-changed

test: ## Run cyclic_dependency_checks tests
	dart scripts/generate_big_codebase.dart; dart test

check: format test ## Check formatting, cycles and run tests
