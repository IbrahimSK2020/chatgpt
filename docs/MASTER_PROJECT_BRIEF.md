# MASTER PROJECT BRIEF: TP53 FUNCTIONAL ADJUDICATION BENCHMARK

## Your role

Act as a senior computational biologist, molecular oncology researcher,
bioinformatics engineer, benchmark architect, adversarial test engineer,
and quality-assurance reviewer. You are entering this project for the
first time. Do not assume access to previous conversations or hidden
context.

This is a hands-on assignment. Inspect the supplied project, audit it,
make improvements directly to its files, run the tests, package the
outputs, and report what was actually completed. Do not stop at
suggestions or a plan.

## Project purpose

Project name: **Clinical TP53 Variant Functional Adjudication**.

The benchmark evaluates whether an AI can interpret functional assay
data for TP53 variants, calculate standardized assay classifications,
separately adjudicate overall functional phenotype using evidence,
document its reasoning, recognize uncertainty, and avoid unsupported
clinical conclusions.

The task uses a yeast-based transcriptional assay with eight promoter
measurements per variant. The benchmark is for research and evaluation
only, not clinical diagnosis or treatment. Do not present functional
assay results as definitive clinical pathogenicity determinations.

## Starter archive

A project archive should be attached to this conversation. If it is not
attached, ask for it before attempting repository-specific changes.
Expected filename:

`clinical-tp53-variant-adjudication-v1.0.0.zip`

Expected contents may include task data, promoter measurements, source
manifests, an Oracle, reference answers, a reference submission, an
independent verifier, JSON schemas, tests, instructions, README, source
documentation, human-review rubric, and validation reports. These
expected paths are not proof that files exist; inventory the actual
archive.

The starter is expected to contain 11 cases and 88 promoter
measurements. Independently verify those counts. Do not assume existing
labels, Oracle output, tests, or documentation are scientifically
correct simply because they are present or tests pass.

## Scientific source and assay thresholds

The project references the National Cancer Institute (NCI) TP53 Database
R21 release, associated with January 2025, and documentation for the
Kato yeast transactivation assay. Verify the current source and exact
definitions against official documentation before release.

The benchmark's documented median activity thresholds are: - Median
\<=20% of wild type: `functionally_abnormal` - Median \>20% and \<=75%:
`mixed_or_context_dependent` - Median \>75% and \<=140%:
`functionally_preserved` - Median \>140%: described in the source as
supertrans; the current benchmark maps it to `functionally_preserved`
under its four-label scheme only if that mapping is justified and
clearly documented.

Implement boundaries exactly and test exact values and values
immediately above/below each threshold. Do not confuse the numerical
assay classification with the overall functional phenotype adjudication.
Do not combine yeast measurements with data from unrelated assays or
experimental systems when calculating the standardized median.

## Source reconciliation

The starter measurements are believed to have been curated from official
NCI TP53 variant detail pages. Prior manual reconciliation reportedly
covered 11 variant identities and 88 promoter measurements, including a
p.R156C notation correction and p.V31I addition. However, a complete
row-by-row comparison against a downloaded and checksummed official bulk
data file has not been established.

Treat bulk reconciliation as unresolved until actually performed. Obtain
relevant official files if accessible. Record official URL, retrieval
date, filename, byte size, SHA-256 checksum, release/version, stable
source row/key, exact variant and promoter mapping, curated value,
official value, match status, and discrepancy resolution. Create a
machine-readable CSV with one row per variant/promoter measurement.

If official files cannot be accessed, record the precise blocker. Never
fabricate files, checksums, source rows, or reconciliation success.

## Keep three outputs distinct

1.  **Standardized assay classification:** Calculate from the eight
    promoter measurements using the documented median thresholds.
2.  **Overall functional phenotype adjudication:** Assess the permitted
    evidence separately, accounting for promoter heterogeneity,
    experimental context, splice effects, conflicting evidence, and
    limitations. Do not simply copy the assay bin. Use uncertainty when
    evidence is insufficient.
3.  **Clinical pathogenicity:** Outside the benchmark's scope. Required
    value: `not_assessed`. Enforce this in instructions, schemas where
    appropriate, Oracle, verifier, reference answers, and tests.

## Evidence rules

All conclusions must be traceable to supplied or verified evidence. Do
not infer dominant-negative effects, loss of function, splice effects,
or other mechanisms solely from hotspot status, variant familiarity,
cancer association, or predictions. Do not treat missing evidence as
evidence of absence. Never invent evidence identifiers or use unrelated
assays to fill missing measurements. Distinguish direct experimental
evidence from inference and record contradictions rather than silently
resolving them.

The overall phenotype labels may be provisional or single-curator. Do
not call them independently validated unless qualified independent
review actually occurred. Create a blinded review worksheet that hides
existing labels and rationales, includes the evidence needed for
adjudication, uses a structured rubric, records confidence, and tracks
disagreements and resolutions.

## Oracle requirements

Inspect and strengthen the reference Oracle. It must deterministically
generate a schema-conformant reference submission from frozen task data
and an approved adjudication key. It must fail clearly on
missing/extra/duplicate cases, missing/extra/duplicate promoters,
malformed or invalid numeric measurements, inconsistent medians,
unsupported labels, missing reference fields, invalid evidence
identifiers, inconsistent source annotations, and clinical-scope
violations.

No silent substitutions, invented evidence, or network access during
execution. Add tests for deterministic output and malformed inputs. Keep
the Oracle, answer key, and reference submission out of the solver-only
package.

## Independent verifier requirements

