
function extract_hrf_mean_timecourses(cfg)
% EXTRACT_HRF_MEAN_TIMECOURSES Extract residual BOLD TC in session masks.
%
% A CSV manifest is used because the final HRF procedure used an individual
% odor-responsive mask for each session. This is safer than the long
% hard-coded exploratory mask list in the historical TC script.
%
% Required CSV columns:
%   Session_ID
%   Mask_File
%   Residual_4D_File

assert(isfile(cfg.roiMaskManifest), ...
    ['HRF ROI/residual manifest not found:\n%s\n' ...
     'Create it from the final individual odor-responsive masks and ' ...
     'merged residual 4-D images.'], ...
    cfg.roiMaskManifest);

M = readtable(cfg.roiMaskManifest,'VariableNamingRule','preserve');

required = {'Session_ID','Mask_File','Residual_4D_File'};
assert(all(ismember(required,M.Properties.VariableNames)), ...
    'Manifest must contain: %s',strjoin(required,', '));

assert(height(M)==cfg.nSessions, ...
    'Expected %d HRF sessions in the manifest.',cfg.nSessions);

if ~isfolder(cfg.timecourseDir)
    mkdir(cfg.timecourseDir);
end

assert(exist('wwf_roi_tcours_old','file')==2, ...
    'Historical helper wwf_roi_tcours_old.m is required.');

for s = 1:height(M)

    sessionID = char(string(M.Session_ID(s)));
    maskFile = char(string(M.Mask_File(s)));
    residualFile = char(string(M.Residual_4D_File(s)));

    assert(isfile(maskFile),'Mask missing:\n%s',maskFile);
    assert(isfile(residualFile),'Residual 4-D file missing:\n%s',residualFile);

    [~,roidata] = wwf_roi_tcours_old(maskFile,residualFile);

    sessionDir = fullfile(cfg.timecourseDir,sessionID);
    if ~isfolder(sessionDir); mkdir(sessionDir); end

    outputFile = fullfile( ...
        sessionDir, ...
        sprintf('%s_%s_roidata.mat',cfg.regionLabel,cfg.maskSource));

    save(outputFile,'roidata');
end

end
