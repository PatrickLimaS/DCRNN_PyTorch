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


class DivergenceHead(nn.Module):
    def __init__(self, dim_in: int, dim_out: int):
        super().__init__()
        self.norm = nn.LayerNorm(dim_in)
        self.proj = nn.Linear(dim_in, dim_out)

    def forward(self, z_local: torch.Tensor, z_global: torch.Tensor):
        delta = z_local - z_global
        delta = self.norm(delta)
        y_div = self.proj(delta)
        return y_div, delta


class LocalGlobalAggBlock(nn.Module):
    def __init__(self, num_nodes: int, hidden_dim: int):
        super().__init__()
        self.num_nodes = num_nodes
        self.hidden_dim = hidden_dim
        self.local_proj = nn.Linear(hidden_dim, hidden_dim)
        self.global_proj = nn.Linear(hidden_dim, hidden_dim)

    def forward(self, x: torch.Tensor, return_parts: bool = False):
        orig_shape = x.shape
        if x.dim() == 2:
            b = x.shape[0]
            x = x.view(b, self.num_nodes, self.hidden_dim)

        z_local = self.local_proj(x)
        z_global = x.mean(dim=1, keepdim=True)
        z_global = self.global_proj(z_global)
        z_global = z_global.expand_as(z_local)

        delta = z_local - z_global
        y = z_local + z_global

        if len(orig_shape) == 2:
            y = y.reshape(orig_shape)
            z_local = z_local.reshape(orig_shape)
            z_global = z_global.reshape(orig_shape)
            delta = delta.reshape(orig_shape)

        if return_parts:
            return y, z_local, z_global, delta
        return y
