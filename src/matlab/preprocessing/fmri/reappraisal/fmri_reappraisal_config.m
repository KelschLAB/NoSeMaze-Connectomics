function cfg = fmri_reappraisal_config(repoRoot)
% FMRI_REAPPRAISAL_CONFIG Paths and manuscript-specific preprocessing values.

arguments
    repoRoot (1,:) char
end

cfg = struct();

%% Non-public raw MRI
%
% Set this environment variable to the root containing the original
% Bruker/ParaVision reappraisal MRI acquisitions:
%
%   NOSEMAZE_REAPPRAISAL_FMRI_RAW_ROOT

cfg.rawMriRoot = getenv('NOSEMAZE_REAPPRAISAL_FMRI_RAW_ROOT');

%% Repository inputs

cfg.scanList = fullfile( ...
    repoRoot,'data','reference','fMRI','reappraisal', ...
    'scanlist_reappraisal_jr.csv');

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

%% Working directories

cfg.workRoot = fullfile( ...
    repoRoot,'data','interim','fMRI','reappraisal');

cfg.convertedDir = fullfile(cfg.workRoot,'converted');
cfg.fileListDir = fullfile(cfg.workRoot,'filelists');
cfg.dartelDir = fullfile(cfg.workRoot,'DARTEL');
cfg.motionDir = fullfile(cfg.workRoot,'motiondiagnosis');

cfg.scanManifestCsv = fullfile( ...
    cfg.fileListDir,'scan_manifest_reappraisal.csv');

cfg.scanManifestMat = fullfile( ...
    cfg.fileListDir,'scan_manifest_reappraisal.mat');

cfg.fileList = fullfile( ...
    cfg.fileListDir,'filelist_reappraisal.mat');

%% Final preprocessing products
%
% Large intermediate MRI data are not intended for GitHub. The final
% analysis-ready products selected for the public figure workflows can be
% exported separately to data/processed/fMRI/.

cfg.processedRoot = fullfile( ...
    repoRoot,'data','processed','fMRI','preprocessing','reappraisal');

%% Acquisition / processing constants

cfg.nVolumesTask = 1600;
cfg.nDummies = 5;

% Coordinates/images were historically resized x10 for SPM compatibility.
% Therefore SPM-space kernels [6 6 6] and [4 4 4] correspond to 0.6 mm and
% 0.4 mm physical FWHM, respectively.
cfg.smoothingPrimarySPM = [6 6 6];
cfg.smoothingRobustnessSPM = [4 4 4];

cfg.waveletThreshold = 10;
cfg.waveletSearch = 'conservative';

end
