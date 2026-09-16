# UART 16550

This directory contains the imported OpenCores/freecores UART 16550-compatible
RTL and its original verification collateral. The import is retained as a
source baseline; generated simulator output and tool-specific run state do not
belong in the source tree.

## Source boundaries

- `rtl/verilog/`: active RTL baseline used by the Verilator checks.
- `rtl/verilog-backup/`: historical RTL snapshot shipped by the upstream tree;
  do not compile it together with `rtl/verilog/`.
- `bench/verilog/`: original OpenCores/NCSim-oriented testbench and test cases.
- `sim/rtl_sim/`: original Cadence/ModelSim scripts and archived logs.
- `doc/`: upstream specification and change history.
- `sim/verilator/`: repository-owned, repeatable Verilator smoke test.

The original testbench is useful reference material, but it is not the current
Verilator entry point. It uses simulator-specific behavior such as cross-top
references to `testcase` and legacy named-block control flow.

## Verilator smoke test

From the repository root:

```bash
make -C designs/uart16550/sim/verilator
```

This performs a timing-aware lint/elaboration and runs a small loopback test
through the Wishbone register interface. Build products are written under
`build/uart16550/verilator/` and are ignored by Git.

The RTL is LGPL-licensed upstream code. Preserve the upstream notices when
modifying or redistributing it; new repository-owned test collateral is covered
by the repository's own licensing decision.
