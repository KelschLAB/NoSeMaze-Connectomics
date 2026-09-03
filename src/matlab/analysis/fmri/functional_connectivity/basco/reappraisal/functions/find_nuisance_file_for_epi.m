function nuisanceFile = find_nuisance_file_for_epi(epiFile, nuisanceFilename)
% FIND_NUISANCE_FILE_FOR_EPI Locate nuisance file belonging to an EPI.

nuisanceFile = '';

if isempty(epiFile) || ~isfile(epiFile)
    return;
end

epiDir = fileparts(epiFile);

candidateDirs = {
    epiDir
    fileparts(epiDir)
    fileparts(fileparts(epiDir))
};

for i = 1:numel(candidateDirs)
    candidate = fullfile(candidateDirs{i}, nuisanceFilename);

    if isfile(candidate)
        nuisanceFile = candidate;
        return;
    end
end

end
