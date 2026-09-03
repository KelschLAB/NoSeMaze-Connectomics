% panel_C_dvars_fd_correlations.m
% Jonathan Reinwald
%
% Supplementary Figure S16C
%
% Subject-wise Pearson correlations between DVARS and FD_SNiP across
% preprocessing strategies in the CONDITIONING cohort only.
%
% Retained preprocessing strategies from the original analysis:
%   1) Nothing
%   2) AFNI
%   3) WD10_AFNI
%
% Canonical repository input:
%
% data/processed/fMRI/preprocessing/reappraisal/model_selection/
% └── DVARS_info.mat
%
% Expected variable:
%   DVARS_info
%
% with fields:
%   DVARS_info.Nothing.DVARS
%   DVARS_info.Nothing.FD_SNiP
%   DVARS_info.AFNI.DVARS
%   DVARS_info.AFNI.FD_SNiP
%   DVARS_info.WD10_AFNI.DVARS
%   DVARS_info.WD10_AFNI.FD_SNiP
%
% Required helper under src/matlab/:
%   notBoxPlot.m
%
% Optional:
%   docDataSrc.m
%
% Outputs:
%   results/supplement/Figure_S16/Figure_S16C/
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

% repository/figures/supplement/Figure_S16/panel_C_dvars_fd_correlations.m
repoRoot = fileparts(fileparts(fileparts(scriptDir)));

%% Repository-relative paths

srcDir = fullfile(repoRoot,'src','matlab');

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s',srcDir);
end

addpath(genpath(srcDir));

inputFile = fullfile( ...
    repoRoot, ...
    'data','processed','fMRI', ...
    'preprocessing','reappraisal', ...
    'model_selection','DVARS_info.mat' ...
);

outputDir = fullfile( ...
    repoRoot, ...
    'results','supplement', ...
    'Figure_S16','Figure_S16C' ...
);

if ~isfolder(outputDir)
    mkdir(outputDir);
end

%% Required helper

if isempty(which('notBoxPlot'))
    error([ ...
        'Required helper notBoxPlot.m was not found.' newline ...
        'Place it somewhere under src/matlab/.' ...
    ]);
end

%% Load conditioning data

if ~isfile(inputFile)
    error([ ...
        'Conditioning DVARS_info.mat not found:' newline ...
        '%s' ...
    ],inputFile);
end

loadedData = load(inputFile,'DVARS_info');

if ~isfield(loadedData,'DVARS_info')
    error('Variable DVARS_info is missing from:\n%s',inputFile);
end

DVARS_info = loadedData.DVARS_info;

%% Preprocessing pipelines

pipelineNames = {
    'Nothing'
    'AFNI'
    'WD10_AFNI'
};

plotLabels = {
    'Nothing'
    'AFNI'
    'WD10-AFNI'
};

%% Compute subject-wise DVARS-FD correlations

results = struct;

for iPipeline = 1:numel(pipelineNames)

    pipelineName = pipelineNames{iPipeline};

    results.(pipelineName) = ...
        computeSubjectwiseCorrelations( ...
            DVARS_info, ...
            pipelineName ...
        );
end

%% Check subject counts

nSubjects = cellfun( ...
    @(x) numel(results.(x)), ...
    pipelineNames ...
);

if numel(unique(nSubjects)) ~= 1
    error([ ...
        'The three preprocessing pipelines contain different numbers ' ...
        'of subjects: %s'], ...
        mat2str(nSubjects) ...
    );
end

nAnimals = nSubjects(1);

fprintf('\nSupplementary Figure S16C\n');
fprintf('Conditioning cohort only.\n');
fprintf('Input:\n%s\n\n',inputFile);
fprintf('Animals: %d\n',nAnimals);

%% Build plotting matrix

plotData = nan(nAnimals,numel(pipelineNames));

for iPipeline = 1:numel(pipelineNames)

    plotData(:,iPipeline) = ...
        results.(pipelineNames{iPipeline})(:);
end

%% Source data: wide format

sourceData = table( ...
    (1:nAnimals)', ...
    plotData(:,1), ...
    plotData(:,2), ...
    plotData(:,3), ...
    'VariableNames', {
        'SubjectIndex'
        'Nothing'
        'AFNI'
        'WD10_AFNI'
    } ...
);

writetable( ...
    sourceData, ...
    fullfile( ...
        outputDir, ...
        'SourceData_Figure_S16C_DVARS_FD_Correlations.csv' ...
    ) ...
);

%% Summary statistics

metricMean = mean(plotData,1,'omitnan')';
metricSD = std(plotData,0,1,'omitnan')';
nNonNaN = sum(~isnan(plotData),1)';
metricSEM = metricSD ./ sqrt(nNonNaN);

summaryTable = table( ...
    string(pipelineNames), ...
    metricMean, ...
    metricSD, ...
    metricSEM, ...
    min(plotData,[],1,'omitnan')', ...
    max(plotData,[],1,'omitnan')', ...
    repmat(nAnimals,numel(pipelineNames),1), ...
    nNonNaN, ...
    'VariableNames', {
        'Pipeline'
        'MeanCorrelation'
        'SD'
        'SEM'
        'Minimum'
        'Maximum'
        'NTotal'
        'NNonNaN'
    } ...
);

