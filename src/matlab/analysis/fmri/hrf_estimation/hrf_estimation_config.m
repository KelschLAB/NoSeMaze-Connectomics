
function cfg = hrf_estimation_config(repoRoot)
% HRF_ESTIMATION_CONFIG Study-specific HRF estimation settings.

arguments
    repoRoot (1,:) char
end

cfg = struct();

cfg.nSessions = 11;
cfg.TR = 0.265;
cfg.nSlices = 6;
cfg.microtimeResolution = 6;
cfg.microtimeOnset = 1;

%% Main HRF mask GLM

cfg.maskGlmRoot = fullfile( ...
    repoRoot,'results','hrf_estimation','mask_glm');

cfg.maskFirstLevelDir = fullfile(cfg.maskGlmRoot,'firstlevel');

cfg.covariateDir = fullfile( ...
    cfg.maskGlmRoot,'covariates','v1');

%% Residual GLM

cfg.residualRoot = fullfile( ...
    repoRoot,'results','hrf_estimation','residual_glm');

cfg.residualFirstLevelDir = fullfile( ...
    cfg.residualRoot,'firstlevel_residuals');

cfg.explicitMask = fullfile( ...
    repoRoot,'data','reference','templates','fMRI','hrf', ...
    'rmask_template_6_polished.nii');

cfg.fileList = fullfile( ...
    repoRoot,'data','interim','fMRI','hrf','filelists','filelist_hrf.mat');

cfg.primaryEpiPrefix = 'msk_s5_rwrst_a1_u_del25_';
cfg.primaryEpiSuffix = '_c2t';

%% Extracted residual time courses

cfg.timecourseDir = fullfile( ...
    repoRoot,'data','processed','fMRI','hrf_estimation','timecourses');

cfg.maskLabel = '2sHRF';

%% HRF fitting

cfg.highResolution = true;
cfg.optimizeOnsetParameter = false;
cfg.spmPaddingSamples = 32;

cfg.start.responseDelay = 1:0.5:4;
cfg.start.undershootDelay = 4:3:10;
cfg.start.dispersion = 0.5:0.5:1.5;
cfg.start.responseUndershootRatio = 3:1.75:10;
cfg.start.onset = 0.2:0.4:1;

cfg.maxFunctionEvaluations = 100000;

cfg.outputDir = fullfile(repoRoot,'results','hrf_estimation','fit');

cfg.finalHrfDir = fullfile( ...
    repoRoot,'src','matlab','preprocessing','toolboxes', ...
    'spm12_animal','longTC','hrf_withoutOnset_from2sHRF-GLM');

cfg.finalHrfFunction = fullfile(cfg.finalHrfDir,'spm_hrf.m');

end
