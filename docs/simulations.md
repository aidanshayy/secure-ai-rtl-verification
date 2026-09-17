# RTL simulation with Verilator

This repository treats RTL simulation as the shortest path for a new user.
Keep design inputs and testbenches under `designs/<name>/`; put simulator
configuration beside the testbench under `designs/<name>/sim/verilator/`.
Generated executables, logs, waveforms, and coverage remain under `build/` and
are not source artifacts.

## What must be configured

Every Verilator run needs:

- one top-level testbench module (`--top`),
- the testbench source (`--tb`),
- every RTL source file (`--rtl`, repeated as needed), and
- include directories (`--include`) when the RTL uses `` `include `` files.

The testbench is responsible for clocks, reset, stimulus, assertions or
`$fatal` checks, and finishing with `$finish`. A passing process exit is the
simulation result; text printed by an AI assistant is not verification
evidence without this reproducible run.

## Run a design directly

From the repository root, lint and run the D flip-flop example:

```bash
./scripts/run_verilator.sh --top tb \
  --tb designs/D_Flip_Flop/tb_DFlipFlop.sv \
  --rtl designs/D_Flip_Flop/DFlipFlop.sv \
  --lint-only

./scripts/run_verilator.sh --top tb \
  --tb designs/D_Flip_Flop/tb_DFlipFlop.sv \
  --rtl designs/D_Flip_Flop/DFlipFlop.sv \
  --build-dir build/D_Flip_Flop/verilator
```

The script accepts multiple `--rtl` and `--include` options, so a larger
design can be configured without copying RTL into the simulation directory.
For a repeatable design-local interface, use the Makefile:

```bash
make -C designs/D_Flip_Flop/sim/verilator lint
make -C designs/D_Flip_Flop/sim/verilator run
```

The UART baseline has its own Makefile and needs timing support for legacy
`#1` delays:

```bash
make -C designs/uart16550/sim/verilator
make -C designs/uart16550/sim/verilator coverage
```

## Capture coverage

Coverage is opt-in because it adds instrumentation and can increase runtime:

```bash
./scripts/run_verilator.sh --top tb \
  --tb designs/D_Flip_Flop/tb_DFlipFlop.sv \
  --rtl designs/D_Flip_Flop/DFlipFlop.sv \
  --build-dir build/D_Flip_Flop/coverage \
  --coverage
```

When supported by the installed Verilator version, the run writes:

```text
build/<design>/coverage/coverage.dat   # native Verilator coverage data
build/<design>/coverage/coverage.info  # LCOV-compatible summary
```

Coverage is only meaningful relative to the exact RTL, testbench, tool
version, flags, and seed. Record those with the result before using it in a
research comparison. Line, toggle, and branch coverage do not replace
functional, assertion, or formal coverage.

## Capture waveforms

Compile with `--trace` and add dumping to the testbench, for example:

```systemverilog
initial begin
  $dumpfile("build/D_Flip_Flop/verilator/waves.vcd");
  $dumpvars(0, tb);
end
```

Then run with the same source list and `--trace`. VCD/FST files are useful for
debugging, but can contain sensitive design information; keep them local and
share only an approved, minimized excerpt.

## Results and reproducibility

Inspect the generated directory instead of mixing outputs into `designs/`:

```bash
find build/D_Flip_Flop -maxdepth 3 -type f | sort
```

For each experiment, record the command, Verilator version, source revision,
tool flags, test result, warnings, coverage files, and any known limitations.
Use `$fatal` for failed checks and a clear `PASS:` message for successful
milestones. Human review is required before accepting generated tests,
assertions, constraints, or RTL changes.
