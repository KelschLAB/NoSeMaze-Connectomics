
function run_firstlevel_hrf_mask_glm( ...
    scans,regressors,covFile,explicitMask,cfg,outputDir)
% RUN_FIRSTLEVEL_HRF_MASK_GLM HRF odor GLM used to define individual masks.
%
% Preserves the contrast structure of do_firstlevel_GLM_hrf_jr:
%   1-4   F contrasts from the historical covariate batch template
%   5-7   individual odor conditions
%   8-10  pairwise odor contrasts
%   11    Odors_combined
%
% No parametric modulators are used in regressor version v1.

assert(numel(regressors)==3, ...
    'HRF mask GLM expects exactly three odor-duration regressors.');

assert(isfile(covFile),'Covariate MAT file not found:\n%s',covFile);
assert(isfile(explicitMask),'Explicit HRF mask not found:\n%s',explicitMask);

if ~isfolder(outputDir)
    mkdir(outputDir);
end

load(covFile,'R','names'); %#ok<LOAD>

ROI_size = numel(regressors); %#ok<NASGU>
PM_size = 0; %#ok<NASGU>
numberREG_rp = sum(contains(names,'rp')); %#ok<NASGU>
numberREG_csf = sum(contains(names,'csf')); %#ok<NASGU>

assert(exist('job_firstlevel_covariates_jr','file')==2, ...
    'job_firstlevel_covariates_jr.m is not on the path.');

clear matlabbatch
job_firstlevel_covariates_jr

matlabbatch{1}.spm.stats.fmri_spec.dir = {outputDir};
matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = cfg.TR;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = cfg.fmri_t;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = cfg.fmri_t0;

matlabbatch{1}.spm.stats.fmri_spec.sess.scans = scans;

% Remove the placeholder condition from the historical job, then rebuild.
matlabbatch{1}.spm.stats.fmri_spec.sess.cond = ...
    struct('name',{},'onset',{},'duration',{},'tmod',{},'pmod',{},'orth',{});

for i = 1:numel(regressors)

    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).name = ...
        regressors(i).name;

    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).onset = ...
        regressors(i).onset;

    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).duration = ...
        regressors(i).duration;

    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).tmod = 0;

    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).pmod = ...
        struct('name',{},'param',{},'poly',{});

    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(i).orth = cfg.orth;
end

matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {covFile};
matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = cfg.highPassSec;
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = cfg.hrfDerivatives;
matlabbatch{1}.spm.stats.fmri_spec.mask = {explicitMask};
matlabbatch{1}.spm.stats.fmri_spec.mthresh = cfg.maskThreshold;

nExisting = numel(matlabbatch{3}.spm.stats.con.consess);

% Individual odor contrasts.
for i = 1:3
    idx = nExisting + i;
    w = zeros(1,3);
    w(i) = 1;

    matlabbatch{3}.spm.stats.con.consess{idx}.tcon.name = ...
        regressors(i).name;
    matlabbatch{3}.spm.stats.con.consess{idx}.tcon.weights = w;
    matlabbatch{3}.spm.stats.con.consess{idx}.tcon.sessrep = 'none';
end

% Historical pairwise order.
pairs = [1 2; 1 3; 2 3];

for p = 1:size(pairs,1)

    idx = nExisting + 3 + p;
    a = pairs(p,1);
    b = pairs(p,2);

    w = zeros(1,3);
    w(a) = 1;
    w(b) = -1;

    matlabbatch{3}.spm.stats.con.consess{idx}.tcon.name = ...
        [regressors(a).name '>' regressors(b).name];

    matlabbatch{3}.spm.stats.con.consess{idx}.tcon.weights = w;
    matlabbatch{3}.spm.stats.con.consess{idx}.tcon.sessrep = 'none';
end

% Combined odor contrast. With the historical job template this is con_0011.
idx = nExisting + 7;
matlabbatch{3}.spm.stats.con.consess{idx}.tcon.name = cfg.maskContrastName;
matlabbatch{3}.spm.stats.con.consess{idx}.tcon.weights = [1 1 1];
matlabbatch{3}.spm.stats.con.consess{idx}.tcon.sessrep = 'none';

spm_jobman('run',matlabbatch);

end
