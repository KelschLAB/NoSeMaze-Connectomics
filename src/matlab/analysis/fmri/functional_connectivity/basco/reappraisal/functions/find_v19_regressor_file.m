function regressorFile = find_v19_regressor_file(cfg, subjectID)
% FIND_V19_REGRESSOR_FILE Find subject-specific BASCO v19 regressors.

regressorFile = '';

if ~isfolder(cfg.regressorsDir)
    return;
end

targetName = [subjectID cfg.regressors.suffix];

files = dir(fullfile(cfg.regressorsDir, '**', targetName));
files = files(~[files.isdir]);

if isempty(files)
    return;
end

if numel(files) > 1
    candidates = strings(numel(files), 1);

    for i = 1:numel(files)
        candidates(i) = string(fullfile(files(i).folder, files(i).name));
    end

    error( ...
        'Multiple %s regressor files were found for %s:\n%s', ...
        cfg.version.regressors, ...
        subjectID, ...
        strjoin(candidates, newline) ...
    );
end

regressorFile = fullfile(files(1).folder, files(1).name);

end
