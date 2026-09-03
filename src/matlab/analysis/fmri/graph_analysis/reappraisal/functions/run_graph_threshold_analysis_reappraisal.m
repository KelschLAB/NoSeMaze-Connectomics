function gstrucFile = run_graph_threshold_analysis_reappraisal(prepared,cfg,suffix)

assert(exist('rb_graph_thresh_flex','file')==2, ...
    ['rb_graph_thresh_flex.m is missing. Place it under ' ...
     'graph_analysis/common/functions/.']);

% Preserve the historical cell-array orientation.
cormatForGraph = prepared.cormat';

gstruc = rb_graph_thresh_flex( ...
    cormatForGraph, ...
    cfg.cutoffs, ...
    cfg.normalizationMethod, ...
    cfg.calcat);

if ~isfolder(cfg.gstrucDir)
    mkdir(cfg.gstrucDir);
end

gstrucFile = fullfile(cfg.gstrucDir,sprintf('gstruc_%s_p.mat',suffix));

subjectIDs = prepared.subjectIDs; %#ok<NASGU>
cutoffs = cfg.cutoffs; %#ok<NASGU>
normalizationMethod = cfg.normalizationMethod; %#ok<NASGU>
calcat = cfg.calcat; %#ok<NASGU>

save(gstrucFile,'gstruc','subjectIDs','cutoffs', ...
    'normalizationMethod','calcat','-v7.3');
end
