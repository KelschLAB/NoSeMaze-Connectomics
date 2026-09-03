function prepare_basco_input_reappraisal(manifest, cfg)
% PREPARE_BASCO_INPUT_REAPPRAISAL Prepare per-subject BASCO input folders.

requiredColumns = {
    'Subject_ID'
    'EPI_File'
    'Nuisance_File'
    'Regressor_File'
};

assert(all(ismember(requiredColumns, manifest.Properties.VariableNames)), ...
    'FC manifest does not contain all required columns.');

if ~isfolder(cfg.inputDir)
    mkdir(cfg.inputDir);
end

sessionRows = cell(height(manifest), 5);

for i = 1:height(manifest)

    subjectID = char(manifest.Subject_ID(i));
    epiFile = char(manifest.EPI_File(i));
    nuisanceFile = char(manifest.Nuisance_File(i));
    regressorFile = char(manifest.Regressor_File(i));

    assert(isfile(epiFile), ...
        'Missing unsmoothed EPI for %s:\n%s', subjectID, epiFile);

    assert(isfile(nuisanceFile), ...
        'Missing nuisance file for %s:\n%s', subjectID, nuisanceFile);

    assert(isfile(regressorFile), ...
        ['Missing BASCO %s regressors for %s:\n%s\n' ...
         'These are trial-wise FC regressors and are not the voxelwise v22 model.'], ...
        cfg.version.regressors, ...
        subjectID, ...
        regressorFile ...
    );

    % Guard against accidentally feeding a voxelwise-smoothed branch to FC.
    [~, epiName, epiExt] = fileparts(epiFile);
    epiNameWithExt = [epiName epiExt];

    for tokenIndex = 1:numel(cfg.epi.forbiddenTokens)
        assert( ...
            ~contains(epiNameWithExt, cfg.epi.forbiddenTokens{tokenIndex}), ...
            ['FC input for %s contains smoothing token "%s":\n%s\n' ...
             'FC/graph analyses must use unsmoothed normalized EPI.'], ...
            subjectID, ...
            cfg.epi.forbiddenTokens{tokenIndex}, ...
            epiFile ...
        );
    end

    runDir = fullfile(cfg.inputDir, subjectID, 'run1');

    if ~isfolder(runDir)
        mkdir(runDir);
    end

    %% Functional image

    [~, epiBase, epiExtension] = fileparts(epiFile);
    copiedEpi = fullfile(runDir, [epiBase epiExtension]);

    if ~isfile(copiedEpi)
        copyfile(epiFile, copiedEpi);
    end

    %% Trial-wise onsets

    loaded = load(regressorFile, 'regressors');

    assert(isfield(loaded, 'regressors'), ...
        'Variable "regressors" missing in:\n%s', regressorFile);

    onsetFile = fullfile( ...
        runDir, ...
        sprintf('onsets_%s.txt', cfg.version.basco) ...
    );

    fid = fopen(onsetFile, 'wt');
    assert(fid ~= -1, 'Could not open onset file:\n%s', onsetFile);
    cleanup = onCleanup(@() fclose(fid));

    for regressorIndex = 1:numel(loaded.regressors)
        fprintf(fid, '%g\t', loaded.regressors(regressorIndex).onset);
        fprintf(fid, '\n');
    end

    clear cleanup;

    %% Nuisance regressors
    %
    % The BASCO v11 nuisance file is identical to the primary voxelwise-GLM
    % v1 nuisance source; only the BASCO filename differs.

    nuisanceMatrix = readmatrix(nuisanceFile);

    assert(size(nuisanceMatrix, 2) == cfg.nuisance.expectedColumns, ...
        '%s nuisance file has %d columns; expected %d.', ...
        subjectID, ...
        size(nuisanceMatrix, 2), ...
        cfg.nuisance.expectedColumns ...
    );

    copiedNuisance = fullfile( ...
        runDir, ...
        cfg.nuisance.bascoFilename ...
    );

    copyfile(nuisanceFile, copiedNuisance);

    copiedMatrix = readmatrix(copiedNuisance);

    assert(isequaln(nuisanceMatrix, copiedMatrix), ...
        'Copied BASCO nuisance file differs from its v1 source for %s.', ...
        subjectID ...
    );

    sessionRows(i, :) = {
        subjectID
        copiedEpi
        onsetFile
        copiedNuisance
        regressorFile
    };
end

%% Analysis-level metainfo

metainfo = struct();

metainfo.EPI = cfg.epi.prefix;
metainfo.onsets = ['regressors' cfg.regressors.suffix];
metainfo.onset_dir = cfg.regressorsDir;
metainfo.covariates = cfg.nuisance.bascoFilename;
metainfo.covariate_dir = 'session-specific; input/<subject>/run1';
metainfo.HRF = cfg.hrf.name;
metainfo.unsmoothed_FC_input = true;
metainfo.expected_ROI_count = cfg.atlas.expectedROIcount;
metainfo.atlas = cfg.atlas.name;
metainfo.leftRightCombination = cfg.atlas.leftRightCombination;

metainfoFile = cfg.files.metainfo;

save(metainfoFile, 'metainfo');

sessionManifest = cell2table( ...
    sessionRows, ...
    'VariableNames', ...
    {'Subject_ID', 'Copied_EPI', 'Onset_File', ...
     'Copied_Nuisance', 'Source_Regressor_File'} ...
);

writetable( ...
    sessionManifest, ...
    fullfile(cfg.manifestDir, 'basco_input_manifest_reappraisal.csv') ...
);

fprintf('Prepared BASCO input for %d subjects.\n', height(manifest));
fprintf('Saved BASCO metainfo:\n%s\n', metainfoFile);

end
