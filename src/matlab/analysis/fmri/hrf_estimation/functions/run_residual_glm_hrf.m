
function run_residual_glm_hrf(scans,covFile,explicitMask,cfg,outputDir)
% RUN_RESIDUAL_GLM_HRF Nuisance-only HRF GLM with residual-image output.
%
% This represents the manuscript HRF residual model:
% 14 nuisance regressors and no task regressors.

if ~isfolder(outputDir); mkdir(outputDir); end

clear matlabbatch

matlabbatch{1}.spm.stats.fmri_spec.dir = {outputDir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = cfg.TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = cfg.microtimeResolution;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = cfg.microtimeOnset;

matlabbatch{1}.spm.stats.fmri_spec.sess.scans = scans;
matlabbatch{1}.spm.stats.fmri_spec.sess.cond = ...
    struct('name',{},'onset',{},'duration',{},'tmod',{},'pmod',{},'orth',{});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{1}.spm.stats.fmri_spec.sess.regress = ...
    struct('name',{},'val',{});
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {covFile};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;

matlabbatch{1}.spm.stats.fmri_spec.fact = ...
    struct('name',{},'levels',{});
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
matlabbatch{1}.spm.stats.fmri_spec.mthresh = 0;
matlabbatch{1}.spm.stats.fmri_spec.mask = {explicitMask};
matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';

matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep( ...
    'fMRI model specification: SPM.mat File', ...
    substruct('.','val','{}',{1},'.','val','{}',{1},'.','val','{}',{1}), ...
    substruct('.','spmmat'));

% Explicitly request residuals instead of depending on an old modified SPM.
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 1;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

spm_jobman('run',matlabbatch);

end
