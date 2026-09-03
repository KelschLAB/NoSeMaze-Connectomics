
function cfg = eyelid_config(repoRoot)
% EYELID_CONFIG Final eyelid preprocessing settings.
%
% This module intentionally contains only the eyelid-area estimator used
% for the manuscript source data: quadratic polynomial fits through five
% upper-lid and five lower-lid landmarks.
%
% No pupil, ellipse, cubic-interpolation, polygon-area, or eyelid-distance
% alternatives are implemented in the active repository pipeline.

arguments
    repoRoot (1,:) char
end

cfg = struct();

%% External/private inputs

cfg.dlcRoot = getenv('NOSEMAZE_EYELID_DLC_ROOT');
cfg.videoRoot = getenv('NOSEMAZE_EYELID_VIDEO_ROOT');

cfg.processedProtocolRoot = getenv( ...
    'NOSEMAZE_EYELID_PROTOCOL_PROCESSED_ROOT');

if isempty(cfg.processedProtocolRoot)
    cfg.processedProtocolRoot = fullfile( ...
        repoRoot,'data','interim','eyelid','processed_protocol_files');
end

%% Repository files

cfg.manifestFile = fullfile( ...
    repoRoot,'data','reference','eyelid','eyelid_sessions.csv');

cfg.outputDir = fullfile( ...
    repoRoot,'data','processed','eyelid');

cfg.outputFile = fullfile( ...
    cfg.outputDir,'eyelid_summary_all.mat');

%% Video / DLC

% Historical effective video rate used by the analysis.
cfg.frameRateHz = 10;

% Exact eight eyelid bodyparts in the supplied DLC output.
cfg.bodyparts = [ ...
    "LidN","LidNE","LidE","LidSE", ...
    "LidS","LidSW","LidW","LidNW" ...
];

% Source-data generating MATLAB master used 0.80. The current manuscript
% text states 0.95; this discrepancy is documented in README.md rather
% than silently changing the executed source-data pipeline.
cfg.likelihoodThreshold = 0.80;

%% Final polynomial eyelid-area estimator

% Bodypart order above:
% 1 N, 2 NE, 3 E, 4 SE, 5 S, 6 SW, 7 W, 8 NW
cfg.upperLidIndices = [7 8 1 2 3]; % W, NW, N, NE, E
cfg.lowerLidIndices = [7 4 5 6 3]; % W, SE, S, SW, E
cfg.eastIndex = 3;
cfg.westIndex = 7;

cfg.polynomialDegree = 2;
cfg.fitStepPixels = 0.1;

%% Historical spike/NaN correction

cfg.coordinateSpikeStdThreshold = 3;
cfg.coordinateMaxGap = 4;

cfg.trialSpikeStdThreshold = 3;
cfg.trialMaxGap = 4;

%% Video synchronization

cfg.videoSyncSearchSec = 60;

%% Trial alignment / normalization

cfg.preSec = 1.9;
cfg.postSec = 9.9;
cfg.timeSec = -cfg.preSec:(1/cfg.frameRateHz):cfg.postSec;

% Historical baseline: 19 frames immediately before odor onset.
cfg.baselineSec = 1.9;

%% CR windows used by the final analyses

cfg.distalWindowSec = [0.1 1.1];
cfg.proximalWindowSec = [2.5 3.5];

end
