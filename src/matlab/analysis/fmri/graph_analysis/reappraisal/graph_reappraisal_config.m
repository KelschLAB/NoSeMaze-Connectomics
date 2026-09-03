function cfg = graph_reappraisal_config(repoRoot)
% Primary graph-analysis settings recovered from master_GA_reappraisal_jr.m.

cfg = struct();

cfg.cohort = 'reappraisal';
cfg.cormatVersion = 'v11';

canonicalCormatDir = fullfile(repoRoot,'data','processed','fMRI', ...
    'functional_connectivity','reappraisal','basco','v11', ...
    'correlation_matrices');

externalCormatDir = getenv('NOSEMAZE_REAPPRAISAL_CORMAT_ROOT');

if ~isempty(externalCormatDir)
    cfg.cormatDir = externalCormatDir;
else
    cfg.cormatDir = canonicalCormatDir;
end

cfg.matrixSuffixes = {
    'Odor1to10'
    'Odor11to40'
    'Odor_TPNoPuff'
    'Odor_TPPuff'
    'Odor81to120'
    'TPnoPuff1to10'
    'TPnoPuff11to40'
    'TPnoPuff41to80'
    'TP-Puff'
    'TPnoPuff81to120'
};

cfg.edgeMode = 'positive';
cfg.removeDiagonal = true;

% Historical variable was called binarization_method, but 'max' is passed
% to rb_graph_thresh_flex as its normalization method.
cfg.normalizationMethod = 'max';
cfg.connectednessLabel = 'connected';

cfg.cutoffs = 0.10:0.01:0.50;
cfg.aucMinIndex = 36; % 0.45
cfg.aucMaxIndex = 41; % 0.50

cfg.calcat = {'manuscript'};

cfg.expectedROIcount = 52;
cfg.leftRightCombination = true;

cfg.graphDataRoot = fullfile(repoRoot,'data','processed','fMRI', ...
    'graph_analysis','reappraisal','v11', ...
    [cfg.normalizationMethod '_' cfg.connectednessLabel]);

cfg.preparedCormatDir = fullfile(cfg.graphDataRoot,'positive_cormats');
cfg.gstrucDir = fullfile(cfg.graphDataRoot,'gstruc');
cfg.aucDir = fullfile(cfg.graphDataRoot,'auc');
cfg.manifestDir = fullfile(cfg.graphDataRoot,'manifests');

toolboxRoot = fullfile(repoRoot,'src','matlab','preprocessing','toolboxes');
cfg.bctDir = fullfile(toolboxRoot,'2019_03_03_BCT');

cfg.requiredProjectFunctions = {
    'rb_graph_thresh_flex'
    'rb_gstruc_2_auc'
    'rb_graph_individual_flex'
    'diacut'
    'small_world_propensity'
};
end
