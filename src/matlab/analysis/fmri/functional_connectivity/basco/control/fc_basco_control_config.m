function cfg = fc_basco_control_config(repoRoot)
% FC_BASCO_CONTROL_CONFIG Control cohort beta-series FC configuration.

cfg = struct();

cfg.cohort = 'reappraisal_control_2023';
cfg.version.basco = 'v6';
cfg.version.regressors = 'v16';

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
    'wave_10cons_med1000new_msk_wrst_a1_u_despiked_del5_';
cfg.epi.suffix = '_c2t_wds';
cfg.epi.smoothed = false;
cfg.epi.forbiddenTokens = {'msk_s4_','msk_s6_'};

cfg.regressorsDir = fullfile( ...
    repoRoot, 'data', 'processed', 'fMRI', ...
    'functional_connectivity', 'control', 'basco', 'v6', ...
    'regressors_v16');

cfg.fcRoot = fullfile( ...
    repoRoot, 'data', 'processed', 'fMRI', ...
    'functional_connectivity', 'control', 'basco', 'v6');

cfg.manifestDir = fullfile(cfg.fcRoot,'manifests');
cfg.inputDir = fullfile(cfg.fcRoot,'input');
cfg.toolboxOutputDir = fullfile(cfg.fcRoot,'toolbox_output');
cfg.betaSeriesDir = fullfile(cfg.fcRoot,'beta_series');
cfg.correlationMatrixDir = fullfile(cfg.fcRoot,'correlation_matrices');
cfg.roiDataDir = fullfile(cfg.fcRoot,'roi_data');

cfg.subjectManifestCsv = fullfile( ...
    cfg.manifestDir,'fc_subject_manifest_control.csv');
cfg.subjectManifestMat = fullfile( ...
    cfg.manifestDir,'fc_subject_manifest_control.mat');

cfg.files.metainfo = fullfile(cfg.inputDir,'metainfo_v6.mat');

cfg.regressors.suffix = '_v16.mat';
cfg.regressors.expectedLavender = 120;
cfg.regressors.expectedTPNoPuff = 120;
cfg.regressors.odorDelay = 1.3;

cfg.nuisance.sourceFilename = 'regressors_despiked_motcsf_der.txt';
cfg.nuisance.bascoFilename = ...
    'rp_regressors_despiked_motcsf_der_v6.txt';
cfg.nuisance.expectedColumns = 14;

cfg.hrf.name = 'HRFlongTC_withoutOnset_from2sHRF-GLM';
cfg.model.TR = 1.2;
cfg.model.fmri_t = 22;
cfg.model.fmri_t0 = 1;
cfg.model.HRFDERIVS = [0 0];

cfg.model.conditionLavender = 'Lavender';
cfg.model.conditionTPNoPuff = 'TP_noPuff';

cfg.model.specMask = fullfile( ...
    repoRoot, 'data', 'reference', 'templates', 'fMRI', ...
    'mask_template_6_polished.nii');

% Primary manuscript network uses the same merged 52-node atlas as the
% conditioning cohort.
cfg.atlas.name = 'AllenBrain_2021_v2_inPax_merged';
cfg.atlas.leftRightCombination = true;
cfg.atlas.expectedROIcount = 52;
cfg.atlas.labels = fullfile( ...
    repoRoot, 'data', 'reference', 'atlases', 'AllenBrain_2021_v2', ...
    'AllenBrain_2021_v2_inPax_merged_jr.txt');
cfg.atlas.nifti = fullfile( ...
    repoRoot, 'data', 'reference', 'atlases', 'AllenBrain_2021_v2', ...
    'AllenBrain_2021_v2_inPax_merged.nii');

% Only matrix sets consumed by manuscript figure/statistics scripts.
cfg.primaryMatrixSuffixes = {
    'Odor1to40'
    'Odor11to40'
    'Odor81to120'
    'TPnoPuff11to40'
    'TPnoPuff81to120'
};
cfg.expectedMatrixCount = 5;

toolboxRoot = fullfile( ...
    repoRoot, 'src', 'matlab', 'preprocessing', 'toolboxes');
cfg.toolboxes.basco = fullfile(toolboxRoot,'BASCO');
cfg.toolboxes.spm12Animal = fullfile(toolboxRoot,'spm12_animal');

cfg.basco.anaobjFile = fullfile( ...
    cfg.toolboxOutputDir,'out_estimated_reappraisal_v6.mat');

end
