function res=wwf_fix_fm_offset(Pmap,P3d)
%fix the offset in the fieldmaps of PV360
% - Create brainmask on P3d
% - Reslice to Fieldmap Resolution
% - Erode 6-8 Times to catch more the center of the brain
% extract fieldmap date in mask, create median and deduct
% from fieldmap.
addExtractBrain;
%1. Creat Brainmask
ms_do_brainExtraction(P3d);
[fp, fn, fext]=fileparts(P3d);
Pmsk=[fp filesep fn '_brainmask' fext];
if ~exist(Pmsk,'file'), keyboard, end
%2. Reslice mask
matlabbatch=job_reslice_mask;
matlabbatch{1}.spm.spatial.coreg.write.ref{1}=Pmap;
matlabbatch{1}.spm.spatial.coreg.write.source{1}=Pmsk;
spm_jobman('run',matlabbatch);
Pmsk_r=[fp filesep 'rfm_' fn '_brainmask' fext];
if ~exist(Pmsk_r,'file'), keyboard, end
%3. Erode Mask
Vmsk=spm_vol(Pmsk_r);
mtx_msk=spm_read_vols(Vmsk);
p.DilateNum=0;
p.ErodeNum=6;
mtx_msk_er=wwf_polish_mask2(mtx_msk,p);
[fp, fn, fext]=fileparts(Pmap);
Pmsk_er=[fp filesep 'erodedBrainMask.nii'];
Vo=Vmsk;
Vo.fname=Pmsk_er;
spm_write_vol(Vo,mtx_msk_er>0.5);
%4. Calculate median and write down new Fieldmap
Vfm=spm_vol(Pmap);
mtxmap=spm_read_vols(Vfm);
mtxmsk=spm_read_vols(spm_vol(Pmsk_er));
offset=median(mtxmap(mtxmsk>0));
offset_mean=mean(mtxmap(mtxmsk>0));
fprintf('Offset mean/median:  %6.2f Hz/ %6.2f Hz\n',offset_mean,offset);
fprintf('%s Offset: %6.2f Hz\n',Pmap,offset);
Vo=Vfm;
Vo.fname=[fp filesep 'fpm_ofix_' fn fext];
spm_write_vol(Vo,mtxmap-offset);
res=Vo.fname;
%create the spm2 version for the gui
nii2ana(Vo.fname);
end


function matlabbatch=job_reslice_mask
%-----------------------------------------------------------------------
% Job saved on 27-Sep-2022 14:59:54 by cfg_util (rev $Rev: 6134 $)
% spm SPM - SPM12 (6225)
% cfg_basicio BasicIO - Unknown
% cfg_ppt_root PostProc - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.spatial.coreg.write.ref = {''};
matlabbatch{1}.spm.spatial.coreg.write.source = {''};
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'rfm_';
end