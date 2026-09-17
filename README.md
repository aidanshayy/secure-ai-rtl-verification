# Secure AI-Assisted RTL Verification Research Repository

This repository is a research environment for secure, AI-assisted RTL
verification. It is intended to support multiple RTL designs, verification
environments, tools, experiments, and agent workflows rather than a single
production design flow.

## Current Phase

Phase 0 - Establish a reproducible RTL-verification baseline and define the
interfaces between verification tools, AI agents, and protected design data.

The repository currently contains small RTL examples, an imported UART 16550
baseline, reusable Verilator simulation commands, setup scripts, environment checks, a minimal
SiliconCompiler RTL-to-GDSII flow, and operating documentation. The full
RTL-to-GDSII flow is a supporting baseline for learning and for studying
downstream effects of RTL decisions; it is not the primary scope of the
project. The repository does not yet implement a complete AI integration,
policy harness, formal-verification research system, or cloud service.

See [AGENTS.md](AGENTS.md) for guidance intended for Codex and other agents
working in this repository.

## Research Motivation

This project supports research into secure AI-assisted RTL verification. The
envisioned use case is a verification engineer or contractor receiving
proprietary RTL and verification collateral from a semiconductor company and
using AI agents such as Codex, ChatGPT, Claude, or local models to accelerate
verification work without casually exposing sensitive design information.

A future AI harness may sit between the LLM and the EDA environment and enforce policies governing what RTL or design information may be exposed externally, what must remain local, anonymization of EDA logs and reports, filesystem and tool permissions, model-specific access policies, auditability, secure EDA execution, and formal or functional verification workflows.

SiliconCompiler and its open-source tool ecosystem provide the EDA
orchestration baseline. The research emphasis is RTL verification and security,
not AI-driven physical-design optimization.

Research areas may include:

- SystemVerilog Assertions (SVA) generation and review.
- UVM and testbench scaffolding.
- Test planning, stimulus generation, and simulation triage.
- Functional, code, assertion, and formal coverage analysis.
- Log and failure debugging across simulators, linters, synthesis, and formal tools.
- Design understanding, documentation, dependency mapping, and change impact analysis.
- Secure AI context preparation, anonymization, policy enforcement, and auditability.
- Centaur-style workflows that coordinate verification tools, agents, artifacts,
  and human approval points.
- SiliconCompiler-backed experiments that connect RTL verification findings to
  synthesis or implementation behavior.

## Repository Layout

```text
.
├── AGENTS.md
├── README.md
├── requirements.txt
├── scripts/
│   ├── setup.sh
│   ├── check_environment.sh
│   └── run_verilator.sh
├── designs/
│   ├── D_Flip_Flop/
│   │   └── sim/verilator/       # runnable example configuration
│   ├── mux2/
│   ├── uart16550/
│   │   ├── rtl/verilog/         # active imported RTL
│   │   └── sim/verilator/       # UART smoke test configuration
│   └── ...                       # add new designs here
├── flows/
│   └── example_flow.py
├── build/                       # generated, ignored simulation/EDA output
└── docs/
    ├── environment.md
    ├── research_direction.md
    ├── scope.md
    ├── simulations.md
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

## Run RTL simulations

RTL simulation is the recommended starting point. The reusable runner takes a
testbench top, testbench file, and one or more RTL files:

```bash
./scripts/run_verilator.sh --top tb \
  --tb designs/D_Flip_Flop/tb_DFlipFlop.sv \
  --rtl designs/D_Flip_Flop/DFlipFlop.sv \
  --build-dir build/D_Flip_Flop/verilator
```

Use `--lint-only` for a fast compile/elaboration check or `--coverage` to
instrument the run. See [docs/simulations.md](docs/simulations.md) for include
paths, waveforms, coverage reports, and configuring multi-file designs.

The same example has a design-local interface:

```bash
make -C designs/D_Flip_Flop/sim/verilator run
make -C designs/D_Flip_Flop/sim/verilator coverage
```

The UART baseline is also directly runnable:

```bash
make -C designs/uart16550/sim/verilator
make -C designs/uart16550/sim/verilator coverage
```

Outputs stay under `build/`, keeping design source directories clean.

## Run the optional SiliconCompiler flow

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

## Run the UART Verilator baseline

The active UART RTL is under `designs/uart16550/rtl/verilog/`. The original
OpenCores bench is preserved as reference collateral, while the repository's
Verilator entry point is a small, timing-aware Wishbone/serial loopback smoke
test:

```bash
make -C designs/uart16550/sim/verilator
```

The test builds and runs under `build/uart16550/verilator/`, which is generated
output and is ignored by Git. See [designs/uart16550/README.md](designs/uart16550/README.md)
for the source boundaries and legacy-bench notes.

## Operating Notes

See `docs/usage.md` for command recipes covering:

- the RTL-first Verilator workflow
- running the Docker-backed flow
- inspecting build outputs
- opening GDS in native WSL KLayout
- entering the SiliconCompiler Docker runner manually
- deciding when to edit the flow versus experiment in a container

## Research Direction

See `docs/scope.md` and `docs/research_direction.md` for the project scope,
verification research themes, Centaur workflow direction, AI-agent concepts,
and security questions around what EDA data can safely reach an LLM.

## Validation Status

See `docs/validation.md` for the exact validation performed in this environment and the current host limitations.
