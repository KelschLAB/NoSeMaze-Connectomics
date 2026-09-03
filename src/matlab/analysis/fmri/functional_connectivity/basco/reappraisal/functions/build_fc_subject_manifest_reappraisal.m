function manifest = build_fc_subject_manifest_reappraisal(cfg)
% BUILD_FC_SUBJECT_MANIFEST_REAPPRAISAL Build portable FC input manifest.
%
% This replaces filelist_ICON_reappraisal_jr.mat, which contains
% machine-specific absolute paths.

if ~isfolder(cfg.manifestDir)
    mkdir(cfg.manifestDir);
end

nSubjects = numel(cfg.subjectIDs);

Subject_ID = strings(nSubjects, 1);
Animal_Number = cfg.subjectNumbers(:);
EPI_File = strings(nSubjects, 1);
Protocol_File = strings(nSubjects, 1);
Nuisance_File = strings(nSubjects, 1);
Regressor_File = strings(nSubjects, 1);

for i = 1:nSubjects

    subjectID = cfg.subjectIDs{i};
    animalNumber = cfg.subjectNumbers(i);

    Subject_ID(i) = string(subjectID);

    epiFile = find_fc_epi_for_subject(cfg, subjectID);
    EPI_File(i) = string(epiFile);

    protocolFile = find_subject_protocol_file_fc( ...
        cfg.protocolDir, ...
        subjectID, ...
        animalNumber ...
    );
    Protocol_File(i) = string(protocolFile);

    nuisanceFile = find_nuisance_file_for_epi( ...
        epiFile, ...
        cfg.nuisance.filename ...
    );
    Nuisance_File(i) = string(nuisanceFile);

    regressorFile = find_v19_regressor_file(cfg, subjectID);
    Regressor_File(i) = string(regressorFile);
end

manifest = table( ...
    Subject_ID, ...
    Animal_Number, ...
    EPI_File, ...
    Protocol_File, ...
    Nuisance_File, ...
    Regressor_File ...
);

manifest.Has_EPI = strlength(manifest.EPI_File) > 0;
manifest.Has_Protocol = strlength(manifest.Protocol_File) > 0;
manifest.Has_Nuisance = strlength(manifest.Nuisance_File) > 0;
manifest.Has_v19_Regressors = strlength(manifest.Regressor_File) > 0;

writetable(manifest, cfg.subjectManifestCsv);
save(cfg.subjectManifestMat, 'manifest');

fprintf('Saved FC subject manifest:\n%s\n', cfg.subjectManifestCsv);

missingRequired = ...
    ~manifest.Has_EPI | ...
    ~manifest.Has_Protocol | ...
    ~manifest.Has_Nuisance | ...
    ~manifest.Has_v19_Regressors;

if any(missingRequired)

    fprintf('\nFC manifest is incomplete for %d/%d subjects.\n', ...
        sum(missingRequired), height(manifest));

    disp(manifest(missingRequired, { ...
        'Subject_ID', ...
        'Has_EPI', ...
        'Has_Protocol', ...
        'Has_Nuisance', ...
        'Has_v19_Regressors' ...
    }));

    if cfg.strictManifest
        error('FC manifest is incomplete.');
    end
end

end
