function res=do_coreg_func23d_lw(P3d,Pfunc)
start=pwd;
if nargin < 1
    P3d=spm_select(1, 'image', '3D-Data (non brain extracted)');
end

if nargin < 1
    Pfunc=spm_select(1, 'image', 'Functional data');
end

[fdir fname1 ext]=fileparts(Pfunc);
% Pfuncmean=spm_select('FPlist',fdir,['^meanuZI.*reorient.nii']);
Pfuncmean=spm_select('FPlist',fdir,['^meanu_despiked.*reorient.nii']); %2014_Pain
Pfunc_simp=spm_select('FPlist',fdir,['^' fname1 '.nii']);

[fdir fname2 ext]=fileparts(Pfuncmean);
Pfuncmean_cor=[fdir filesep fname2 '_c1' ext];
ppt_resave(Pfuncmean,Pfuncmean_cor);

[fdir fname3 ext]=fileparts(Pfunc_simp);
Pfunc_simp_cor=[fdir filesep fname3 '_c1' ext];
ppt_resave(Pfunc_simp,Pfunc_simp_cor);


[fdir fname4 ext]=fileparts(Pfunc_simp_cor);
Pfuncall=spm_select('ExtFPlist',fdir,['^' fname4 '.nii'],[1:2500]);

[fdir fname5 ext]=fileparts(P3d);
P3dbrain=spm_select('ExtFPlist',fdir,['^' fname5 '.nii'],1);


%also consider hdr.PVM_EpiModuleTime

job_coreg_func23d
matlabbatch{1}.spm.spatial.coreg.estimate.ref{1}=P3dbrain;
matlabbatch{1}.spm.spatial.coreg.estimate.source{1}=Pfuncmean_cor;
matlabbatch{1}.spm.spatial.coreg.estimate.other=cellstr(Pfuncall);


spm_jobman('run',matlabbatch);