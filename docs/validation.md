# Validation Log

Date: 2026-09-16

## Completed

- Added and ran the timing-aware UART 16550 Verilator smoke test.
- Verified Wishbone register writes, divisor setup, serial loopback, receive
  status, and received data (`0x5a`) with the active UART RTL.

- Created a Python virtual environment in `.venv/`.
- Installed `siliconcompiler==0.38.2`.
- Verified SiliconCompiler imports and prints version `0.38.2`.
- Downloaded OSS CAD Suite `2026-08-24` and verified SHA-256.
- Verified Verilator runs on `designs/example/tiny_counter.v`.
- Verified Yosys can synthesize `designs/example/tiny_counter.v`.
- Verified Docker Desktop is reachable from WSL when run with Docker socket permissions.
- Pulled and ran `ghcr.io/siliconcompiler/sc_runner:v0.38.2`.
- Verified OpenROAD inside the runner image with `openroad -version`.
- Ran the full FreePDK45/Nangate45 SiliconCompiler flow through the Docker scheduler.
- Produced final GDSII output at `build/tiny_counter/job0/write.gds/0/outputs/tiny_counter.gds.gz`.
- Verified the compressed GDS archive with `gzip -t`.
- Generated final summary image at `build/tiny_counter/job0/tiny_counter.png`.

## Tool Versions Observed

- SiliconCompiler: `0.38.2`
- Local fallback Yosys: `0.68+120`
- Verilator: `5.051 devel rev v5.050-251-g477b48fb3`
- Docker runner Yosys: `0.67`
- Docker runner OpenROAD: `26Q3-411-ga65b06e763`
- Docker runner OpenSTA: `3.1.0`
- Docker runner KLayout: `0.30.9`

## Docker Flow Command

```bash
.venv/bin/python flows/example_flow.py \
  --scheduler docker \
  --docker-image ghcr.io/siliconcompiler/sc_runner:v0.38.2
```

## Flow Result

- Final `write.views/0` step completed with `0` errors and `0` warnings.
- Final setup slack was about `7.910 ns`.
- Final hold slack was about `0.094 ns`.
- Reported `clk` fmax was about `478.50 MHz`.
- Final detailed route reported `0` DRCs.
- Final design area was about `38 um^2` at about `52%` utilization.

## Warnings To Revisit

- `designs/example/tiny_counter.sdc` currently applies `set_input_delay` relative to a clock defined on the same port, which OpenSTA warns is not allowed.
- OpenROAD CTS emitted deprecation warnings for `-balance_levels` and `-obstruction_aware` in the bundled flow scripts.

## Remaining Native Limitation

Official native `sc-install -group asic digital-simulation` was attempted, but stopped at `sudo apt-get update` because this session cannot provide a sudo password. Docker is therefore the working OpenROAD path for this WSL setup.

For future native installation, run `sc-install` from an interactive WSL shell with sudo available, or manually install the apt prerequisites first and rerun:

```bash
./scripts/check_environment.sh
PATH="$PWD/.sc-tools/bin:$PWD/.sc-tools/oss-cad-suite/bin:$PATH" .venv/bin/python flows/example_flow.py
```
