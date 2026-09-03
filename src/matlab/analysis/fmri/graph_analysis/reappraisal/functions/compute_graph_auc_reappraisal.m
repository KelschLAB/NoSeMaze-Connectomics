function aucFile = compute_graph_auc_reappraisal(gstrucFile,cfg,suffix)

assert(exist('rb_gstruc_2_auc','file')==2, ...
    ['rb_gstruc_2_auc.m is missing. Place it under ' ...
     'graph_analysis/common/functions/.']);

loaded = load(gstrucFile,'gstruc','subjectIDs');
assert(isfield(loaded,'gstruc'),'Variable "gstruc" missing in:\n%s',gstrucFile);

auc_struc = rb_gstruc_2_auc( ...
    loaded.gstruc, ...
    cfg.aucMinIndex, ...
    cfg.aucMaxIndex);

if ~isfolder(cfg.aucDir)
    mkdir(cfg.aucDir);
end

thresholdLabel = sprintf('%dto%d', ...
    round(cfg.cutoffs(cfg.aucMinIndex)*100), ...
    round(cfg.cutoffs(cfg.aucMaxIndex)*100));

aucFile = fullfile(cfg.aucDir, ...
    sprintf('auc_struc_%s_%s_p.mat',suffix,thresholdLabel));

if isfield(loaded,'subjectIDs')
    subjectIDs = loaded.subjectIDs; %#ok<NASGU>
else
    subjectIDs = strings(0,1); %#ok<NASGU>
end

cutoffs = cfg.cutoffs; %#ok<NASGU>
aucMinIndex = cfg.aucMinIndex; %#ok<NASGU>
aucMaxIndex = cfg.aucMaxIndex; %#ok<NASGU>

save(aucFile,'auc_struc','subjectIDs','cutoffs', ...
    'aucMinIndex','aucMaxIndex','-v7.3');
end
