%% main_preprocess_rhd_reappraisal.m
%
% Preprocess RHD task-timing recordings for the reappraisal fMRI cohort.
%
% Raw RHD recordings can either be placed under the repository data/raw/
% tree or supplied from an external/private location through the environment
% variable NOSEMAZE_REAPPRAISAL_RHD_ROOT.
%
% Protocol MAT files are expected under:
%   data/raw/RHD/reappraisal/protocol_files/
%
% Output:
%   data/processed/RHD/reappraisal/processed_protocol_files/
%
% The numerical event extraction itself is implemented in:
%   functions/process_protocol_reappraisal.m

clearvars;
close all;
clc;

scriptFile = mfilename('fullpath');
scriptDir = fileparts(scriptFile);
preprocessingRoot = fileparts(fileparts(scriptDir));

addpath(scriptDir);
addpath(fullfile(scriptDir,'functions'));
addpath(fullfile(preprocessingRoot,'helpers'));

repoRoot = find_repo_root(scriptFile);

protocolDir = fullfile( ...
    repoRoot,'data','raw','RHD','reappraisal','protocol_files');

repoRhdDir = fullfile( ...
    repoRoot,'data','raw','RHD','reappraisal','rhd_files');

externalRhdDir = getenv('NOSEMAZE_REAPPRAISAL_RHD_ROOT');

if isfolder(repoRhdDir)
    rhdDir = repoRhdDir;
elseif ~isempty(externalRhdDir) && isfolder(externalRhdDir)
    rhdDir = externalRhdDir;
else
    error([ ...
        'RHD input directory not found.\n\n' ...
        'Either place the RHD files under:\n%s\n\n' ...
        'or set NOSEMAZE_REAPPRAISAL_RHD_ROOT.'], ...
        repoRhdDir ...
    );
end

outputDir = fullfile( ...
    repoRoot,'data','processed','RHD','reappraisal', ...
    'processed_protocol_files');

workDir = fullfile( ...
    repoRoot,'data','interim','RHD','reappraisal');

if ~isfolder(outputDir); mkdir(outputDir); end
if ~isfolder(workDir); mkdir(workDir); end

protocolList = get_all_files_recursive(protocolDir,'*protocol.mat');
rhdList = get_all_files_recursive(rhdDir,'*.rhd');

if isempty(protocolList)
    error('No *protocol.mat files found in:\n%s',protocolDir);
end

if isempty(rhdList)
    error('No *.rhd files found in:\n%s',rhdDir);
end

% Historical task run length.
nVolume = 1600;

process_protocol_reappraisal( ...
    protocolList, ...
    rhdList, ...
    outputDir, ...
    workDir, ...
    nVolume ...
);

fprintf('\nRHD/task-timing preprocessing completed.\n');
fprintf('Outputs:\n%s\n',outputDir);
