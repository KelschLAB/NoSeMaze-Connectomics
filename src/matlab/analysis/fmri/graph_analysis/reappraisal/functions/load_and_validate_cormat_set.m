function data = load_and_validate_cormat_set(cormatFile,cfg)

loaded = load(cormatFile);
assert(isfield(loaded,'cormat'),'Variable "cormat" missing in:\n%s',cormatFile);

cormat = loaded.cormat;
assert(iscell(cormat) && ~isempty(cormat), ...
    'cormat must be a non-empty cell array:\n%s',cormatFile);

for subjectIndex=1:numel(cormat)
    M = cormat{subjectIndex};

    assert(ismatrix(M) && size(M,1)==size(M,2), ...
        'Subject %d cormat is not square.',subjectIndex);

    assert(size(M,1)==cfg.expectedROIcount, ...
        'Subject %d matrix is %d x %d, expected %d x %d.', ...
        subjectIndex,size(M,1),size(M,2), ...
        cfg.expectedROIcount,cfg.expectedROIcount);

    symmetryError = max(abs(M(:)-M.'(:)));
    assert(symmetryError < 1e-10, ...
        'Subject %d cormat is not symmetric.',subjectIndex);
end

data = struct();
data.cormat = cormat;

if isfield(loaded,'subjectIDs')
    data.subjectIDs = loaded.subjectIDs;
else
    data.subjectIDs = strings(numel(cormat),1);
end

if isfield(loaded,'names')
    data.names = loaded.names;
else
    data.names = {};
end

data.sourceFile = cormatFile;
end
