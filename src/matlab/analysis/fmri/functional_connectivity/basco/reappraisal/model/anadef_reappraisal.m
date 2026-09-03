% anadef_reappraisal.m
%
% BASCO analysis-definition script for the primary reappraisal FC analysis.
%
% This is a path-independent reconstruction of the historical analysis
% definition. It intentionally remains a SCRIPT because BASCO expects
% AnaDef to be created in the caller workspace.

scriptFile = mfilename('fullpath');
reappraisalDir = fileparts(fileparts(scriptFile));

cfg = fc_basco_reappraisal_config( ...
    find_repo_root_fc(scriptFile) ...
);

assert(isfile(cfg.files.metainfo), ...
    'BASCO metainfo file not found:\n%s', cfg.files.metainfo);

load(cfg.files.metainfo, 'metainfo');

assert(isfield(metainfo, 'EPI'), ...
    'metainfo.EPI missing.');
assert(isfield(metainfo, 'onsets'), ...
    'metainfo.onsets missing.');
assert(isfield(metainfo, 'covariates'), ...
    'metainfo.covariates missing.');

%% Core BASCO model

AnaDef.Img = 'nii';
AnaDef.Img4D = true;

AnaDef.units = 'secs';
AnaDef.RT = cfg.model.TR;
AnaDef.fmri_t = cfg.model.fmri_t;
AnaDef.fmri_t0 = cfg.model.fmri_t0;

AnaDef.OutDir = ['betaseries_' cfg.version.basco];
AnaDef.Prefix = metainfo.EPI;
AnaDef.OnsetModifier = 0;

%% BASCO estimation mode
%
% Historical model: voxel-level beta estimation.
% ROI aggregation is performed AFTER BASCO using the merged Allen atlas.

AnaDef.VoxelAnalysis = true;
AnaDef.ROIAnalysis = false;

% Retained only because BASCO's AnaDef schema contains these fields.
AnaDef.ROIDir = '';
AnaDef.ROIPrefix = '';
AnaDef.ROINames = '';
AnaDef.ROISummaryFunction = 'mean';

AnaDef.SpecMask = cfg.model.specMask;

AnaDef.HRFDERIVS = cfg.model.HRFDERIVS;

%% Nuisance model

AnaDef.MotionReg = true;
AnaDef.CSFReg = true;
AnaDef.DerivReg = true;
AnaDef.GlobalMeanReg = false;

%% Output

if ~isfolder(cfg.toolboxOutputDir)
    mkdir(cfg.toolboxOutputDir);
end

AnaDef.Outfile = cfg.basco.anaobjFile;

%% Subjects

subjectDirs = dir(fullfile(cfg.inputDir, 'ZI_M*'));
subjectDirs = subjectDirs([subjectDirs.isdir]);

[~, order] = sort({subjectDirs.name});
subjectDirs = subjectDirs(order);

assert(numel(subjectDirs) == numel(cfg.subjectIDs), ...
    'Found %d BASCO subject folders; expected %d.', ...
    numel(subjectDirs), ...
    numel(cfg.subjectIDs) ...
);

%% Regresor names and durations
%
% Use the first subject only to obtain the common v19 model definition.

firstRegressorFile = fullfile( ...
    cfg.regressorsDir, ...
    [subjectDirs(1).name cfg.regressors.suffix] ...
);

assert(isfile(firstRegressorFile), ...
    'v19 regressor file not found:\n%s', firstRegressorFile);

R = load(firstRegressorFile, 'regressors');

assert(isfield(R, 'regressors'), ...
    'Variable "regressors" missing in:\n%s', firstRegressorFile);

AnaDef.NumCond = numel(R.regressors);
AnaDef.Cond = {R.regressors.name};

duration = [R.regressors.duration];

expectedConditions = {'Lavender', 'TP Puff', 'TP NoPuff'};

assert(isequal(AnaDef.Cond, expectedConditions), ...
    ['Unexpected v19 condition order.\nExpected: %s\nFound: %s'], ...
    strjoin(expectedConditions, ', '), ...
    strjoin(AnaDef.Cond, ', ') ...
);

%% Per-subject BASCO entries

for subjectIndex = 1:numel(subjectDirs)

    subjectID = subjectDirs(subjectIndex).name;

    assert(strcmp(subjectID, cfg.subjectIDs{subjectIndex}), ...
        'Unexpected subject order at position %d: %s', ...
        subjectIndex, ...
        subjectID ...
    );

    AnaDef.Subj{subjectIndex}.DataPath = ...
        fullfile(cfg.inputDir, subjectID);

    AnaDef.Subj{subjectIndex}.NumRuns = 1;
    AnaDef.Subj{subjectIndex}.RunDirs = {'run1'};

    AnaDef.Subj{subjectIndex}.Onsets = {
        ['onsets_' cfg.version.basco '.txt']
    };

    AnaDef.Subj{subjectIndex}.Duration = duration;

    AnaDef.Subj{subjectIndex}.Covariates = ...
        cfg.nuisance.bascoFilename;
end

AnaDef.NumSubjects = numel(subjectDirs);

%% Enrich metainfo

metainfo.ROI_name = AnaDef.Cond;
metainfo.duration = duration;
metainfo.numb_onsets = cellfun( ...
    @(x) numel(x), ...
    {R.regressors.onset} ...
);
metainfo.unsmoothed_EPI = true;
metainfo.atlas = cfg.atlas.name;
metainfo.leftRightCombination = cfg.atlas.leftRightCombination;

save(cfg.files.metainfo, 'metainfo');

clear R duration expectedConditions firstRegressorFile ...
    subjectDirs subjectID subjectIndex order reappraisalDir scriptFile
