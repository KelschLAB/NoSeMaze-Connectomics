# Supplementary Figure S12

MRIcroGL scripts used to reproduce Supplementary Figure S12.

## Scripts

| Panel | Rendering | Script |
|---|---|---|
| S12A | rank-related deactivation map, more stringent `T001` threshold | `panel_A_mricrogl_S12A.py` |
| S12B | z-scored David's-score deactivation map at `T01` | `panel_B_mricrogl_S12B.py` |
| S12C | activation map at `T01` | `panel_C_mricrogl_S12C.py` |
| S12D | TFCE/FWE-confirmed rank-related map | `panel_D_mricrogl_S12D.py` |

Outputs are written under:

```text
results/supplement/Figure_S12/
├── Figure_S12A/
├── Figure_S12B/
├── Figure_S12C/
└── Figure_S12D/
```

## MRIcroGL requirement

These scripts are intended to be run from MRIcroGL's embedded Python environment:

```python
import gl
```

Because MRIcroGL does not reliably expose the script path to embedded Python, the repository root is intentionally specified manually near the top of each script:

```python
repo_root = r'...\NoSeMaze-Connectomics'
```

If the repository is moved, edit this single line.

## Common anatomical template

All four panels use:

```text
data/reference/templates/
└── DL_template_original_inPax_brain.nii.gz
```

Common rendering settings:

```text
background     = white
template range = 0–1,200,000
mosaic         = C -27 -31 -37 S X R 0; A -32 -35 -37
shader         = MatcapMix_JR
color map      = 1LilaJR
```

The anatomical template is extracted three times with:

```python
gl.extract(1, 1, 5)
```

matching the historical rendering workflow.

## Overlay handling

Each script clears previous overlays before loading the panel-specific map:

```python
gl.overlaycloseall()
gl.overlayload(overlay_file)
```

This prevents overlay accumulation when several maps are rendered sequentially in one MRIcroGL session.

---

## Figure S12A

Input source is deliberately reused from main Figure 6A:

```text
data/processed/fMRI/Figure_6/Figure_6A/
└── deactivation*T001.nii
```

The script selects all files satisfying:

```text
deactivation*T001.nii
```

and renders each separately.

Overlay settings:

```text
display range = 2–5
opacity       = 100%
color map     = 1LilaJR
```

Run from MRIcroGL:

```python
exec(open(r'figures\supplement\Figure_S12\panel_A_mricrogl_S12A.py').read())
```

The corrected script only fixes the stale header documentation: the executable code already pointed to the Figure 6A source directory.

---

## Figure S12B

Input:

```text
data/processed/fMRI/Figure_S12/Figure_S12B/
└── deactivation*T01.nii
```

The script selects all matching deactivation maps and renders each separately.

Overlay settings:

```text
display range = 2–5
opacity       = 100%
color map     = 1LilaJR
```

Run from MRIcroGL:

```python
exec(open(r'figures\supplement\Figure_S12\panel_B_mricrogl_S12B.py').read())
```

---

## Figure S12C

Input:

```text
data/processed/fMRI/Figure_S12/Figure_S12C/
└── activation*T01.nii
```

The script selects all matching activation maps and renders each separately.

Overlay settings:

```text
display range = 2–5
opacity       = 100%
color map     = 1LilaJR
```

Run from MRIcroGL:

```python
exec(open(r'figures\supplement\Figure_S12\panel_C_mricrogl_S12C.py').read())
```

---

## Figure S12D

Input source is deliberately reused from main Figure 6A:

```text
data/processed/fMRI/Figure_6/Figure_6A/
└── TFCE_rankPos_FWE_05.nii
```

Unlike S12A-C, S12D loads one exact overlay file rather than searching by pattern.

Overlay settings:

```text
display range = 350–550
opacity       = 100%
color map     = 1LilaJR
```

Run from MRIcroGL:

```python
exec(open(r'figures\supplement\Figure_S12\panel_D_mricrogl_S12D.py').read())
```

## Repository check

The supplied S12 scripts were already technically consistent in the important rendering logic:

- all use the same anatomical template and mosaic;
- all clear existing overlays before loading a new map;
- S12A and S12D intentionally reuse source maps from main Figure 6A;
- S12B and S12C use dedicated Supplementary Figure S12 processed-data folders;
- output directories are panel-specific.

No rendering parameters or statistical inputs were changed. The cleanup is limited to stale documentation/comments and minor formatting.

