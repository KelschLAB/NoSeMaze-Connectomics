% panel_B_Odor_NBS_control_vs_conditioning.m
% Jonathan Reinwald
%
% Supplementary Figure S5B:
% distal-CR (Odor) Network-Based Statistics comparison of PRE-to-TEST
% connectivity changes between control and conditioning cohorts.
%
% PRE  = Odor trials 11-40
% TEST = Odor trials 81-120
%
% Steps:
%   1. Compute TEST - PRE within each mouse.
%   2. Compare change matrices between cohorts.
%   3. Run the original NBS procedure.
%   4. Display the edge-wise T matrix and any NBS-significant component.
%
% Helpers/support files:
%   src/matlab/helpers/NBS1.2/input_files/UI.mat
%   src/matlab/helpers/NBS1.2/input_files/COG.txt
%   src/matlab/helpers/colormaps/myColormap_darkredgreen.mat
%
% Original contrasts:
%   [1 -1]  control > conditioning
%   [-1 1]  conditioning > control
%   [1 1]
%
% The displayed NBS component preferentially uses CON_MAT2, matching the
% original workflow.

clear;
close all;
clc;

%% Repository root

scriptFile = mfilename('fullpath');

if isempty(scriptFile)
    error(['MATLAB could not determine the script location. ' ...
        'Run the complete saved script rather than selected lines.']);
end

scriptDir = fileparts(scriptFile);
repoRoot = fileparts(fileparts(fileparts(scriptDir)));

%% Paths

srcDir = fullfile(repoRoot,'src','matlab');

inputDirControl = fullfile( ...
    repoRoot,'data','processed','fMRI','Figure_3','control' ...
);

inputDirConditioning = fullfile( ...
    repoRoot,'data','processed','fMRI','Figure_3','conditioning' ...
);

outputDir = fullfile( ...
    repoRoot,'results','supplement','Figure_S5','Figure_S5B' ...
);

nbsInputDir = fullfile( ...
    srcDir,'helpers','NBS1.2','input_files' ...
);

colormapFile = fullfile( ...
    srcDir,'helpers','colormaps','myColormap_darkredgreen.mat' ...
);

%% Settings

analysisName = 'Odor';

controlSuffix = 'v6';
conditioningSuffix = 'v11';

preRange = '11to40';
testRange = '81to120';

inputType = {'Extent'};
thresholdProbability = 0.975;

fdrThreshold = 0.05;
tColorLimits = [-5,5];

sorting = [ ...
    4:8,42:43,24:27,1:3,28,12:16,19,18,17,20,21,9:11, ...
    32:33,29:31,34:35,38:41,45:52,22:23,36,37,44 ...
];

%% Dependencies

if ~isfolder(srcDir)
    error('MATLAB source directory not found:\n%s',srcDir);
end

addpath(genpath(srcDir));

requiredFunctions = {'acl_NBS_intercept','lei_ttest2','schemaball'};
missingFunctions = requiredFunctions( ...
    cellfun(@(x) isempty(which(x)),requiredFunctions) ...
);

if ~isempty(missingFunctions)
    error('Required MATLAB functions not found:\n%s', ...
        strjoin(missingFunctions,newline));
end

if isempty(ver('stats'))
    error('Statistics and Machine Learning Toolbox is required for tinv and finv.');
end

if ~isfolder(inputDirControl)
    error('Control input directory not found:\n%s',inputDirControl);
end

if ~isfolder(inputDirConditioning)
    error('Conditioning input directory not found:\n%s',inputDirConditioning);
end

if ~isfolder(outputDir)
    mkdir(outputDir);
end

uiTemplateFile = fullfile(nbsInputDir,'UI.mat');
cogFile = fullfile(nbsInputDir,'COG.txt');

requiredSupportFiles = {uiTemplateFile,cogFile,colormapFile};
missingSupportFiles = requiredSupportFiles( ...
    ~cellfun(@isfile,requiredSupportFiles) ...
);

