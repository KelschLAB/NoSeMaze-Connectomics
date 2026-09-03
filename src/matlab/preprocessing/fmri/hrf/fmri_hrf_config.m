
function cfg = fmri_hrf_config(repoRoot)
% FMRI_HRF_CONFIG HRF-cohort preprocessing settings and paths.

arguments
    repoRoot (1,:) char
end

cfg = struct();

%% Non-public data

cfg.rawMriRoot = getenv('NOSEMAZE_HRF_FMRI_RAW_ROOT');

% Optional existing historical preprocessing tree. This is useful when
% reconstructing downstream stages without reconverting the original Bruker
% acquisitions.
cfg.historicalProcessedRoot = ...
    getenv('NOSEMAZE_HRF_FMRI_PROCESSED_ROOT');

%% Repository inputs

cfg.scanList = fullfile( ...
    repoRoot,'data','reference','fMRI','hrf','scanlist_hrf_jr.csv');

cfg.template = fullfile( ...
    repoRoot,'data','reference','templates','fMRI', ...
    'DLtemplate_brain_rs1x1x1.nii');

cfg.templateMask = fullfile( ...
    repoRoot,'data','reference','templates','fMRI', ...
    'DLtemplate_brainmask_rs1x1x1_polish.nii');

cfg.tpm = {
    fullfile(repoRoot,'data','reference','templates','fMRI','TPM', ...
        'sGM_template_markus_inPax_msk.nii')
    fullfile(repoRoot,'data','reference','templates','fMRI','TPM', ...
        'sWM_template_markus_inPax_msk.nii')
    fullfile(repoRoot,'data','reference','templates','fMRI','TPM', ...
        'sCSF_template_markus_inPax_msk.nii')
    fullfile(repoRoot,'data','reference','templates','fMRI','TPM', ...
        'sBackground_template_markus_msk.nii')
};

%% Working/output directories

cfg.workRoot = fullfile(repoRoot,'data','interim','fMRI','hrf');
cfg.convertedDir = fullfile(cfg.workRoot,'converted');
cfg.fileListDir = fullfile(cfg.workRoot,'filelists');
cfg.dartelDir = fullfile(cfg.workRoot,'DARTEL');
cfg.motionDir = fullfile(cfg.workRoot,'motiondiagnosis');

cfg.fileList = fullfile(cfg.fileListDir,'filelist_hrf.mat');

cfg.processedRoot = fullfile( ...
    repoRoot,'data','processed','fMRI','preprocessing','hrf');

%% Acquisition

cfg.nSessions = 11;
cfg.TR = 0.265;
cfg.TE = 0.018;
cfg.nSlices = 6;
cfg.nVolumes = 8200;
cfg.nDummies = 25;

% Physical acquisition voxel size in mm.
cfg.voxelSizeMm = [0.25 0.25 0.60];

% Historical DARTEL import used SPM-rescaled coordinates.
cfg.dartelImportVoxelSPM = 2.5;

%% Historical primary HRF-analysis EPI branch

% This is the EPI prefix used by the supplied HRF time-course analysis.
cfg.primaryEpi.prefix = 'msk_s5_rwrst_a1_u_del25_';
cfg.primaryEpi.suffix = '_c2t';
cfg.primaryEpi.smoothingSPM = [5 5 5];

%% Historical optional branches

cfg.waveletThreshold = 10;
cfg.waveletSearch = 'harsh';

end
