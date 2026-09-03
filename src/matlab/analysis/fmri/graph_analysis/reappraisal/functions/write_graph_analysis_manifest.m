function write_graph_analysis_manifest(rows,cfg)

if ~isfolder(cfg.manifestDir)
    mkdir(cfg.manifestDir);
end

manifest = cell2table(rows,'VariableNames',{ ...
    'Matrix_Suffix','Input_Cormat','Prepared_Positive_Cormat', ...
    'Gstruc_File','AUC_File','N_Subjects','N_ROIs'});

manifest.Cormat_Version = repmat(string(cfg.cormatVersion),height(manifest),1);
manifest.Edge_Mode = repmat(string(cfg.edgeMode),height(manifest),1);
manifest.Normalization = repmat(string(cfg.normalizationMethod),height(manifest),1);
manifest.Threshold_Min = repmat(cfg.cutoffs(1),height(manifest),1);
manifest.Threshold_Max = repmat(cfg.cutoffs(end),height(manifest),1);
manifest.Threshold_Step = repmat(cfg.cutoffs(2)-cfg.cutoffs(1),height(manifest),1);

writetable(manifest,fullfile(cfg.manifestDir, ...
    'graph_analysis_manifest_reappraisal.csv'));
save(fullfile(cfg.manifestDir,'graph_analysis_manifest_reappraisal.mat'), ...
    'manifest');
end
