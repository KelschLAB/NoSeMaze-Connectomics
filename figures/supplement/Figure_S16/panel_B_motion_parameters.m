% panel_B_motion_parameters.m
% Jonathan Reinwald
%
% Supplementary Figure S16B
%
% Across-animal summary of head-motion parameters for the reappraisal
% fMRI dataset.
%
% IMPORTANT:
% This version uses the DESPIKED motion-parameter files from the canonical
% preprocessing repository location:
%
% data/processed/fMRI/preprocessing/reappraisal/
% ├── ZI_M13/
% │   └── motion/
% │       └── rp_despiked_del*.txt
% ├── ZI_M14/
% │   └── motion/
% │       └── rp_despiked_del*.txt
% └── ...
%
% Motion processing retained from the original analysis:
%   - quadratic detrending of each of the six motion parameters
%   - SNiP_framewise_displacement(rp)
%   - translational parameters divided by 10 after FD calculation
%   - per-animal mean absolute frame-to-frame motion
%
% Required helpers under src/matlab/:
%   SNiP_framewise_displacement.m
%   notBoxPlot.m
%
% Outputs:
%   results/supplement/Figure_S16/Figure_S16B/
%
% -------------------------------------------------------------------------

clear;
close all;
clc;

%% Locate repository root

scriptFile = mfilename('fullpath');

if isempty(scriptFile)
    error([ ...
        'MATLAB could not determine the location of this script. ' ...
        'Run the complete saved script rather than selected lines.' ...
    ]);
end

scriptDir = fileparts(scriptFile);

% repository/figures/supplement/Figure_S16/panel_B_motion_parameters.m
repoRoot = fileparts(fileparts(fileparts(scriptDir)));

%% Repository-relative paths

srcDir = fullfile(repoRoot,'src','matlab');

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s',srcDir);
end

addpath(genpath(srcDir));

inputRoot = fullfile( ...
    repoRoot, ...
    'data','processed','fMRI', ...
    'preprocessing','reappraisal' ...
);

outputDir = fullfile( ...
    repoRoot, ...
    'results','supplement', ...
    'Figure_S16','Figure_S16B' ...
);

if ~isfolder(outputDir)
    mkdir(outputDir);
end

%% Required helpers

requiredFunctions = {
    'SNiP_framewise_displacement'
    'notBoxPlot'
};

missingFunctions = requiredFunctions( ...
    cellfun(@(x) isempty(which(x)), requiredFunctions) ...
);

if ~isempty(missingFunctions)
    error([ ...
        'Required MATLAB helper functions not found:\n%s\n\n' ...
        'Place them somewhere under src/matlab/.' ...
    ], ...
        strjoin(missingFunctions,newline) ...
    );
end

%% Find canonical animal folders

if ~isfolder(inputRoot)
    error( ...
        ['Canonical preprocessing directory not found:\n%s\n\n' ...
         'Expected folders such as ZI_M13/motion/ underneath it.'], ...
        inputRoot ...
    );
end

animalDirs = dir(fullfile(inputRoot,'ZI_M*'));
animalDirs = animalDirs([animalDirs.isdir]);
animalDirs = animalDirs(~ismember({animalDirs.name},{'.','..'}));

if isempty(animalDirs)
    error('No ZI_M* animal folders found under:\n%s',inputRoot);
end

%% Sort animal folders numerically by ZI_M number

animalIDs = string({animalDirs.name})';
animalNumbers = nan(numel(animalDirs),1);

for i = 1:numel(animalDirs)

    token = regexp( ...
        animalDirs(i).name, ...
        '^ZI_M(\d+)$', ...
        'tokens','once' ...
    );

    if ~isempty(token)
        animalNumbers(i) = str2double(token{1});
    end
end

[~,sortIndex] = sortrows( ...
    [isnan(animalNumbers),animalNumbers], ...
    [1 2] ...
);

animalDirs = animalDirs(sortIndex);
animalIDs = animalIDs(sortIndex);

%% Find one rp_despiked_del*.txt file per animal

motionFiles = strings(numel(animalDirs),1);

