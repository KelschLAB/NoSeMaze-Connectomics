function [cormat, subj] = wwf_covmat_hres_jr(Ptxt, P, Patlas)
% WWF_COVMAT_HRES_JR Extract merged-ROI beta series and Pearson FC matrices.
%
% Ptxt
%   Text file describing merged ROIs. Every line contains one or more
%   integer atlas labels followed by the ROI name. Example conceptually:
%
%       <left-label>,<right-label>,S1
%
%   All listed labels are combined with ISMEMBER before voxel averaging.
%   Therefore homologous left/right regions are summarized into ONE node.
%
% P
%   Character array of 4-D beta-series NIfTI paths; one row per subject.
%
% Patlas
%   Integer-label atlas NIfTI.
%
% OUTPUT
%   cormat{subject} : nROI × nROI Pearson correlation matrix.
%   subj(subject).roi(roi).tcourse : mean beta series for that merged ROI.
%
% This cleaned version preserves the historical scientific calculation but:
%   - fixes the function/file-name mismatch,
%   - removes eval()/read_t2s(),
%   - uses the FIRST functional volume as the reslicing reference,
%   - does not write one temporary NIfTI per ROI,
%   - validates the merged ROI definition explicitly.

if nargin < 1 || isempty(Ptxt)
    Ptxt = spm_select(1, 'any', 'Select merged atlas text file');
end

if nargin < 2 || isempty(P)
    P = spm_select(inf, 'image', 'Select 4-D beta-series images');
end

if nargin < 3 || isempty(Patlas)
    Patlas = spm_select(1, 'image', 'Select merged atlas');
end

Ptxt = deblank(Ptxt);
Patlas = deblank(Patlas);

assert(isfile(Ptxt), 'Atlas label text file not found:\n%s', Ptxt);
assert(isfile(Patlas), 'Atlas NIfTI not found:\n%s', Patlas);

regions = parse_merged_roi_file(Ptxt);

nRegions = numel(regions);
nSubjects = size(P, 1);

assert(nRegions > 1, 'Merged ROI definition contains fewer than two ROIs.');

cormat = cell(nSubjects, 1);
subj = struct([]);

for subjectIndex = 1:nSubjects

    Pcur = deblank(P(subjectIndex, :));

    assert(isfile(Pcur), ...
        'Beta-series NIfTI not found:\n%s', Pcur);

    [fpath, fname] = fileparts(Pcur);

    Vfunc = spm_vol(Pcur);
    assert(~isempty(Vfunc), 'Could not read functional file:\n%s', Pcur);

    Vref = Vfunc(1);
    VatlasNative = spm_vol(Patlas);

    % Reslice label atlas to the beta-series space with nearest-neighbour
    % interpolation. Crucially, the reference is only Vfunc(1); this avoids
    % the ambiguous historical [V1 V2] construction for 4-D inputs.
    atlasFuncFile = fullfile(fpath, 'atlas_func.nii');

    Vout = Vref;
    Vout.fname = atlasFuncFile;

    Vatlas = spm_imcalc( ...
        [Vref VatlasNative], ...
        Vout, ...
        'i2', ...
        {0, 0, 0} ...
    );

    atlasData = spm_read_vols(Vatlas);
    funcData = spm_read_vols(Vfunc);

    nImages = size(funcData, 4);

    funcData = reshape( ...
        funcData, ...
        prod(size(funcData, 1:3)), ...
        nImages ...
    );

    atlasData = atlasData(:);

    tcMatrix = nan(nImages, nRegions);

    subj(subjectIndex).name = Pcur; %#ok<AGROW>

    fprintf('%s: ', fname);

    for regionIndex = 1:nRegions

        fprintf('%d ', regionIndex);

        mask = ismember( ...
            atlasData, ...
            regions(regionIndex).nums ...
        );

        voxelIndices = find(mask);

        assert(~isempty(voxelIndices), ...
            'ROI "%s" contains no voxels after atlas reslicing.', ...
            regions(regionIndex).name ...
        );

        roiData = funcData(voxelIndices, :);

        % Historical behavior: exclude voxels containing any NaN across the
        % beta series before calculating the voxel mean.
        nanVoxel = any(isnan(roiData), 2);

        roiData = roiData(~nanVoxel, :);

        assert(~isempty(roiData), ...
            'ROI "%s" contains no valid voxels after NaN exclusion.', ...
            regions(regionIndex).name ...
        );

        meanBeta = mean(roiData, 1);

        subj(subjectIndex).roi(regionIndex).tcourse = meanBeta;
        subj(subjectIndex).roi(regionIndex).name = ...
            regions(regionIndex).name;
        subj(subjectIndex).roi(regionIndex).size = ...
            numel(voxelIndices);

        tcMatrix(:, regionIndex) = meanBeta(:);
    end

    fprintf('\n');

    cormat{subjectIndex} = corrcoef( ...
        tcMatrix, ...
        'Rows', ...
        'pairwise' ...
    );

    fprintf( ...
        'Subject %d: NaN in ROI beta matrix = %d; NaN in FC matrix = %d\n', ...
        subjectIndex, ...
        any(isnan(tcMatrix(:))), ...
        any(isnan(cormat{subjectIndex}(:))) ...
    );
end

fnames = {subj(1).roi.name}; %#ok<NASGU>

end


function regions = parse_merged_roi_file(Ptxt)

raw = readlines(Ptxt);
raw = strip(raw);
raw(raw == "") = [];

regions = repmat( ...
    struct('name', '', 'nums', []), ...
    numel(raw), ...
    1 ...
);

for lineIndex = 1:numel(raw)

    parts = strtrim(split(raw(lineIndex), ','));

    assert(numel(parts) >= 2, ...
        'Invalid ROI-definition line %d:\n%s', ...
        lineIndex, ...
        raw(lineIndex) ...
    );

    regions(lineIndex).name = char(parts(end));

    nums = str2double(parts(1:end-1));

    assert(all(isfinite(nums)), ...
        'Non-numeric atlas label in ROI-definition line %d.', ...
        lineIndex ...
    );

    regions(lineIndex).nums = nums(:)';
end

end
