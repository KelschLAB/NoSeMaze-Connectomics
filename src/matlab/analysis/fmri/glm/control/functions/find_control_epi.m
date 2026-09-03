function epiFile = find_control_epi(cfg, subjectID)
% FIND_CONTROL_EPI Locate the primary smoothed control EPI.

if ~isfolder(cfg.preprocessedFmriRoot)
    epiFile = '';
    return;
end

pattern = [cfg.epi.prefix '*' subjectID '*' cfg.epi.suffix '.nii'];

matches = dir(fullfile(cfg.preprocessedFmriRoot, '**', pattern));
matches = matches(~[matches.isdir]);

if isempty(matches)
    % Historical filenames may contain the subject ID before the prefix.
    matches = dir(fullfile(cfg.preprocessedFmriRoot, '**', ...
        [cfg.epi.prefix '*' cfg.epi.suffix '.nii']));
    matches = matches(~[matches.isdir]);
    keep = contains(string({matches.name}), erase(subjectID,'ZI_'));
    matches = matches(keep);
end

if isempty(matches)
    epiFile = '';
elseif numel(matches) == 1
    epiFile = fullfile(matches(1).folder,matches(1).name);
else
    error('Multiple primary EPI files found for %s.',subjectID);
end
end
