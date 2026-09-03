% anadef_control.m
% BASCO v6 analysis definition for the control cohort.

scriptFile = mfilename('fullpath');
repoRoot = find_repo_root_fc(scriptFile);
cfg = fc_basco_control_config(repoRoot);

load(cfg.files.metainfo,'metainfo');

AnaDef.Img = 'nii';
AnaDef.Img4D = true;
AnaDef.units = 'secs';
AnaDef.RT = cfg.model.TR;
AnaDef.fmri_t = cfg.model.fmri_t;
AnaDef.fmri_t0 = cfg.model.fmri_t0;
AnaDef.OutDir = 'betaseries_v6';
AnaDef.Prefix = metainfo.EPI;
AnaDef.OnsetModifier = 0;

AnaDef.VoxelAnalysis = true;
AnaDef.ROIAnalysis = false;
AnaDef.ROIDir = '';
AnaDef.ROIPrefix = '';
AnaDef.ROINames = '';
AnaDef.ROISummaryFunction = 'mean';

AnaDef.SpecMask = cfg.model.specMask;
AnaDef.HRFDERIVS = cfg.model.HRFDERIVS;

AnaDef.MotionReg = true;
AnaDef.CSFReg = true;
AnaDef.DerivReg = true;
AnaDef.GlobalMeanReg = false;

if ~isfolder(cfg.toolboxOutputDir); mkdir(cfg.toolboxOutputDir); end
AnaDef.Outfile = cfg.basco.anaobjFile;

subjectDirs = dir(fullfile(cfg.inputDir,'ZI_M*'));
subjectDirs = subjectDirs([subjectDirs.isdir]);
[~,ord] = sort({subjectDirs.name});
subjectDirs = subjectDirs(ord);

firstReg = fullfile(cfg.regressorsDir, ...
    sprintf('%s_v16.mat',subjectDirs(1).name));
S = load(firstReg,'regressors');

AnaDef.NumCond = numel(S.regressors);
AnaDef.Cond = {S.regressors.name};
duration = [S.regressors.duration];

assert(isequal(AnaDef.Cond,{'Lavender','TP_noPuff'}), ...
    'Unexpected v16 BASCO condition order.');

for i=1:numel(subjectDirs)
    AnaDef.Subj{i}.DataPath = fullfile(cfg.inputDir,subjectDirs(i).name);
    AnaDef.Subj{i}.NumRuns = 1;
    AnaDef.Subj{i}.RunDirs = {'run1'};
    AnaDef.Subj{i}.Onsets = {'onsets_v6.txt'};
    AnaDef.Subj{i}.Duration = duration;
    AnaDef.Subj{i}.Covariates = cfg.nuisance.bascoFilename;
end

AnaDef.NumSubjects = numel(subjectDirs);
