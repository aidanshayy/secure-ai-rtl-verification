# Secure AI-Assisted RTL Verification Baseline

This repository is the base environment for research into secure AI-assisted RTL verification and EDA workflows.

## Current Phase

Phase 0 - Establish and understand the baseline SiliconCompiler RTL-to-GDSII workflow.

The current repository intentionally contains only a small example design, setup scripts, environment checks, and a minimal SiliconCompiler flow. It does not implement an AI integration, policy harness, formal-verification research system, or any cloud service.

## Research Motivation

This project will eventually support research into secure AI-assisted third-party RTL verification. The envisioned use case is a verification contractor receiving proprietary RTL and verification collateral from a semiconductor company and using AI agents such as Codex, ChatGPT, Claude, or local models to accelerate verification work.

A future AI harness may sit between the LLM and the EDA environment and enforce policies governing what RTL or design information may be exposed externally, what must remain local, sanitization of EDA logs and design information, filesystem and tool permissions, model-specific access policies, auditability, secure EDA execution, and formal or functional verification workflows.

SiliconCompiler and its open-source tool ecosystem provide the initial EDA orchestration baseline. The research emphasis remains verification and security, not AI-driven physical-design optimization.

Future phases may examine SiliconCompiler-captured data, simulation and lint results, metrics and manifests, formal verification, test generation, failure diagnosis, AI tool interfaces, data-classification policies, secure context filtering, and agentic verification workflows.

## Repository Layout

```text
.
├── README.md
├── requirements.txt
├── scripts/
│   ├── setup.sh
│   └── check_environment.sh
├── designs/
│   └── example/
├── flows/
│   └── example_flow.py
├── results/
└── docs/
```

Generated tool installs, PDK caches, virtualenvs, build directories, and large EDA outputs are ignored by Git.

## Setup

```bash
./scripts/setup.sh
source .venv/bin/activate
source .sc-tools/oss-cad-suite/environment
```

The preferred native SiliconCompiler path is `sc-install -group asic digital-simulation`. On this WSL2 host, that path is blocked because the official Ubuntu install scripts require `sudo apt-get` for prerequisites. Docker is also unavailable inside this distro until Docker Desktop WSL integration is enabled.

## Check The Environment

```bash
./scripts/check_environment.sh
```

This verifies Python, SiliconCompiler import/version, executable discovery, Verilator lint, and Yosys synthesis for the example RTL.

## Run The Example Flow

Once OpenROAD and KLayout are available through `sc-install`, Docker, or another local installation:

```bash
PATH="$PWD/.sc-tools/bin:$PWD/.sc-tools/oss-cad-suite/bin:$PATH" .venv/bin/python flows/example_flow.py
```

The flow uses SiliconCompiler `0.38.2`, FreePDK45/Nangate45 via `lambdapdk`, and a tiny synthesizable counter design.

SiliconCompiler writes logs, reports, manifests, intermediate artifacts, metrics, and final layout output under `build/`. Start by inspecting `build/tiny_counter/job0/` after a run.

## Validation Status

See `docs/validation.md` for the exact validation performed in this environment and the current host limitations.
