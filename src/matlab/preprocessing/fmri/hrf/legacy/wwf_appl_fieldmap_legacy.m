
function res=wwf_appl_fieldmap(Pfmdir,Pfunci,P3di)
PB0map=spm_select('ExtFPlist',Pfmdir,'^full_fpm_.*_cf_spm2.img',1);
Pmagmap=spm_select('ExtFPlist',[Pfmdir '/p2'],'^ZI.*_acq0_reorient_cf.nii',1);
[fdir,~,~]=fileparts(Pfunci);
hdrfile=spm_select('FPlist',fdir,'.*.brkhdr');
hdr=readBrukerParamFile(hdrfile);
Epitime=hdr.PVM_EpiEchoSpacing*hdr.PVM_EpiNEchoes;
job_create_vdm
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.precalcfieldmap{1}=PB0map;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.magfieldmap{1}=Pmagmap;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.session.epi{1}=Pfunci;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.tert=Epitime;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.blipdir=-1;
if nargin >=3
    matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.anat{1}=P3di;
end
spm_jobman('run',matlabbatch);
res=1;
end
