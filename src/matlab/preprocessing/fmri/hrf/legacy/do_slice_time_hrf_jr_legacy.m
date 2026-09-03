
function res=do_slice_time_hrf_jr(Pfunc)
[fdir,fname,~]=fileparts(Pfunc);
Pfuncall=spm_select('ExtFPlist',fdir,['^' fname],[1:20000]);
job_slice_time
matlabbatch{1}.spm.temporal.st.scans{1}=cellstr(Pfuncall);
matlabbatch{1}.spm.temporal.st.prefix='a1_';
matlabbatch{1}.spm.temporal.st.nslices=6;
matlabbatch{1}.spm.temporal.st.tr=0.265;
matlabbatch{1}.spm.temporal.st.ta=0.265-(0.265/6);
matlabbatch{1}.spm.temporal.st.so=[1 2 3 4 5 6];
matlabbatch{1}.spm.temporal.st.refslice=1;
spm_jobman('run',matlabbatch);
res=1;
end
