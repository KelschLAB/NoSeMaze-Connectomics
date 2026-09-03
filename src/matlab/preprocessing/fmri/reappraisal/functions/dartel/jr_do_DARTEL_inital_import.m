function jr_do_DARTEL_inital_import(Pcur, Pdir, voxsize)
% Pcur is a cell array with all _seg_sn.mat files
% Pdir is the output directory

job_DARTEL_initial_import

matlabbatch{1}.spm.tools.dartel.initial.matnames = [Pcur(:)];
matlabbatch{1}.spm.tools.dartel.initial.odir = cellstr(Pdir);
matlabbatch{1}.spm.tools.dartel.initial.vox = voxsize; 
matlabbatch{1}.spm.tools.dartel.initial.CSF = 1;
matlabbatch{1}.spm.tools.dartel.initial.bb = [NaN NaN NaN; NaN NaN NaN];%[-75 -110 -80; 69.4 80 20]%[-68 -106 22; 68 56 -87];%

spm_jobman('run',matlabbatch);