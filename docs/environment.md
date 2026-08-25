# Environment Notes

## Verified Sources

- SiliconCompiler docs for `v0.38.2` identify Python 3.10+ as required, recommend installing the latest stable PyPI package, and document `sc-install -group asic` for local ASIC tools.
- SiliconCompiler GitHub releases list `v0.38.2` as the latest stable release at setup time.
- SiliconCompiler's Docker guide documents the prebuilt `ghcr.io/siliconcompiler/sc_runner:v<version>` runner path for hosts that cannot run native tools.

## Host

- OS: Ubuntu 24.04.4 LTS on WSL2
- Kernel: `6.6.87.2-microsoft-standard-WSL2`
- Python: `3.12.3`
- Native limitation observed here: non-interactive `sudo` is unavailable, so the official `sc-install` Ubuntu scripts cannot install apt prerequisites.
- Docker Desktop WSL integration is now reachable from this distro when run with Docker socket permissions.

## Installed In This Repo

- Python virtual environment: `.venv/`
- SiliconCompiler: `0.38.2`
- User-space fallback bundle: `.sc-tools/oss-cad-suite/`
- OSS CAD Suite release: `2026-08-24`
- OSS CAD Suite archive SHA-256: `9d7f79975ef624e1119fc9690fd9b9839b67026925aff3e2a1192d861b8dbb7c`

The OSS CAD Suite fallback provides working Verilator and Yosys here. It does not provide OpenROAD or KLayout in this release, so it cannot complete the SiliconCompiler physical implementation flow by itself.

## Docker Tool Path

The verified OpenROAD path is the official SiliconCompiler runner image:

```bash
docker run --rm ghcr.io/siliconcompiler/sc_runner:v0.38.2 openroad -version
```

Observed OpenROAD version from that image:

```text
26Q3-411-ga65b06e763
```

The image also provides the OpenSTA and KLayout executables needed by the FreePDK45/Nangate45 example flow.

## Activation

```bash
source .venv/bin/activate
source .sc-tools/oss-cad-suite/environment
```

## Commands

Check the environment:

```bash
./scripts/check_environment.sh
```

Run the SiliconCompiler example flow through Docker:

```bash
.venv/bin/python flows/example_flow.py \
  --scheduler docker \
  --docker-image ghcr.io/siliconcompiler/sc_runner:v0.38.2
```

Run the same flow locally when OpenROAD and KLayout are available on the WSL `PATH`:

```bash
PATH="$PWD/.sc-tools/bin:$PWD/.sc-tools/oss-cad-suite/bin:$PATH" .venv/bin/python flows/example_flow.py
```

## SiliconCompiler Output To Inspect

When the flow runs, SiliconCompiler writes under `build/`. The useful categories to inspect are:

- manifests and snapshots describing project configuration, filesets, options, tool settings, libraries, PDK selection, and flowgraph state
- per-step logs from import, synthesis, floorplan, placement, CTS, routing, and signoff tasks
- metrics such as errors, warnings, area, timing, power, utilization, and tool runtime
- reports emitted by Yosys, OpenROAD, OpenSTA, and KLayout
- intermediate Verilog/netlist, DEF/ODB/layout data, and final GDS/OAS outputs when the full toolchain is present

These are the baseline data surfaces that later research can classify before exposing anything to an AI assistant.
