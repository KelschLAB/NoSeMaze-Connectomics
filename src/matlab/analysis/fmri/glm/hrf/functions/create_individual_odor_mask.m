
function maskFile = create_individual_odor_mask( ...
    firstLevelDir,sessionID,cfg)
% CREATE_INDIVIDUAL_ODOR_MASK Create the individual odor-responsive mask.
%
% The historical source comment says "5% maximum values", but its executed
% threshold expression divides by 100 and therefore selects approximately
% the highest 1%. The active public code preserves that executed fraction
% through cfg.maskTopFraction.

spmFile = fullfile(firstLevelDir,'SPM.mat');
assert(isfile(spmFile),'SPM.mat not found:\n%s',spmFile);

S = load(spmFile,'SPM');
SPM = S.SPM;

names = string({SPM.xCon.name});
idx = find(names == string(cfg.maskContrastName));

assert(numel(idx)==1, ...
    'Expected one contrast named %s in %s.', ...
    cfg.maskContrastName,spmFile);

Vcon = SPM.xCon(idx).Vcon;
conFile = Vcon.fname;

if ~isfile(conFile)
    conFile = fullfile(firstLevelDir,conFile);
end

assert(isfile(conFile),'Combined-odor contrast image not found:\n%s',conFile);

V = spm_vol(conFile);
img = spm_read_vols(V);

values = sort(img(~isnan(img(:))),'ascend');

assert(~isempty(values),'Combined-odor image contains no finite voxels.');

% Reproduce the historical threshold expression:
%   end - round(length(values)/100)
%
% Generalized through cfg.maskTopFraction while preserving 0.01 by default.
thresholdIndex = numel(values) - round(numel(values)*cfg.maskTopFraction);
thresholdIndex = max(1,min(numel(values),thresholdIndex));

threshold = values(thresholdIndex);

mask = zeros(size(img));
mask(img >= threshold) = 1;

maskFile = fullfile( ...
    firstLevelDir, ...
    sprintf('%s_odormask_%s.nii',sessionID,cfg.initialHrfLabel));

Vout = V;
Vout.fname = maskFile;
Vout.dt = [spm_type('uint8') 0];

spm_write_vol(Vout,mask);

end
