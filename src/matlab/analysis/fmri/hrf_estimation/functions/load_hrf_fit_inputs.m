
function [meanTC,onsets] = load_hrf_fit_inputs(cfg,sessionID)
% LOAD_HRF_FIT_INPUTS Load residual ROI time course and mask-GLM onsets.

sessionID = char(sessionID);

tcFile = fullfile( ...
    cfg.timecourseDir, ...
    sessionID, ...
    sprintf('%s_odormask_%s_roidata.mat',sessionID,cfg.maskLabel));

assert(isfile(tcFile),'HRF ROI time-course file missing:\n%s',tcFile);

T = load(tcFile,'roidata');

assert(isfield(T,'roidata') && isfield(T.roidata,'tc'), ...
    'Expected roidata.tc in:\n%s',tcFile);

meanTC = mean(T.roidata.tc,1);

spmFile = fullfile(cfg.maskFirstLevelDir,sessionID,'SPM.mat');
assert(isfile(spmFile),'HRF mask-GLM SPM.mat missing:\n%s',spmFile);

G = load(spmFile,'SPM');
SPM = G.SPM;

assert(numel(SPM.Sess.U)>=3, ...
    'Expected three odor-duration conditions in %s.',spmFile);

if cfg.highResolution

    onsets = SPM.Sess.U(1).u + ...
             SPM.Sess.U(2).u + ...
             SPM.Sess.U(3).u;

    onsets(1:cfg.spmPaddingSamples,:) = [];
    onsets = full(onsets);

else
    error('Only the historical high-resolution HRF fitting branch is public.');
end

end