The verifier must not import the Oracle or reuse its calculation
functions. Independently recompute numerical values from task input.
Validate schema, exact case coverage, duplicates, unknown IDs, labels,
promoter counts, medians, assay and overall classifications, evidence
IDs, source annotations, clinical-scope restrictions, and rationale
structure. Check unsupported claims where reliable programmatic checks
are possible.

Return machine-readable JSON with total score, per-case breakdown,
individual errors, failed requirements, evidence/provenance violations,
and limitations. A matching label must not receive full credit if
evidence is fabricated or scope restrictions are violated. State clearly
that automated verification cannot fully establish the scientific
validity of unrestricted natural-language rationales.

## Adversarial testing

Run comprehensive unit and integration tests, including: - Thresholds
exactly at 20, 75, and 140 and values immediately above/below them. -
Values above 100% wild-type activity. - Missing, duplicate, extra,
negative, non-finite, and non-numeric measurements. - Missing,
duplicate, and unexpected case identifiers. - Missing or duplicate
promoters. - Incorrect medians, swapped labels, wrong source
annotations, and invented evidence IDs. - Unsupported dominant-negative
or loss-of-function claims. - Splice-confounded cases, conflicting
evidence, and uncertainty handling. - Unsupported clinical pathogenicity
claims. - Oracle determinism, row-order invariance where appropriate,
verifier independence, malformed submissions, and solver-package
leakage.

Use deliberately incorrect submissions to measure what the verifier
catches. Synthetic data may be used only as clearly labelled
software-test fixtures, never as real biological evidence. Justify
additional dependencies.

## Benchmark difficulty and expansion

Evaluate whether 11 cases are sufficiently diverse. Assess sample size,
hotspot bias, threshold coverage, promoter heterogeneity, and evidence
quality. Propose an expanded cohort with source-supported borderline
medians, discordant promoter responses, non-hotspot variants,
splice-confounded variants, conflicting contexts, incomplete evidence,
and cases where uncertainty is appropriate.

Do not fabricate biological values or add cases merely to achieve a
desired label. Add real cases only after source verification and review.
Difficulty must arise from genuine scientific reasoning, not broken
rules, corrupted inputs, or a defective verifier.

## Packaging and answer-key protection

Produce two distributions:

**Developer package:** full source, Oracle, answer key, reference
submission, tests, curation materials, and validation reports.

**Solver-only package:** task instructions, permitted data, schemas,
legitimate solver-facing files, and necessary public-source
documentation. Exclude Oracle, answer key, gold reference submission,
hidden scoring logic, and accidental answer-key copies.

Recursively inspect archive paths and file contents for leakage,
including backups and generated files. Generate SHA-256 manifests and
verify ZIP integrity. Do not claim the package is leak-free just because
the Oracle directory is absent.

## Required documentation

Update or create equivalent files for: - `README.md` -
`instruction.md` - `sources.md` - `CHANGELOG.md` -
`docs/human_review_rubric.md` - `validation/test_results.txt` -
`validation/known_limitations.md` -
`validation/bulk_reconciliation.csv` -
`validation/source_reconciliation_report.md` -
`validation/reference_verifier_report.json` -
`validation/solver_bundle_audit.json` - `validation/file_hashes.sha256`

Document setup, dependencies, commands, input/output formats,
thresholds, scoring, attribution, limitations, and the difference
between technical validity and scientific readiness. Record actual
commands, versions, output, and exit codes. Never invent test results.

## Mandatory workflow

1.  Inventory the actual archive and files.
2.  Read instructions, data, sources, Oracle, verifier, schemas, and
    tests.
3.  Run baseline tests before edits; record commands and actual results.
4.  Verify official scientific sources and reconcile data where
    possible.
5.  Recalculate all medians independently.
6.  Audit provisional overall phenotype labels.
7.  Improve Oracle, verifier, schemas, and tests.
8.  Run adversarial and integration tests.
9.  Improve source reconciliation and human-review materials.
10. Build and audit the solver-only package.
11. Build the developer package.
12. Run all tests against the final files.
13. Verify ZIP integrity and hashes.
14. Return the artifacts and a factual validation report.

If a step is blocked, continue with feasible work and document the
blocker. Never mark incomplete work as complete.

## Release gates

Report two separate statuses.

**Technical completion** requires tests actually executed and passing,
reproducible Oracle/verifier behavior, independent calculations,
schema/input validation, successful package integrity checks, a
documented solver-only leakage audit, and reproducible instructions.

**Scientific release readiness** requires verified data provenance,
completed source reconciliation or explicitly accepted exceptions,
independently recalculated classifications, reviewed overall phenotype
adjudications, a documented review process, qualified independent
scientific review actually completed, and disclosed or resolved material
disagreements.

Passing software tests does not establish scientific release readiness.
If no qualified independent reviewer has completed review, leave that
gate open.

## Final report

Return: 1. Actual project structure and baseline findings. 2. Files
changed and reasons. 3. Sources consulted, reconciliation status,
discrepancies, and scientific-review status. 4. Actual test commands,
counts, results, and exit codes. 5. Verifier performance and
limitations. 6. Developer and solver-only ZIPs, integrity checks,
hashes, and leakage audit. 7. Known limitations and release blockers. 8.
Download links to generated artifacts. 9. Separate final statuses for
technical completion and scientific release readiness.

Never claim work or validation that was not performed. If the
environment allows direct file editing, return the finished project
files and packages rather than code snippets alone.

Preserve this task instruction exactly in the project's task
instructions:

"You have 28800 seconds to complete the analysis. Do not use online
solutions or task-specific external hints."

Start by confirming the archive is available, inventorying its actual
contents, and running the baseline tests. Then proceed with
implementation and validation.
