# Media Gallery — Related Stack

Links and attributions for the research systems this project positions
itself alongside. Each entry points to the original authors' public
project page or repository; nothing is hosted in this repository.

If local preview assets are added in the future, per-asset licensing
will be tracked in [`third_party/gallery/LICENSE.md`](third_party/gallery/LICENSE.md).

---

## Vision-Language-Action

### OpenVLA — Open-Source Vision-Language-Action Model

- **Authors:** Kim et al., Stanford / Google DeepMind / TRI / Physical Intelligence / MIT
- **Paper:** OpenVLA: An Open-Source Vision-Language-Action Model (CoRL 2024)
- **Repo:** https://github.com/openvla/openvla
- **Project:** https://openvla.github.io
- **License:** MIT
- **Relation:** Specified as an optional Stage C head or external oracle in [`paper/sections/11_droid_openvla_integration.md`](paper/sections/11_droid_openvla_integration.md).

### RT-2 — Vision-Language-Action Models Transfer Web Knowledge to Robotic Control

- **Authors:** Brohan et al., Google DeepMind
- **Paper:** CoRL 2023
- **Project:** https://robotics-transformer2.github.io
- **Relation:** Structural lineage for multimodal integration in [`paper/sections/10_related_lineages.md`](paper/sections/10_related_lineages.md).

### Octo — Open-Source Generalist Robot Policy

- **Authors:** Octo Model Team (UC Berkeley / Stanford / CMU / Google DeepMind)
- **Paper:** RSS 2024
- **Repo:** https://github.com/octo-models/octo
- **Project:** https://octo-models.github.io
- **License:** MIT
- **Relation:** Structural lineage for generalist multi-stream policies.

---

## Robot Data at Scale

### DROID — Distributed Robot Interaction Dataset

- **Authors:** Khazatsky et al.
- **Paper:** DROID: A Large-Scale In-the-Wild Robot Manipulation Dataset (2024)
- **Repo:** https://github.com/droid-dataset/droid
- **Project:** https://droid-dataset.github.io
- **License:** CC-BY-NC 4.0 (non-commercial)
- **Relation:** Proposed as a Stage A stream generator in [`paper/sections/11_droid_openvla_integration.md`](paper/sections/11_droid_openvla_integration.md). License note: CC-BY-NC 4.0; any future use within this project is research-only.

---

## Event-Based / Neuromorphic Vision

### AEGNN — Asynchronous Event-based Graph Neural Networks

- **Authors:** Schaefer, Gehrig, Scaramuzza, University of Zurich / ETH Zurich
- **Paper:** CVPR 2022
- **Repo:** https://github.com/uzh-rpg/aegnn
- **Project:** https://uzh-rpg.github.io/aegnn/
- **Relation:** Structural lineage for Stage A (multi-rate ingestion).

### Event-Based Vision: A Survey

- **Authors:** Gallego et al.
- **Paper:** IEEE TPAMI 2022
- **Resources:** https://github.com/uzh-rpg/event-based_vision_resources
- **Relation:** Foundational survey cited as lineage for event-driven sensing.

---

## Spatiotemporal Graph Learning

### DCRNN — Diffusion Convolutional Recurrent Neural Network

- **Authors:** Li et al., USC / Tsinghua
- **Paper:** ICLR 2018
- **Original TF repo:** https://github.com/liyaguang/DCRNN
- **PyTorch port (upstream of this project):** https://github.com/chnsh/DCRNN_PyTorch
- **Relation:** This repository's core spatiotemporal backbone. See top-level `README.md` and `GOVERNANCE.md` for current evidence status.

---

## Attribution and license discipline

- Every entry in this gallery is linked, not copied.
- Every entry names the original authors, their paper, and their license where applicable.
- Where a license restricts commercial use (e.g., DROID, CC-BY-NC 4.0), that restriction is honored within this project.
- If any original author wishes an entry to be removed or modified, please open an issue.
