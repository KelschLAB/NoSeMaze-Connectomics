function create_input_BASCO(Pfunc_all, cfg)
%CREATE_INPUT_BASCO Prepare per-session BASCO inputs and metainfo.

if ~isfolder(cfg.paths.input_dir)
    mkdir(cfg.paths.input_dir);
end

for subj = 1:numel(Pfunc_all)
    [fdir, fname] = fileparts(Pfunc_all{subj});
    subj_abbrev = subject_abbrev(fname);

    run_dir = fullfile(cfg.paths.input_dir, subj_abbrev, 'run1');
    if ~isfolder(run_dir)
        mkdir(run_dir);
    end

    %% Functional image
    if contains(cfg.epi.prefix, 'wave')
        epi_dir = fullfile(fdir, 'wavelet');
    else
        epi_dir = fdir;
    end

    epi_name = [cfg.epi.prefix fname cfg.epi.suffix '.nii'];
    epi_source = fullfile(epi_dir, epi_name);
    epi_destination = fullfile(run_dir, epi_name);

    assert(isfile(epi_source), 'Missing EPI: %s', epi_source);
    if ~isfile(epi_destination)
        copyfile(epi_source, epi_destination);
    end

    %% Regressors of interest -> BASCO onset text file
    regressor_file = fullfile(cfg.paths.regressors_dir, ...
        [subj_abbrev cfg.regressors.suffix]);
    R = load(regressor_file, 'regressors');
    assert(isfield(R, 'regressors'), ...
        'Variable regressors missing in %s', regressor_file);

    onset_file = fullfile(run_dir, ...
        ['onsets_' cfg.version.basco '.txt']);
    fid = fopen(onset_file, 'wt');
    assert(fid ~= -1, 'Could not open %s for writing.', onset_file);
    cleanup = onCleanup(@() fclose(fid));

    for ii = 1:numel(R.regressors)
        fprintf(fid, '%g\t', R.regressors(ii).onset);
        fprintf(fid, '\n');
    end
    clear cleanup;

    %% Motion / CSF / derivative nuisance regressors
    if cfg.epi.despiked
        covariate_source = fullfile(fdir, ...
            'regressors_despiked_motcsf_der.txt');
        covariate_name = ['rp_regressors_despiked_motcsf_der_' ...
            cfg.version.basco '.txt'];
    else
        covariate_source = fullfile(fdir, 'regressors_motcsf_der.txt');
        covariate_name = ['rp_regressors_motcsf_der_' ...
            cfg.version.basco '.txt'];
    end

    assert(isfile(covariate_source), ...
        'Missing nuisance-regressor file: %s', covariate_source);
    copyfile(covariate_source, fullfile(run_dir, covariate_name));
end

%% BASCO metainfo: analysis-level metadata shared by all sessions
metainfo = struct();
metainfo.EPI = cfg.epi.prefix;
metainfo.onsets = ['regressors' cfg.regressors.suffix];
metainfo.onset_dir = cfg.paths.regressors_dir;
metainfo.covariates = covariate_name;
metainfo.covariate_dir = 'session-specific; see input/<subject>/run1';
metainfo.HRF = cfg.hrf.name;

save(cfg.files.metainfo, 'metainfo');
fprintf('Saved BASCO metainfo: %s\n', cfg.files.metainfo);
end

function s = subject_abbrev(fname)
underscore = strfind(fname, '_');
assert(numel(underscore) >= 2, ...
    'Cannot derive subject abbreviation from filename: %s', fname);
s = fname(1:underscore(2)-1);
end
