function manifest = build_fc_subject_manifest_control(cfg)

if ~isfolder(cfg.manifestDir); mkdir(cfg.manifestDir); end

T = readtable(cfg.scanlist,'VariableNamingRule','preserve');
[subjectIDs,ia] = unique(string(T.Subject),'stable');
scannerIDs = T.ID(ia);

n = numel(subjectIDs);
EPI_File = strings(n,1);
Nuisance_File = strings(n,1);
Regressor_File = strings(n,1);

for i = 1:n
    subjectID = char(subjectIDs(i));

    EPI_File(i) = string(find_fc_epi_control(cfg,subjectID));

    if strlength(EPI_File(i)) > 0
        nuisanceCandidate = fullfile( ...
            fileparts(char(EPI_File(i))), ...
            cfg.nuisance.sourceFilename);
        if isfile(nuisanceCandidate)
            Nuisance_File(i) = string(nuisanceCandidate);
        end
    end

    regCandidate = fullfile(cfg.regressorsDir, ...
        sprintf('%s_v16.mat',subjectID));
    if isfile(regCandidate)
        Regressor_File(i) = string(regCandidate);
    end
end

manifest = table(subjectIDs,scannerIDs,EPI_File,Nuisance_File,Regressor_File, ...
    'VariableNames',{'Subject_ID','Scanner_ID','EPI_File', ...
    'Nuisance_File','Regressor_File'});

writetable(manifest,cfg.subjectManifestCsv);
save(cfg.subjectManifestMat,'manifest');
end
