
function [R,names] = create_covariates_hrf_v1(regressorFile)
% CREATE_COVARIATES_HRF_V1 Reproduce the historical 14 nuisance covariates.
%
% Source regressors_motcsf_der.txt columns:
%   1:6   motion parameters
%   7     CSF
%   8:13  motion derivatives
%   14    CSF derivative
%
% Historical output ordering:
%   rp1..rp6, rp1_deriv..rp6_deriv, csf, csf_deriv.

assert(isfile(regressorFile), ...
    'HRF nuisance-regressor file not found:\n%s',regressorFile);

X = load(regressorFile);

assert(size(X,2) >= 14, ...
    'Expected at least 14 columns in %s.',regressorFile);

R = [X(:,1:6), X(:,8:13), X(:,7), X(:,14)];

names = cell(1,14);

for i = 1:6
    names{i} = sprintf('rp%d',i);
    names{i+6} = sprintf('rp%d_deriv',i);
end

names{13} = 'csf';
names{14} = 'csf_deriv';

end
