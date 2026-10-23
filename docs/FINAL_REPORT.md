# Final report — Clinical TP53 Variant Functional Adjudication v1.1.0

**Date:** 2026-10-23
**Scope of this report:** what was actually done, what the tests actually
returned, what was verified against official sources, where scientific
disagreement remains, and what still blocks release.

This report separates claims by evidence class. Anything not demonstrated in
this session is marked as such, including work inherited from the prior curator.

---

## 1. Verdict

| Standard | Status |
|---|---|
| **Technical completion** | **ACHIEVED.** Oracle, independent verifier, schemas, tests and packaging operate correctly and reproducibly. 129 tests pass. |
| **Scientific release readiness** | **NOT ACHIEVED.** Official-source reconciliation is blocked, no qualified independent review has occurred, and the cohort is too small and too hotspot-heavy to support benchmark claims. |

Release gates G4–G7 pass. **G1, G2, G3, G8, G9 and G10 fail.** The definitions
are in `docs/cohort2_proposal.md`.

This build must not be described as an expert-panel gold standard, and must not
be used for clinical decision-making.

---

## 2. Baseline audit of the inherited v1.0.0 build

Executed before any change was made:

- `python3 -m unittest discover -s tests -v` → **28 tests, OK**, exit 0.
- `python3 oracle/oracle.py` output was **byte-identical** to the committed
  `oracle/reference_submission.json`.
- `python3 verifier/verify.py docs/reference_submission_example.json` → **PASS**,
  exit 0.

The inherited build was functional. Its tests passing did not, however, mean it
was correct: the defects in §5 were all present in a build whose suite was green.

---

## 3. Independent scientific re-verification (completed)

### 3.1 Medians recomputed from raw values

All 11 medians were recomputed from the 88 raw measurements using **exact
rational arithmetic** (`fractions.Fraction`), not floating point, so the check
could not inherit the Oracle's own rounding behaviour. All 11 reproduce the
stored key exactly, with zero drift. This is now pinned by
`test_data_integrity.py::test_key_medians_match_exact_rational_recomputation`.

### 3.2 Cross-file consistency

`data/task_input.json`, `data/promoter_activities.csv` (88 rows) and
`data/source_reconciliation.csv` agree with each other on every measurement,
every variant identity, every cDNA notation and every source URL. The source
manifest and the in-JSON source registry contain identical identifier sets.

### 3.3 Agreement with NCI's own classification

The project recomputes its bins from raw values rather than copying NCI's
`TransactivationClass`. Comparing the two as an independent check:

| Case | Variant | Median % WT | Recomputed bin | NCI class | Agree |
|---|---|---:|---|---|---|
| TP53-001 | p.R175H | 9.15 | functionally_abnormal | non-functional | yes |
| TP53-002 | p.R248Q | 0.00 | functionally_abnormal | non-functional | yes |
| TP53-003 | p.R273H | 0.00 | functionally_abnormal | non-functional | yes |
| TP53-004 | p.R282W | 0.00 | functionally_abnormal | non-functional | yes |
| TP53-005 | p.G245S | 0.00 | functionally_abnormal | non-functional | yes |
| TP53-006 | p.Y220C | 2.25 | functionally_abnormal | non-functional | yes |
| TP53-007 | p.R337H | 69.00 | mixed_or_context_dependent | partially functional | yes |
| TP53-008 | p.R156C | 62.70 | mixed_or_context_dependent | partially functional | yes |
| TP53-009 | p.P72R | 93.60 | functionally_preserved | NA (no class) | n/a |
| TP53-010 | p.G187S | 78.70 | functionally_preserved | functional | yes |
| TP53-011 | p.V31I | 108.75 | functionally_preserved | functional | yes |

**Agreement: 10 of 10** cases where NCI assigns a class. This corroborates the
threshold implementation and the transcription's internal coherence. It does
**not** verify the transcription against official file bytes (§4).

### 3.4 Threshold rule verified against the official manual