writetable( ...
    summaryTable, ...
    fullfile( ...
        outputDir, ...
        'Statistics_Figure_S16C_DVARS_FD_Correlations.csv' ...
    ) ...
);

%% Figure S16C

fig = figure( ...
    'Name','Supplementary Figure S16C: DVARS-FD correlations', ...
    'Visible','on', ...
    'Color','white', ...
    'Position',[100,100,700,650] ...
);

Bx = notBoxPlot(plotData);

gray = [0.2,0.2,0.2];
formatNotBoxPlot(Bx,gray);

ax = gca;
box(ax,'off');

ax.YLim = [0,1];
ax.YTick = 0:0.2:1;

ax.XTick = 1:numel(plotLabels);
ax.XTickLabel = plotLabels;

ax.FontSize = 14;
ax.LineWidth = 1;

ylabel(ax,'Pearson r (DVARS vs FD_{SNiP})');

%% Analysis metadata

metadata = table( ...
    string('Figure S16C'), ...
    nAnimals, ...
    string(strjoin(pipelineNames, ',')), ...
    string('Pearson'), ...
    string('subject-wise correlation across time points'), ...
    string('FD_SNiP(:,2:end) aligned to DVARS'), ...
    string(makeRepoRelative(inputFile,repoRoot)), ...
    'VariableNames', { ...
        'Panel'
        'NumberOfAnimals'
        'Pipelines'
        'CorrelationType'
        'AnalysisUnit'
        'FDAlignment'
        'InputFile'
    } ...
);

writetable( ...
    metadata, ...
    fullfile( ...
        outputDir, ...
        'AnalysisMetadata_Figure_S16C_DVARS_FD_Correlations.csv' ...
    ) ...
);

%% Save MATLAB result

result = struct;
result.pipelineNames = pipelineNames;
result.plotLabels = plotLabels;
result.correlations = results;
result.plotData = plotData;
result.sourceData = sourceData;
result.summaryTable = summaryTable;
result.inputFile = makeRepoRelative(inputFile,repoRoot);
result.metadata = metadata;

save( ...
    fullfile( ...
        outputDir, ...
        'Results_Figure_S16C_DVARS_FD_Correlations.mat' ...
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

%% Export figure

exportgraphics( ...
    fig, ...
    fullfile( ...
        outputDir, ...
        'Figure_S16C_DVARS_FD_Correlations.pdf' ...
    ), ...
    'ContentType','vector', ...
    'BackgroundColor','white' ...
);

exportgraphics( ...
    fig, ...
    fullfile( ...
        outputDir, ...
        'Figure_S16C_DVARS_FD_Correlations.png' ...
    ), ...
    'Resolution',300, ...
    'BackgroundColor','white' ...
);

savefig( ...
    fig, ...
    fullfile( ...
        outputDir, ...
        'Figure_S16C_DVARS_FD_Correlations.fig' ...
    ) ...
);

fprintf('\nSummary statistics:\n');
disp(summaryTable);

fprintf('Supplementary Figure S16C completed.\n');
fprintf('Results saved to:\n%s\n',outputDir);


%% ========================================================================
% Local functions
%% ========================================================================

function subjectCorrelations = computeSubjectwiseCorrelations( ...
    dvarsInfoStruct, ...
    pipelineField ...
)

    if ~isfield(dvarsInfoStruct,pipelineField)
        error( ...
            'Missing pipeline field "%s" in DVARS_info.', ...
            pipelineField ...
        );
    end

    pipelineData = dvarsInfoStruct.(pipelineField);

    if ~isfield(pipelineData,'DVARS')
        error( ...
            'Missing DVARS in pipeline "%s".', ...
            pipelineField ...
        );
    end

    if ~isfield(pipelineData,'FD_SNiP')
        error( ...
            'Missing FD_SNiP in pipeline "%s".', ...
            pipelineField ...
        );
    end

    dvarsMatrix = pipelineData.DVARS;
    fdMatrix = pipelineData.FD_SNiP(:,2:end);

    if size(dvarsMatrix,1) ~= size(fdMatrix,1)
        error( ...
            'Subject-count mismatch for pipeline "%s".', ...
            pipelineField ...
        );
    end

    if size(dvarsMatrix,2) ~= size(fdMatrix,2)
        error([ ...
            'Timepoint mismatch for pipeline "%s". ' ...
            'DVARS and FD_SNiP(:,2:end) must have the same ' ...
            'number of columns.'], ...
            pipelineField ...
        );
    end

    % Retains the exact calculation used in the original script:
    % correlation matrix across all subjects, followed by the diagonal.
    correlationMatrix = corr( ...
        dvarsMatrix', ...
        fdMatrix', ...
        'Type','Pearson', ...
        'Rows','pairwise' ...
    );

    subjectCorrelations = diag(correlationMatrix);
end


function formatNotBoxPlot(Bx,gray)

    for nBx = 1:numel(Bx)

        % Slightly larger individual-animal dots.
        Bx(nBx).data.MarkerSize = 10;
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
