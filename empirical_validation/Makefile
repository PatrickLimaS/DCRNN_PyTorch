ROOT := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))
MANIFEST := $(ROOT)manifests/validation_targets.yaml
INPUT_CSV := $(ROOT)reporting/summary_results.csv
OUT_CSV := $(ROOT)reporting/classified_results.csv
OUT_MD := $(ROOT)reporting/classification_summary.md

.PHONY: validate summary clean

validate:
bash $(ROOT)run_validation.sh

summary:
@if [ -f "$(OUT_MD)" ]; then cat "$(OUT_MD)"; else echo "No classification summary yet."; fi

clean:
rm -f "$(OUT_CSV)" "$(OUT_MD)"
