function cormatFile = resolve_graph_cormat_file(cfg,suffix)

expectedName = sprintf('cormat_%s_%s.mat',cfg.cormatVersion,suffix);
exactCandidate = fullfile(cfg.cormatDir,expectedName);

if isfile(exactCandidate)
    cormatFile = exactCandidate;
    return;
end

if ~isfolder(cfg.cormatDir)
    error(['Correlation-matrix directory not found:\n%s\n\n' ...
        'Set NOSEMAZE_REAPPRAISAL_CORMAT_ROOT if the derived cormats ' ...
        'are stored elsewhere.'],cfg.cormatDir);
end

matches = dir(fullfile(cfg.cormatDir,'**',expectedName));
matches = matches(~[matches.isdir]);

if isempty(matches)
    error('Required correlation matrix not found:\n%s',expectedName);
elseif numel(matches) > 1
    candidates = strings(numel(matches),1);
    for i=1:numel(matches)
        candidates(i) = string(fullfile(matches(i).folder,matches(i).name));
    end
    error('Multiple files match %s:\n%s',expectedName,strjoin(candidates,newline));
end

cormatFile = fullfile(matches(1).folder,matches(1).name);
end
