
function scans = expand_4d_nifti(niftiFile)
% EXPAND_4D_NIFTI Return SPM volume references for all volumes in a 4-D NIfTI.

assert(isfile(niftiFile),'NIfTI not found:\n%s',niftiFile);

V = spm_vol(niftiFile);
nVol = numel(V);

scans = cell(nVol,1);
for i = 1:nVol
    scans{i} = sprintf('%s,%d',niftiFile,i);
end

end
