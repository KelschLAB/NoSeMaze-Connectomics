
%% main_preprocess_protocol_hrf.m
%
% Clean HRF-cohort task/RHD timing preprocessing.

clearvars;
close all;
clc;

scriptFile = mfilename('fullpath');
if isempty(scriptFile)
    error('Run the complete saved script rather than selected lines.');
end

scriptDir = fileparts(scriptFile);
preprocessingRoot = fileparts(fileparts(scriptDir));
helpersDir = fullfile(preprocessingRoot,'helpers');

if isfolder(helpersDir)
    addpath(helpersDir); % find_repo_root
end

repoRoot = find_repo_root(scriptFile);

matlabRoot = fullfile(repoRoot,'src','matlab');

% Shared generic helpers.
addpath(fullfile(matlabRoot,'helpers'));

% RHD conversion code already distributed with the reappraisal pipeline.
rhdShared = fullfile( ...
    matlabRoot,'preprocessing','rhd','reappraisal','functions');
if isfolder(rhdShared)
    addpath(genpath(rhdShared));
end

% HRF-specific parser.
addpath(genpath(fullfile(scriptDir,'functions')));

cfg = hrf_protocol_config(repoRoot);

if ~isfolder(cfg.processedProtocolDir)
    mkdir(cfg.processedProtocolDir);
end

runStage.processProtocols = false;

requiredFunctions = {'getAllFiles','RhdToMat_lw','process_protocol__hrf'};
missingFunctions = requiredFunctions( ...
    cellfun(@(x) isempty(which(x)),requiredFunctions));

if ~isempty(missingFunctions)
    fprintf('Missing HRF protocol dependency/dependencies:\n');
    fprintf('  %s.m\n',missingFunctions{:});
end

if runStage.processProtocols

    assert(~isempty(cfg.rawRoot) && isfolder(cfg.rawRoot), ...
        ['Set NOSEMAZE_HRF_PROTOCOL_RAW_ROOT to the historical ' ...
         'ICON_HRF/02-raw-data/01-MRI directory.']);

    assert(isfolder(cfg.protocolDir), ...
        'HRF protocol directory missing:\n%s',cfg.protocolDir);

    assert(isfolder(cfg.rhdDir), ...
        'HRF RHD directory missing:\n%s',cfg.rhdDir);

    assert(isempty(missingFunctions), ...
        'One or more HRF protocol dependencies are missing.');

    protocolList = getAllFiles(cfg.protocolDir,'*protocol.mat',1);
    rhdList = getAllFiles(cfg.rhdDir,'*.rhd',1);

    process_protocol__hrf( ...
        protocolList, ...
        rhdList, ...
        cfg.processedProtocolDir, ...
        cfg.rawRoot, ...
        cfg.expectedVolumes ...
    );
end

fprintf('\nHRF protocol preprocessing initialized.\n');