for i = 1:numel(animalDirs)

    animalDir = fullfile( ...
        animalDirs(i).folder, ...
        animalDirs(i).name ...
    );

    motionDir = fullfile(animalDir,'motion');

    if ~isfolder(motionDir)
        error( ...
            'Motion directory missing for %s:\n%s', ...
            animalDirs(i).name,motionDir ...
        );
    end

    % Prefer the exact historical naming branch.
    candidates = dir(fullfile( ...
        motionDir, ...
        'rp_despiked_del5*.txt' ...
    ));

    candidates = candidates(~[candidates.isdir]);

    % Fallback for naming variants such as rp_despiked_del_...
    if isempty(candidates)

        candidates = dir(fullfile( ...
            motionDir, ...
            'rp_despiked_del*.txt' ...
        ));

        candidates = candidates(~[candidates.isdir]);
    end

    if isempty(candidates)

        error( ...
            ['No rp_despiked_del*.txt file found for %s in:\n%s'], ...
            animalDirs(i).name, ...
            motionDir ...
        );
    end

    if numel(candidates) > 1

        candidatePaths = fullfile( ...
            {candidates.folder}, ...
            {candidates.name} ...
        );

        error([ ...
            'Multiple rp_despiked_del*.txt files found for %s.\n' ...
            'Expected exactly one:\n%s'], ...
            animalDirs(i).name, ...
            strjoin(candidatePaths,newline) ...
        );
    end

    motionFiles(i) = string(fullfile( ...
        candidates(1).folder, ...
        candidates(1).name ...
    ));
end

fprintf('\nSupplementary Figure S16B\n');
fprintf('Using DESPIKED motion parameters.\n');
fprintf('Canonical preprocessing directory:\n%s\n\n',inputRoot);
fprintf('Found %d animals with rp_despiked_del files.\n\n', ...
    numel(motionFiles));

%% Process each animal

nAnimals = numel(motionFiles);

meanMotionPerAnimal = nan(nAnimals,6);
meanFDPerAnimal = nan(nAnimals,1);

for subjectIndex = 1:nAnimals

    currentFile = char(motionFiles(subjectIndex));

    fprintf('[%02d/%02d] %s <- %s\n', ...
        subjectIndex, ...
        nAnimals, ...
        animalIDs(subjectIndex), ...
        currentFile ...
    );

    rp = loadMotionParameters(currentFile);

    if size(rp,2) ~= 6
        error( ...
            ['Motion file must contain exactly 6 columns. ' ...
             'Found %d columns in:\n%s'], ...
            size(rp,2), ...
            currentFile ...
        );
    end

    if size(rp,1) < 3
        error( ...
            'Motion file contains fewer than 3 frames:\n%s', ...
            currentFile ...
        );
    end

    %% Quadratic detrending
    %
    % Retained from the original script.

    frameIndex = 1:size(rp,1);

    for parameterIndex = 1:size(rp,2)

        [p,~,mu] = polyfit( ...
            frameIndex, ...
            rp(:,parameterIndex)', ...
            2 ...
        );

        trend = polyval( ...
            p, ...
            frameIndex, ...
            [], ...
            mu ...
        );

        rp(:,parameterIndex) = ...
            rp(:,parameterIndex) - trend';
    end

    %% Framewise displacement
    %
    % IMPORTANT:
    % calculated from the detrended original rp values BEFORE the
    % translation columns are divided by 10, exactly as in the original
    % analysis.

    FD = SNiP_framewise_displacement(rp);
    FD = FD(:);

    if numel(FD) ~= size(rp,1)
        error([ ...
            'SNiP_framewise_displacement returned %d values for %d frames ' ...
            'in:\n%s'], ...
            numel(FD), ...
            size(rp,1), ...
            currentFile ...
        );
    end

    %% Correct translation scaling
    %
    % Retained exactly from the original analysis:
    % translation columns 1:3 divided by 10; rotations unchanged.

    rpCorr = [
        rp(:,1:3)./10, ...
        rp(:,4:6)
    ];

    %% Frame-to-frame motion

    rpDiff = [
        zeros(1,6)
        diff(rpCorr)
    ];

    meanMotionPerAnimal(subjectIndex,:) = ...
        mean(abs(rpDiff),1,'omitnan');

    meanFDPerAnimal(subjectIndex) = ...
        mean(FD,'omitnan');
