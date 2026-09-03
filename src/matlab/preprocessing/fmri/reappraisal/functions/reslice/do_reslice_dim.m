function do_reslice_dim(Pinput,interp,dimensions)
job_reslice
matlabbatch{1}.spm.spatial.realign.write.data = Pinput;
matlabbatch{1}.spm.spatial.realign.write.roptions.which = [1 0];
matlabbatch{1}.spm.spatial.realign.write.roptions.interp = interp;
matlabbatch{1}.spm.spatial.realign.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.realign.write.roptions.prefix = ['r' num2str(dimensions)];
spm_jobman('run',matlabbatch);
1==1;