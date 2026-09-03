function key = session_key_from_filename(fileName)
% SESSION_KEY_FROM_FILENAME Derive subject/session token such as d01_ses1.

[~,name,~] = fileparts(fileName);

tok = regexp(name,'(?i)([a-z]+\d+_ses\d+)','tokens','once');
if ~isempty(tok)
    key = lower(tok{1});
    return;
end

parts = split(string(name),'_');
assert(numel(parts)>=2, ...
    'Cannot derive subject/session key from filename: %s',name);
key = lower(char(join(parts(1:2),'_')));
end
