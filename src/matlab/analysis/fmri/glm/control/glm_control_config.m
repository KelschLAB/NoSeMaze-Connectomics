function cfg = glm_control_config(repoRoot)
% GLM_CONTROL_CONFIG Primary voxelwise control-cohort GLM.

cfg = struct();

cfg.cohort = 'reappraisal_control_2023';
cfg.regressorVersion = 'v22';
cfg.covariateVersion = 'v1';

cfg.subjectIDs = {
    'ZI_M230908H'
    'ZI_M230908G'
    'ZI_M230908F'
    'ZI_M230908E'
    'ZI_M230908D'
    'ZI_M230908C'
    'ZI_M230908B'
    'ZI_M230908A'
    'ZI_M230907H'
    'ZI_M230907G'
    'ZI_M230907F'
    'ZI_M230907E'
    'ZI_M230907D'
    'ZI_M230907C'
    'ZI_M230907B'
    'ZI_M230907A'
    'ZI_M230906H'
    'ZI_M230906G'
    'ZI_M230906F'
    'ZI_M230906E'
    'ZI_M230906D'
    'ZI_M230906C'
    'ZI_M230906B'
    'ZI_M230906A'
};
cfg.scannerIDs = [3190 3196 3200 3188 3186 3189 3191 3193 3219 3225 3222 3228 3227 3223 3220 3224 3209 3207 3208 3210 3206 3205 3213 3216];

cfg.scanlist = fullfile( ...
    repoRoot, 'data', 'reference', 'fMRI', 'control', ...
    'ScanList_reappraisal_control_2023.csv');

cfg.protocolDir = fullfile( ...
    repoRoot, 'data', 'processed', 'RHD', 'control', ...
    'processed_protocol_files');

processedRoot = getenv('NOSEMAZE_CONTROL_FMRI_PROCESSED_ROOT');
if isempty(processedRoot)
    processedRoot = fullfile( ...
        repoRoot, 'data', 'processed', 'fMRI', 'preprocessing', 'control');
end
cfg.preprocessedFmriRoot = processedRoot;

cfg.epi.prefix = ...
    'wave_10cons_med1000new_msk_s6_wrst_a1_u_despiked_del5_';
cfg.epi.suffix = '_c2t_wds';
cfg.epi.smoothed = true;

cfg.regressorsDir = fullfile( ...
    repoRoot, 'data', 'processed', 'fMRI', 'glm', 'control', ...
    'regressors_v22');

cfg.covariatesDir = fullfile( ...
    repoRoot, 'data', 'processed', 'fMRI', 'glm', 'control', ...
    'covariates_v1');

cfg.resultsDir = fullfile( ...
    repoRoot, 'data', 'processed', 'fMRI', 'glm', 'control', ...
    'results_v22');

cfg.odorDelay = 0.425; % historical control v22 GLM timing
cfg.TR = 1.2;
cfg.fmri_t = 22;
cfg.fmri_t0 = 1;
cfg.DerDisp = [0 0];
cfg.orth = 1;
cfg.maskThreshold = 0;

cfg.hrf.tcBased = 'longTC';
cfg.hrf.onset = 'withoutOnset';
cfg.hrf.estimateLength = 'from2sHRF-GLM';
cfg.hrf.name = 'HRFlongTC_withoutOnset_from2sHRF-GLM';

cfg.explicitMask = fullfile( ...
    repoRoot, 'data', 'reference', 'atlases', 'AllenBrain_2021_v2', ...
    'mask_noCB_noBS_polished.nii');

end
