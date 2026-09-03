
function [rsq,hrfParam] = fit_hrf_multistart( ...
    meanTC,onsets,tr,T,T0,x0,highResolution,maxFunEvals)
% FIT_HRF_MULTISTART Historical fminsearch HRF optimization.
%
% This is the cleaned version of nested function master_fmin() from
% master_HRF_estimation_jr.m. The numerical optimization is preserved.

if highResolution

    assert(exist('estimate_GLM_model_highres','file')==2, ...
        ['Missing historical fitting dependency: ' ...
         'estimate_GLM_model_highres.m']);

    objective = @(x) -1 .* estimate_GLM_model_highres( ...
        meanTC,onsets,tr,T,T0,x);

else

    assert(exist('estimate_GLM_model_lowres','file')==2, ...
        ['Missing historical fitting dependency: ' ...
         'estimate_GLM_model_lowres.m']);

    objective = @(x) -1 .* estimate_GLM_model_lowres( ...
        meanTC,onsets,tr,x);
end

options = optimset('MaxFunEvals',maxFunEvals);

rsq = nan(1,size(x0,1));
hrfParam = nan(size(x0));

for i = 1:size(x0,1)

    x = fminsearch(objective,x0(i,:),options);

    if highResolution
        r2 = estimate_GLM_model_highres(meanTC,onsets,tr,T,T0,x);
    else
        r2 = estimate_GLM_model_lowres(meanTC,onsets,tr,x);
    end

    rsq(i) = r2;
    hrfParam(i,:) = x;
end

end
