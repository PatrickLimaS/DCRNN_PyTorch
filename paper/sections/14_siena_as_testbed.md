# Siena as a Multi-Channel Temporal Testbed

## Role in this project

The Siena Scalp EEG Database (PhysioNet v1.0.0, 2020) is used as a
testbed for the cascade's multi-channel temporal regime, not as a
seizure-detection benchmark.

- As a testbed, Siena exercises Stage A ingestion under genuinely
  multi-channel data and exercises the recurrent coordination core
  under a signal regime where ruptures of regularity are densely
  annotated.
- As a benchmark, Siena would require multi-patient splits, held-out
  test patients, and comparison against published seizure-detection
  baselines (Shoeb 2010, Truong 2018, Roy 2019), which is out of scope
  for the present work.

No benchmark claim is made. No ranking against seizure-detection
literature is attempted.

## Why Siena fits the stack

- Multi-channel native (29-35 scalp EEG channels per recording).
- Annotated ruptures of regularity (seizure onset/offset per second).
- Graph-valued substrate (10-20 electrode positions form a spatial
  graph; DCRNN is a spatiotemporal graph operator).

## Claim scope

Does claim (Tier 1, once results are produced): the cascade's ingestion
stage accepts real multi-channel temporal data without manual
per-sensor synchronisation; the recurrent core can be applied to EEG
input; preprocessing is reproducible.

Does not claim: that any resulting metric competes with published
seizure-detection baselines; that the cognitive stack's proposed layers
participate in anything operational; that performance generalises.

## Separation from benchmark claims

Any number reported on Siena is labelled as "testbed result" or
"pipeline validation." Neither label permits transfer to seizure-
detection comparison tables.

## Relation to the baseline gate

The dcrnn_baseline reproduction gate (METR-LA traffic forecasting) is
independent of Siena. Siena work does not substitute for clearing that
gate. Both tracks proceed in parallel.
