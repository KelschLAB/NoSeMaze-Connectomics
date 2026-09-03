function filePath = find_unique_file_recursive_fc(rootDir, predicate, description)
% FIND_UNIQUE_FILE_RECURSIVE_FC Find exactly one file satisfying predicate.
%
% predicate receives a dir() structure element and must return true/false.

arguments
    rootDir (1,:) char
    predicate (1,1) function_handle
    description (1,:) char = 'requested file'
end

if ~isfolder(rootDir)
    filePath = '';
    return;
end

files = dir(fullfile(rootDir, '**', '*'));
files = files(~[files.isdir]);

keep = false(size(files));

for i = 1:numel(files)
    keep(i) = predicate(files(i));
end

files = files(keep);

if isempty(files)
    filePath = '';
    return;
end

if numel(files) > 1
    candidates = strings(numel(files), 1);
    for i = 1:numel(files)
        candidates(i) = string(fullfile(files(i).folder, files(i).name));
    end

    error( ...
        'Expected one %s, found %d:\n%s', ...
        description, ...
        numel(files), ...
        strjoin(candidates, newline) ...
    );
end

filePath = fullfile(files(1).folder, files(1).name);

end
