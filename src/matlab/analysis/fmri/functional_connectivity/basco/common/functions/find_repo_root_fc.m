function repoRoot = find_repo_root_fc(startPath)
% FIND_REPO_ROOT_FC Find NoSeMaze-Connectomics repository root.

if nargin < 1 || isempty(startPath)
    startPath = mfilename('fullpath');
end

if isfile(startPath)
    currentDir = fileparts(startPath);
else
    currentDir = startPath;
end

while true

    hasGit = isfolder(fullfile(currentDir, '.git'));
    hasProject = isfile(fullfile(currentDir, 'NoSeMaze-Connectomics.Rproj'));

    if hasGit || hasProject
        repoRoot = currentDir;
        return;
    end

    parentDir = fileparts(currentDir);

    if strcmp(parentDir, currentDir)
        error([ ...
            'Could not find repository root above:\n%s\n' ...
            'Expected .git/ or NoSeMaze-Connectomics.Rproj.' ...
        ], startPath);
    end

    currentDir = parentDir;
end

end
