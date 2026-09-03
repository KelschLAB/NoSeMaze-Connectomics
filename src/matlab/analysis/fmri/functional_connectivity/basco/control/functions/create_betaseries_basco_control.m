function create_betaseries_basco_control(manifest,cfg)
% CREATE_BETASERIES_BASCO_CONTROL
% Create only the beta-series subsets consumed by manuscript figures.
%
% v16 condition order:
%   Lavender   120 trials
%   TP_noPuff  120 trials

assert(isfile(cfg.basco.anaobjFile), ...
    'BASCO anaobj file not found:\n%s',cfg.basco.anaobjFile);

Sana = load(cfg.basco.anaobjFile,'anaobj');
anaobj = Sana.anaobj;

conditionNames = anaobj{1,1}.Ana{1,1}.AnaDef.Cond;
assert(isequal(conditionNames,{'Lavender','TP_noPuff'}), ...
    'Unexpected BASCO condition order.');

if ~isfolder(cfg.betaSeriesDir); mkdir(cfg.betaSeriesDir); end

% Condition-relative trial selections required by manuscript scripts.
spec = {
    'Odor1to40',       1, 1:40
    'Odor11to40',      1, 11:40
    'Odor81to120',     1, 81:120
    'TPnoPuff11to40',  2, 11:40
    'TPnoPuff81to120', 2, 81:120
};

for s = 1:height(manifest)

    subjectID = char(manifest.Subject_ID(s));
    workDir = fullfile(cfg.inputDir,subjectID,'betaseries_v6');

    betaFiles = dir(fullfile(workDir,'beta_*.nii'));
    assert(~isempty(betaFiles),'No BASCO beta images for %s.',subjectID);

    betaNumbers = nan(numel(betaFiles),1);
    for k=1:numel(betaFiles)
        tok = regexp(betaFiles(k).name,'beta_(\d+)','tokens','once');
        betaNumbers(k) = str2double(tok{1});
    end
    [~,ord] = sort(betaNumbers);
    betaFiles = betaFiles(ord);

    condLengths = cellfun(@numel, ...
        anaobj{1,1}.Ana{1,1}.AnaDef.RegCondVec);
    condStarts = [1, 1+cumsum(condLengths(1:end-1))];

    for q=1:size(spec,1)

        suffix = spec{q,1};
        condIndex = spec{q,2};
        relIdx = spec{q,3};
        globalIdx = condStarts(condIndex)-1 + relIdx;

        outputFile = fullfile(cfg.betaSeriesDir, ...
            sprintf('%s_betaseries_v6_%s.nii',subjectID,suffix));

        if isfile(outputFile); delete(outputFile); end

        for n=1:numel(globalIdx)
            V = spm_vol(fullfile(betaFiles(globalIdx(n)).folder, ...
                betaFiles(globalIdx(n)).name));
            Vout = V;
            Vout.fname = outputFile;
            Vout.n = [n 1];
            spm_write_vol(Vout,spm_read_vols(V));
        end
    end
end
end