if ~isempty(missingSupportFiles)
    error('Required NBS/support files are missing:\n%s', ...
        strjoin(missingSupportFiles,newline));
end

tmp = load(colormapFile);

if ~isfield(tmp,'myColormap')
    error('Variable "myColormap" missing from:\n%s',colormapFile);
end

myColormap = tmp.myColormap;

%% ROI labels: use control v6 file preferentially

roiDataFiles = dir(fullfile(inputDirControl,'roidata*.mat'));

if isempty(roiDataFiles)
    error('No roidata*.mat file found in:\n%s',inputDirControl);
end

[~,order] = sort({roiDataFiles.name});
roiDataFiles = roiDataFiles(order);

preferred = find(contains({roiDataFiles.name},controlSuffix),1,'first');

if isempty(preferred)
    preferred = 1;
end

if numel(roiDataFiles) > 1
    warning('Multiple control roidata files found. Using:\n%s', ...
        roiDataFiles(preferred).name);
end

roiDataFile = fullfile( ...
    roiDataFiles(preferred).folder, ...
    roiDataFiles(preferred).name ...
);

roiData = load(roiDataFile);

if ~isfield(roiData,'subj') || ...
        ~isfield(roiData.subj(1),'roi') || ...
        ~isfield(roiData.subj(1).roi,'name')
    error('Could not read ROI names from:\n%s',roiDataFile);
end

roiNamesUnsorted = {roiData.subj(1).roi.name};

if max(sorting) > numel(roiNamesUnsorted)
    error('Sorting requires at least %d ROIs; only %d found.', ...
        max(sorting),numel(roiNamesUnsorted));
end

roiNames = roiNamesUnsorted(sorting);
numberOfROIs = numel(roiNames);

%% Input files

controlPreFileName = sprintf('cormat_%s_%s%s.mat', ...
    controlSuffix,analysisName,preRange);

controlTestFileName = sprintf('cormat_%s_%s%s.mat', ...
    controlSuffix,analysisName,testRange);

conditioningPreFileName = sprintf('cormat_%s_%s%s.mat', ...
    conditioningSuffix,analysisName,preRange);

conditioningTestFileName = sprintf('cormat_%s_%s%s.mat', ...
    conditioningSuffix,analysisName,testRange);

controlPreFile = fullfile(inputDirControl,controlPreFileName);
controlTestFile = fullfile(inputDirControl,controlTestFileName);
conditioningPreFile = fullfile(inputDirConditioning,conditioningPreFileName);
conditioningTestFile = fullfile(inputDirConditioning,conditioningTestFileName);

requiredFiles = { ...
    controlPreFile,controlTestFile, ...
    conditioningPreFile,conditioningTestFile ...
};

missingFiles = requiredFiles(~cellfun(@isfile,requiredFiles));

if ~isempty(missingFiles)
    error('Required cormat files are missing:\n%s', ...
        strjoin(missingFiles,newline));
end

controlPreData = load(controlPreFile);
controlTestData = load(controlTestFile);
conditioningPreData = load(conditioningPreFile);
conditioningTestData = load(conditioningTestFile);

loaded = {controlPreData,controlTestData,conditioningPreData,conditioningTestData};
loadedNames = {controlPreFile,controlTestFile,conditioningPreFile,conditioningTestFile};

for k = 1:numel(loaded)
    if ~isfield(loaded{k},'cormat')
        error('Variable "cormat" missing from:\n%s',loadedNames{k});
    end
end

cormatPreControl = controlPreData.cormat;
cormatTestControl = controlTestData.cormat;
cormatPreConditioning = conditioningPreData.cormat;
cormatTestConditioning = conditioningTestData.cormat;

nControl = numel(cormatPreControl);
nConditioning = numel(cormatPreConditioning);

if nControl ~= numel(cormatTestControl)
    error('Control PRE and TEST subject counts differ.');
