function create_covariates_control_v1(cfg, epiManifest)
% CREATE_COVARIATES_CONTROL_V1 Create the historical 14 nuisance covariates.
%
% Source columns:
%   1:6   realignment parameters
%   7     CSF
%   8:13  derivatives of realignment parameters
%   14    CSF derivative
%
% Translation parameters and their derivatives are divided by 10, matching
% the historical control script.

if ~isfolder(cfg.covariatesDir); mkdir(cfg.covariatesDir); end

required = {'Subject_ID','EPI_File'};
assert(all(ismember(required, epiManifest.Properties.VariableNames)), ...
    'epiManifest must contain Subject_ID and EPI_File.');

for i = 1:height(epiManifest)

    subjectID = char(epiManifest.Subject_ID(i));
    epiFile = char(epiManifest.EPI_File(i));
    epiDir = fileparts(epiFile);

    sourceFile = fullfile(epiDir, ...
        'regressors_despiked_motcsf_der.txt');

    assert(isfile(sourceFile), ...
        'Missing nuisance source for %s:\n%s', subjectID, sourceFile);

    R0 = readmatrix(sourceFile);
    assert(size(R0,2) == 14, ...
        '%s nuisance source has %d columns; expected 14.', ...
        subjectID, size(R0,2));

    covar = repmat(struct('name','','value',[]),1,14);

    for k = 1:6
        covar(k).name = sprintf('rp%d',k);
        covar(k).value = R0(:,k);

        covar(k+6).name = sprintf('rp%d_deriv',k);
        covar(k+6).value = R0(:,k+7);
    end

    for k = [1:3, 7:9]
        covar(k).value = covar(k).value ./ 10;
    end

    covar(13).name = 'csf';
    covar(13).value = R0(:,7);

    covar(14).name = 'csf_deriv';
    covar(14).value = R0(:,14);

    save(fullfile(cfg.covariatesDir, ...
        sprintf('%s_v1.mat',subjectID)), 'covar');
end
end
