function repoRoot = find_repo_root(startPath)
% FIND_REPO_ROOT Locate the NoSeMaze-Connectomics repository root.
%
% Searches upward from startPath until a directory containing
% data/, figures/, and src/ is found.

arguments
    startPath (1,:) char
end

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
        error( ...
            ['Could not locate the NoSeMaze-Connectomics repository root ' ...
             'starting from:\n%s'], ...
            startPath ...
        );
    end

    currentDir = parentDir;
end
end
