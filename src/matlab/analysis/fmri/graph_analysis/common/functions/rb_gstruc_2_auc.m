function auc_struc = rb_gstruc_2_auc( ...
    gstruc, thr_minind, thr_maxind)
% RB_GSTRUC_2_AUC Summarize graph metrics across thresholds.
%
% IMPORTANT:
% The historical function calls this quantity "AUC", but mathematically it
% computes the arithmetic MEAN across the selected threshold values:
%
%     mean(metric(thr_minind:thr_maxind))
%
% It does NOT use trapz() or multiply by the threshold spacing.
%
% For the primary analysis the thresholds are equally spaced
% (0.10:0.01:0.50), so this historical summary is proportional to a
% conventional numerical area under the curve by a constant factor.
%
% The cleaned implementation intentionally preserves the historical
% calculation exactly so that reported graph metrics are reproducible.

assert(thr_minind >= 1, ...
    'thr_minind must be >= 1.');

assert(thr_maxind >= thr_minind, ...
    'thr_maxind must be >= thr_minind.');

[x, y] = size(gstruc);

if x == 1 && y == 1

    assert(exist('rb_gstruc_old2new', 'file') == 2, ...
        ['Old-format gstruc detected, but rb_gstruc_old2new.m is ' ...
         'not available.']);

    fprintf([ ...
        'Old gstruc format detected; converting with ' ...
        'rb_gstruc_old2new.m.\n' ...
    ]);

    gstruc_n = rb_gstruc_old2new(gstruc);

else
    gstruc_n = gstruc;
end

[Nthr, Nsub] = size(gstruc_n);

assert(thr_maxind <= Nthr, ...
    'thr_maxind (%d) exceeds number of thresholds (%d).', ...
    thr_maxind, ...
    Nthr ...
);

fieldNames = fieldnames(gstruc_n);

auc_struc = struct([]);

for fieldIndex = 1:numel(fieldNames)

    currentField = fieldNames{fieldIndex};

    if numel(currentField) < 2
        continue;
    end

    isGraphMetric = ...
        strcmp(currentField(1:2), 'g_') || ...
        strcmp(currentField(1:2), 'l_');

    if ~isGraphMetric
        continue;
    end

    for subjectIndex = 1:Nsub

        selected = gstruc_n( ...
            thr_minind:thr_maxind, ...
            subjectIndex ...
        );

        metricValues = [selected.(currentField)];

        % Preserve historical "AUC" definition exactly.
        aucValue = mean(metricValues, 2);

        auc_struc(subjectIndex).(currentField) = aucValue;
        auc_struc(subjectIndex).o_thr_range = ...
            [selected.o_cutoffs];
    end
end

end
