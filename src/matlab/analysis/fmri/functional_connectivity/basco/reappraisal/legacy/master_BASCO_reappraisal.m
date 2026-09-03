%% master_BASCO_reappraisal.m
% Reproducible BASCO / beta-series connectivity pipeline for the
% reappraisal experiment.
%
% Scientific settings are defined in config_BASCO_reappraisal.m.
% Execution switches live here only.

clearvars;
close all;
clc;

%% Project setup
script_dir = fileparts(mfilename('fullpath'));
repo_root  = find_repo_root(script_dir);
cfg        = config_BASCO_reappraisal(repo_root);

% Select stages to run.
steps.create_input      = false;
steps.run_basco         = false;   % BASCO GUI / toolbox step
steps.create_betaseries = false;
steps.create_cormat     = true;

setup_basco_paths(cfg);

%% Load subject/file list
S = load(cfg.files.filelist, 'Pfunc_reappraisal');
assert(isfield(S, 'Pfunc_reappraisal'), ...
    'Expected variable Pfunc_reappraisal in %s', cfg.files.filelist);
Pfunc_reappraisal = S.Pfunc_reappraisal;

fprintf('BASCO version:       %s\n', cfg.version.basco);
fprintf('Regressor version:   %s\n', cfg.version.regressors);
fprintf('Atlas:               %s\n', cfg.atlas.name);
fprintf('Number of sessions:  %d\n\n', numel(Pfunc_reappraisal));

%% 1. Create BASCO input
if steps.create_input
    create_input_BASCO(Pfunc_reappraisal, cfg);
end

%% 2. Run BASCO
if steps.run_basco
    assert(isfile(cfg.files.anadef), ...
        'Missing BASCO analysis-definition file: %s', cfg.files.anadef);

    fprintf('Opening BASCO.\n');
    fprintf('Analysis definition: %s\n', cfg.files.anadef);
    fprintf('Metainfo:            %s\n', cfg.files.metainfo);
    BASCO;
end

%% 3. Create 4-D beta-series images
if steps.create_betaseries
    create_betaseries_BASCO(Pfunc_reappraisal, cfg);
end

%% 4. Create ROI correlation matrices
if steps.create_cormat
    create_cormat_BASCO(Pfunc_reappraisal, cfg);
end

fprintf('\nBASCO pipeline finished.\n');

%% Local helper
function repo_root = find_repo_root(start_dir)
% Walk upwards until the repository marker is found.
repo_root = start_dir;
while true
    if isfolder(fullfile(repo_root, '.git')) || ...
            isfile(fullfile(repo_root, 'NoSeMaze-Connectomics.Rproj'))
        return;
    end

    parent = fileparts(repo_root);
    if strcmp(parent, repo_root)
        error(['Could not find repository root. Expected either .git/ or ' ...
            'NoSeMaze-Connectomics.Rproj above %s.'], start_dir);
    end
    repo_root = parent;
end
end

function setup_basco_paths(cfg)
% Add external dependencies without embedding machine-specific paths.
required_dirs = { ...
    cfg.toolboxes.spm12, ...
    cfg.toolboxes.marsbar, ...
    cfg.toolboxes.basco, ...
    cfg.hrf.path};

for ii = 1:numel(required_dirs)
    assert(isfolder(required_dirs{ii}), ...
        'Required toolbox/path not found: %s', required_dirs{ii});
end

% SPM itself should be added at its root. The other legacy toolboxes are
% added recursively because they contain callable functions in subfolders.
addpath(cfg.toolboxes.spm12);
addpath(genpath(cfg.toolboxes.marsbar));
addpath(genpath(cfg.toolboxes.basco));
addpath(genpath(cfg.hrf.path));

spm('defaults', 'fmri');
end
