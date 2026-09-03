
function [r2s,bs,X_hrf] = estimate_GLM_model_highres( ...
    y,X,tr,T,T0,hrf_param_input)
% ESTIMATE_GLM_MODEL_HIGHRES Fit a custom-HRF GLM at high temporal resolution.
%
% Adapted from the supplied Ronald Sladky / Magdalena Boch implementation
% and JR high-resolution convolution/downsampling modifications.

r2s = 0;
bs = 0;
X_hrf = [];

def = [6 16 1 1 6 0 32];

hrf_param_input(isnan(hrf_param_input)) = ...
    def(isnan(hrf_param_input));

hrf_param = nan(1,7);

hrf_param(1) = hrf_param_input(1);
hrf_param(2) = hrf_param_input(2);
hrf_param(3) = hrf_param_input(3);
hrf_param(4) = hrf_param_input(3);
hrf_param(5) = hrf_param_input(4);

if numel(hrf_param_input)==5
    hrf_param(6) = hrf_param_input(5);
elseif numel(hrf_param_input)==4
    hrf_param(6) = 0;
else
    error('Expected four or five fitted HRF parameters.');
end

hrf_param(7) = 32;

% Historical plausibility ranges.
hrf_param_range = [ ...
    1   4
    4  10
    0.5 1.5
    0.5 1.5
    3  10
    0  1.5
    30 34 ...
];

% Abort implausible solutions, reproducing the historical objective.
for h = 1:numel(hrf_param)
    if hrf_param(h) < hrf_param_range(h,1) || ...
            hrf_param(h) > hrf_param_range(h,2)
        return
    end
end

% JR high-resolution convolution.
X_hrf_highres = conv( ...
    repmat(X,2,1), ...
    spm_hrf(tr/T,hrf_param) ...
);

if ~isempty(X_hrf_highres)
    idx = (0:(length(y)-1))*T + T0;
    X_hrf = X_hrf_highres(idx,:);
end

X_hrf = [X_hrf X_hrf*0+1];

r2s = zeros(1,size(y,1));
bs = nan(size(y,1),size(X_hrf,2));

for s = 1:size(y,1)

    [b,~,~,~,stats] = regress(y(s,:)',X_hrf);

    if b(1)>0
        r2s(s) = stats(1);
    else
        r2s(s) = 0;
    end

    bs(s,:) = b';
end

end
