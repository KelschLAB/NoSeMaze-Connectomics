% Generic SPM FieldMap batch template.
% Subject-specific field map, magnitude image, EPI, anatomical image,
% total EPI readout time, and blip direction are populated by the wrapper.

matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.precalcfieldmap = {''};
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.magfieldmap = {''};
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.et = [4 6];
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.maskbrain = 0;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.blipdir = -1;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.tert = 0;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.epifm = 0;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.ajm = 0;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.uflags.method = 'Mark3D';
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.uflags.fwhm = 10;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.uflags.pad = 0;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.uflags.ws = 1;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.mflags.template = { ...
    fullfile(spm('Dir'),'canonical','avg152T1.nii') ...
};
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.mflags.fwhm = 5;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.mflags.nerode = 2;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.mflags.ndilate = 4;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.mflags.thresh = 0.5;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.defaults.defaultsval.mflags.reg = 0.02;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.session.epi = {''};
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.matchvdm = 0;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.sessname = 'session';
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.writeunwarped = 1;
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.anat = {''};
matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj.matchanat = 0;
