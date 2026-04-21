"""
wildtime_loader.py
==================

Wild-Time adapter for the Yearbook task. This is the ONLY file that changes
when porting from the synthetic stand-in to real Wild-Time. It produces the
same (A, A_norm, (Xtr, ytr), (Xst, yst), shift) interface that data.py and
data_harder.py produce, so the downstream modules.py / models.py / train.py /
run.py can be reused unchanged.

Task chosen: Yearbook.
  - Binary classification (male vs. female from a yearbook portrait)
  - 32x32 grayscale images, years 1930-2013
  - Smallest Wild-Time task — the cleanest Bronze-standard test
  - Source: Yao et al., "Wild-Time: A Benchmark of in-the-Wild Distribution
    Shift over Time", NeurIPS Datasets & Benchmarks, 2022.

HOW TO GET THE DATA
-------------------
1. Clone the Wild-Time repo:
     git clone https://github.com/huaxiuyao/Wild-Time
2. Follow their download instructions to get yearbook.pkl (~100 MB).
3. Pass the directory containing yearbook.pkl as wildtime_data_root.

Expected pickle structure:
    {
      year_int: {
        'images': np.ndarray shape (n_that_year, 1, 32, 32) in [0, 1],
        'labels': np.ndarray shape (n_that_year,) in {0, 1},
      },
      ...
    }

HOW TO USE
----------
Replace make_data() in run.py or run_harder.py with:

    def make_data(seed):
        from wildtime_loader import build_wildtime_yearbook
        return build_wildtime_yearbook(
            wildtime_data_root=os.environ["WILDTIME_ROOT"],
            N=CFG["N"], seed=seed,
        )

and set CFG["d_in"] = 1024 (flattened 32x32).

Then:

    WILDTIME_ROOT=/path/to/yearbook python3 run.py

Node semantics
--------------
The stand-in generates (T steps, N nodes, d features) per step. Wild-Time is
(many samples, one timestamp per sample). To unify: at each "timestep" (=year)
we draw N random samples from that year's slice to form N "nodes". This is
one of several reasonable reductions; alternatives are documented at the
bottom.

Honest caveats
--------------
1. The MLP encoder (16→32→16) in v2 will underfit 1024-dim images. If
   train accuracy stays below ~0.75, swap in a small CNN encoder. The rest
   of the architecture is encoder-agnostic.
2. The v2 synthetic task is engineered so cross-node averaging helps (all
   nodes share a latent factor). Yearbook has no such shared structure at
   each timestep — each image is independent. The graph coordination
   hypothesis should therefore be TESTED, not assumed. If graph_no_residual
   fails to beat local_only on Yearbook, that's a real finding about the
   architecture's inductive bias, not a bug.
3. If you want a Wild-Time task with natural per-timestep correlated
   structure, use MIMIC (clinical cohort) or arXiv (same-year paper
   topics), not Yearbook.
"""
import os
import pickle
import numpy as np


YEARBOOK_YEARS = list(range(1930, 2014))
YEARBOOK_TRAIN_YEARS = list(range(1930, 1970))
YEARBOOK_STREAM_YEARS = list(range(1970, 2014))


def _load_yearbook_pickle(data_root):
    candidates = [
        os.path.join(data_root, "yearbook.pkl"),
        os.path.join(data_root, "yearbook_v1.0.pkl"),
        os.path.join(data_root, "yearbook/yearbook.pkl"),
    ]
    path = next((p for p in candidates if os.path.exists(p)), None)
    if path is None:
        raise FileNotFoundError(
            f"No yearbook pickle under {data_root}. Tried: {candidates}. "
            "See HOW TO GET THE DATA in wildtime_loader.py."
        )
    with open(path, "rb") as f:
        data = pickle.load(f)
    for y in YEARBOOK_YEARS[:3]:
        if y not in data:
            raise ValueError(f"Year {y} missing from yearbook pickle.")
    return data


def _flatten(img):
    return img.reshape(-1).astype(np.float32)


def build_wildtime_yearbook(wildtime_data_root, N=8, seed=0,
                             max_t_train=None, max_t_stream=None,
                             use_full_graph=False):
    """Returns (A, A_norm, (Xtr, ytr), (Xst, yst), shift) compatible with v2."""
    rng = np.random.default_rng(seed)

    # Graph: reuse stand-in's ring+shortcuts builder
    from data import build_graph
    A, A_norm = build_graph(N=N, seed=seed)
    if use_full_graph:
        A = (np.ones((N, N), np.float32) - np.eye(N, dtype=np.float32))
        D = A.sum(1)
        Dinv = 1.0 / np.sqrt(D)
        A_norm = (Dinv[:, None] * A) * Dinv[None, :]

    data = _load_yearbook_pickle(wildtime_data_root)

    def _slice(year_list, cap):
        rng_local = np.random.default_rng(seed + 7919 * year_list[0])
        Xs, ys = [], []
        for yr in year_list:
            entry = data[yr]
            imgs, labs = entry["images"], entry["labels"]
            n_avail = len(imgs)
            replace = n_avail < N
            idx = rng_local.choice(n_avail, size=N, replace=replace)
            X_t = np.stack([_flatten(imgs[i]) for i in idx], axis=0)
            y_t = labs[idx].astype(np.int64)
            Xs.append(X_t)
            ys.append(y_t)
            if cap is not None and len(Xs) >= cap:
                break
        return np.stack(Xs, axis=0), np.stack(ys, axis=0)

    X_train, y_train = _slice(YEARBOOK_TRAIN_YEARS, max_t_train)
    X_stream, y_stream = _slice(YEARBOOK_STREAM_YEARS, max_t_stream)
    shift = 0   # boundary is the transition from train to stream window
    return A, A_norm, (X_train, y_train), (X_stream, y_stream), shift


# ============================================================================
# ALTERNATIVE NODE SEMANTICS
# ============================================================================
# Instead of random N-samples per year, you can:
#   (a) use N age-bucket partitions (if age metadata available) — graph structure
#       becomes meaningful (adjacent ages are more similar)
#   (b) N geographic regions — requires region metadata
#   (c) N random disjoint partitions — permutation-invariant baseline
#
# (a) and (b) give the graph structure a real interpretation.
# (c) is the simplest randomized baseline.
#
# The current implementation uses a variant of (c): independent random draws
# per node, not disjoint partitions. For disjoint partitions:
#   shuffled = rng_local.permutation(n_avail)
#   groups = np.array_split(shuffled, N)
#   idx = np.array([g[0] for g in groups])   # one per group per timestep
