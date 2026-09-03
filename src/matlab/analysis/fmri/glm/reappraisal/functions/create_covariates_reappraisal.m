function create_covariates_reappraisal(cfg)
% CREATE_COVARIATES_REAPPRAISAL Create nuisance covariates for first-level GLM.
%
% v1:
%   rp1-rp6
%   derivatives of rp1-rp6
%   CSF
%   CSF derivative
%
% v3:
%   same as v1 + framewise displacement
%
% The cleaned master defaults to v1 because the supplied historical GLM
% master selects covariate suffix _v1.mat.

if ~isfolder(cfg.preprocessedFmriRoot)
    error([ ...
        'Preprocessed fMRI root not found:\n%s\n\n' ...
        'Set NOSEMAZE_REAPPRAISAL_FMRI_PROCESSED_ROOT if the large ' ...
        'preprocessed MRI data are stored outside the repository.' ...
    ], cfg.preprocessedFmriRoot);
end

if ~isfolder(cfg.covariatesDir)
    mkdir(cfg.covariatesDir);
end

switch cfg.covariateModel
    case 'v1'
        includeFD = false;
    case 'v3'
        includeFD = true;
    otherwise
        error('Unsupported nuisance-covariate model: %s', cfg.covariateModel);
end

if includeFD && isempty(which('SNiP_framewise_displacement'))
    error([ ...
        'Covariate model v3 requires SNiP_framewise_displacement.m. ' ...
        'Copy this helper before using v3.' ...
    ]);
end

metadataRows = cell(numel(cfg.subjectIDs), 4);

for subjectIndex = 1:numel(cfg.subjectIDs)

    subjectID = cfg.subjectIDs{subjectIndex};

    regressorFile = find_unique_subject_file( ...
        cfg.preprocessedFmriRoot, ...
        subjectID, ...
        cfg.nuisanceRegressorFile ...
    );

    nuisance = load(regressorFile);

    if size(nuisance, 2) < 14
        error( ...
            '%s contains %d columns; expected at least 14.', ...
            regressorFile, ...
            size(nuisance, 2) ...
        );
    end

    covar = repmat( ...
        struct('name', '', 'value', []), ...
        1, ...
        14 + double(includeFD) ...
    );

    % Original motion parameters.
    for motionIndex = 1:6
        covar(motionIndex).name = sprintf('rp%d', motionIndex);
        covar(motionIndex).value = nuisance(:, motionIndex);

        covar(motionIndex + 6).name = ...
            sprintf('rp%d_deriv', motionIndex);

        % Historical layout:
        % col 7 = CSF; cols 8-13 = motion derivatives; col 14 = CSF deriv.
        covar(motionIndex + 6).value = ...
            nuisance(:, motionIndex + 7);
    end

    if cfg.scaleTranslationsBy10
        % Translation parameters (and their derivatives) were stored in the
        % x10 SPM coordinate system and historically divided by 10.
        for covIndex = [1:3, 7:9]
            covar(covIndex).value = covar(covIndex).value ./ 10;
        end
    end

    covar(13).name = 'csf';
    covar(13).value = nuisance(:, 7);

    covar(14).name = 'csf_deriv';
    covar(14).value = nuisance(:, 14);

    rpFile = '';

    if includeFD

        rpFile = find_unique_subject_file( ...
            cfg.preprocessedFmriRoot, ...
            subjectID, ...
            'rp_despiked_del5_*.txt' ...
        );

        rp = load(rpFile);
        FD = SNiP_framewise_displacement(rp);

        covar(15).name = 'FD';
        covar(15).value = FD;
    end

    outputFile = fullfile( ...
        cfg.covariatesDir, ...
        sprintf('%s_%s.mat', subjectID, cfg.covariateModel) ...
    );

    save(outputFile, 'covar');

    metadataRows(subjectIndex, :) = {
        subjectID
        regressorFile
        rpFile
        outputFile
    };

    fprintf('Saved nuisance covariates: %s\n', outputFile);
end

metadata = cell2table( ...
    metadataRows, ...
    'VariableNames', ...
    {'Subject_ID', 'Nuisance_Source', 'Motion_Source', 'Covariate_File'} ...
);

metadata.Model = repmat( ...
    string(cfg.covariateModel), ...
    height(metadata), ...
    1 ...
);

writetable( ...
    metadata, ...
    fullfile(cfg.covariatesDir, 'covariate_manifest.csv') ...
);

end