end

if nConditioning ~= numel(cormatTestConditioning)
    error('Conditioning PRE and TEST subject counts differ.');
end

if nControl == 0 || nConditioning == 0
    error('One or both cohorts contain no subjects.');
end

%% TEST - PRE change matrices

cormatDiffControl = cell(1,nControl);
cormatDiffConditioning = cell(1,nConditioning);

for subjectIndex = 1:nControl

    preMatrix = cormatPreControl{subjectIndex};
    testMatrix = cormatTestControl{subjectIndex};

    validateCormatMatrix(preMatrix,sorting,'control PRE',subjectIndex);
    validateCormatMatrix(testMatrix,sorting,'control TEST',subjectIndex);

    differenceMatrix = testMatrix - preMatrix;
    cormatDiffControl{subjectIndex} = differenceMatrix(sorting,sorting);
end

for subjectIndex = 1:nConditioning

    preMatrix = cormatPreConditioning{subjectIndex};
    testMatrix = cormatTestConditioning{subjectIndex};

    validateCormatMatrix(preMatrix,sorting,'conditioning PRE',subjectIndex);
    validateCormatMatrix(testMatrix,sorting,'conditioning TEST',subjectIndex);

    differenceMatrix = testMatrix - preMatrix;
    cormatDiffConditioning{subjectIndex} = differenceMatrix(sorting,sorting);
end

%% NBS matrices and design

Mat = cat(3,cormatDiffControl{:},cormatDiffConditioning{:});

matFile = fullfile( ...
    outputDir,'Figure_S5B_Odor_NBS_InputMatrices_TESTminusPRE.mat' ...
);

save(matFile,'Mat');

GLM_design = [ ...
    ones(nControl,1),zeros(nControl,1); ...
    zeros(nConditioning,1),ones(nConditioning,1) ...
];

designFile = fullfile(outputDir,'Figure_S5B_Odor_NBS_Design.txt');
writematrix(GLM_design,designFile,'Delimiter','tab');

degreesOfFreedom = size(GLM_design,1) - size(GLM_design,2);

thr_t = tinv(thresholdProbability,degreesOfFreedom);
thr_F = finv(thresholdProbability,1,degreesOfFreedom);

%% Edge-wise between-cohort statistics

% Orientation: control minus conditioning.
[T,p,p2,fdrMatrix,meanValue,standardDeviation] = ...
    lei_ttest2(cormatDiffControl,cormatDiffConditioning,fdrThreshold);

%% Run NBS

uiData = load(uiTemplateFile);

if ~isfield(uiData,'UI')
    error('UI.mat does not contain variable "UI".');
end

UI = uiData.UI;
UI.matrices.ui = matFile;
UI.design.ui = designFile;
UI.node_label.ui = '';
UI.exchange.ui = '';

COG = load(cogFile); %#ok<NASGU>

contrasts = {'[1 -1]','[-1 1]','[1 1]'};
tstat = T;

resNBS = acl_NBS_intercept( ...
    UI,tstat,thr_t,thr_F,inputType,contrasts ...
);

[NBSmat,nbsContrastUsed] = extractNBSMatrix(resNBS,numberOfROIs);

%% T-statistic matrix

lowerMask = tril(true(size(T)),-1);
displayData = nan(size(T));
displayData(lowerMask) = T(lowerMask);

figureTitle = sprintf( ...
    'Figure S5B: %s TEST-PRE, control vs conditioning',analysisName ...
);

figMatrix = figure( ...
    'Name',figureTitle, ...
    'Visible','on', ...
    'Color','white', ...
    'Position',[100,100,900,780] ...
);

imagesc(displayData,'AlphaData',~isnan(displayData));

ax = gca;
axis(ax,'image');
box(ax,'off');
ax.CLim = tColorLimits;
ax.TickLabelInterpreter = 'none';
ax.XTick = 1:numberOfROIs;
ax.XTickLabel = roiNames;
ax.YTick = 1:numberOfROIs;
ax.YTickLabel = roiNames;
ax.FontSize = 6;