end

fprintf('\nProcessed %d animals.\n',nAnimals);

%% Figure S16B

fig = figure( ...
    'Name','Supplementary Figure S16B: motion parameters', ...
    'Visible','on', ...
    'Color','white', ...
    'Position',[100,100,1050,650] ...
);

gray = [0.2,0.2,0.2];

%% Translation

subplot(2,2,1);

Bx = notBoxPlot(meanMotionPerAnimal(:,1:3));

formatNotBoxPlot(Bx,gray);

ax = gca;
box(ax,'off');

ax.YLim = [0,0.1];
ax.YTick = 0:0.02:0.1;
ylabel(ax,'rp [mm]');

ax.XTick = 1:3;
ax.XTickLabel = {'right','forward','up'};
xtickangle(ax,70);

ax.FontSize = 14;
title(ax,'translation');

%% Rotation

subplot(2,2,2);

Bx = notBoxPlot(meanMotionPerAnimal(:,4:6));

formatNotBoxPlot(Bx,gray);

ax = gca;
box(ax,'off');

ax.YLim = [0,0.01];
ax.YTick = 0:0.005:0.01;
ylabel(ax,'rp [rad]');

ax.XTick = 1:3;
ax.XTickLabel = {'pitch','roll','yaw'};
xtickangle(ax,70);

ax.FontSize = 14;
title(ax,'rotation');

%% Framewise displacement

subplot(2,2,3);

Bx = notBoxPlot(meanFDPerAnimal);

formatNotBoxPlot(Bx,gray);

ax = gca;
box(ax,'off');

ax.YLim = [0,0.1];
ax.YTick = 0:0.025:0.1;
ylabel(ax,'FD [mm]');

ax.XTick = 1;
ax.XTickLabel = {''};
ax.XLim = [0,2];

ax.FontSize = 14;
title(ax,'FD');

%% Source data

relativeMotionPath = strings(nAnimals,1);

for i = 1:nAnimals

    relativeMotionPath(i) = makeRepoRelative( ...
        motionFiles(i), ...
        repoRoot ...
    );
end

sourceData = table( ...
    animalIDs, ...
    relativeMotionPath, ...
    meanMotionPerAnimal(:,1), ...
    meanMotionPerAnimal(:,2), ...
    meanMotionPerAnimal(:,3), ...
    meanMotionPerAnimal(:,4), ...
    meanMotionPerAnimal(:,5), ...
    meanMotionPerAnimal(:,6), ...
    meanFDPerAnimal, ...
    'VariableNames', {
        'Animal'
        'MotionFile'
        'MeanAbsTranslation_Right_mm'
        'MeanAbsTranslation_Forward_mm'
        'MeanAbsTranslation_Up_mm'
        'MeanAbsRotation_Pitch_rad'
        'MeanAbsRotation_Roll_rad'
        'MeanAbsRotation_Yaw_rad'
        'MeanFD_mm'
    } ...
);

writetable( ...
    sourceData, ...
    fullfile( ...
        outputDir, ...
        'SourceData_Figure_S16B_MotionParameters.csv' ...
    ) ...
);

%% Summary statistics

metricNames = [
    "Translation_Right"
    "Translation_Forward"
    "Translation_Up"
    "Rotation_Pitch"
    "Rotation_Roll"
    "Rotation_Yaw"
    "FD"
];

allValues = [
    meanMotionPerAnimal, ...
    meanFDPerAnimal
];

nPerMetric = sum(~isnan(allValues),1);

summaryTable = table( ...
    metricNames, ...
    mean(allValues,1,'omitnan')', ...
    std(allValues,0,1,'omitnan')', ...
    (std(allValues,0,1,'omitnan') ./ sqrt(nPerMetric))', ...
    min(allValues,[],1,'omitnan')', ...
    max(allValues,[],1,'omitnan')', ...
    nPerMetric', ...
    'VariableNames', {
        'Metric'
        'Mean'
        'SD'
        'SEM'
        'Minimum'
        'Maximum'
        'N'
    } ...
);

writetable( ...
    summaryTable, ...
    fullfile( ...
        outputDir, ...
        'Statistics_Figure_S16B_MotionParameters.csv' ...
    ) ...
);

