# Makefile for macbuild - macOS system configuration tool
.PHONY: help test install update clean coverage lint check

# Default target
.DEFAULT_GOAL := help

## Display this help message
help:
	@echo "macbuild - macOS System Configuration Tool"
	@echo "=========================================="
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "Examples:"
	@echo "  make install          # Full system setup"
	@echo "  make test             # Run test suite"
	@echo "  make update           # Update packages only"

test:   ## Run the complete test suite with coverage report
	@echo "Running macbuild test suite..."
	@./run_tests.sh

check:  ## Run syntax check on the script
	@echo "Checking script syntax..."
	@bash -n ./macbuild && echo "✓ Syntax OK"

lint:   ## Run shellcheck linting
	@echo "Running shellcheck..."
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck ./macbuild; \
	else \
		echo "shellcheck not installed. Install with: brew install shellcheck"; \
	fi

coverage: ## Display coverage report
	@if [ -f coverage/coverage_report.txt ]; then \
		cat coverage/coverage_report.txt; \
	else \
		echo "No coverage report found. Run 'make test' first."; \
	fi

clean:  ## Clean up test artifacts and logs
	@echo "Cleaning up test artifacts..."
	@rm -rf coverage/ test_files/ test_results.log
	@rm -f brew uv pnpm gem mise xcode-select launchctl
	@echo "✓ Cleanup complete"

debug: ## Run installation with debug logging
	@LOG_LEVEL=DEBUG ./macbuild

## Validate package configuration file
validate-config: ## Check packages.ini syntax
	@if [ -f files/packages.ini ]; then \
		echo "Validating packages.ini..."; \
		awk 'BEGIN{sections=0} /^\[.*\]$$/{sections++} END{if(sections>0) print "✓ Valid INI format ("sections" sections)"; else exit 1}' files/packages.ini; \
	else \
		echo "✗ packages.ini not found"; \
		exit 1; \
	fi
