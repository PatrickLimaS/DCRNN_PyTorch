# Claim status

_Last updated: 2026-04-20_

## Currently supported claim

On tasks with shared-signal structure across nodes per timestep, the load-bearing mechanism is:

- skip-connected graph coordination with normalization
- skip-connected local-global aggregation

## Evidence backing this claim

| Target | Status | Contribution |
| --- | --- | --- |
| `synthetic_v2` | not yet normalized here | Core synthetic support |
| `synthetic_harder` | not yet normalized here | Source of the narrowing |

Both targets are synthetic stand-ins. **No real-benchmark evidence supports the claim at this time.**

## Not validated core

| Component | Status | Reason |
| --- | --- | --- |
| Residual gating | conditional extension | Not supported as load-bearing by current synthetic ablations. |
| Adaptive scheduling | conditional extension | Not supported as load-bearing by current synthetic ablations. |

## Pending public statement

The repository's public framing remains:

**No real-benchmark result is yet claimed.**
