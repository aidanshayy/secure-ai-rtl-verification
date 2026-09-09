# Repository Guidance

## Project Intent

This is a research repository for secure, AI-assisted RTL verification. The
central question is how AI agents can help engineers understand, verify, debug,
and improve RTL while keeping proprietary design data protected and preserving
human accountability.

The repository is intentionally broader than one design or one verification
method. It may contain multiple RTL designs, testbenches, assertions, formal
properties, simulation environments, coverage data, log parsers, agent
experiments, policy controls, and reproducible workflow documentation.

## Scope Priority

Prioritize work in this order:

1. RTL and verification understanding, quality, debug, and measurable research
   experiments.
2. AI-assisted workflows for SVA generation, UVM/testbench scaffolding,
   coverage analysis, log debugging, design understanding, test planning,
   failure triage, and related verification tasks.
3. Secure, local-first agent orchestration, data classification,
   anonymization, audit trails, tool permissions, and human approval points.
4. SiliconCompiler integration for reproducible lint, simulation, synthesis,
   formal, and other verification-facing workflows.
5. Full RTL-to-GDSII execution only as a supporting baseline or as evidence
   that a verification finding has downstream implementation impact.

The existing SiliconCompiler ASIC configuration is valuable infrastructure,
but physical design and GDSII signoff are not the primary research objective.
Do not expand physical-design automation unless it directly supports an RTL
verification question or a documented experiment.

## Centaur Workflow

Treat the Centaur workflow as a research direction for coordinating tools,
artifacts, and AI agents across a verification loop. When adding Centaur-related
work, document the workflow stages, inputs and outputs, agent permissions,
human checkpoints, and evidence used to reach conclusions. Prefer small,
reproducible experiments over an opaque autonomous system.

## Engineering and Research Expectations

- Keep raw RTL, logs, waveforms, coverage, and other potentially sensitive
  artifacts local by default.
- Make data exposed to an AI model explicit, minimized, and auditable.
- Require human review before accepting generated assertions, tests,
  constraints, RTL edits, or signoff conclusions.
- Record tool versions, commands, assumptions, and evaluation criteria for
  experiments.
- Keep examples runnable and separate generated build output from durable
  source artifacts.
- Do not treat an AI response as verification evidence without reproducible
  tool results or a clearly labeled human judgment.

## Repository Orientation

- `designs/`: RTL designs and design-specific collateral.
- `flows/`: reproducible SiliconCompiler and verification workflow entry points.
- `docs/`: research scope, experiment notes, environment, usage, and validation.
- `scripts/`: setup and environment checks.
- `build/` and other generated outputs: disposable run artifacts, not research
  conclusions unless captured in documentation.

When a task is ambiguous, choose the smallest verification-focused experiment
that produces inspectable artifacts and update the relevant documentation.