%% Analysis metadata

metadata = table( ...
    string('Figure S16B'), ...
    string('rp_despiked_del'), ...
    nAnimals, ...
    string('quadratic detrending'), ...
    string('SNiP_framewise_displacement on detrended original rp values'), ...
    string('translation columns 1:3 divided by 10 after FD calculation'), ...
    string(makeRepoRelative(inputRoot,repoRoot)), ...
    'VariableNames', { ...
        'Panel'
        'MotionFileType'
        'NumberOfAnimals'
        'Detrending'
        'FramewiseDisplacement'
        'TranslationScaling'
        'InputRoot'
    } ...
);

writetable( ...
    metadata, ...
    fullfile( ...
        outputDir, ...
        'AnalysisMetadata_Figure_S16B_MotionParameters.csv' ...
    ) ...
);

%% Save MATLAB result

result = struct;
result.animalID = animalIDs;
result.motionFilePath = relativeMotionPath;
result.motionFileType = 'rp_despiked_del';
result.meanMotionPerAnimal = meanMotionPerAnimal;
result.meanFDPerAnimal = meanFDPerAnimal;
result.sourceData = sourceData;
result.summaryTable = summaryTable;
result.metadata = metadata;

save( ...
    fullfile( ...
        outputDir, ...
        'Results_Figure_S16B_MotionParameters.mat' ...
    ), ...
    'result' ...
);

%% Optional provenance

if ~isempty(which('docDataSrc'))
    try
        docDataSrc(fig,outputDir,scriptFile,true);
    catch documentationError
        warning( ...
            'docDataSrc failed: %s', ...
            documentationError.message ...
        );
    end
end

%% Export

exportgraphics( ...
    fig, ...
    fullfile( ...
        outputDir, ...
        'Figure_S16B_MotionParameters.pdf' ...
    ), ...
    'ContentType','vector', ...
    'BackgroundColor','white' ...
);

exportgraphics( ...
    fig, ...
    fullfile( ...
        outputDir, ...
        'Figure_S16B_MotionParameters.png' ...
    ), ...
    'Resolution',300, ...
    'BackgroundColor','white' ...
);

fprintf('\nSupplementary Figure S16B completed.\n');
fprintf('Results saved to:\n%s\n',outputDir);


%% ========================================================================
% Local functions
%% ========================================================================

function rp = loadMotionParameters(filename)

    rp = readmatrix(filename);

    if isempty(rp) || ~isnumeric(rp)
        error( ...
            'Could not read numeric motion parameters from:\n%s', ...
            filename ...
        );
    end

    % Remove fully empty rows/columns if readmatrix introduced them.
    rp = rp(~all(isnan(rp),2),:);
    rp = rp(:,~all(isnan(rp),1));

    if any(isnan(rp(:)))
        error( ...
            'Motion file contains non-numeric or missing entries:\n%s', ...
            filename ...
        );
    end
end


function formatNotBoxPlot(Bx,gray)

    for nBx = 1:numel(Bx)

        Bx(nBx).data.MarkerSize = 5;
        Bx(nBx).data.MarkerEdgeColor = 'none';
        Bx(nBx).data.MarkerFaceColor = gray;

        Bx(nBx).sdPtch.EdgeColor = 'none';
        Bx(nBx).semPtch.EdgeColor = 'none';

        Bx(nBx).mu.Color = gray;
        Bx(nBx).mu.LineWidth = 1;

        if isprop(Bx(nBx).sdPtch,'FaceColor')
            Bx(nBx).sdPtch.FaceColor = [0.75,0.75,0.75];
        end

        if isprop(Bx(nBx).semPtch,'FaceColor')
            Bx(nBx).semPtch.FaceColor = [0.5,0.5,0.5];
        end
    end
end


function rel = makeRepoRelative(pathString,repoRoot)

    p = strrep(char(pathString),'\','/');
    r = strrep(char(repoRoot),'\','/');

    if startsWith(lower(p),lower(r))
        rel = extractAfter(string(p),strlength(r));
        rel = regexprep(rel,'^[\\/]+','');
    else
        rel = string(p);
    end
end
