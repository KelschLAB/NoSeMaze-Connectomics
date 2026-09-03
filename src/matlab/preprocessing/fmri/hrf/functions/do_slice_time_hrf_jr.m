
function matlabbatch = do_slice_time_hrf_jr(Pfunc)
% DO_SLICE_TIME_HRF_JR Slice-time correction for the ultrafast HRF cohort.
%
% Historical settings:
%   nslices   = 6
%   TR        = 0.265 s
%   TA        = TR - TR/6
%   order     = [1 2 3 4 5 6]
%   reference = slice 1
%   prefix    = a1_
%
% Unlike the historical helper, this implementation constructs the SPM
% batch directly and expands the exact number of volumes present instead
% of requesting 1:20000.

if nargin < 1 || isempty(Pfunc)
    error('A functional 4-D NIfTI is required.');
end

Pfunc = regexprep(strtrim(char(Pfunc)),',\d+$','');

assert(isfile(Pfunc),'Functional NIfTI missing:\n%s',Pfunc);

V = spm_vol(Pfunc);
nVolumes = numel(V);

scans = cell(nVolumes,1);
for i = 1:nVolumes
    scans{i} = sprintf('%s,%d',Pfunc,i);
end

TR = 0.265;
nSlices = 6;

clear matlabbatch

matlabbatch{1}.spm.temporal.st.scans = {scans};
matlabbatch{1}.spm.temporal.st.nslices = nSlices;
matlabbatch{1}.spm.temporal.st.tr = TR;
matlabbatch{1}.spm.temporal.st.ta = TR-(TR/nSlices);
matlabbatch{1}.spm.temporal.st.so = 1:nSlices;
matlabbatch{1}.spm.temporal.st.refslice = 1;
matlabbatch{1}.spm.temporal.st.prefix = 'a1_';

spm_jobman('run',matlabbatch);

end
