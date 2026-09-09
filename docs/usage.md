# Usage Runbook

This runbook explains how the WSL repo, Python virtual environment, SiliconCompiler, Docker runner, and layout viewers fit together.

The SiliconCompiler flow documented here is a supporting reproducibility
baseline. The primary project scope is RTL verification; use this flow when an
experiment needs lint, synthesis, implementation context, or downstream
evidence for a verification question.

## Component Model

```text
WSL repo
  RTL, constraints, flow scripts, docs, build outputs

WSL .venv
  SiliconCompiler Python package and project orchestration

Docker image
  OpenROAD, OpenSTA, KLayout, Yosys, and other EDA binaries

Temporary Docker containers
  Started by SiliconCompiler when the Docker scheduler runs tool steps

Native WSL KLayout
  Optional GUI viewer for inspecting generated GDS files
```

SiliconCompiler runs locally from `.venv`. When `--scheduler docker` is selected, SiliconCompiler launches local Docker containers from `ghcr.io/siliconcompiler/sc_runner:v0.38.2` for EDA tool execution. The containers mount the working files they need and write logs, reports, metrics, and final outputs back into the repo under `build/`.

This is not a cloud run. Docker Desktop provides the local container runtime.

## Activate The Project

From WSL:

```bash
cd /home/adshay17/code/secure-ai-rtl-verification
source .venv/bin/activate
```

If the virtual environment is not activated, use `.venv/bin/python` explicitly in commands.

## Check The Environment

```bash
./scripts/check_environment.sh
```

This checks the local Python/SiliconCompiler setup, local fallback tools, and whether the SiliconCompiler Docker runner can execute OpenROAD.

If Docker is not visible from WSL, open Docker Desktop on Windows and enable:

```text
Settings -> Resources -> WSL Integration
```

Then restart WSL from PowerShell:

```powershell
wsl --shutdown
```

## Run The Example Flow Through Docker

```bash
python flows/example_flow.py \
  --scheduler docker \
  --docker-image ghcr.io/siliconcompiler/sc_runner:v0.38.2
```

Equivalent form without activating `.venv`:

```bash
.venv/bin/python flows/example_flow.py \
  --scheduler docker \
  --docker-image ghcr.io/siliconcompiler/sc_runner:v0.38.2
```

This command means:

- `python`: run the local Python interpreter from `.venv` when activated
- `flows/example_flow.py`: execute the SiliconCompiler flow recipe
- `--scheduler docker`: use Docker containers for EDA tool steps
- `--docker-image ghcr.io/siliconcompiler/sc_runner:v0.38.2`: use the pinned SiliconCompiler runner image

## Run A Different RTL Design

For a new design, keep source inputs in the repo and update the flow recipe.

Recommended layout:

```text
designs/<design_name>/
  rtl files
  constraints
  notes

flows/
  <design_name>_flow.py
```

For the current example, `flows/example_flow.py` declares:

- design name: `tiny_counter`
- top module: `tiny_counter`
- RTL input: `designs/example/tiny_counter.v`
- SDC input: `designs/example/tiny_counter.sdc`
- build output root: `build/`

When adding a real design, copy the example flow and change the design name, top module, RTL files, constraints, and any flow settings. Then rerun with the same Docker scheduler pattern:

```bash
.venv/bin/python flows/<design_name>_flow.py \
  --scheduler docker \
  --docker-image ghcr.io/siliconcompiler/sc_runner:v0.38.2
```

## Inspect Flow Outputs

SiliconCompiler writes run data under:

```text
build/tiny_counter/job0/
```

Useful starting points:

```bash
less build/tiny_counter/job0/job.log
ls build/tiny_counter/job0/write.gds/0/outputs
find build/tiny_counter/job0/write.views/0/reports -maxdepth 3 -type f | sort
```

Important output files from the example flow:

```text
build/tiny_counter/job0/job.log
build/tiny_counter/job0/tiny_counter.pkg.json
build/tiny_counter/job0/tiny_counter.png
build/tiny_counter/job0/write.gds/0/outputs/tiny_counter.gds.gz
```

The `build/` directory is ignored by Git because EDA outputs can become large.

## Open The Layout In Native WSL KLayout

Use Docker for the reproducible flow, then use native WSL KLayout as the GUI viewer.

Install native WSL KLayout if needed:

```bash
sudo apt-get update
sudo apt-get install -y klayout
```

Open the example GDS:

```bash
cd /home/adshay17/code/secure-ai-rtl-verification
mkdir -p results/tiny_counter
gzip -dkc build/tiny_counter/job0/write.gds/0/outputs/tiny_counter.gds.gz > results/tiny_counter/tiny_counter.gds
klayout results/tiny_counter/tiny_counter.gds
```

The decompressed copy under `results/` is a convenience viewing artifact. The authoritative flow output remains under `build/`.

## Open The Output Folder In Windows

If using Windows KLayout instead of WSL KLayout:

```bash
explorer.exe "$(wslpath -w results/tiny_counter)"
```

Or open the original SiliconCompiler output folder:

```bash
explorer.exe "$(wslpath -w build/tiny_counter/job0/write.gds/0/outputs)"
```

## Enter The Docker Runner Manually

Use an interactive container when learning or debugging tool commands:

```bash
cd /home/adshay17/code/secure-ai-rtl-verification

docker run --rm -it \
  -v "$PWD:/work" \
  -w /work \
  ghcr.io/siliconcompiler/sc_runner:v0.38.2 \
  /bin/bash
```

Inside the container:

```bash
openroad -version
yosys -V
sta -version
klayout -v
find build/tiny_counter/job0 -name "*.odb" -o -name "*.def" -o -name "*.sdc" -o -name "*.vg" | sort
```

This is a scratchpad path. Commands run manually inside the container are useful for learning, but durable project changes should be captured in flow scripts, constraints, or configuration files.

## Try KLayout GUI From Inside Docker

GUI applications inside Docker are less reliable than command-line EDA tools because the container must forward its display to WSLg/Windows. Prefer native WSL KLayout for normal viewing.

If you still want to try:

```bash
cd /home/adshay17/code/secure-ai-rtl-verification

docker run --rm -it \
  -v "$PWD:/work" \
  -w /work \
  -e DISPLAY="$DISPLAY" \
  -e WAYLAND_DISPLAY="$WAYLAND_DISPLAY" \
  -e XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /mnt/wslg:/mnt/wslg \
  ghcr.io/siliconcompiler/sc_runner:v0.38.2 \
  /bin/bash
```

Inside the container:

```bash
QT_QPA_PLATFORM=xcb LIBGL_ALWAYS_SOFTWARE=1 klayout build/tiny_counter/job0/write.gds/0/outputs/tiny_counter.gds.gz
```

If it stalls or does not create a window, exit and use native WSL KLayout.

## When To Edit The Flow Versus Use An Interactive Container

Edit `flows/example_flow.py` or related config when the change should be repeatable:

- changing RTL or SDC inputs
- changing the target or flow setup
- changing placement, routing, timing, or reporting options
- collecting repeatable metrics for comparisons
- creating a research artifact that another user or machine can rerun

Use an interactive Docker container when exploring:

- learning OpenROAD commands
- inspecting generated intermediate files
- trying a Tcl command before encoding it in the flow
- debugging a failed step
- checking tool versions or filesystem layout

Recommended loop:

1. Run the SiliconCompiler Docker flow.
2. Inspect logs, reports, images, and GDS.
3. Experiment manually inside the Docker runner if needed.
4. Encode useful changes in the flow or constraints.
5. Rerun and compare generated output under `build/`.
