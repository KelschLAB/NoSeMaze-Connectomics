function repoRoot = find_repo_root(startPath)
% FIND_REPO_ROOT Locate the NoSeMaze-Connectomics repository root.

arguments
    startPath (1,:) char
end

if isfile(startPath)
    currentDir = fileparts(startPath);
else
    currentDir = startPath;
end

while true
    if isfolder(fullfile(currentDir,'data')) && ...
            isfolder(fullfile(currentDir,'figures')) && ...
            isfolder(fullfile(currentDir,'src'))
        repoRoot = currentDir;
        return;
    end

    parentDir = fileparts(currentDir);

    if strcmp(parentDir,currentDir)
        error('Could not locate repository root starting from:\n%s',startPath);
    end

    currentDir = parentDir;
end
end
