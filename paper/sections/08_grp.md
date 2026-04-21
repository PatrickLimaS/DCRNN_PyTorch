# Global Re-entry Projection (GRP)

## Proposed operator

GRP is a proposed architectural operator specified to operate within Stage B of the asynchronous inferential cascade (`06_cascade_abc.md`). It is specified; it is not empirically validated here.

## Specification

Let `H_t = {h_{i,t}}` denote local hidden states at time `t`, indexed by node `i`.

- **Pooling.** `g_t = P(H_t)`, permutation-invariant pooling over nodes.
- **Projection.** `p_{i,t} = W_g · g_t`, linear projection back to each local node's state space.
- **Residual merge with layer norm.** `~h_{i,t} = LN(h_{i,t} + α · p_{i,t})`, `α` learnable or scheduled.

The output `{~h_{i,t}}` replaces the local hidden states before downstream blocks consume them.

## Architectural role

Additive operator inside Stage B. Does not modify surrounding blocks; setting `α = 0` recovers the unmodified core.

## Paper-safe naming

"Global re-entry projection" is preferred over any cognition-loaded alternative. Motivational language such as "pervasive evaluative constraint" appears only in `07_motivation.md` and is never a capability claim.

## Claim boundary

No claim is made that GRP improves, degrades, or equals the Probingnoise core on any metric. Empirical validation is deferred and gate-blocked by `dcrnn_baseline`.
