% panel_D_lid_boxplot.m
% Jonathan Reinwald
%
% Supplementary Figure S1D, left:
% tonic eyelid opening in the no-puff control cohort.
%
% Included periods:
%   PRE          = trials 11-40
%   NON-PAIRING  = trials 41-80
%   TEST         = trials 81-120
%
% Input:
%   data/processed/eyelid/control/
%       Mean_LidData_R_intrasession_control.xlsx
%
% Required columns:
%   animal_ID
%   block
%   lid
%
% Statistical testing is performed in:
%   panel_D_lid_stats.R
%
% Outputs:
%   results/supplement/Figure_S1/Figure_S1D/

clear;
close all;
clc;

%% Locate repository root

scriptFile = mfilename('fullpath');

if isempty(scriptFile)
    error([ ...
        'MATLAB could not determine the script location. ' ...
        'Run the complete saved script rather than selected lines.' ...
    ]);
end

scriptDir = fileparts(scriptFile);
repoRoot = fileparts(fileparts(fileparts(scriptDir)));

%% Paths

srcDir = fullfile(repoRoot, 'src', 'matlab');

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s', srcDir);
end

addpath(genpath(srcDir));

inputFile = fullfile( ...
    repoRoot, 'data', 'processed', 'eyelid', 'control', ...
    'Mean_LidData_R_intrasession_control.xlsx' ...
);

outputDir = fullfile( ...
    repoRoot, 'results', 'supplement', 'Figure_S1', 'Figure_S1D' ...
);

if ~isfile(inputFile)
    error('Figure S1D tonic input file not found:\n%s', inputFile);
end

if ~isfolder(outputDir)
    mkdir(outputDir);
end

if isempty(which('notBoxPlot_modified_pupilANDlid'))
    error([ ...
        'Required plotting helper not found: ' ...
        'notBoxPlot_modified_pupilANDlid.m' ...
    ]);
end

%% Load and clean processed tonic values

myData = readtable( ...
    inputFile, ...
    'VariableNamingRule', 'preserve' ...
);

requiredVariables = {'animal_ID','block','lid'};

for variableIndex = 1:numel(requiredVariables)
    if ~ismember(requiredVariables{variableIndex}, myData.Properties.VariableNames)
        error( ...
            'Required column "%s" is missing from:\n%s', ...
            requiredVariables{variableIndex}, inputFile ...
        );
    end
end

myData.lid = str2double(string(myData.lid));
blockNumeric = str2double(string(myData.block));

keepRows = ...
    isfinite(myData.lid) & ...
    isfinite(blockNumeric) & ...
    ismember(blockNumeric, [1,2,3]);

myData = myData(keepRows, :);
blockNumeric = blockNumeric(keepRows);

presentBlocks = sort(unique(blockNumeric));

if ~isequal(presentBlocks(:)', [1,2,3])
    error( ...
        'Figure S1D requires block codes 1, 2, and 3. Present: %s', ...
        mat2str(presentBlocks(:)') ...
    );
end

%% Construct animal-by-block matrix

animalStrings = string(myData.animal_ID);
animalIDs = unique(animalStrings, 'stable');

nAnimals = numel(animalIDs);
nBlocks = 3;

plotData = nan(nAnimals, nBlocks);

for animalIndex = 1:nAnimals
    for blockIndex = 1:nBlocks

        selectedRows = ...
            animalStrings == animalIDs(animalIndex) & ...
            blockNumeric == blockIndex;

        currentValues = myData.lid(selectedRows);

        if ~isempty(currentValues)
            plotData(animalIndex, blockIndex) = ...
                mean(currentValues, 'omitnan');
        end
    end
end

%% Plot

fig = figure( ...
    'Name', 'Figure S1D: tonic control eyelid response', ...
    'Visible', 'on', ...
    'Color', 'white', ...
    'Position', [100,100,470,500] ...
);

ax = axes(fig);
hold(ax, 'on');

nb = notBoxPlot_modified_pupilANDlid(plotData);

plotColor = [0, 0.5, 0];

for blockIndex = 1:nBlocks

    nb(blockIndex).sdPtch.EdgeColor = 'none';
    nb(blockIndex).semPtch.EdgeColor = 'none';

    nb(blockIndex).sdPtch.FaceColor = plotColor;
    nb(blockIndex).semPtch.FaceColor = plotColor;

    nb(blockIndex).sdPtch.FaceAlpha = 0.10;
    nb(blockIndex).semPtch.FaceAlpha = 0.30;

    nb(blockIndex).mu.Color = plotColor;

    nb(blockIndex).data.MarkerFaceColor = plotColor;
    nb(blockIndex).data.MarkerEdgeColor = 'none';
    nb(blockIndex).data.MarkerSize = 8;
end

box(ax, 'off');

ax.XTick = 1:3;
ax.XTickLabel = {'PRE','NON-PAIRING','TEST'};

ax.XLabel.String = 'Block';
ax.YLabel.String = {'Eye opening [A.U.]','mean per block'};

ax.FontWeight = 'bold';
ax.LineWidth = 1;
ax.FontSize = 11;

title(ax, 'Tonic eye-lid opening: no-puff control');

%% Export source data

cleanSourceData = table( ...
    animalStrings, ...
    blockNumeric, ...
    myData.lid, ...
    'VariableNames', {'animal_ID','block','lid'} ...
);

writetable( ...
    cleanSourceData, ...
    fullfile(outputDir,'SourceData_Figure_S1D_tonic_lid_long.csv') ...
);

wideSourceData = array2table( ...
    plotData, ...
    'VariableNames', {'PRE','NON_PAIRING','TEST'} ...
);

wideSourceData = addvars( ...
    wideSourceData, ...
    animalIDs, ...
    'Before',1, ...
    'NewVariableNames','animal_ID' ...
);

writetable( ...
    wideSourceData, ...
    fullfile(outputDir,'SourceData_Figure_S1D_tonic_lid_wide.csv') ...
);

metadata = table( ...
    string('Figure S1D'), ...
    string('control/no-puff'), ...
    string('tonic'), ...
    nAnimals, ...
    string('1=PRE;2=NON-PAIRING;3=TEST'), ...
    string(inputFile), ...
    'VariableNames', { ...
        'Figure','Cohort','Analysis','N_Animals','Blocks','InputFile' ...
    } ...
);

writetable( ...
    metadata, ...
    fullfile(outputDir,'AnalysisMetadata_Figure_S1D_tonic_plot.csv') ...
);

if ~isempty(which('docDataSrc'))
    try
        docDataSrc(fig, outputDir, scriptFile, true);
    catch documentationError
        warning('docDataSrc failed: %s', documentationError.message);
    end
end

exportgraphics( ...
    fig, ...
    fullfile(outputDir,'Figure_S1D_tonic_lid_boxplot.pdf'), ...
    'ContentType','vector', ...
    'BackgroundColor','white' ...
);

exportgraphics( ...
    fig, ...
    fullfile(outputDir,'Figure_S1D_tonic_lid_boxplot.png'), ...
    'Resolution',300, ...
    'BackgroundColor','white' ...
);

savefig(fig, fullfile(outputDir,'Figure_S1D_tonic_lid_boxplot.fig'));

save( ...
    fullfile(outputDir,'Figure_S1D_tonic_lid_complete_results.mat'), ...
    'plotData','animalIDs','plotColor','inputFile' ...
);

fprintf('\nCompleted Supplementary Figure S1D tonic control plot.\n');
fprintf('Animals: %d\n', nAnimals);
fprintf('Outputs saved to:\n%s\n', outputDir);
