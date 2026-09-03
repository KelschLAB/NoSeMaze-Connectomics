% Generic SPM slice-timing batch template.
% Subject scans and final acquisition parameters are populated by
% do_slice_time_reappraisal_jr.m.

matlabbatch{1}.spm.temporal.st.scans = {{''}};
matlabbatch{1}.spm.temporal.st.nslices = 22;
matlabbatch{1}.spm.temporal.st.tr = 1.2;
matlabbatch{1}.spm.temporal.st.ta = 1.2-(1.2/22);
matlabbatch{1}.spm.temporal.st.so = 1:22;
matlabbatch{1}.spm.temporal.st.refslice = 1;
matlabbatch{1}.spm.temporal.st.prefix = 'a1_';