The NCI TP53 Database User Manual (<https://tp53.cancer.gov/help>) was retrieved
and read in this session. Its `TransactivationClass` definition states that the
median of the 8 promoter-specific activities is calculated, and variants are
classified non-functional if ≤20, partially functional if >20 and ≤75,
functional if >75 and ≤140, and supertrans if >140. This matches
`data/task_input.json → thresholds` **exactly**. This is a genuine
official-source verification and is the only one completed in this session.

### 3.5 New finding: a cross-system pooling hazard

The same manual documents that `FunctionIshiokaDownload_r21.csv` — the correct
bulk file for this panel — contains both the yeast promoter columns
(`WAF1nWT`, `MDM2nWT`, …) **and** human Saos-2 columns (`WAF1nWT_Saos2`, …)
plus `SubG1nWT_Saos2`. A bulk reconciliation that selects promoter columns by
name prefix would silently pool two cell systems into one median, violating
`curation/criteria.md` §A.

This was not previously documented. Mitigations: the Oracle now refuses any case
whose `cell_system` is not `yeast`, and `validation/bulk_reconciliation.csv`
names the required source column per row. Logged as **D-06**.

---

## 4. Source-verification status: the provenance gate is BLOCKED

**No official data file was obtained. No file checksum is recorded. The
bulk-reconciliation gate is open.**

Two retrieval paths were attempted and both failed:

1. **Container egress.** The allowlist excludes the NCI host; DNS resolution
   fails before any connection (`getent hosts tp53.cancer.gov` → exit 2;
   `curl` → "Could not resolve host", exit 6). The same applies to
   `www.ncbi.nlm.nih.gov` (ClinVar, SRC-016).
2. **Assistant-side retrieval.** Returns rendered page text — which is how §3.4
   was completed — but not raw file bytes. The download controls on the NCI
   downloads page are JavaScript-rendered Google Cloud Storage objects; the
   static HTML exposes no direct file URL.

A SHA-256 is only meaningful over the bytes the official server served. Hashing
extracted page text and labelling it a file checksum would be a fabricated
provenance record, so **none is recorded**.

`validation/bulk_reconciliation.csv` contains all 88 case/promoter rows with
`expected_value_pct_wt` populated, `observed_value_pct_wt` **empty**, and
`match_status = not_verified_source_unavailable` on every row. A test
(`test_bulk_reconciliation_file_exists_and_is_not_marked_complete`) fails if
anyone marks this gate complete without supplying real observed values.

Full detail: `validation/source_access_blocker.md`.

### What this means for the inherited page-level reconciliation

`curation/source_reconciliation_report.md` claims 88 of 88 values were checked
against official variant-detail pages. That claim is **inherited from the prior
curator and was not re-executed in this session**, because those pages are
unreachable. It is neither confirmed nor contradicted here. It should not be
counted as verification performed by this build.

---

## 5. Defects found and fixed

### In the inherited build

| # | Defect | Resolution |
|---|---|---|
| 1 | The shipped JSON schemas were never executed anywhere — documentation, not an enforced contract. | Added dependency-free `verifier/schema_check.py`; wired into the verifier and four tests. |
| 2 | Oracle accepted unsupported label values in the key. | Fails loudly. |
| 3 | Oracle accepted key annotations contradicting the task input. | Fails loudly. |
| 4 | Oracle accepted invented evidence IDs, and IDs not declared in the case's own provenance. | Fails loudly on both. |
| 5 | Oracle read JSON `true` as activity 1.0 (Python `bool` is `int`). | Booleans, nulls, NaN and infinity all rejected. |
| 6 | Oracle would accept a non-yeast panel as the standardized median. | Refuses any `cell_system != "yeast"` (D-06). |
| 7 | The `>140` supertrans branch was implicit fall-through; the subclass was lost silently. | Branch written out explicitly; `panel_subclass()` preserves it; tested. |
| 8 | Oracle output ordering followed input file order. | Sorted by `case_id`; order-invariance tested. |
| 9 | Verifier independence was asserted in a comment only. | Enforced by a test asserting `oracle` is absent from `sys.modules`. |
| 10 | Provenance and scope violations only deducted points; a submission could fabricate evidence and still score 90%. | **Scoring change:** evidence, annotation fidelity and clinical scope are gating — violating any zeroes that case. |
| 11 | Rationale check was satisfiable by bare identifier-stuffing. | Requires ≥8 non-identifier tokens. |
| 12 | `build_solver_bundle.py` rewrote `README_solver.md` as a build side effect. | Removed; a test asserts the working tree is unmodified by a build. |
| 13 | Builds were non-deterministic (timestamps, member order). | Fixed ZIP epoch and sorted members; byte-identical builds tested. |
| 14 | `__pycache__`/`.pyc` artifacts shipped in the release ZIP. | Removed and excluded. |
| 15 | No leakage audit existed. | Added `scripts/audit_solver_bundle.py`. |

### In my own work during this session

Recorded because a report that only lists other people's mistakes is not an
honest audit.

| # | Defect | Resolution |
|---|---|---|
| A | My first leakage audit matched gold tokens at **whole-file** granularity, so the submission schema's field names and the task input's thresholds block registered as leaks on every build — an audit that always fires trains operators to ignore it. | Rewrote to check association **per JSON object**, with proximity matching for non-JSON members, plus a planted-leak negative control test. |
| B | A unit test asserted an incorrect median (110.55; the correct value is 110.5). The code was right and my test was wrong. | Test corrected, with the sorted values shown in a comment. |
| C | The first captured run revealed duplicate and extra-case submissions reporting **score 100.0 with status FAIL** — a misleading score. | Added a coverage gate: invalid case coverage zeroes the reported score, with `raw_points_score` retained for diagnosis. |

---

## 6. Actual test results

Captured verbatim in `validation/test_results.txt`. Environment: Ubuntu 24.04.4
LTS, Python 3.12.3, standard library only (`import jsonschema` →
`ModuleNotFoundError`, confirming no third-party dependency is present).

| Module | Tests | Result |
|---|---:|---|
| `test_data_integrity` | 19 | OK |
| `test_oracle` | 44 | OK |
| `test_verifier` | 54 | OK |
| `test_packaging` | 12 | OK |
| **Total** | **129** | **OK**, exit 0 |

Baseline was 28 tests; the suite grew 4.6×.

Key captured results:

- Oracle determinism: two subprocess runs, SHA-256
  `588e09d1fb2fe00b72b51378cdab34487009f8c126f906c3313ccd9924725cc0` both times.
- Oracle fails loudly with exit 2 and an `ORACLE_ERROR` on stderr for negative
  values, short panels, non-yeast cell systems and fabricated key evidence IDs.
  Stdout stays empty — it never emits a partial artifact.
- Schema validation: both documents `VALID`, exit 0.
- Verifier on the reference: `PASS`, 1100/1100, 0 errors, 0 schema errors.
- Verifier independence: `oracle imported: False`.
- Malformed JSON: exit 1 with a structured FAIL report, no traceback.
- Solver archive audit: `PASS`, 8 members, no leakage, ZIP integrity verified.
- Negative control: the developer archive **fails** the same audit with 147
  findings, proving the detector can actually detect.

### Adversarial battery (`scripts/adversarial_report.py`)

**15 of 15** deliberately incorrect submissions were rejected; the baseline
passed. Coverage included: malformed structure, missing/duplicate/extra cases,
incorrect medians, a threshold-boundary error, swapped labels, collapsing the
overall label into the panel bin, invented evidence identifiers, incorrect
source annotations, clinical-pathogenicity claims at both top and case level,
inadequate and identifier-stuffed rationales, and a smuggled ACMG field.

**What the battery does not catch, and cannot:**

- prose that cites the correct identifiers but reasons incorrectly;
- a label that matches the key while **the key itself is wrong**;
- any error originating upstream in the unreconciled source data (D-04).

---

## 7. Scientific disagreements (unresolved, deliberately not actioned)

### D-09 — TP53-011 (p.V31I) overall label

The overall phenotype is `mixed_or_context_dependent`, justified by a narrative
summary of "partial WAF1/MDM2 activity and retained BAX activity in another
assay". **That conflicting evidence has no identified source row, cell system,
construct or PMID** anywhere in the evidence packet — only prose in
`secondary_evidence_summary`.

Against it stands a complete, source-identified eight-promoter panel with median
108.75% WT, an NCI class of `functional`, and validated-polymorphism status. The
project's own evidence hierarchy (`curation/criteria.md` §D) ranks identifiable
assay records above narrative summaries and requires assay contexts to be kept
separate.

Defensible alternatives a reviewer should weigh: `functionally_preserved` (the
only identifiable evidence shows preserved function); `indeterminate`
(conflicting contexts exist but the conflicting evidence is too poorly specified
to adjudicate); or the current label, if the summarised evidence is judged
sufficient.

**The label was not changed.** Changing a scientific label to match an auditor's
reading, without source access or qualified review, is precisely the failure
mode this project exists to prevent.

### Reviewer questions raised but not decided

- **TP53-009 (p.P72R):** median 93.6% WT, but AIP1 is 50.2 and GADD45 is 64.1 —
  two promoters below 75%, spread 77.1. Whether `functionally_preserved`
  adequately represents that heterogeneity is a legitimate reviewer question.
- **TP53-008 (p.R156C):** spread 34.7–162.8 (128.1 points) around a median of
  62.7. The median summarises a markedly discordant panel.
- **TP53-010 (p.G187S):** the `indeterminate` overall label against a preserved
  protein-only panel is, on the evidence supplied, the best-reasoned adjudication
  in the cohort and is the one case that genuinely tests the task.

### Vocabulary divergences from upstream

- **D-01:** `validated_polymorphism` uses `{Yes, No}`; upstream `Polymorphism`
  uses `{Validated, No, NA}`. Upstream `NA` is unrepresentable.
- **D-02:** `nci_dne_lof_class` admits `NA` and `Indeterminate`, which the
  upstream Giacomelli-derived classifier does not emit. TP53-009 carries `NA`.

Both are left open rather than patched, because fixing them correctly requires
the bulk file (D-04) and both are submission-contract changes best made once.

Full log, including D-05 (the p.R156C correction is inherited and could not be
re-verified) and D-07 (evidence fields are verbatim duplicates in 10 of 11
cases, inviting double-counting): `validation/discrepancy_log.md`.

---

## 8. Independent human review: NOT performed

No qualified independent reviewer has adjudicated any label in this build. I am
not a qualified independent reviewer, and I had already read the answer key
before the review artifacts were built, so I could not have performed a blinded
review even in principle.

What was built instead, for a real reviewer:

- `docs/blinded_review_worksheet.csv` — 11 rows × 36 columns, carrying variant
  identity, all eight promoter values, promoter min/max, the count below 75% WT,
  assay and cell system, NCI annotations, evidence notes and source URL. It
  contains **no** prior label, median or rationale; blinding was verified at
  generation time and is pinned by test. **Every reviewer column is empty.**
- `docs/human_review_rubric.md` — an 8-step rubric that keeps the mechanical
  assay bin separate from the overall adjudication, requires promoter
  heterogeneity to be examined rather than summarised away, requires the
  provenance of any conflicting evidence to be checked before it overrides a
  panel, treats `indeterminate` as a legitimate result, and records confidence
  in the assay and the overall call as two distinct judgements.

Until that worksheet is completed by a qualified reviewer, the answer key is
**provisional**, and every artifact in this build says so.

---

## 9. Benchmark quality assessment

Measured properties of the cohort:

- 11 cases; **6 are canonical hotspots** (55%), all with identical labels on
  both axes.
- **0 cases** have a median within ±5 points of the 20% boundary.
- **0 cases** exceed 140% — the supertrans path is exercised only by unit tests.
- **0 cases** have incomplete panels — the `indeterminate`-from-missingness path
  is likewise untested by real data.
- **1 case** (TP53-010) carries a genuine evidence confound.

**A solver that emits `functionally_abnormal` whenever it recognises a hotspot
codon scores roughly 55% on the overall axis without performing the
adjudication** — the exact inference `instruction.md` forbids. No current test
detects that shortcut at the cohort level, because it is a property of the
cohort rather than of any submission. This is gate G9, and it fails.

`docs/cohort2_proposal.md` specifies a stratified ~40-case redesign covering
non-hotspot variants at both extremes, borderline medians at 20% and 75%,
supertrans cases, high promoter discordance, splice confounding, incomplete
panels, conflicting yeast/Saos-2 contexts, and DNE/LOF discordance — with hard
constraints: no fabricated biology, source reconciliation before any case is
added, blinded review before freeze, and stratum membership kept out of the
task-facing packet.

---

## 10. Release blockers

| ID | Blocker | Gate |
|---|---|---|
| D-04 | Bulk file not retrieved, checksummed or compared; 0 of 88 values verified against official bytes | G1 |
| D-05 | Variant identities, including the p.R156C correction, not re-verified against `MutationView_r21.csv` | G2 |
| — | No qualified independent review of any overall label; worksheet empty | G3 |
| D-10 | 11 cases, 55% hotspot, no boundary or supertrans cases, 1 hard case | G8, G9 |
| D-09 | Unresolved scientific disagreement on TP53-011 | G3 |
| D-01, D-02 | Source-annotation vocabularies diverge from upstream | G1 |
| — | Upstream redistribution terms not re-checked in this session | G10 |

### Order of operations to clear them

1. On a host with NCI egress, download `FunctionIshiokaDownload_r21.csv` and
   `MutationView_r21.csv`; record filename, timestamp, byte size, SHA-256 and
   terms of use.
2. Populate all 88 rows of `validation/bulk_reconciliation.csv` from the
   **non-`_Saos2`** columns only (D-06). Preserve every mismatch; do not
   overwrite curated values.
3. Re-verify the 11 variant identities and resolve D-01, D-02 and D-05 against
   the bulk data.
4. Have a qualified reviewer complete the blinded worksheet; log disagreements
   and resolutions; settle D-09 on the evidence.
5. Only then expand the cohort per `docs/cohort2_proposal.md`.
6. Re-run the full suite, the adversarial battery and the leakage audit; freeze.

---

## 11. Statements this build does not make

For the avoidance of doubt, and because each of these would be easy to imply
from a green test suite:

- It does **not** claim complete official-source reconciliation.
- It does **not** record any official file checksum.
- It does **not** claim independent expert review occurred.
- It does **not** claim its overall phenotype labels are correct.
- It does **not** assign clinical pathogenicity, and the field is pinned to
  `not_assessed` by the Oracle, the verifier, the schema and the tests.
- It does **not** treat a passing test suite as scientific validation.
