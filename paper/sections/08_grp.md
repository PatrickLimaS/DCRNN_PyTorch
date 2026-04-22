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

## Convergent direction — GDGCRN (2025)

The GDGCRN (Yang et al., 2025, IEEE Sensors Journal) introduces a **signal decoupling mechanism** that separates steady-state from non-steady-state components in traffic signals. This is a convergent direction with GRP: both operate on the principle that computation benefits from explicit separation of regimes. The mechanisms differ:

- **GRP (this project):** decouples along the **architectural axis** — global re-entry projection as an operator distinct from local aggregation. The separation is between scales of computation.
- **GDGCRN:** decouples along the **signal axis** — steady-state and non-steady-state components as distinct data regimes. The separation is between predictability classes of input.

The two are not redundant. GRP could in principle be applied within either branch of a GDGCRN-style decomposition, and GDGCRN's decomposition could in principle be applied to the input of a GRP-augmented network. This is left as a Tier 4 speculation; no implementation is proposed.

**Claim boundary for this subsection:** GRP remains Tier 3 (proposed, not implemented). GDGCRN is Tier 2 (cited from literature). Their composition is Tier 4 (speculative).
