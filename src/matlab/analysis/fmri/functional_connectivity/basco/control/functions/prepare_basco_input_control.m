function prepare_basco_input_control(manifest,cfg)

if ~isfolder(cfg.inputDir); mkdir(cfg.inputDir); end

for i = 1:height(manifest)

    subjectID = char(manifest.Subject_ID(i));
    epiFile = char(manifest.EPI_File(i));
    nuisanceFile = char(manifest.Nuisance_File(i));
    regressorFile = char(manifest.Regressor_File(i));

    assert(isfile(epiFile),'Missing FC EPI for %s.',subjectID);
    assert(isfile(nuisanceFile),'Missing nuisance file for %s.',subjectID);
    assert(isfile(regressorFile),'Missing v16 regressors for %s.',subjectID);

    [~,epiBase,epiExt] = fileparts(epiFile);
    epiName = [epiBase epiExt];

    for k=1:numel(cfg.epi.forbiddenTokens)
        assert(~contains(epiName,cfg.epi.forbiddenTokens{k}), ...
            'Smoothed EPI accidentally selected for FC: %s',epiName);
    end

    runDir = fullfile(cfg.inputDir,subjectID,'run1');
    if ~isfolder(runDir); mkdir(runDir); end

    copyfile(epiFile,fullfile(runDir,epiName));

    S = load(regressorFile,'regressors');

    onsetFile = fullfile(runDir,'onsets_v6.txt');
    fid = fopen(onsetFile,'wt');
    cleanup = onCleanup(@() fclose(fid));

    for j=1:numel(S.regressors)
        fprintf(fid,'%g\t',S.regressors(j).onset);
        fprintf(fid,'\n');
    end
    clear cleanup;

    nuisance = readmatrix(nuisanceFile);
    assert(size(nuisance,2)==cfg.nuisance.expectedColumns, ...
        'Expected 14 nuisance columns for %s.',subjectID);

    copyfile(nuisanceFile, ...
        fullfile(runDir,cfg.nuisance.bascoFilename));
end

metainfo = struct();
metainfo.EPI = cfg.epi.prefix;
metainfo.onsets = 'regressors_v16.mat';
metainfo.onset_dir = cfg.regressorsDir;
metainfo.covariates = cfg.nuisance.bascoFilename;
metainfo.HRF = cfg.hrf.name;
metainfo.unsmoothed_FC_input = true;
metainfo.expected_ROI_count = cfg.atlas.expectedROIcount;
metainfo.atlas = cfg.atlas.name;
metainfo.leftRightCombination = true;

save(cfg.files.metainfo,'metainfo');
end
