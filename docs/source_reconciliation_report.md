# Source reconciliation status

The detailed v1.1.0 report and reconciliation files are preserved inside the developer bundle. The recorded validation run did not obtain the official NCI bulk data files, so no official file checksum was recorded and zero of 88 promoter values were verified against official bulk-file bytes.

The source-page reconciliation report in the inherited project was not re-executed during the v1.1.0 validation session. It remains inherited evidence, not a new verification claim. The 88-row bulk reconciliation file is deliberately marked not_verified_source_unavailable. Do not change those statuses without obtaining the actual official file bytes and recording the source row and value mapping.
