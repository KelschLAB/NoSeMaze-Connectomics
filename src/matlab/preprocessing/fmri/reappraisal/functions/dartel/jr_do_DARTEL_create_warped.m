function jr_do_DARTEL_create_warped(Pcur1,Pcur2,Pcur3)

job_DARTEL_create_warped

matlabbatch{1}.spm.tools.dartel.crt_warped.flowfields = Pcur1;
matlabbatch{1}.spm.tools.dartel.crt_warped.images = {Pcur2,Pcur3};
matlabbatch{1}.spm.tools.dartel.crt_warped.jactransf = 0; % modulated or not
    
spm_jobman('run',matlabbatch);