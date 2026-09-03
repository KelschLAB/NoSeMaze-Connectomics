
function fileList = build_hrf_filelist(cfg)
% BUILD_HRF_FILELIST Reconstruct Pfunc/P3d/Pdmap from the HRF scan list.
%
% The historical scan list contained six columns in this order:
%   subject ID, subject name, study, examination, series, image comment.
%
% The output preserves the historical variables required by preprocessing:
%   Pfunc, Pfunc_subjName, P3d, Pdmap.

assert(isfile(cfg.scanList), ...
    'HRF scan list not found:\n%s',cfg.scanList);

assert(isfolder(cfg.convertedDir), ...
    'Converted HRF directory not found:\n%s',cfg.convertedDir);

T = readtable(cfg.scanList,'VariableNamingRule','preserve');

assert(width(T) >= 5, ...
    'HRF scan list must contain at least five columns.');

subjID = string(T{:,1});
subjName = string(T{:,2});
examn = string(T{:,4});
series = T{:,5};

nii = dir(fullfile(cfg.convertedDir,'**','*reorient.nii'));
niiPaths = string(fullfile({nii.folder},{nii.name}))';

isEpi = examn == "EPI paradigma (E5)";
is3d = contains(examn,"TurboRARE3D_Awake_biggerFOV (E6)");
isFmap = examn == "Fieldmap (E4)";

Pfunc = strings(sum(isEpi),1);
Pfunc_subjName = strings(sum(isEpi),1);
P3d = strings(sum(is3d),1);
Pdmap = strings(sum(isFmap),1);

epiRows = find(isEpi);
for k = 1:numel(epiRows)
    row = epiRows(k);
    hit = find_matching_scan(niiPaths,subjID(row),series(row));
    Pfunc(k) = hit;
    Pfunc_subjName(k) = subjName(row);
end

anRows = find(is3d);
for k = 1:numel(anRows)
    row = anRows(k);
    P3d(k) = find_matching_scan(niiPaths,subjID(row),series(row));
end

fmRows = find(isFmap);
for k = 1:numel(fmRows)
    row = fmRows(k);
    hit = find_matching_scan(niiPaths,subjID(row),series(row));

    % Historical Pdmap stored the field-map directory rather than the NIfTI.
    Pdmap(k) = string(fileparts(hit));
end

assert(numel(Pfunc)==numel(P3d) && numel(Pfunc)==numel(Pdmap), ...
    ['HRF EPI/anatomical/field-map counts do not match: ' ...
     'EPI=%d, 3D=%d, fieldmap=%d.'], ...
    numel(Pfunc),numel(P3d),numel(Pdmap));

if ~isfolder(cfg.fileListDir)
    mkdir(cfg.fileListDir);
end

fileList = struct();
fileList.Pfunc = cellstr(Pfunc);
fileList.Pfunc_subjName = cellstr(Pfunc_subjName);
fileList.P3d = cellstr(P3d);
fileList.Pdmap = cellstr(Pdmap);

Pfunc = fileList.Pfunc; %#ok<NASGU>
Pfunc_subjName = fileList.Pfunc_subjName; %#ok<NASGU>
P3d = fileList.P3d; %#ok<NASGU>
Pdmap = fileList.Pdmap; %#ok<NASGU>

save(cfg.fileList,'Pfunc','Pfunc_subjName','P3d','Pdmap');

end

function hit = find_matching_scan(paths,subjectID,seriesNumber)

seriesToken = [filesep char(string(seriesNumber)) filesep];

keep = contains(paths,subjectID) & contains(paths,seriesToken);

matches = paths(keep);

assert(numel(matches)==1, ...
    'Expected one scan for %s series %s; found %d.', ...
    subjectID,string(seriesNumber),numel(matches));

hit = matches(1);

end
