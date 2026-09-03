function create_correlation_matrices_basco_control(manifest,cfg)

assert(exist('wwf_covmat_hres_jr','file')==2, ...
    'Shared wwf_covmat_hres_jr.m is not on the MATLAB path.');

assert(isfile(cfg.atlas.labels) && isfile(cfg.atlas.nifti), ...
    'Primary merged 52-ROI atlas files are missing.');

for d={cfg.correlationMatrixDir,cfg.roiDataDir,cfg.manifestDir}
    if ~isfolder(d{1}); mkdir(d{1}); end
end

rows = cell(numel(cfg.primaryMatrixSuffixes),5);

for q=1:numel(cfg.primaryMatrixSuffixes)

    suffix = cfg.primaryMatrixSuffixes{q};
    betaFiles = strings(height(manifest),1);

    for s=1:height(manifest)
        subjectID = char(manifest.Subject_ID(s));
        betaFile = fullfile(cfg.betaSeriesDir, ...
            sprintf('%s_betaseries_v6_%s.nii',subjectID,suffix));
        assert(isfile(betaFile),'Missing beta series: %s',betaFile);
        betaFiles(s) = string(betaFile);
    end

    [cormat,subj] = wwf_covmat_hres_jr( ...
        cfg.atlas.labels,char(betaFiles),cfg.atlas.nifti);

    for s=1:numel(cormat)
        assert(isequal(size(cormat{s}),[52 52]), ...
            'Control %s matrix is not 52x52.',suffix);
    end

    subjectIDs = manifest.Subject_ID; %#ok<NASGU>
    matrixFile = fullfile(cfg.correlationMatrixDir, ...
        sprintf('cormat_v6_%s.mat',suffix));
    roiFile = fullfile(cfg.roiDataDir, ...
        sprintf('roidata_v6_%s.mat',suffix));

    save(matrixFile,'cormat','subjectIDs','-v7.3');
    save(roiFile,'subj','subjectIDs','-v7.3');

    rows(q,:) = {suffix,matrixFile,roiFile,height(manifest),52};
end

matrixManifest = cell2table(rows,'VariableNames', ...
    {'Series','Correlation_Matrix_File','ROI_Data_File', ...
     'N_Subjects','N_ROIs'});
writetable(matrixManifest,fullfile(cfg.manifestDir, ...
    'correlation_matrix_manifest_control.csv'));
end
