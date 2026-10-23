# Validation limitations

The source archive's captured v1.1.0 run reports 129 passing tests, a passing reference submission, and a solver-only leakage audit. Those are technical checks against the supplied provisional key; they do not establish biological truth.

The task wrapper in this branch was locally tested against the available v1.0.0 archives, not against the remote v1.1.0 archive bytes. The remote archive's byte identity and the complete Harbor/Docker execution have not been independently rechecked in this runtime. Re-run the full suite and the Harbor oracle trial before publishing.

Scientific release remains blocked by incomplete official bulk-source reconciliation, lack of qualified independent review, unresolved label and annotation issues, and the limited hotspot-heavy cohort.
