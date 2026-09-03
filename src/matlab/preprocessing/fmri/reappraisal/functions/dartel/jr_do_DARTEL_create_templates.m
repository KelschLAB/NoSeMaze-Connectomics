function jr_do_DARTEL_create_templates(Pcur1,Pcur2)

job_DARTEL_create_templates

matlabbatch{1}.spm.tools.dartel.warp.images = {cellstr(Pcur1),cellstr(Pcur2)}%[Pcur1; Pcur2];

spm_jobman('run',matlabbatch);