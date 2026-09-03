function do_smoothSpecific_jr(Pcur,fwhm)

[fdir fname ext]=fileparts(Pcur);
Pcurn=spm_select('ExtFPlist',fdir,['^' fname '.nii$'],[1:5000]);

job_smooth;

matlabbatch{1}.spm.spatial.smooth.data=cellstr(Pcurn);
matlabbatch{1}.spm.spatial.smooth.fwhm = [fwhm];
matlabbatch{1}.spm.spatial.smooth.prefix = 's6_'

spm_jobman('run',matlabbatch);  