# Project Scope

## Mission

Explore how AI agents can make RTL verification more effective, explainable,
secure, and reproducible. The repository is a research workspace, not a single
chip project and not a production signoff environment.

## In Scope

- Multiple RTL designs and verification collateral.
- Simulation, lint, formal verification, assertions, UVM, scoreboards, and
  coverage workflows.
- AI assistance for SVA generation, UVM scaffolding, test planning, coverage
  analysis, log debugging, design understanding, and failure triage.
- Agent evaluation and reproducible experiments with explicit evidence.
- Secure handling of proprietary RTL, logs, waveforms, coverage, and reports.
- Centaur workflows coordinating agents, EDA tools, artifacts, and people.
- SiliconCompiler as an orchestration layer for RTL and EDA experiments.
- Selective RTL-to-GDSII runs when they help validate downstream impact or
  provide useful tool and artifact baselines.

## Supporting, Not Primary, Scope

The existing FreePDK45/Nangate45 SiliconCompiler configuration demonstrates a
full RTL-to-GDSII flow. Keep it working as a baseline and use it to study
questions such as whether an RTL or constraint issue propagates into synthesis,
timing, or layout. Do not interpret its presence as a change in project focus:
physical implementation and manufacturing signoff are not the central goals.

## Out of Scope Unless Explicitly Justified

- Building a production-grade autonomous signoff system.
- Treating model-generated assertions, tests, or conclusions as proof without
  tool execution and human review.
- Optimizing placement, routing, or PPA without a verification research link.
- Sending raw proprietary design data to external models by default.
- Adding infrastructure that cannot be reproduced or evaluated from recorded
  inputs, commands, versions, and outputs.

## Definition of a Useful Experiment

An experiment should state:

1. The verification problem and design context.
2. The agent or workflow being evaluated.
3. What data the agent may access and what policy filters apply.
4. Which tools are run and what evidence they produce.
5. How a human reviews or approves the result.
6. The evaluation criteria, limitations, and reproducibility details.

The desired outcome is not merely a fluent model response. It is a documented,
reviewable improvement to verification understanding or workflow efficiency
without weakening design confidentiality or engineering accountability.
