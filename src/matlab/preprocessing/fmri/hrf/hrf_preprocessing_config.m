function cfg = hrf_preprocessing_config(repoRoot)
% HRF_PREPROCESSING_CONFIG Acquisition/preprocessing provenance.

cfg = struct();

cfg.cohort = 'hrf';
cfg.expectedSessions = 11;

cfg.TR = 0.265;
cfg.TE = 0.018;
cfg.nSlices = 6;
cfg.nVolumes = 8200;
cfg.dummyVolumes = 25;

cfg.voxelSizeMm = [0.25 0.25 0.6];
cfg.matrix = [48 48];
cfg.flipAngleDeg = 30;

% Historical master uses [5 5 5] in SPM-rescaled space for the final
% smoothing branch.
cfg.historicalSmoothing = [5 5 5];

cfg.rawRootEnv = 'NOSEMAZE_HRF_FMRI_RAW_ROOT';
cfg.processedRootEnv = 'NOSEMAZE_HRF_FMRI_PROCESSED_ROOT';

cfg.finalHrfFile = fullfile( ...
    repoRoot, 'src', 'matlab', 'preprocessing', 'toolboxes', ...
    'spm12_animal', 'longTC', ...
    'hrf_withoutOnset_from2sHRF-GLM', 'spm_hrf.m');

end
