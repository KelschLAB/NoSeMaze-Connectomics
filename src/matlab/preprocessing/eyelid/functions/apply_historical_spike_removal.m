function corrected = apply_historical_spike_removal(areaRatio,cfg)
% APPLY_HISTORICAL_SPIKE_REMOVAL Optional historical compatibility stage.
%
% The final written eyelid methods do not describe this step, so it is not
% used by the primary manuscript profile.

if ~cfg.useHistoricalSpikeRemoval
    corrected = areaRatio;
    return;
end

assert(~isempty(which('RemovePikes_NaN_jr')), ...
    ['Historical profile requested RemovePikes_NaN_jr, but that helper is ' ...
     'not on the MATLAB path. The primary manuscript profile does not ' ...
     'require this helper.']);

M = zeros(1,size(areaRatio,2),size(areaRatio,1));
M(1,:,:) = areaRatio';
[Mcorrected,~] = RemovePikes_NaN_jr(M,M,3,4,0,NaN);
corrected = squeeze(Mcorrected)';
end
