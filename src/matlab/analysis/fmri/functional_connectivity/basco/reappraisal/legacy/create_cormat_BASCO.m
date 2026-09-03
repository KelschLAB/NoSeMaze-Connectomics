function create_cormat_BASCO(Pfunc_all, cfg)
%CREATE_CORMAT_BASCO Create ROI-wise correlation matrices from beta series.
%
% Subject ordering is taken explicitly from Pfunc_all instead of relying on
% a wildcard such as "ZI*", making the output deterministic.

assert(isfile(cfg.atlas.labels), 'Missing atlas labels: %s', cfg.atlas.labels);
assert(isfile(cfg.atlas.nifti),  'Missing atlas NIfTI: %s', cfg.atlas.nifti);
assert(exist('wwf_covmat_hres_jr', 'file') == 2, ...
    ['wwf_covmat_hres_jr.m is not on the MATLAB path. Copy/refactor this ' ...
     'legacy helper before running correlation-matrix creation.']);

ensure_dir(cfg.paths.cormat_dir);
ensure_dir(cfg.paths.beta4D_dir);
ensure_dir(cfg.paths.matrix_dir);
ensure_dir(cfg.paths.roidata_dir);

%% Discover available beta-series suffixes from the first session
[~, first_name] = fileparts(Pfunc_all{1});
first_subject = subject_abbrev(first_name);
prefix = sprintf('%s_betaseries_%s_', first_subject, cfg.version.basco);
files = dir(fullfile(cfg.paths.beta4D_dir, [prefix '*.nii']));
assert(~isempty(files), ...
    'No beta-series NIfTIs found for %s in %s', ...
    first_subject, cfg.paths.beta4D_dir);

suffix_list = cell(numel(files), 1);
for ii = 1:numel(files)
    suffix_list{ii} = erase(files(ii).name, prefix);
    suffix_list{ii} = erase(suffix_list{ii}, '.nii');
end
suffix_list = sort(unique(suffix_list));

%% Correlation matrices
for jx = 1:numel(suffix_list)
    suffix = suffix_list{jx};
    Pcur_cell = cell(numel(Pfunc_all), 1);

    for subj = 1:numel(Pfunc_all)
        [~, fname] = fileparts(Pfunc_all{subj});
        subj_abbrev = subject_abbrev(fname);
        beta_file = fullfile(cfg.paths.beta4D_dir, sprintf( ...
            '%s_betaseries_%s_%s.nii', subj_abbrev, ...
            cfg.version.basco, suffix));
        assert(isfile(beta_file), ...
            'Missing beta-series file for %s: %s', subj_abbrev, beta_file);
        Pcur_cell{subj} = beta_file;
    end

    Pcur = char(Pcur_cell);
    [cormat, subj] = wwf_covmat_hres_jr( ...
        cfg.atlas.labels, Pcur, cfg.atlas.nifti);

    matrix_file = fullfile(cfg.paths.matrix_dir, sprintf( ...
        'cormat_%s_%s.mat', cfg.version.basco, suffix));
    roi_file = fullfile(cfg.paths.roidata_dir, sprintf( ...
        'roidata_%s_%s.mat', cfg.version.basco, suffix));

    save(matrix_file, 'cormat', '-v7.3');
    save(roi_file, 'subj', '-v7.3');

    fprintf('Saved %s\n', matrix_file);
end
end

function s = subject_abbrev(fname)
underscore = strfind(fname, '_');
assert(numel(underscore) >= 2, ...
    'Cannot derive subject abbreviation from filename: %s', fname);
s = fname(1:underscore(2)-1);
end

function ensure_dir(p)
if ~isfolder(p)
    mkdir(p);
end
end
