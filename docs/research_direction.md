# Research Direction

This project is primarily about secure AI-assisted RTL verification research.
The repository may include many designs and workflows, but each addition
should help answer a verification question or make a verification experiment
more reproducible.

The near-term direction is to build small, measurable agent workflows that
extract useful but approved information from RTL and verification artifacts,
send only necessary context to an AI model, and collect structured engineering
feedback. SiliconCompiler remains useful for orchestrating reproducible EDA
steps and for connecting RTL findings to synthesis or implementation behavior,
but broader physical-design automation is secondary.

## Core Research Themes

The repository should be able to host experiments in:

- SVA generation, mutation, explanation, and human review.
- UVM/testbench scaffolding and stimulus suggestions.
- Coverage-gap analysis and targeted test or assertion proposals.
- Simulation, lint, formal, synthesis, and regression-log debugging.
- Design understanding: module summaries, interfaces, protocols, state
  machines, dependencies, and change impact.
- Verification planning and traceability from requirements to checks.
- Agent evaluation: correctness, usefulness, reproducibility, time saved,
  false positives, missed issues, and unsafe suggestions.

## Centaur Workflow Direction

Centaur is a working direction for a coordinated verification workflow. A
typical experiment may look like:

```text
RTL and verification intent
        -> context preparation and policy checks
        -> agent proposes plan, assertions, tests, or diagnosis
        -> human approval where required
        -> simulator / formal / lint / coverage tools
        -> artifact and result extraction
        -> agent analyzes evidence and proposes next action
        -> human records the conclusion
```

Each workflow should make its tool boundaries, permissions, state, artifacts,
and approval gates visible. The goal is not unrestricted autonomy; it is a
repeatable way to study how agents can help verification engineers while
keeping evidence and accountability clear.

## Initial Research Thesis

Verification and EDA tools already emit rich diagnostic information:

- lint warnings
- synthesis warnings
- timing reports
- constraint warnings
- optimized-away logic
- unconnected nets
- area and cell-count changes
- placement and routing metrics
- DRC and antenna-repair results
- clock-tree and hold/setup timing reports
- power, IR-drop, and congestion summaries
- simulation transcripts and waveforms
- assertion failures and formal counterexamples
- code, functional, and assertion coverage
- UVM reports, objections, phase activity, and scoreboard failures

These artifacts are useful to engineers, but they may also contain sensitive design information. The harness should treat logs and reports as data that must be classified, filtered, summarized, and audited before it reaches any external or less-trusted AI model.

## Phase 1 Focus: RTL Verification Assistant

The first useful harness should focus on RTL and verification-facing issues:

- parse simulator, Verilator, formal, UVM, Yosys, SiliconCompiler, OpenSTA,
  and OpenROAD logs as appropriate to an experiment
- extract errors, warnings, metrics, and suspect design symptoms
- map tool messages back to source files, modules, constraints, or flow stages
- anonymize module names, signal names, file paths, hierarchy, and proprietary values where needed
- preserve enough context for an LLM to produce useful engineering guidance
- collect the LLM response as a structured assistant report
- keep raw logs local and record what was exposed

The output should help answer questions such as:

- Did the RTL lint cleanly?
- Did synthesis optimize away logic unexpectedly?
- Are resets, clocks, or constraints suspicious?
- Did timing fail because of RTL structure, constraints, or physical effects?
- Which warnings are likely benign, and which deserve review?
- What should a verification engineer inspect next?

## Later Expansion

After the RTL-first workflow is stable, the harness can expand into more of the RTL-to-GDSII flow:

- compare metrics across runs
- detect regressions in timing, area, power, DRCs, and congestion
- summarize placement/routing failures
- identify physical-design symptoms that point back to RTL or constraints
- connect screenshots and report summaries to explain APR outcomes
- generate human-review checklists
- support formal-verification, simulation, assertion, and coverage artifacts
- integrate multiple verification tools behind a policy-controlled interface

## Human In The Loop

Human-in-the-loop RTL verification should remain central. The AI should not be treated as an autonomous signoff authority.

Useful HILT patterns include:

- AI proposes likely issue categories; engineer confirms or rejects them
- AI drafts a debug checklist; engineer chooses what to run
- AI summarizes warnings; engineer marks severity and false positives
- AI suggests assertions, tests, or constraints; engineer reviews before use
- AI compares runs; engineer approves conclusions before they are recorded

The harness should capture this interaction history so later experiments can study whether AI assistance improved debugging speed, reduced missed warnings, or introduced new risks.

## Agentic AI Direction

Agentic workflows may eventually coordinate multiple tools:

- run lint
- run simulation
- run synthesis
- run selected APR stages
- parse logs
- ask for human approval
- modify tests or constraints
- rerun targeted checks
- produce an audit trail

For this project, agentic behavior should be gated by policy. The agent should have explicit permissions for what it may read, what it may modify, which tools it may run, and what data it may send to a model.

## Security And Anonymization Questions

Important research questions:

- What data in EDA logs can reveal proprietary RTL?
- Which identifiers should be redacted, hashed, generalized, or preserved?
- How much context does an LLM need to be useful?
- Can useful guidance be produced from metrics and anonymized snippets alone?
- How should prompts and model outputs be audited?
- What should remain local when using cloud LLMs?
- When should a local model be required?
- How should tool permissions be represented and enforced?
- How should the system prove that sensitive RTL was not exposed?

## Valuable Artifacts

For a physical-design engineer, the most valuable artifacts are usually timing reports, DRC/routing reports, congestion, utilization, power, IR-drop, tool warnings, and final layout inspection.

For an RTL or verification engineer, the most valuable artifacts are usually lint warnings, synthesis warnings, optimized-away logic, clock/reset issues, constraint mismatches, timing paths, simulation failures, assertions, and coverage data.

Visuals are useful for intuition and sanity checks. Logs and reports usually drive engineering decisions.

## Guiding Principle

The project should make AI assistance useful without making sensitive design exposure casual. The harness should be designed around local-first data collection, explicit policy, reversible anonymization where appropriate, human approval points, and reproducible EDA runs.
