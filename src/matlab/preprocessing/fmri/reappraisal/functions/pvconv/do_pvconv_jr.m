function do_pvconv_jr(indir,outdir,name)

P=spm_select('FPList',indir,'dir',['^' name])

matlabbatch{1}.cfg_ppt_root{1}.pvconv.indir = cellstr(P);
matlabbatch{1}.cfg_ppt_root{1}.pvconv.outdir = cellstr(outdir);
matlabbatch{1}.cfg_ppt_root{1}.pvconv.serpattern = '[all]';
matlabbatch{1}.cfg_ppt_root{1}.pvconv.options.outspace = 'reorient';
matlabbatch{1}.cfg_ppt_root{1}.pvconv.options.reorienttype = 'default';
matlabbatch{1}.cfg_ppt_root{1}.pvconv.options.interclear = true;

% spm_jobman('initcfg')
spm_jobman('run',matlabbatch);