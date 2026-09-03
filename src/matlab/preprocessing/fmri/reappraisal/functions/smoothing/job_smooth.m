% Generic SPM smoothing batch template.
% Subject-specific data, FWHM, and prefix are set by do_smooth_lw.m.

matlabbatch{1}.spm.spatial.smooth.data = {};
matlabbatch{1}.spm.spatial.smooth.fwhm = [0.6 0.6 0.6];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 0;
matlabbatch{1}.spm.spatial.smooth.prefix = 's6_';
