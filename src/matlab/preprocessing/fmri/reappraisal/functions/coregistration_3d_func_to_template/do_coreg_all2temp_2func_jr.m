function res=do_coreg_all2temp_2func_jr(P3dbrain,P3d_whole,Pfunc,Pfunc2,Ptemp)
start=pwd;
if nargin < 1
    P3dbrain=spm_select(1, 'image', '3D-Data (non brain extracted)');
end

if nargin < 2
    Pfunc=spm_select(1, 'image', 'Functional data');
end

if nargin < 3
    Pfunc=spm_select(1, 'image', 'Template');
end

[fdir, fname1, ext]=fileparts(Pfunc);
Pfunc_simp=spm_select('FPlist',fdir,['^' fname1 '.nii']);

[fdir, fname2, ext]=fileparts(Pfunc_simp);
Pfunc_simp_cor=[fdir filesep fname2 '_c2t' ext];
ppt_resave(Pfunc_simp,Pfunc_simp_cor);

[fdir, fname3, ext]=fileparts(P3dbrain);
P3d_simp=spm_select('FPlist',fdir,['^' fname3 '.nii$']);
P3dbrain_cor=[fdir filesep fname3 '_c2t.nii'];
ppt_resave(P3d_simp,P3dbrain_cor);

[fdir, fname4, ext]=fileparts(P3d_whole);
P3d_whole=spm_select('FPlist',fdir,['^' fname4 '.nii$']);
P3d_whole_cor=[fdir filesep fname4 '_c2t' '.nii'];
ppt_resave(P3d_whole,P3d_whole_cor);

[fdir, fname5, ext]=fileparts(Pfunc2);
Pfunc_simp2=spm_select('FPlist',fdir,['^' fname5 '.nii']);

[fdir, fname6, ext]=fileparts(Pfunc_simp2);
Pfunc_simp_cor2=[fdir filesep fname6 '_c2t' ext];
ppt_resave(Pfunc_simp2,Pfunc_simp_cor2);

[fdir, fname7, ext]=fileparts(Pfunc_simp_cor);
Pfuncall1=spm_select('ExtFPlist',fdir,['^' fname7 '.nii'],[1:2500]);

[fdir, fname8, ext]=fileparts(Pfunc_simp_cor2);
Pfuncall2=spm_select('ExtFPlist',fdir,['^' fname8 '.nii'],[1:2500]);

[fdir, fname9, ext]=fileparts(P3dbrain_cor);
P3dbrain_cor=spm_select('ExtFPlist',fdir,['^' fname9 '.nii'],1);

Nvol1=size(Pfuncall1,1);
Nvol2=size(Pfuncall2,1);
%also consider hdr.PVM_EpiModuleTime

job_coreg_bad23dtemp %% <-<-<-BE SURE TO USE THE CORRECT JOB FOR YOUR DATA%%
matlabbatch{1}.spm.spatial.coreg.estimate.ref{1}=Ptemp;
matlabbatch{1}.spm.spatial.coreg.estimate.source= {deblank(P3dbrain_cor(1,:))};
matlabbatch{1}.spm.spatial.coreg.estimate.other={}; % CC added 171020 - because the former resulted in a mixture of volumes from different studies!!
matlabbatch{1}.spm.spatial.coreg.estimate.other{1,1}=deblank(P3d_whole_cor(1,:));
matlabbatch{1}.spm.spatial.coreg.estimate.other(2:(Nvol1+Nvol2+1),1)=[cellstr(Pfuncall1);cellstr(Pfuncall2)]; %<-the batch wanted to take all 396 as one single block volume

spm_jobman('run',matlabbatch);




