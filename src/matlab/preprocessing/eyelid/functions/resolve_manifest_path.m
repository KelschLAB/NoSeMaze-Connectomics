function p = resolve_manifest_path(value,rootDir)
% RESOLVE_MANIFEST_PATH Resolve absolute or root-relative manifest path.

value = strtrim(char(string(value)));
if isempty(value) || strcmpi(value,'<missing>')
    p = '';
    return;
end

if is_absolute_path(value)
    p = value;
else
    assert(~isempty(rootDir), ...
        'A relative path was supplied but its external root is not configured: %s',value);
    p = fullfile(rootDir,value);
end
end
