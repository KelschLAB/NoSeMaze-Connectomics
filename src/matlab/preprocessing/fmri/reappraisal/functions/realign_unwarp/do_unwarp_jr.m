function res=do_unwarp_jr(Pfmdir,Pfunc)
start=pwd;
if nargin < 1
    Pfmdir=spm_select(inf, 'dir', 'Field-Map');
end

if nargin < 1
    Pfunc=spm_select(inf, 'dir', 'Functional data');
end

PB0map=spm_select('ExtFPlist',Pfmdir,'^vdm5_fpm_ofix_full_.*_spm2.img',1)                  


[fdir fname ext]=fileparts(Pfunc);
Pfuncall=spm_select('ExtFPlist',fdir,['^' fname],[1:15000]);                    
%also consider hdr.PVM_EpiModuleTime

job_unwarp

 matlabbatch{1}.spm.spatial.realignunwarp.data.scans=cellstr(Pfuncall);
 matlabbatch{1}.spm.spatial.realignunwarp.data.pmscan=cellstr(PB0map);
 matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm = 0; %1=register to mean; 0=register to first
 matlabbatch{1}.spm.spatial.realignunwarp.uwroptions.prefix = 'u_';



spm_jobman('run',matlabbatch);