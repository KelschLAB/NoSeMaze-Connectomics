function repoRoot = find_repo_root_graph(startPath)
if nargin < 1 || isempty(startPath)
    startPath = mfilename('fullpath');
end
if isfile(startPath)
    currentDir = fileparts(startPath);
else
    currentDir = startPath;
end
while true
    if isfolder(fullfile(currentDir,'.git')) || ...
            isfile(fullfile(currentDir,'NoSeMaze-Connectomics.Rproj'))
        repoRoot = currentDir;
        return;
    end
    parentDir = fileparts(currentDir);
    if strcmp(parentDir,currentDir)
        error('Could not locate repository root above:\n%s',startPath);
    end
    currentDir = parentDir;
end
end
