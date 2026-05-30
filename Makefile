SHELL := /bin/bash

LOG_DIR := test_data
OUT_DIR := output
SCRIPT := scripts/analyze.sh

LOGS := $(wildcard $(LOG_DIR)/*.log)

.PHONY: all test report clean help setup

# -------------------------
# ALL
# -------------------------
all: ## Run analyzer on all test logs
	@echo "Running analyzer on all logs..."
	@for file in $(LOGS); do \
		bash $(SCRIPT) $$file; \
	done

# -------------------------
# TEST
# -------------------------
test: ## Run analyzer on each test log file
	@echo "Running tests..."
	@for file in $(LOGS); do \
		echo "Testing $$file"; \
		bash $(SCRIPT) $$file; \
	done

# -------------------------
# REPORT
# -------------------------
report: ## Generate summary report in output/
	@echo "Generating report..."
	@mkdir -p $(OUT_DIR)
	@bash scripts/analyze.sh $(LOG_DIR)/sample_sim.log --output $(OUT_DIR)/report.txt || true

# -------------------------
# CLEAN
# -------------------------
clean: ## Remove generated output files
	@echo "Cleaning output directory..."
	@rm -rf $(OUT_DIR)/*

# -------------------------
# SETUP
# -------------------------
setup: ## Check required tools and environment
	@bash scripts/setup_env.sh

# -------------------------
# HELP
# -------------------------
help: ## Show available targets
	@bash scripts/analyze.sh --help