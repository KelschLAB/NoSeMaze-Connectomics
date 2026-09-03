
function outputFile = merge_residuals_hrf(sessionDir,deleteOriginals)
% MERGE_RESIDUALS_HRF Concatenate SPM ResI_*.nii files into one 4-D NIfTI.
%
% Cleaned version of merge_residuals_jr:
% - no GUI directory selection
% - explicit session directory
% - full output filename
% - deletion is opt-in rather than automatic

if nargin < 2
    deleteOriginals = false;
end

D = dir(fullfile(sessionDir,'ResI_*.nii'));
assert(~isempty(D),'No ResI_*.nii files found in:\n%s',sessionDir);

[~,order] = sort({D.name});
D = D(order);

P = fullfile({D.folder},{D.name})';

[~,sessionID] = fileparts(sessionDir);
outputFile = fullfile(sessionDir,['4D_residuals_' sessionID '.nii']);

clear matlabbatch

matlabbatch{1}.spm.util.cat.vols = P;
matlabbatch{1}.spm.util.cat.name = outputFile;
matlabbatch{1}.spm.util.cat.dtype = 0;

spm_jobman('run',matlabbatch);

if deleteOriginals
    for i = 1:numel(D)
        delete(fullfile(D(i).folder,D(i).name));
    end
end

end
