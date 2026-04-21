#!/usr/bin/env python3
import argparse, csv, math, pathlib, sys, yaml

REQUIRED = [
    "target_id","variant","in_scope","role","n_seeds","seed_std",
    "effect_vs_baseline","effect_sigma_ratio","replicated",
    "baseline_collapse","null_observed"
]

def b(v):
    s = str(v).strip().lower()
    if s in ("true","1","yes","y"): return True
    if s in ("false","0","no","n",""): return False
    raise ValueError(f"bad bool: {v}")

def f(v):
    s = str(v).strip().lower()
    if s in ("","nan","none","null"): return float("nan")
    return float(v)

def i(v):
    return int(str(v).strip())

def classify(r):
    if not b(r["in_scope"]) and b(r["null_observed"]):
        return "INCONCLUSIVE", "scope_confirmation_not_falsification"
    if not b(r["in_scope"]) and not b(r["null_observed"]):
        return "INCONCLUSIVE", "out_of_scope_positive_requires_scope_review"
    if b(r["baseline_collapse"]):
        return "FAILED-REOPEN", "underperforms_baseline_in_scope"
    if i(r["n_seeds"]) < 3:
        return "INCONCLUSIVE", "insufficient_seeds"
    es = f(r["effect_sigma_ratio"])
    if math.isnan(es) or es < 2.0:
        return "INCONCLUSIVE", "effect_within_noise"
    if not b(r["replicated"]):
        return "INCONCLUSIVE", "needs_replication"
    return "FOLLOW THROUGH", "scope_matched_replicated_strong_effect"

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--manifest", required=True)
    ap.add_argument("--input-csv", required=True)
    ap.add_argument("--out-csv", required=True)
    ap.add_argument("--out-md", required=True)
    args = ap.parse_args()

    with open(args.manifest) as fh:
        manifest = yaml.safe_load(fh)
    targets = {t["id"]: t for t in manifest.get("targets", [])}

    with open(args.input_csv) as fh:
        rows = list(csv.DictReader(fh))

    if not rows:
        pathlib.Path(args.out_csv).write_text(",".join(REQUIRED + ["verdict","rationale"]) + "\n")
        pathlib.Path(args.out_md).write_text("# Classification summary\n\n_No rows found._\n")
        return 0

    for n, r in enumerate(rows, 1):
        miss = [c for c in REQUIRED if c not in r]
        if miss:
            raise ValueError(f"row {n} missing columns: {miss}")
        if r["target_id"] not in targets:
            raise ValueError(f"row {n} unknown target_id: {r['target_id']}")
        t = targets[r["target_id"]]
        if b(r["in_scope"]) != bool(t["in_scope"]):
            raise ValueError(f"row {n} in_scope mismatch for {r['target_id']}")
        if str(r["role"]).strip() != str(t["role"]).strip():
            raise ValueError(f"row {n} role mismatch for {r['target_id']}")

    verdicts = [classify(r) for r in rows]

    fields = list(rows[0].keys()) + ["verdict","rationale"]
    with open(args.out_csv, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=fields)
        w.writeheader()
        for r, (v, why) in zip(rows, verdicts):
            out = dict(r)
            out["verdict"] = v
            out["rationale"] = why
            w.writerow(out)

    lines = [
        "# Classification summary", "",
        "| Verdict | Count |",
        "| --- | ---: |",
    ]
    for v in ("FOLLOW THROUGH","INCONCLUSIVE","FAILED-REOPEN"):
        lines.append(f"| {v} | {sum(1 for x,_ in verdicts if x==v)} |")
    lines += ["", "| target_id | variant | verdict | rationale |", "| --- | --- | --- | --- |"]
    for r, (v, why) in zip(rows, verdicts):
        lines.append(f"| {r['target_id']} | {r['variant']} | {v} | {why} |")
    lines += ["", "> No row here authorizes a public real-benchmark claim by itself."]
    pathlib.Path(args.out_md).write_text("\n".join(lines))

    for r, (v, why) in zip(rows, verdicts):
        print(f"{r['target_id']:<18} {r['variant']:<24} {v:<16} {why}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
