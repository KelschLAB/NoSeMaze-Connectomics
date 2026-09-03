%% main_secondlevel_graph_covariates_reappraisal.m
%
% Second-level voxelwise regression using graph-derived Delta L adaptation.
%
% Primary manuscript definition:
%   PRE  = TPnoPuff trials 11-40
%   TEST = TPnoPuff trials 81-120
%   graph density summary = 45-50%
%   DeltaL_change = g_delta_L(TEST) - g_delta_L(PRE)
%
% The graph metric is generated upstream by:
%   analysis/fmri/graph_analysis/reappraisal/main_graph_analysis_reappraisal.m
%
% Large graph/GLM inputs are not required to be public. If the AUC files
% are stored externally, set NOSEMAZE_REAPPRAISAL_GRAPH_AUC_ROOT.

clearvars;
close all;
clc;

scriptFile = mfilename('fullpath');
scriptDir = fileparts(scriptFile);
glmRoot = fileparts(scriptDir);

addpath(fullfile(glmRoot,'common','functions'));
addpath(fullfile(scriptDir,'functions'));

repoRoot = find_repo_root_analysis(scriptFile);
cfg = glm_reappraisal_config(repoRoot);

if isempty(which('spm'))
    error('SPM12 is not available on the MATLAB path.');
end

if isempty(which('do_secondlevel_GLM_to_NoSeMaze_jr'))
    error('do_secondlevel_GLM_to_NoSeMaze_jr.m is not available.');
end

if ~isfile(cfg.explicitMask)
    error('Explicit analysis mask not found:\n%s',cfg.explicitMask);
end

contrastInfoFile = fullfile(cfg.firstLevelDir,'contrast_info.mat');
if ~isfile(contrastInfoFile)
    error('contrast_info.mat not found:\n%s',contrastInfoFile);
end

loadedContrast = load(contrastInfoFile,'contrast_info');
contrast_info = loadedContrast.contrast_info;

preFile = fullfile( ...
    cfg.graphAucDir, ...
    'auc_struc_TPnoPuff11to40_45to50_p.mat' ...
);

testFile = fullfile( ...
    cfg.graphAucDir, ...
    'auc_struc_TPnoPuff81to120_45to50_p.mat' ...
);

requiredFiles = {preFile;testFile};
missingFiles = requiredFiles(~cellfun(@isfile,requiredFiles));
if ~isempty(missingFiles)
    error([ ...
        'Required graph AUC files are missing:\n\n%s\n\n' ...
        'Run the graph-analysis pipeline or set ' ...
        'NOSEMAZE_REAPPRAISAL_GRAPH_AUC_ROOT.' ...
    ],strjoin(missingFiles,newline));
end

pre = load(preFile,'auc_struc','subjectIDs');
test = load(testFile,'auc_struc','subjectIDs');

if ~isfield(pre,'auc_struc') || ~isfield(test,'auc_struc')
    error('Variable auc_struc is missing from one or both graph AUC files.');
end

if ~isfield(pre.auc_struc,'g_delta_L') || ~isfield(test.auc_struc,'g_delta_L')
    error('g_delta_L is missing from one or both graph AUC structures.');
end

preValues = [pre.auc_struc.g_delta_L]';
testValues = [test.auc_struc.g_delta_L]';

if numel(preValues) ~= numel(testValues)
    error('PRE/TEST g_delta_L vectors have different sample sizes.');
end

subjectIDs = resolveSubjectIDs(pre,test,numel(preValues));
animalNumbers = parseAnimalNumbers(subjectIDs);

deltaLChange = testValues - preValues;

if any(~isfinite(deltaLChange))
    error('DeltaL_change contains NaN/Inf values.');
end

ExplVar = struct();
ExplVar.name = 'DeltaL_change';
ExplVar.values = deltaLChange(:);
ExplVar.ID = cellstr(subjectIDs(:));
ExplVar.AnimalNumb = animalNumbers(:);

[sortedValues,sortedIndex] = sort(ExplVar.values,'descend');
ExplVar.DS_sorted = sortedValues;
ExplVar.DS_sortedIndex = sortedIndex;

outputDir = fullfile(cfg.graphCovariatesDir,ExplVar.name);
if ~isfolder(outputDir)
    mkdir(outputDir);
end

sourceData = table( ...
    subjectIDs(:), ...
    animalNumbers(:), ...
    preValues(:), ...
    testValues(:), ...
    deltaLChange(:), ...
    'VariableNames', { ...
        'SubjectID', ...
        'AnimalNumber', ...
        'DeltaL_PRE', ...
        'DeltaL_TEST', ...
        'DeltaL_change' ...
    } ...
);

writetable(sourceData,fullfile(outputDir,'DeltaL_secondlevel_source_data.csv'));

do_secondlevel_GLM_to_NoSeMaze_jr( ...
    outputDir, ...
    contrast_info, ...
    cfg.firstLevelDir, ...
    cfg.explicitMask, ...
    ExplVar ...
);

fprintf('\nGraph-derived Delta L second-level GLMs completed.\n');
fprintf('Output: %s\n',outputDir);


function subjectIDs = resolveSubjectIDs(pre,test,nSubjects)

hasPre = isfield(pre,'subjectIDs') && numel(pre.subjectIDs)==nSubjects;
hasTest = isfield(test,'subjectIDs') && numel(test.subjectIDs)==nSubjects;

if ~hasPre || ~hasTest
    error([ ...
        'Graph AUC files must contain subjectIDs for safe alignment with ' ...
        'the voxelwise first-level data.' ...
    ]);
end

preIDs = string(pre.subjectIDs(:));
testIDs = string(test.subjectIDs(:));

if ~isequal(preIDs,testIDs)
    error('PRE and TEST graph AUC subjectIDs differ in identity or order.');
end

subjectIDs = preIDs;
end


function animalNumbers = parseAnimalNumbers(subjectIDs)

animalNumbers = nan(numel(subjectIDs),1);

for i = 1:numel(subjectIDs)
    token = regexp(char(subjectIDs(i)),'ZI_M(\d+)','tokens','once');
    if isempty(token)
        error('Could not parse MRI animal number from subject ID: %s',subjectIDs(i));
    end
    animalNumbers(i) = str2double(token{1});
end

if numel(unique(animalNumbers)) ~= numel(animalNumbers)
    error('Graph AUC subject IDs do not map to unique MRI animal numbers.');
end
end
