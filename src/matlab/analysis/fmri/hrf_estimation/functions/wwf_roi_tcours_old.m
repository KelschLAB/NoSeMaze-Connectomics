
function [tc,roidata] = wwf_roi_tcours_old(Pmsk,Pdata)
% WWF_ROI_TCOURS_OLD Compatibility wrapper for historical HRF scripts.

[dataDir,dataName,~] = fileparts(Pdata);
[~,maskName,~] = fileparts(Pmsk);

outputFile = fullfile( ...
    dataDir, ...
    sprintf('%s_%s_roidata.mat',dataName,maskName));

[tc,roidata] = extract_roi_timecourse(Pmsk,Pdata,outputFile);

end
