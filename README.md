# Secure AI-Assisted RTL Verification Baseline

This repository is the base environment for research into secure AI-assisted RTL verification and EDA workflows.

## Current Phase

Phase 0 - Establish and understand the baseline SiliconCompiler RTL-to-GDSII workflow.

The current repository intentionally contains only a small example design, setup scripts, environment checks, a minimal SiliconCompiler flow, and documentation for operating the Docker-backed EDA environment. It does not yet implement an AI integration, policy harness, formal-verification research system, or any cloud service.

## Research Motivation

This project will eventually support research into secure AI-assisted third-party RTL verification. The envisioned use case is a verification contractor receiving proprietary RTL and verification collateral from a semiconductor company and using AI agents such as Codex, ChatGPT, Claude, or local models to accelerate verification work.

A future AI harness may sit between the LLM and the EDA environment and enforce policies governing what RTL or design information may be exposed externally, what must remain local, anonymization of EDA logs and reports, filesystem and tool permissions, model-specific access policies, auditability, secure EDA execution, and formal or functional verification workflows.

SiliconCompiler and its open-source tool ecosystem provide the initial EDA orchestration baseline. The research emphasis remains verification and security, not AI-driven physical-design optimization.

Future phases may examine SiliconCompiler-captured data, simulation and lint results, metrics and manifests, formal verification, test generation, failure diagnosis, AI tool interfaces, data-classification policies, secure context filtering, human-in-the-loop verification, and agentic verification workflows.

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
    ├── environment.md
    ├── research_direction.md
    ├── usage.md
    └── validation.md
```

Generated tool installs, PDK caches, virtualenvs, build directories, and large EDA outputs are ignored by Git.

## Setup

```bash
./scripts/setup.sh
source .venv/bin/activate
source .sc-tools/oss-cad-suite/environment  # optional fallback bundle
```

The preferred native SiliconCompiler path is `sc-install -group asic digital-simulation`.
On this WSL2 host, native `sc-install` is blocked from this non-interactive session because the official Ubuntu install scripts require `sudo apt-get` for prerequisites.

The working path here is the official SiliconCompiler Docker runner:

```bash
docker run --rm ghcr.io/siliconcompiler/sc_runner:v0.38.2 openroad -version
```

## Check The Environment

```bash
./scripts/check_environment.sh
```

This verifies Python, SiliconCompiler import/version, executable discovery, Verilator lint, and Yosys synthesis for the example RTL.

## Run The Example Flow

Run through the Docker scheduler:

```bash
.venv/bin/python flows/example_flow.py \
  --scheduler docker \
  --docker-image ghcr.io/siliconcompiler/sc_runner:v0.38.2
```

If OpenROAD, OpenSTA, and KLayout are available natively through `sc-install` or another local installation:

```bash
PATH="$PWD/.sc-tools/bin:$PWD/.sc-tools/oss-cad-suite/bin:$PATH" .venv/bin/python flows/example_flow.py
```

The flow uses SiliconCompiler `0.38.2`, FreePDK45/Nangate45 via `lambdapdk`, and a tiny synthesizable counter design.

SiliconCompiler writes logs, reports, manifests, intermediate artifacts, metrics, and final layout output under `build/`. Start by inspecting `build/tiny_counter/job0/` after a run. The Docker-validated example produces `build/tiny_counter/job0/write.gds/0/outputs/tiny_counter.gds.gz`.

## Operating Notes

See `docs/usage.md` for command recipes covering:

- running the Docker-backed flow
- inspecting build outputs
- opening GDS in native WSL KLayout
- entering the SiliconCompiler Docker runner manually
- deciding when to edit the flow versus experiment in a container

## Research Direction

See `docs/research_direction.md` for the planned AI harness direction, including anonymized log/report extraction, RTL-first issue triage, human-in-the-loop verification, agentic workflows, multi-tool interfaces, and security questions around what EDA data can safely reach an LLM.

## Validation Status

See `docs/validation.md` for the exact validation performed in this environment and the current host limitations.
