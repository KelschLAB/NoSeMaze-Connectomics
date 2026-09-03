function res=do_slice_time_reappraisal_jr(Pfunc)
start=pwd;
if nargin < 1
    Pfunc=spm_select(inf, 'dir', 'Functional data');
end


[fdir fname ext]=fileparts(Pfunc);
Pfuncall=spm_select('ExtFPlist',fdir,['^' fname],[1:2500]);
%also consider hdr.PVM_EpiModuleTime

job_slice_time
matlabbatch{1}.spm.temporal.st.scans{1}=cellstr(Pfuncall);
matlabbatch{1}.spm.temporal.st.prefix = 'a1_';
matlabbatch{1}.spm.temporal.st.nslices = 22;
matlabbatch{1}.spm.temporal.st.tr = 1.2;
matlabbatch{1}.spm.temporal.st.ta = 1.2-(1.2/22); % TR-(TR/slices)
matlabbatch{1}.spm.temporal.st.so = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22];
matlabbatch{1}.spm.temporal.st.refslice = 1;

spm_jobman('run',matlabbatch);

