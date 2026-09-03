
function cfg = glm_hrf_config(repoRoot)
% GLM_HRF_CONFIG HRF-cohort odor-mask GLM settings.

arguments
    repoRoot (1,:) char
end

cfg = struct();

%% Cohort/acquisition
cfg.nSessions = 11;
cfg.TR = 0.265;
cfg.fmri_t = 6;
cfg.fmri_t0 = 1;
cfg.hrfDerivatives = [0 0];
cfg.orth = 1;
cfg.maskThreshold = 0;
cfg.highPassSec = 128;

%% Inputs from HRF preprocessing
cfg.fileList = fullfile( ...
    repoRoot,'data','interim','fMRI','hrf','filelists','filelist_hrf.mat');

cfg.processedProtocolDir = fullfile( ...
    repoRoot,'data','interim','fMRI','hrf','processed_protocol_files');

cfg.explicitMask = fullfile( ...
    repoRoot,'data','reference','templates','fMRI','hrf', ...
    'rmask_template_6_polished.nii');

cfg.epiPrefix = 'msk_s5_rwrst_a1_u_del25_';
cfg.epiSuffix = '_c2t';

%% Mask-generating task model
%
% create_individual_odor_masks_jr used regressor version v1:
% three odor conditions with their actual 0.5/1.0/2.4-s durations.

cfg.regressorVersion = 'v1';
cfg.covariateVersion = 'v1';
cfg.odorDelaySec = 0.7;

cfg.conditionNames = { ...
    'Odor_500ms', ...
    'Odor_1000ms', ...
    'Odor_2400ms' ...
};

cfg.conditionDurations = [0.5 1.0 2.4];

%% Initial HRF used to define the individual odor masks
%
% The final TC-analysis script explicitly selects *_odormask_2sHRF.nii.
% The historical GLM master called its corresponding custom-HRF branch
% "hrf_new". That exact folder was not supplied. The repository does
% contain the earlier 2-s mouse HRF from Philipp Lebhardt, which is kept as
% the default candidate. Override this path if the exact historical
% "hrf_new" folder becomes available.

cfg.initialHrfLabel = '2sHRF';
cfg.initialHrfDir = fullfile( ...
    repoRoot,'src','matlab','preprocessing','toolboxes', ...
    'spm12_animal','hrf_philipplebhardt');

%% Derived inputs/results
cfg.analysisRoot = fullfile( ...
    repoRoot,'results','hrf_estimation');

cfg.glmRoot = fullfile(cfg.analysisRoot,'mask_glm');
cfg.firstLevelDir = fullfile(cfg.glmRoot,'firstlevel');
cfg.regressorDir = fullfile(cfg.glmRoot,'regressors',cfg.regressorVersion);
cfg.covariateDir = fullfile(cfg.glmRoot,'covariates',cfg.covariateVersion);

%% Individual mask threshold
%
% IMPORTANT HISTORICAL DISCREPANCY:
% The source comment says "5% maximum values", but the actual expression
%
%   end - round(length(img_vec_sorted)/100)
%
% selects approximately the highest 1% (subject to ties/off-by-one).
% We preserve the executed code here for reproducibility.

cfg.maskTopFraction = 0.01;
cfg.maskCommentClaimedFraction = 0.05;
cfg.maskContrastName = 'Odors_combined';

end
