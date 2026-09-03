# Left/right ROI combination

The primary FC graph does **not** contain separate left- and right-hemisphere
nodes.

Historical atlas files:

```text
AllenBrain_2021_v2_inPax_merged_jr.txt
AllenBrain_2021_v2_inPax_merged.nii
```

The combination occurs during ROI extraction.

Each row of the `*_merged_jr.txt` file contains one or more integer atlas
labels followed by a single anatomical ROI name. The extraction code does:

```matlab
mask = ismember(atlasData, regions(regionIndex).nums);
meanBeta = mean(funcData(mask, :), 1);
```

Therefore, when a row contains the labels for left S1 and right S1, all of
those voxels are combined **before** the beta series is averaged:

```text
S1-left voxels
       +
S1-right voxels
       ↓
single bilateral S1 beta series
       ↓
one S1 node in the 52 × 52 matrix
```

This is more precise than saying merely "bilateral atlas": the primary
network contains **52 anatomical ROIs obtained by combining the atlas labels
assigned to each merged region, including homologous left/right labels**.
