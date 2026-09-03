function res=wwf_appl_fieldmap(Pfmdir,Pfunci,P3di)
start=pwd;
if nargin < 1
    Pfmdir=spm_select(inf, 'dir', 'Field-Map');
end

if nargin < 1
    Pfunci=spm_select(inf, 'dir', 'Functional data');
end

PB0map=spm_select('ExtFPlist',Pfmdir,'^full_fpm_.*spm2.img',1)
% PB0map=spm_select('FPlist',Pfmdir,'^fpm_.*spm2.img')
Pmagmap=spm_select('ExtFPlist',fullfile(Pfmdir,'p2'),'^ZI.*_acq0_reorient.nii',1)
save Pmagmap
[fdir, fname, ext]=fileparts(Pfunci)
hdrfile=spm_select('FPlist',fdir,'.*.brkhdr');
hdr=readBrukerParamFile(hdrfile);
Epitime=hdr.PVM_EpiEchoSpacing*hdr.PVM_EpiNEchoes
% Pfuncii=[Pfunci ',1'];
%also consider hdr.PVM_EpiModuleTime
job_create_vdm

matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.precalcfieldmap{1}=PB0map;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.magfieldmap{1}=Pmagmap;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.session.epi{1}=Pfunci;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.tert=Epitime;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.blipdir=-1;
if nargin >=3
     matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.anat{1}=P3di
end

spm_jobman('run',matlabbatch);
spm_print