colormap(ax,myColormap);
xtickangle(ax,90);
title(ax,figureTitle,'Interpreter','none');
colorbar;
hold(ax,'on');

if any(NBSmat(:))
    for rowIndex = 2:numberOfROIs
        for columnIndex = 1:(rowIndex-1)
            if NBSmat(rowIndex,columnIndex)
                rectangle(ax, ...
                    'Position',[columnIndex-0.5,rowIndex-0.5,1,1], ...
                    'EdgeColor',[0.1,0.1,0.1], ...
                    'LineWidth',1);
            end
        end
    end
end

exportgraphics(figMatrix, ...
    fullfile(outputDir, ...
    'Figure_S5B_Odor_NBS_Control_vs_Conditioning_TESTminusPRE.pdf'), ...
    'ContentType','vector','BackgroundColor','white');

exportgraphics(figMatrix, ...
    fullfile(outputDir, ...
    'Figure_S5B_Odor_NBS_Control_vs_Conditioning_TESTminusPRE.png'), ...
    'Resolution',300,'BackgroundColor','white');

%% Source/statistical matrices

writeLabeledMatrix(fullfile(outputDir, ...
    'SourceData_Figure_S5B_Odor_T_ControlMinusConditioning.csv'), ...
    displayData,roiNames);

writeLabeledMatrix(fullfile(outputDir, ...
    'SourceData_Figure_S5B_Odor_T_ConditioningMinusControl.csv'), ...
    -displayData,roiNames);

writeLabeledMatrix(fullfile(outputDir, ...
    'Statistics_Figure_S5B_Odor_T_full.csv'),T,roiNames);

writeLabeledMatrix(fullfile(outputDir, ...
    'Statistics_Figure_S5B_Odor_P.csv'),p,roiNames);

writeLabeledMatrix(fullfile(outputDir, ...
    'Statistics_Figure_S5B_Odor_FDR.csv'),double(fdrMatrix),roiNames);

writeLabeledMatrix(fullfile(outputDir, ...
    'Statistics_Figure_S5B_Odor_NBSMask.csv'),double(NBSmat),roiNames);

%% Schemaball

if any(NBSmat(:))

    % NBSmat is already a symmetric logical mask.
    Cdata = double(NBSmat) .* T;

    cmap = flipud(myColormap(100:end,:));
    finiteValues = Cdata(NBSmat & isfinite(Cdata));

    if isempty(finiteValues)
        RGB = ones(numberOfROIs,numberOfROIs,3).*0.5;
    else
        cmin = min(finiteValues);
        cmax = max(finiteValues);
        nColors = size(cmap,1);

        if cmax == cmin
            index = ones(size(Cdata));
        else
            index = fix((Cdata-cmin)./(cmax-cmin).*(nColors-1))+1;
        end

        index(~isfinite(index)) = 1;
        index = max(1,min(nColors,index));
        RGB = ind2rgb(index,cmap);
    end

    figSchemaball = figure( ...
        'Name',[figureTitle ' schemaball'], ...
        'Visible','on', ...
        'Color','white', ...
        'Position',[100,100,900,780] ...
    );

    schemaball( ...
        roiNames,Cdata,10,tColorLimits, ...
        ones(numberOfROIs,3).*0.5,RGB ...
    );

    title(sprintf('Figure S5B: %s; %s',analysisName,nbsContrastUsed), ...
        'Interpreter','none');

    exportgraphics(figSchemaball, ...
        fullfile(outputDir,'Figure_S5B_Odor_NBS_Schemaball.pdf'), ...
        'ContentType','vector','BackgroundColor','white');

    exportgraphics(figSchemaball, ...
        fullfile(outputDir,'Figure_S5B_Odor_NBS_Schemaball.png'), ...
        'Resolution',300,'BackgroundColor','white');
