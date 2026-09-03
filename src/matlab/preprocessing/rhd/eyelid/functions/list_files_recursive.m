function files = list_files_recursive(rootDir,pattern)
% LIST_FILES_RECURSIVE Return recursively matched files as a cell array.

D = dir(fullfile(rootDir,'**',pattern));
D = D(~[D.isdir]);
files = arrayfun(@(x) fullfile(x.folder,x.name),D,'UniformOutput',false)';
files = sort(files);
end
