function inputFiles = collect_firstlevel_contrasts(firstlevelDir,contrastName,contrastType)
% COLLECT_FIRSTLEVEL_CONTRASTS Resolve a named contrast for every subject.

subjectDirs = dir(fullfile(firstlevelDir,'ZI_M*'));
subjectDirs = subjectDirs([subjectDirs.isdir]);

[~,idx] = sort({subjectDirs.name});
subjectDirs = subjectDirs(idx);

inputFiles = {};

for subj = 1:numel(subjectDirs)

    subjDir = fullfile(subjectDirs(subj).folder,subjectDirs(subj).name);
    spmFile = fullfile(subjDir,'SPM.mat');

    if ~isfile(spmFile)
        warning('No SPM.mat for %s; skipping.',subjectDirs(subj).name);
        continue;
    end

    L = load(spmFile,'SPM');
    conIdx = find(strcmp({L.SPM.xCon.name},contrastName),1);

    if isempty(conIdx)
        warning('Contrast "%s" absent for %s; skipping.', ...
            contrastName,subjectDirs(subj).name);
        continue;
    end

    switch lower(contrastType)
        case 'tcon'
            fileName = sprintf('con_%04d.nii',conIdx);
        case 'fcon'
            fileName = sprintf('ess_%04d.nii',conIdx);
        otherwise
            error('Unknown contrast type: %s',contrastType);
    end

    filePath = fullfile(subjDir,fileName);

    if ~isfile(filePath)
        error('Expected contrast image not found:\n%s',filePath);
    end

    inputFiles{end+1,1} = filePath; %#ok<AGROW>
end

if isempty(inputFiles)
    error('No images found for contrast "%s".',contrastName);
end

fprintf('Second level "%s": %d subjects.\n', ...
    contrastName,numel(inputFiles));

end
