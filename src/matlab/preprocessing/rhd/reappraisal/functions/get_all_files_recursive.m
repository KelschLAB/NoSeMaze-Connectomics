function files = get_all_files_recursive(rootDir, pattern)
% GET_ALL_FILES_RECURSIVE Return recursively matching files as full paths.

arguments
    rootDir (1,:) char
    pattern (1,:) char = '*'
end

if ~isfolder(rootDir)
    error('Directory not found:\n%s',rootDir);
end

listing = dir(fullfile(rootDir,'**',pattern));
listing = listing(~[listing.isdir]);

files = arrayfun( ...
    @(x) fullfile(x.folder,x.name), ...
    listing, ...
    'UniformOutput',false ...
);
files = files(:);
end
