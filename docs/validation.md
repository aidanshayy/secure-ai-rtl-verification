# Validation Log

Date: 2026-08-25

## Completed

- Created a Python virtual environment in `.venv/`.
- Installed `siliconcompiler==0.38.2`.
- Verified SiliconCompiler imports and prints version `0.38.2`.
- Downloaded OSS CAD Suite `2026-08-24` and verified SHA-256.
- Verified Verilator runs on `designs/example/tiny_counter.v`.
- Verified Yosys can synthesize `designs/example/tiny_counter.v`.
- Ran `flows/example_flow.py`; SiliconCompiler constructed the FreePDK45/Nangate45 ASIC flowgraph and wrote `build/tiny_counter/job0/job.log` plus `build/tiny_counter/job0/tiny_counter.pkg.json`.

## Tool Versions Observed

- SiliconCompiler: `0.38.2`
- Yosys: `0.68+120`
- Verilator: `5.051 devel rev v5.050-251-g477b48fb3`

## Blocked

- Official native `sc-install -group asic digital-simulation` was attempted, but stopped at `sudo apt-get update` because this session cannot provide a sudo password.
- Docker is installed on Windows, but this WSL distro does not have Docker Desktop integration enabled, so `docker version` fails from Ubuntu.
- The user-space OSS CAD Suite fallback installed here does not include OpenROAD or KLayout, so this session cannot produce GDSII yet.
- SiliconCompiler halted before execution because required physical-design/signoff executables were missing: `openroad`, `sta`, and `klayout`.

## Next Environment Fix

Enable one of:

- non-interactive sudo or manual installation of the `sc-install -group asic digital-simulation` prerequisites, then rerun `./scripts/setup.sh`
- Docker Desktop WSL2 integration for this Ubuntu distro, then run the SiliconCompiler Docker scheduler

After either fix, rerun:

```bash
./scripts/check_environment.sh
PATH="$PWD/.sc-tools/bin:$PWD/.sc-tools/oss-cad-suite/bin:$PATH" .venv/bin/python flows/example_flow.py
```
