function prepared = prepare_positive_cormats_reappraisal(data,cfg,suffix)
% Explicitly reproduce the historical diagonal-removal + positive-edge steps.

cormat = data.cormat;

for subjectIndex=1:numel(cormat)
    M = cormat{subjectIndex};

    if cfg.removeDiagonal
        M(1:size(M,1)+1:end) = 0;
    end

    switch cfg.edgeMode
        case 'positive'
            M = M .* (M > 0);
        case 'absolute'
            M = abs(M);
        otherwise
            error('Unsupported edge mode: %s',cfg.edgeMode);
    end

    cormat{subjectIndex} = M;
end

if ~isfolder(cfg.preparedCormatDir)
    mkdir(cfg.preparedCormatDir);
end

outputFile = fullfile(cfg.preparedCormatDir, ...
    sprintf('cormat_%s_%s_p.mat',cfg.cormatVersion,suffix));

subjectIDs = data.subjectIDs; %#ok<NASGU>
names = data.names; %#ok<NASGU>
save(outputFile,'cormat','subjectIDs','names','-v7.3');

prepared = struct();
prepared.cormat = cormat;
prepared.subjectIDs = subjectIDs;
prepared.names = names;
prepared.outputFile = outputFile;
end
