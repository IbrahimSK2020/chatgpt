# Clinical TP53 adjudication task

This branch packages the Clinical TP53 Variant Functional Adjudication pilot as a Harbor-compatible task. The agent receives only the solver-facing evidence packet. The developer archive is used by the separate verifier and reference solution and is not copied into the agent image.

## Run contract

- Agent input: /app/data/task_input.json
- Submission output: /app/submission.json
- Output schema: /app/schemas/submission.schema.json
- Runtime dependencies: Python 3.12 standard library only
- Agent timeout: 28,800 seconds
- Agent internet access: disabled because the task is self-contained and the public staging repository contains developer artifacts.

The environment build extracts only approved solver-facing archive members and rejects unexpected paths. Tests run in a separate no-network Python 3.12 container. The test script always writes a Harbor reward file and normalizes the verifier's objective score to 0–1; schema failures gate the reward to zero.

## Scientific status

Technical completion and scientific release readiness are separate. The linked v1.1.0 validation report records 129 passing tests and a passing solver-only leakage audit. It also explicitly leaves official bulk-file reconciliation and qualified independent review incomplete. The 11-case panel is small and hotspot-heavy; labels are provisional and not suitable for clinical decisions.

The developer archive contains the full project source, Oracle, reference key, verifier, schemas, tests, curation files, and validation artifacts. See docs/FINAL_REPORT.md, docs/MASTER_PROJECT_BRIEF.md, and validation/test_results.txt for the detailed audit record.
