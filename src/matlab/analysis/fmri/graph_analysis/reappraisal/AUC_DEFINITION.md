# Historical graph-metric "AUC" definition

The project function `rb_gstruc_2_auc.m` historically computes:

```matlab
auc_cur = mean(grmat, 2);
```

Thus the manuscript variable called an AUC is the mean graph-metric value
across the selected density thresholds.

For the primary analysis:

```text
thresholds calculated = 0.10:0.01:0.50
manuscript mean       = 0.45:0.01:0.50
indices               = 36:41
```

Because threshold spacing is constant, this summary is proportional to the
usual numerical area under the curve by a fixed constant. The repository
preserves the historical calculation rather than replacing it with `trapz`,
which would change the numerical values.