else
    warning('No NBS component returned for %s. Schemaball skipped.',analysisName);
end

%% Complete results and metadata

save(fullfile(outputDir,'Figure_S5B_Odor_CompleteNBSResults.mat'), ...
    'resNBS','NBSmat','nbsContrastUsed','T','p','p2','fdrMatrix', ...
    'meanValue','standardDeviation','GLM_design','thr_t','thr_F', ...
    'thresholdProbability','inputType','contrasts', ...
    'cormatDiffControl','cormatDiffConditioning','roiNames','sorting', ...
    'nControl','nConditioning','analysisName');

metadata = table( ...
    string('Figure S5B'), ...
    string(analysisName), ...
    nControl,nConditioning,thresholdProbability,thr_t,thr_F, ...
    string(nbsContrastUsed), ...
    string(controlPreFileName),string(controlTestFileName), ...
    string(conditioningPreFileName),string(conditioningTestFileName), ...
    string(roiDataFile),string(uiTemplateFile),string(cogFile), ...
    'VariableNames',{ ...
        'Figure','Analysis','N_Control','N_Conditioning', ...
        'NBS_PrimaryProbability','T_Threshold','F_Threshold', ...
        'NBS_ContrastDisplayed','Control_Pre_File','Control_Test_File', ...
        'Conditioning_Pre_File','Conditioning_Test_File', ...
        'ROIDataFile','NBS_UI_File','NBS_COG_File' ...
    } ...
);

writetable(metadata, ...
    fullfile(outputDir,'AnalysisMetadata_Figure_S5B_Odor.csv'));

if ~isempty(which('docDataSrc'))
    try
        docDataSrc(figMatrix,outputDir,scriptFile,true);
    catch documentationError
        warning('docDataSrc failed: %s',documentationError.message);
    end
end

fprintf('\nCompleted Supplementary Figure S5B.\n');
fprintf('Control n = %d; conditioning n = %d\n',nControl,nConditioning);
fprintf('Outputs saved to:\n%s\n',outputDir);

%% Local functions

function validateCormatMatrix(matrixData,sorting,conditionLabel,subjectIndex)

    if ~ismatrix(matrixData) || size(matrixData,1) ~= size(matrixData,2)
        error('%s matrix for subject %d is not square.', ...
            conditionLabel,subjectIndex);
    end

    if size(matrixData,1) < max(sorting)
        error('%s matrix for subject %d contains too few ROIs.', ...
            conditionLabel,subjectIndex);
    end
end

function [NBSmat,contrastLabel] = extractNBSMatrix(resNBS,numberOfROIs)

    NBSmat = false(numberOfROIs);
    contrastLabel = 'no significant NBS component';

    if isfield(resNBS,'CON_MAT2') && ...
            ~isempty(resNBS.CON_MAT2) && ...
            ~isempty(resNBS.CON_MAT2{1,1})

        component = full(resNBS.CON_MAT2{1,1});
        NBSmat = logical((component + component') ~= 0);
        contrastLabel = '[-1 1] conditioning > control';
        return;
    end

    if isfield(resNBS,'CON_MAT1') && ...
            ~isempty(resNBS.CON_MAT1) && ...
            ~isempty(resNBS.CON_MAT1{1,1})

        component = full(resNBS.CON_MAT1{1,1});
        NBSmat = logical((component + component') ~= 0);
        contrastLabel = '[1 -1] control > conditioning';
    end
end

function writeLabeledMatrix(filePath,matrixData,labels)

    labels = labels(:);
    n = numel(labels);

    if ~isequal(size(matrixData),[n,n])
        error('Matrix dimensions do not match ROI labels.');
    end

    outputCell = cell(n+1,n+1);
    outputCell(1,2:end) = labels';
    outputCell(2:end,1) = labels;
    outputCell(2:end,2:end) = num2cell(matrixData);

    writecell(outputCell,filePath);
end
