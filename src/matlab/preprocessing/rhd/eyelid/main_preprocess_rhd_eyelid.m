
%% main_preprocess_rhd_eyelid.m
%
% Pair eyelid-session protocol MAT files with their RHD segments and
% generate synchronized odor/air-puff/video timing files.

clearvars;
close all;
clc;

scriptFile = mfilename('fullpath');
scriptDir = fileparts(scriptFile);

preprocessingRoot = fileparts(fileparts(scriptDir));
helpersDir = fullfile(preprocessingRoot,'helpers');

if isfolder(helpersDir)
    addpath(helpersDir);
end

repoRoot = find_repo_root(scriptFile);

addpath(genpath(fullfile(scriptDir,'functions')));

% Reuse the common RHD conversion code distributed for task timing.
sharedRhdFunctions = fullfile( ...
    preprocessingRoot,'rhd','reappraisal','functions');

if isfolder(sharedRhdFunctions)
    addpath(genpath(sharedRhdFunctions));
end

cfg = eyelid_protocol_config(repoRoot);

if ~isfolder(cfg.outputDir)
    mkdir(cfg.outputDir);
end

if ~isfolder(cfg.workDir)
    mkdir(cfg.workDir);
end

runStage.process = false;

if runStage.process

    assert(~isempty(cfg.rawRoot) && isfolder(cfg.rawRoot), ...
        'Set NOSEMAZE_EYELID_RAW_ROOT.');

    assert(isfolder(cfg.protocolDir), ...
        'Protocol directory missing:\n%s',cfg.protocolDir);

    assert(isfolder(cfg.rhdDir), ...
        'RHD directory missing:\n%s',cfg.rhdDir);

    protocolFiles = list_files_recursive( ...
        cfg.protocolDir,'*protocol.mat');

    rhdFiles = list_files_recursive( ...
        cfg.rhdDir,'*.rhd');

    pairs = pair_eyelid_protocol_rhd( ...
        protocolFiles,rhdFiles);

    process_protocol_eyelid(pairs,cfg);
end

fprintf('\nEyelid RHD/protocol preprocessing initialized.\n');
