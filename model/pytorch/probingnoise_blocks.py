"""
Probingnoise architectural blocks.
"""

import torch
import torch.nn as nn


class SkipLayerNorm(nn.Module):
    def __init__(self, inner_module: nn.Module, normalized_shape):
        super().__init__()
        self.inner = inner_module
        self.norm = nn.LayerNorm(normalized_shape)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        return self.norm(x + self.inner(x))


class LocalGlobalAggBlock(nn.Module):
    def __init__(self, num_nodes: int, hidden_dim: int):
        super().__init__()
        self.num_nodes = num_nodes
        self.hidden_dim = hidden_dim
        self.local_proj = nn.Linear(hidden_dim, hidden_dim)
        self.global_proj = nn.Linear(hidden_dim, hidden_dim)

    def forward(self, x: torch.Tensor) -> torch.Tensor:
        orig_shape = x.shape
        if x.dim() == 2:
            b = x.shape[0]
            x = x.view(b, self.num_nodes, self.hidden_dim)

        local = self.local_proj(x)
        global_ctx = x.mean(dim=1, keepdim=True)
        global_ctx = self.global_proj(global_ctx)
        y = local + global_ctx

        if len(orig_shape) == 2:
            y = y.reshape(orig_shape)
        return y
