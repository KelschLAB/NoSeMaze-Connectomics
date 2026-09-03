function epiFile = find_fc_epi_for_subject(cfg, subjectID)
% FIND_FC_EPI_FOR_SUBJECT Find manuscript-consistent unsmoothed EPI.

epiFile = '';

rootDir = cfg.preprocessedFmriRoot;

if ~isfolder(rootDir)
    return;
end

files = dir(fullfile(rootDir, '**', '*.nii'));
files = files(~[files.isdir]);

if isempty(files)
    return;
end

names = {files.name};

keep = contains(names, subjectID) & ...
    startsWith(names, cfg.epi.prefix) & ...
    endsWith(names, [cfg.epi.suffix '.nii']);

for i = 1:numel(cfg.epi.forbiddenTokens)
    keep = keep & ~contains(names, cfg.epi.forbiddenTokens{i});
end

matches = files(keep);

% If exact prefix matching fails, use a tightly constrained unsmoothed
% fallback. This supports minor filename differences without accepting s4/s6.
if isempty(matches)

    keep = contains(names, subjectID) & ...
        contains(names, 'wave_10cons') & ...
        contains(names, 'msk_') & ...
        contains(names, 'despiked_del5') & ...
        endsWith(names, [cfg.epi.suffix '.nii']);

    for i = 1:numel(cfg.epi.forbiddenTokens)
        keep = keep & ~contains(names, cfg.epi.forbiddenTokens{i});
    end

    matches = files(keep);
end

if isempty(matches)
    return;
end

if numel(matches) > 1
    candidates = strings(numel(matches), 1);

    for i = 1:numel(matches)
        candidates(i) = string(fullfile(matches(i).folder, matches(i).name));
    end

    error( ...
        ['More than one unsmoothed FC EPI candidate was found for %s.\n' ...
         'Resolve the ambiguity rather than selecting by directory order:\n%s'], ...
        subjectID, ...
        strjoin(candidates, newline) ...
    );
end

epiFile = fullfile(matches(1).folder, matches(1).name);

end
