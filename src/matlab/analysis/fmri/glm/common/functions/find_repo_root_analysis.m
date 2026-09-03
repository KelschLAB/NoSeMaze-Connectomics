function repoRoot = find_repo_root_analysis(startPath)
% FIND_REPO_ROOT_ANALYSIS Locate NoSeMaze-Connectomics repository root.

if isfile(startPath)
    currentDir = fileparts(startPath);
else
    currentDir = startPath;
end

while true

    if isfolder(fullfile(currentDir, 'data')) && ...
            isfolder(fullfile(currentDir, 'figures')) && ...
            isfolder(fullfile(currentDir, 'src'))

        repoRoot = currentDir;
        return;
    end

    parentDir = fileparts(currentDir);

    if strcmp(parentDir, currentDir)
        error('Could not locate repository root from:\n%s', startPath);
    end

    currentDir = parentDir;
end

end
