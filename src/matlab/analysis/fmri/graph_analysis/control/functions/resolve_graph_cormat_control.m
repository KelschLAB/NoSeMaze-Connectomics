function cormatFile = resolve_graph_cormat_control(cfg,suffix)

name = sprintf('cormat_%s_%s.mat',cfg.cormatVersion,suffix);
candidate = fullfile(cfg.cormatDir,name);

if isfile(candidate)
    cormatFile = candidate;
    return;
end

matches = dir(fullfile(cfg.cormatDir,'**',name));
matches = matches(~[matches.isdir]);

assert(numel(matches)==1, ...
    'Expected one %s, found %d.',name,numel(matches));

cormatFile = fullfile(matches(1).folder,matches(1).name);
end
