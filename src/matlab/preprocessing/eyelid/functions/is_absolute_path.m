function tf = is_absolute_path(p)
% IS_ABSOLUTE_PATH Platform-independent absolute-path test.
p = char(p);
if ispc
    tf = ~isempty(regexp(p,'^[A-Za-z]:[\\/]','once')) || startsWith(p,'\\');
else
    tf = startsWith(p,'/');
end
end
