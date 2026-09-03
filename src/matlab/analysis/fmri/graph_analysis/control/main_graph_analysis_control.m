%% main_graph_analysis_control.m
% Control manuscript graph metrics.

clearvars;
close all;
clc;

scriptFile = mfilename('fullpath');
controlDir = fileparts(scriptFile);
graphRoot = fileparts(controlDir);

commonDir = fullfile(graphRoot,'common','functions');
addpath(commonDir);
addpath(fullfile(controlDir,'functions'));

repoRoot = find_repo_root_graph(scriptFile);
cfg = graph_control_config(repoRoot);

if isfolder(cfg.bctDir); addpath(genpath(cfg.bctDir)); end

required = {'rb_graph_thresh_flex','rb_graph_individual_flex', ...
    'rb_gstruc_2_auc','diacut','small_world_propensity'};
assert(all(cellfun(@(x) ~isempty(which(x)),required)), ...
    'One or more shared graph functions are missing.');

for d={cfg.preparedCormatDir,cfg.gstrucDir,cfg.aucDir,cfg.manifestDir}
    if ~isfolder(d{1}); mkdir(d{1}); end
end

runStage.preparePositiveNetworks = false;
runStage.computeThresholdMetrics = false;
runStage.computeManuscriptMean = false;

for q=1:numel(cfg.matrixSuffixes)

    suffix = cfg.matrixSuffixes{q};
    cormatFile = resolve_graph_cormat_control(cfg,suffix);

    S = load(cormatFile,'cormat');
    cormat = S.cormat;

    for s=1:numel(cormat)
        M = cormat{s};
        assert(isequal(size(M),[52 52]), ...
            '%s subject %d is not 52x52.',suffix,s);
    end

    preparedFile = fullfile(cfg.preparedCormatDir, ...
        sprintf('cormat_%s_%s_p.mat',cfg.cormatVersion,suffix));

    if runStage.preparePositiveNetworks
        for s=1:numel(cormat)
            M = cormat{s};
            M(1:size(M,1)+1:end)=0;
            M = M .* (M>0);
            cormat{s}=M;
        end
        save(preparedFile,'cormat','-v7.3');
    else
        if isfile(preparedFile)
            P = load(preparedFile,'cormat');
            cormat = P.cormat;
        end
    end

    gstrucFile = fullfile(cfg.gstrucDir, ...
        sprintf('gstruc_%s_p.mat',suffix));

    if runStage.computeThresholdMetrics
        gstruc = rb_graph_thresh_flex( ...
            cormat',cfg.cutoffs,cfg.normalizationMethod,cfg.calcat);
        save(gstrucFile,'gstruc','-v7.3');
    end

    if runStage.computeManuscriptMean
        G = load(gstrucFile,'gstruc');
        auc_struc = rb_gstruc_2_auc( ...
            G.gstruc,cfg.aucMinIndex,cfg.aucMaxIndex);

        aucFile = fullfile(cfg.aucDir, ...
            sprintf('auc_struc_%s_45to50_p.mat',suffix));
        save(aucFile,'auc_struc','-v7.3');
    end
end
