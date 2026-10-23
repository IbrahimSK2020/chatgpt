Use the supplied evidence packet at /app/data/task_input.json to create /app/submission.json. The submission must conform to /app/schemas/submission.schema.json and contain exactly one object for every supplied case_id.

For each case, calculate the median of the eight yeast promoter activities and apply the packet's thresholds exactly: median <=20% WT is functionally_abnormal; >20% and <=75% is mixed_or_context_dependent; >75% and <=140% is functionally_preserved; >140% is represented as functionally_preserved in this four-label contract, while preserving the supertrans distinction in the rationale where relevant. Do not combine measurements from different cell systems.

Keep the assay-specific label separate from the overall functional phenotype. Consider promoter heterogeneity, experimental context, missing evidence, splice confounding, and conflicts in the supplied packet. Reproduce the NCI annotations exactly; do not infer DNE, LOF, gain-of-function, or clinical pathogenicity from hotspot status or the assay median. Cite only declared source IDs, include the required confidence fields, and keep each rationale evidence-linked. Set top-level and case-level clinical_pathogenicity to not_assessed. Do not add unsupported fields or invent data.

The supplied labels are provisional and have not received qualified independent review. A passing automated check is not scientific validation or clinical advice.

You have 28800 seconds to complete the analysis. Do not use online solutions or task-specific external hints.

You have 28800 seconds to complete this task. Do not cheat by using online solutions or hints specific to this task.
