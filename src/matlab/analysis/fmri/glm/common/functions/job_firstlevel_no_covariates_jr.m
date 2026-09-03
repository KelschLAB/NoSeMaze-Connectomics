% job_firstlevel_no_covariates_jr.m
% Historical SPM12 first-level batch template without nuisance covariates.
% Original batch saved 26-Mar-2018; cleaned only for formatting.

matlabbatch{1}.spm.stats.fmri_spec.dir = {''};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 1.2;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = '';
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = '';

matlabbatch{1}.spm.stats.fmri_spec.sess.scans = {''};

matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'Lavendel';
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = [];
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod = ...
    struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).orth = 1;

matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = ...
    struct('name', {}, 'val', {});
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.fact = ...
    struct('name', {}, 'levels', {});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep( ...
    'fMRI model specification: SPM.mat File', ...
    substruct('.','val','{}',{1},'.','val','{}',{1},'.','val','{}',{1}), ...
    substruct('.','spmmat') ...
);
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep( ...
    'fMRI model specification: SPM.mat File', ...
    substruct('.','val','{}',{1},'.','val','{}',{1},'.','val','{}',{1}), ...
    substruct('.','spmmat') ...
);

matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'EffectsOfInterest';
matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = ...
    eye(ROI_size + PM_size);
matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';

matlabbatch{3}.spm.stats.con.delete = 0;
