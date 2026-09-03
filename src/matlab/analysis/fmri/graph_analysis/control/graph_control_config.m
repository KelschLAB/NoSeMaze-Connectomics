function cfg = graph_control_config(repoRoot)
% GRAPH_CONTROL_CONFIG Primary control graph-analysis configuration.
%
% Primary manuscript settings:
%   cormat version      v6
%   FC variant          normal non-DVARS branch
%   hemisphere mode     combined
%   network             52 merged anatomical ROIs
%   graph metrics       manuscript metrics only

cfg = struct();

cfg.cohort = 'reappraisal_control_2023';
cfg.cormatVersion = 'v6';

external = getenv('NOSEMAZE_CONTROL_GRAPH_CORMAT_ROOT');
if ~isempty(external)
    cfg.cormatDir = external;
else
    cfg.cormatDir = fullfile( ...
        repoRoot,'data','processed','fMRI', ...
        'functional_connectivity','control','basco','v6', ...
        'correlation_matrices');
end

% Only control matrices used in manuscript graph comparisons.
cfg.matrixSuffixes = {
    'TPnoPuff11to40'
    'TPnoPuff81to120'
};

cfg.edgeMode = 'positive';
cfg.removeDiagonal = true;
cfg.normalizationMethod = 'max';

cfg.cutoffs = 0.10:0.01:0.50;
cfg.aucMinIndex = 36; % 0.45
cfg.aucMaxIndex = 41; % 0.50
cfg.calcat = {'manuscript'};

cfg.expectedROIcount = 52;

cfg.graphDataRoot = fullfile( ...
    repoRoot,'data','processed','fMRI','graph_analysis', ...
    'control',cfg.cormatVersion,'max_connected');

cfg.preparedCormatDir = fullfile(cfg.graphDataRoot,'positive_cormats');
cfg.gstrucDir = fullfile(cfg.graphDataRoot,'gstruc');
cfg.aucDir = fullfile(cfg.graphDataRoot,'auc');
cfg.manifestDir = fullfile(cfg.graphDataRoot,'manifests');

cfg.bctDir = fullfile( ...
    repoRoot,'src','matlab','preprocessing','toolboxes', ...
    '2019_03_03_BCT');

end
