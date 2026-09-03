function run_firstlevel_reappraisal(cfg)
% RUN_FIRSTLEVEL_REAPPRAISAL Run subject-level SPM GLMs.

if ~strcmp(cfg.regressorModel, 'v22')
    error('Primary reappraisal GLM requires regressor model v22.');
end

if abs(cfg.smoothingFWHMmm - 0.6) > eps
    error('Primary reappraisal GLM requires the 0.6-mm (s6) EPI branch.');
end

if ~isfile(cfg.explicitMask)
    error('Explicit analysis mask not found:\n%s', cfg.explicitMask);
end

if ~isfolder(cfg.hrfDir)
    error('Selected animal-HRF directory not found:\n%s', cfg.hrfDir);
end

if ~isfolder(cfg.preprocessedFmriRoot)
    error('Preprocessed fMRI root not found:\n%s', cfg.preprocessedFmriRoot);
end

spm('CreateMenuWin', 'off');
spm('CreateIntWin', 'off');

% Restrict the special mouse HRF override to this function call.
originalPath = path;
cleanupPath = onCleanup(@() path(originalPath)); %#ok<NASGU>
addpath(cfg.hrfDir, '-begin');

for subjectIndex = 1:numel(cfg.subjectIDs)

    subjectID = cfg.subjectIDs{subjectIndex};

    fprintf('\nFirst-level GLM: %s\n', subjectID);

    epiFile = find_preprocessed_epi( ...
        cfg.preprocessedFmriRoot, ...
        subjectID, ...
        cfg.epiPrefix, ...
        cfg.epiSuffix ...
    );

    [epiDir, epiName, epiExt] = fileparts(epiFile);

    Pfuncall = spm_select( ...
        'ExtFPList', ...
        epiDir, ...
        ['^' regexptranslate('escape', [epiName epiExt]) '$'], ...
        1:2500 ...
    );

    if isempty(Pfuncall)
        error('SPM could not select volumes from:\n%s', epiFile);
    end

    regressorFile = fullfile( ...
        cfg.regressorsDir, ...
        sprintf('%s_%s.mat', subjectID, cfg.regressorModel) ...
    );

    if ~isfile(regressorFile)
        error('Regressor file not found:\n%s', regressorFile);
    end

    loadedReg = load(regressorFile, 'regressors');
    regressors = loadedReg.regressors;

    ROI = convert_regressors_to_roi(regressors);

    if strcmp(cfg.covariateModel, 'v0')

        COV = [];

    else

        covariateFile = fullfile( ...
            cfg.covariatesDir, ...
            sprintf('%s_%s.mat', subjectID, cfg.covariateModel) ...
        );

        if ~isfile(covariateFile)
            error('Covariate file not found:\n%s', covariateFile);
        end

        loadedCov = load(covariateFile, 'covar');
        covar = loadedCov.covar;

        R = [covar.value];
        names = {covar.name};

        outputDir = fullfile(cfg.firstLevelDir, subjectID);

        if ~isfolder(outputDir)
            mkdir(outputDir);
        end

        covMatFile = fullfile(outputDir, 'cov.mat');
        save(covMatFile, 'R', 'names');

        COV = covMatFile;
    end

    outputDir = fullfile(cfg.firstLevelDir, subjectID);

    if ~isfolder(outputDir)
        mkdir(outputDir);
    end

    do_firstlevel_jr( ...
        Pfuncall, ...
        ROI, ...
        COV, ...
        cfg.DerDisp, ...
        cfg.explicitMask, ...
        cfg.fmri_t, ...
        cfg.fmri_t0, ...
        cfg.TR, ...
        outputDir, ...
        cfg.maskThreshold, ...
        cfg.orth ...
    );
end

end


function ROI = convert_regressors_to_roi(regressors)

ROI = struct([]);
roiCounter = 0;

for regIndex = 1:numel(regressors)

    if isempty(regressors(regIndex).onset)
        continue;
    end

    roiCounter = roiCounter + 1;

    ROI(roiCounter).name = regressors(regIndex).name;
    ROI(roiCounter).values = regressors(regIndex).onset;
    ROI(roiCounter).duration = regressors(regIndex).duration;
    ROI(roiCounter).PM = struct([]);

    if ~isempty(regressors(regIndex).pm)

        for pmIndex = 1:numel(regressors(regIndex).pm)

            ROI(roiCounter).PM(pmIndex).name = ...
                regressors(regIndex).pm(pmIndex).name;

            ROI(roiCounter).PM(pmIndex).vector = ...
                regressors(regIndex).pm(pmIndex).vector;

            ROI(roiCounter).PM(pmIndex).ROI_numb = regIndex;
        end
    end
end

end
