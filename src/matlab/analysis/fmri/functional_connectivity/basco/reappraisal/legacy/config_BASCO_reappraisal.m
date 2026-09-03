function cfg = config_BASCO_reappraisal(repo_root)
%CONFIG_BASCO_REAPPRAISAL Central configuration for BASCO connectivity.
%
% Keep machine-specific dependency locations in environment variables:
%   SPM12_DIR
%   MARSBAR_DIR
%   BASCO_DIR
%   SPM12_ANIMAL_DIR
%
% If an environment variable is absent, the code falls back to
% <repo>/external/<toolbox>.

%% Analysis identity
cfg.analysis.name       = 'reappraisal';
cfg.version.basco       = 'v11';
cfg.version.regressors  = 'v19';

%% EPI selection
% Preserve the exact legacy preprocessing choice used for BASCO input.
cfg.epi.prefix   = 'wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5_';
cfg.epi.suffix   = '_c1_c2t_wds';
cfg.epi.despiked = true;

%% HRF
cfg.hrf.estimate_length = 'from2sHRF-GLM';
cfg.hrf.onset           = 'withoutOnset';
cfg.hrf.tc_based        = 'longTC';
cfg.hrf.info_path       = sprintf('%s_%s', ...
    cfg.hrf.onset, cfg.hrf.estimate_length);
cfg.hrf.name            = sprintf('HRF%s_%s', ...
    cfg.hrf.tc_based, cfg.hrf.info_path);

%% Repository paths
cfg.paths.repo = repo_root;

% These are the only project-data paths that should need adjustment if the
% copied repository uses a slightly different data layout.
cfg.paths.processed_reappraisal = fullfile(repo_root, 'data', 'processed', ...
    'MRI', 'reappraisal');
cfg.paths.derived_reappraisal = fullfile(repo_root, 'data', 'derived', ...
    'MRI', 'reappraisal');

cfg.paths.protocol_dir = fullfile(cfg.paths.processed_reappraisal, ...
    'protocol');
cfg.paths.regressors_dir = fullfile(cfg.paths.derived_reappraisal, ...
    'GLM', 'regressors');

cfg.paths.basco_dir = fullfile(cfg.paths.derived_reappraisal, ...
    'FC', 'BASCO');
cfg.paths.input_dir = fullfile(cfg.paths.basco_dir, 'input');
cfg.paths.output_dir = fullfile(cfg.paths.basco_dir, 'output');
cfg.paths.cormat_dir = fullfile(cfg.paths.basco_dir, ...
    ['cormat_' cfg.version.basco]);
cfg.paths.beta4D_dir = fullfile(cfg.paths.cormat_dir, 'beta4D');
cfg.paths.matrix_dir = fullfile(cfg.paths.cormat_dir, 'matrices');
cfg.paths.roidata_dir = fullfile(cfg.paths.cormat_dir, 'roidata');

%% Regressor/covariate inputs
cfg.regressors.suffix = ['_' cfg.version.regressors '.mat'];

cfg.files.filelist = fullfile(cfg.paths.processed_reappraisal, ...
    'filelists', 'filelist_ICON_reappraisal_jr.mat');

cfg.files.metainfo = fullfile(cfg.paths.input_dir, ...
    ['metainfo_' cfg.version.basco '.mat']);

%% Atlas
% The legacy master actually used the 2023 separated-hemisphere atlas.
% The unused separated_hemisphere flag has therefore been removed.
cfg.atlas.name = 'AllenBrain_2023_v2_separatedHemispheres';
cfg.atlas.labels = fullfile(repo_root, 'data', 'reference', 'atlas', ...
    cfg.atlas.name, ...
    'AllenBrain_2023_v2_separatedHemispheres_inPax_merged_jr.txt');
cfg.atlas.nifti = fullfile(repo_root, 'data', 'reference', 'atlas', ...
    cfg.atlas.name, ...
    'AllenBrain_2023_v2_separatedHemispheres_inPax_merged_jr.nii');

%% BASCO analysis definition
this_dir = fileparts(mfilename('fullpath'));
cfg.files.anadef = fullfile(this_dir, 'anadef_reappraisal.m');

%% External dependencies
cfg.toolboxes.spm12 = resolve_external_path( ...
    'SPM12_DIR', fullfile(repo_root, 'external', 'spm12'));
cfg.toolboxes.marsbar = resolve_external_path( ...
    'MARSBAR_DIR', fullfile(repo_root, 'external', 'marsbar'));
cfg.toolboxes.basco = resolve_external_path( ...
    'BASCO_DIR', fullfile(repo_root, 'external', 'BASCO'));
cfg.toolboxes.spm12_animal = resolve_external_path( ...
    'SPM12_ANIMAL_DIR', fullfile(repo_root, 'external', 'spm12_animal'));

cfg.hrf.path = fullfile(cfg.toolboxes.spm12_animal, ...
    cfg.hrf.tc_based, ['hrf_' cfg.hrf.info_path]);

end

function p = resolve_external_path(env_name, fallback)
p = getenv(env_name);
if isempty(p)
    p = fallback;
end
end
