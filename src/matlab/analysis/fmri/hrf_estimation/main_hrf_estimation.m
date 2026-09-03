
%% main_hrf_estimation.m
%
% Study-specific mouse HRF fitting.
%
% Preserved numerical procedure:
%
%   1. load mean residual BOLD time course for each HRF session
%   2. load high-resolution SPM onset vectors for the 3 odor durations
%   3. create the historical multi-start parameter grid
%   4. optimize each start with fminsearch by maximizing R²
%   5. retain session-wise solutions above that session's mean R²
%   6. average successful positive-R² parameter estimates
%   7. save fitted parameters and HRF plot
%
% The stale exploratory switches in the historical snapshot are replaced by
% the final manuscript branch:
%
%   mask source = from2sHRF-GLM
%   onset parameter = disabled

clearvars;
close all;
clc;

%% Locate repository / paths

scriptFile = mfilename('fullpath');
if isempty(scriptFile)
    error('Run the complete saved script rather than selected lines.');
end

scriptDir = fileparts(scriptFile); % .../analysis/fmri/hrf_estimation
fmriAnalysisDir = fileparts(scriptDir);
analysisDir = fileparts(fmriAnalysisDir);

commonGlmFunctions = fullfile(fmriAnalysisDir,'glm','common','functions');
localFunctions = fullfile(scriptDir,'functions');

if isfolder(commonGlmFunctions); addpath(commonGlmFunctions); end
addpath(genpath(localFunctions));

if exist('find_repo_root_analysis','file')==2
    repoRoot = find_repo_root_analysis(scriptFile);
else
    % Fallback to preprocessing helper.
    preprocessingHelpers = fullfile( ...
        fileparts(analysisDir),'preprocessing','helpers');
    addpath(preprocessingHelpers);
    repoRoot = find_repo_root(scriptFile);
end

cfg = hrf_estimation_config(repoRoot);

if ~isfolder(cfg.outputDir); mkdir(cfg.outputDir); end

%% Dependencies

if isempty(which('spm_hrf'))
    error('SPM12 spm_hrf.m was not found on the MATLAB path.');
end

if isempty(which('estimate_GLM_model_highres'))
    error([ ...
        'estimate_GLM_model_highres.m is required for the HRF fit but ' ...
        'was not found on the MATLAB path.' ...
    ]);
end

%% Sessions and starting values

sessionIDs = list_hrf_sessions(cfg);
x0 = build_hrf_start_grid(cfg);

nSessions = numel(sessionIDs);
nStarts = size(x0,1);
nParams = size(x0,2);

rsqAll = nan(nSessions,nStarts);
hrfParamAll = nan(nSessions,nStarts,nParams);

%% Session-wise fitting

for s = 1:nSessions

    fprintf('HRF fitting: %s (%d/%d)\n', ...
        sessionIDs(s),s,nSessions);

    [meanTC,onsets] = load_hrf_fit_inputs(cfg,sessionIDs(s));

    [rsqAll(s,:),hrfParamAll(s,:,:)] = fit_hrf_multistart( ...
        meanTC, ...
        onsets, ...
        cfg.TR, ...
        cfg.microtimeResolution, ...
        cfg.microtimeOnset, ...
        x0, ...
        cfg.highResolution, ...
        cfg.maxFunctionEvaluations ...
    );
end

%% Historical aggregation rule

hrfParamConcatenated = [];
rsqConcatenated = [];

for s = 1:nSessions

    keep = rsqAll(s,:) > mean(rsqAll(s,:),'omitnan');

    hrfParamConcatenated = [ ...
        hrfParamConcatenated; ...
        squeeze(hrfParamAll(s,keep,:)) ...
    ]; %#ok<AGROW>

    rsqConcatenated = [ ...
        rsqConcatenated; ...
        rsqAll(s,keep)' ...
    ]; %#ok<AGROW>
end

positiveFits = rsqConcatenated > 0;

assert(any(positiveFits), ...
    'No positive-R² HRF fits were retained.');

hrfVal = mean( ...
    hrfParamConcatenated(positiveFits,:), ...
    1, ...
    'omitnan' ...
);

%% Plot fitted HRF

figure('Color','w');

if cfg.optimizeOnsetParameter

    p = [ ...
        hrfVal(1), ...
        hrfVal(2), ...
        hrfVal(3), ...
        hrfVal(3), ...
        hrfVal(4), ...
        hrfVal(5), ...
        32 ...
    ];

else

    p = [ ...
        hrfVal(1), ...
        hrfVal(2), ...
        hrfVal(3), ...
        hrfVal(3), ...
        hrfVal(4), ...
        0, ...
        32 ...
    ];
end

sampleDt = 0.1;
h = spm_hrf(sampleDt,p);

plot((0:numel(h)-1)*sampleDt,h,'LineWidth',1.5);
xlabel('Time (s)');
ylabel('HRF');
box off;

%% Save

info = struct();
info.sessionIDs = sessionIDs;
info.startingPoints = x0;
info.hrfParamAll = hrfParamAll;
info.hrfParamConcatenated = hrfParamConcatenated;
info.hrfVal = hrfVal;
info.rsqAll = rsqAll;
info.rsqConcatenated = rsqConcatenated;
info.meanPositiveRsq = mean(rsqConcatenated(positiveFits),'omitnan');
info.maskSource = cfg.maskSource;
info.optimizeOnsetParameter = cfg.optimizeOnsetParameter;
info.TR = cfg.TR;
info.microtimeResolution = cfg.microtimeResolution;
info.microtimeOnset = cfg.microtimeOnset;

save(fullfile(cfg.outputDir,'hrf_info.mat'),'info');
saveas(gcf,fullfile(cfg.outputDir,'HRF_plot.pdf'));

fprintf('\nEstimated HRF parameters:\n');
disp(hrfVal);

fprintf('Final packaged HRF implementation:\n%s\n',cfg.finalHrfFunction);
