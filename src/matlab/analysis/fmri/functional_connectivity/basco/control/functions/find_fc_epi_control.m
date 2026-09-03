function epiFile = find_fc_epi_control(cfg,subjectID)

if ~isfolder(cfg.preprocessedFmriRoot)
    epiFile = '';
    return;
end

matches = dir(fullfile(cfg.preprocessedFmriRoot,'**', ...
    [cfg.epi.prefix '*' cfg.epi.suffix '.nii']));
matches = matches(~[matches.isdir]);

keep = contains(string({matches.name}), erase(subjectID,'ZI_'));
matches = matches(keep);

if isempty(matches)
    epiFile = '';
elseif numel(matches)==1
    epiFile = fullfile(matches(1).folder,matches(1).name);
else
    error('Multiple FC EPI files found for %s.',subjectID);
end
end
