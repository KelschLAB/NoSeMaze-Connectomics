function run_firstlevel_control(cfg, epiManifest)
% RUN_FIRSTLEVEL_CONTROL Run primary v22 control first-level GLMs using shared GLM helpers.

for i = 1:height(epiManifest)

    subjectID = char(epiManifest.Subject_ID(i));
    epiFile = char(epiManifest.EPI_File(i));

    assert(isfile(epiFile), 'Missing EPI for %s.',subjectID);

    % SPM accepts the 4-D NIfTI via an expanded volume list.
    Pfuncall = spm_select('ExtFPList', ...
        fileparts(epiFile), ...
        ['^' regexptranslate('escape', string(get_filename(epiFile))) '$'], ...
        1:2500);

    regFile = fullfile(cfg.regressorsDir, ...
        sprintf('%s_v22.mat',subjectID));
    covFile = fullfile(cfg.covariatesDir, ...
        sprintf('%s_v1.mat',subjectID));

    R = load(regFile,'regressors');
    C = load(covFile,'covar');

    ROI = struct([]);
    for j = 1:numel(R.regressors)
        ROI(j).name = R.regressors(j).name;
        ROI(j).values = R.regressors(j).onset;
        ROI(j).duration = R.regressors(j).duration;
        ROI(j).PM = [];
    end

    nuisanceR = [C.covar.value]; %#ok<NASGU>
    names = {C.covar.name}; %#ok<NASGU>

    outputDir = fullfile(cfg.resultsDir,'firstlevel',subjectID);
    if ~isfolder(outputDir); mkdir(outputDir); end

    covMat = fullfile(outputDir,'cov.mat');
    R = nuisanceR; %#ok<NASGU>
    save(covMat,'R','names');

    do_firstlevel_jr( ...
        Pfuncall, ROI, covMat, cfg.DerDisp, cfg.explicitMask, ...
        cfg.fmri_t, cfg.fmri_t0, cfg.TR, outputDir, ...
        cfg.maskThreshold, cfg.orth);
end
end

function name = get_filename(filePath)
[~,base,ext] = fileparts(filePath);
name = [base ext];
end
