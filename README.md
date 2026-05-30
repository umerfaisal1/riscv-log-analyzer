# RISC-V Log Analyzer

## 📌 Project Overview

The **RISC-V Log Analyzer** is a shell-based tool that processes RISC-V simulation log files, extracts execution results, and generates structured summary reports.

It demonstrates Linux shell scripting, text processing tools (`grep`, `awk`), Makefile automation, and basic CI-style workflow design.

---

## 📁 Project Structure

```
riscv-log-analyzer/
├── README.md
├── Makefile
├── .gitignore
├── scripts/
│   ├── analyze.sh
│   ├── setup_env.sh
│   └── generate_report.sh
├── test_data/
│   ├── sample_sim.log
│   ├── sample_pass.log
│   └── sample_fail.log
├── output/
└── docs/
    └── USAGE.md
```

---

## ⚙️ Features

* Parses RISC-V simulation logs
* Counts:

  * Total tests
  * Passed / Failed / Skipped tests
* Calculates pass percentage
* Extracts failing test names
* Computes timing statistics (min, max, average)
* Generates formatted reports
* Supports CLI options:

  * `--output <file>`
  * `--help`
  * `--verbose`

---

## 🚀 Installation

Clone the repository:

```bash
git clone <repo-url>
cd riscv-log-analyzer
```

Setup environment:

```bash
make setup
```

---

## ▶️ Usage

### Run analysis on a single log file

```bash
bash scripts/analyze.sh test_data/sample_sim.log
```

### Save output to file

```bash
bash scripts/analyze.sh test_data/sample_sim.log --output output/report.txt
```

### Generate full report

```bash
make report
```

---

## 🧪 Run Tests

Run analyzer on all test logs:

```bash
make test
```

---

## 🧹 Clean Output

Remove generated files:

```bash
make clean
```

---

## ❓ Help

Show all available Makefile commands:

```bash
make help
```

---

## 📊 Sample Output

```
=== RISC-V Simulation Log Analysis ===
Log file: test_data/sample_fail.log
Analysis date: 2026-05-05 14:30:00

--- Results Summary ---
Total tests: 25
Passed: 22 (88.0%)
Failed: 2 (8.0%)
Skipped: 1 (4.0%)

--- Failed Tests ---
1. rv32i-sll
2. rv32i-beq

--- Timing Statistics ---
Min time: 0.42s
Max time: 2.31s
Avg time: 0.87s

--- Verdict: FAIL ---
Exit code: 1
```

---

## 🛠 Requirements

* Bash
* grep
* awk
* bc
* make

---

## 📌 Author Notes

This project was built for MEDS Grand Aissignment of Module 1 focusing on:

* Text processing pipelines
* Automation using Makefiles
* Git workflow practice
