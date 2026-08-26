# Research Direction

This project is a baseline for secure AI-assisted RTL verification and EDA workflow research.

The near-term direction is to build an AI harness that extracts useful but anonymized information from EDA logs, reports, manifests, and metrics, sends only approved context to an LLM, and collects meaningful engineering feedback. The first target is helping verification engineers identify RTL issues. Over time, the same harness can expand toward the broader RTL-to-GDSII process.

## Initial Research Thesis

EDA tools already emit rich diagnostic information:

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

These artifacts are useful to engineers, but they may also contain sensitive design information. The harness should treat logs and reports as data that must be classified, filtered, summarized, and audited before it reaches any external or less-trusted AI model.

## Phase 1 Focus

The first useful harness should focus on RTL and verification-facing issues:

- parse Verilator, Yosys, SiliconCompiler, OpenSTA, and OpenROAD logs
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
- support formal-verification and simulation artifacts
- integrate multiple tools behind a policy-controlled interface

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

