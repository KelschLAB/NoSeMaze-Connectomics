function do_firstlevel_jr(Pfuncall,ROI,COV,DerDisp,explicit_mask,fmri_t,fmri_t0,TR,outputDir,mask_thres,orth)
% DO_FIRSTLEVEL_JR Run one subject-level SPM GLM.
%
% Required batch templates (copy into this functions folder):
%   job_firstlevel_covariates_jr.m
%   job_firstlevel_no_covariates_jr.m
%
% Scientific model logic is retained from the historical function; only
% path-independent validation and ambiguous logical comparisons were cleaned.

if nargin < 1 || isempty(Pfuncall); Pfuncall = spm_select; end
if nargin < 2; ROI = []; end
if nargin < 3; COV = ''; end
if nargin < 4 || isempty(DerDisp); DerDisp = [0 0]; end
if nargin < 5; explicit_mask = ''; end

if ~isequal(DerDisp,[0 0]) && ~isequal(DerDisp,[1 1])
    error('DerDisp must be [0 0] or [1 1].');
end

clear matlabbatch

%% Quantities used by the historical job templates
if isequal(DerDisp,[0 0])
    ROI_size = length(ROI); %#ok<NASGU>
    if isfield(ROI,'PM')
        PM_size = length([ROI.PM]); %#ok<NASGU>
    else
        PM_size = 0; %#ok<NASGU>
    end
else
    ROI_size = length(ROI).*3; %#ok<NASGU>
    if isfield(ROI,'PM')
        PM_size = length([ROI.PM]).*3; %#ok<NASGU>
    else
        PM_size = 0; %#ok<NASGU>
    end
end

%% Load historical SPM batch template
if ~isempty(COV)
    if ~isfile(COV)
        error('Covariate file not found:\n%s',COV);
    end
    load(COV,'R','names'); %#ok<LOAD>
    numberREG_rp = sum(contains(names,'rp')); %#ok<NASGU>
    numberREG_csf = sum(contains(names,'csf') | contains(names,'FD')); %#ok<NASGU>

    if isempty(which('job_firstlevel_covariates_jr'))
        error('Missing job_firstlevel_covariates_jr.m');
    end
    job_firstlevel_covariates_jr
else
    if isempty(which('job_firstlevel_no_covariates_jr'))
        error('Missing job_firstlevel_no_covariates_jr.m');
    end
    job_firstlevel_no_covariates_jr
end

%% Definitions
numb_contrasts_job = length(matlabbatch{3}.spm.stats.con.consess);

matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(Pfuncall);

%% Regressors of interest
for ix = 1:length(ROI)
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).name = ROI(ix).name;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).onset = ROI(ix).values;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).duration = ROI(ix).duration;
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).tmod = 0;

    hasPM = isfield(ROI(ix),'PM') && ~isempty(ROI(ix).PM);

    if ~hasPM
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).pmod = ...
            struct('name', {}, 'param', {}, 'poly', {});
    else
        for jx = 1:length(ROI(ix).PM)
            matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).pmod(jx).name = ...
                ['PM_' ROI(ix).name '_by_' ROI(ix).PM(jx).name];
            matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).pmod(jx).param = ...
                ROI(ix).PM(jx).vector;
            matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).pmod(jx).poly = 1;
        end
    end
    matlabbatch{1}.spm.stats.fmri_spec.sess.cond(ix).orth = orth;
end

%% Nuisance covariates
if ~isempty(COV)
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = {COV};
end

matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = DerDisp;
matlabbatch{1}.spm.stats.fmri_spec.mask = {explicit_mask};
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = fmri_t0;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = fmri_t;
matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;
matlabbatch{1}.spm.stats.fmri_spec.dir = {outputDir};
matlabbatch{1}.spm.stats.fmri_spec.mthresh = mask_thres;

%% Contrasts for regressors / PMs
counter = 1;

if isfield(ROI,'PM')
    if isequal(DerDisp,[0 0])
        zero_mat = zeros((length(ROI)+length([ROI.PM])),1);
    else
        zero_mat = zeros((length(ROI)+length([ROI.PM]))*3,1);
    end
else
    if isequal(DerDisp,[0 0])
        zero_mat = zeros(length(ROI),1);
    else
        zero_mat = zeros(length(ROI)*3,1);
    end
end

if isequal(DerDisp,[0 0])
    for ix = 1:size(ROI,2)
        matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.name = ROI(ix).name;
        help_mat = zero_mat;
        help_mat(counter) = 1;
        matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.weights = help_mat;
        matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.sessrep = 'none';
        counter = counter + 1;

        if isfield(ROI(ix),'PM') && ~isempty(ROI(ix).PM)
            for jx = 1:length(ROI(ix).PM)
                matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.name = ...
                    ['PM_' ROI(ix).name '_by_' ROI(ix).PM(jx).name];
                help_mat = zero_mat;
                help_mat(counter) = 1;
                matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.weights = help_mat;
                matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.sessrep = 'none';
                counter = counter + 1;
            end
        end
    end
else
    for ix = 1:size(ROI,2)
        for jx = 1:3
            suffix = {'','_Deriv','_Disp'};
            matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.name = ...
                [ROI(ix).name suffix{jx}];
            help_mat = zero_mat;
            help_mat(counter) = 1;
            matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.weights = help_mat;
            matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.sessrep = 'none';
            counter = counter + 1;
        end

        if isfield(ROI(ix),'PM') && ~isempty(ROI(ix).PM)
            for jx = 1:length(ROI(ix).PM)
                for kx = 1:3
                    suffix = {'','_Deriv','_Disp'};
                    matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.name = ...
                        ['PM_' ROI(ix).name '_by_' ROI(ix).PM(jx).name suffix{kx}];
                    help_mat = zero_mat;
                    help_mat(counter) = 1;
                    matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.weights = help_mat;
                    matlabbatch{3}.spm.stats.con.consess{numb_contrasts_job+counter}.tcon.sessrep = 'none';
                    counter = counter + 1;
                end
            end
        end
    end
end

% Retain historical dependency target until the job templates are inspected.
matlabbatch{3}.spm.stats.con.spmmat = cfg_dep( ...
    'fMRI model specification: SPM.mat File', ...
    substruct('.','val','{}',{1},'.','val','{}',{1},'.','val','{}',{1}), ...
    substruct('.','spmmat'));

%% Contrast metadata
contrast_info.names = cell(1,length(matlabbatch{3}.spm.stats.con.consess));
contrast_info.test  = cell(1,length(matlabbatch{3}.spm.stats.con.consess));

for contrastIdx = 1:length(matlabbatch{3}.spm.stats.con.consess)
    current = matlabbatch{3}.spm.stats.con.consess{contrastIdx};
    if isfield(current,'fcon')
        contrast_info.names{contrastIdx} = current.fcon.name;
        contrast_info.test{contrastIdx} = 'fcon';
    elseif isfield(current,'tcon')
        contrast_info.names{contrastIdx} = current.tcon.name;
        contrast_info.test{contrastIdx} = 'tcon';
    end
end

[fdir,~,~] = fileparts(outputDir);
contrastInfoFile = fullfile(fdir,'contrast_info.mat');

if isfile(contrastInfoFile)
    old = load(contrastInfoFile,'contrast_info');
    if ~isequal(old.contrast_info,contrast_info)
        error('Contrast definitions differ between subjects.');
    end
else
    save(contrastInfoFile,'contrast_info');
end

spm_jobman('run',matlabbatch);

end
