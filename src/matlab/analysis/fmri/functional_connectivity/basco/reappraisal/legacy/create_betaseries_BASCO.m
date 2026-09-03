function create_betaseries_BASCO(Pfunc_all, cfg)
%CREATE_BETASERIES_BASCO Convert BASCO beta images into 4-D beta series.
%
% This preserves the legacy trial definitions while replacing absolute beta
% indices by condition-relative indices. Thus the scientific selection is
% unchanged even if condition order changes.

ensure_dir(cfg.paths.cormat_dir);
ensure_dir(cfg.paths.beta4D_dir);

anaobj_file = fullfile(cfg.paths.output_dir, ...
    ['out_estimated_reappraisal_' cfg.version.basco '.mat']);
A = load(anaobj_file, 'anaobj');
assert(isfield(A, 'anaobj'), 'Variable anaobj missing in %s', anaobj_file);

anadef = A.anaobj{1,1}.Ana{1,1}.AnaDef;
condition_names = anadef.Cond;
condition_nbeta = cellfun(@numel, anadef.RegCondVec);
condition_start = cumsum([1 condition_nbeta(1:end-1)]);
condition_end   = cumsum(condition_nbeta);

for subj = 1:numel(Pfunc_all)
    [~, fname] = fileparts(Pfunc_all{subj});
    subj_abbrev = subject_abbrev(fname);

    protocol = load_protocol(cfg.paths.protocol_dir, fname);

    work_dir = fullfile(cfg.paths.input_dir, subj_abbrev, ...
        ['betaseries_' cfg.version.basco]);
    curr_filelist = spm_select('FPList', work_dir, '^beta_.*\.nii$');
    assert(~isempty(curr_filelist), 'No beta images found in %s', work_dir);

    for jx = 1:numel(condition_names)
        condition_name = condition_names{jx};
        safe_name = strrep(condition_name, ' ', '-');
        idx = condition_start(jx):condition_end(jx);

        out_file = fullfile(cfg.paths.beta4D_dir, sprintf( ...
            '%s_betaseries_%s_%s.nii', subj_abbrev, ...
            cfg.version.basco, safe_name));
        write_beta4d(curr_filelist, idx, out_file);

        %% Legacy condition-specific subseries
        if strcmp(condition_name, 'Lavender')
            assert(numel(idx) >= 120, ...
                'Lavender requires at least 120 betas for legacy splits.');

            write_named_subset(idx(1:40),  'Odor1to40');
            write_named_subset(idx(1:10),  'Odor1to10');
            write_named_subset(idx(11:40), 'Odor11to40');
            write_named_subset(idx(41:80), 'Odor41to80');
            write_named_subset(idx(81:120),'Odor81to120');
            write_named_subset(idx(81:110),'Odor81to110');

            puff_or_not = [protocol.events.puff_or_not];
            puff_trials = find(puff_or_not);
            assert(all(puff_trials <= numel(idx)), ...
                'Protocol puff indices exceed Lavender beta count.');
            write_named_subset(idx(puff_trials), 'Odor_TPPuff');

            no_puff_trials = find(puff_or_not == 0);
            no_puff_trials = no_puff_trials( ...
                no_puff_trials > 40 & no_puff_trials < 81);
            write_named_subset(idx(no_puff_trials), 'Odor_TPNoPuff');

        elseif strcmp(condition_name, 'TP NoPuff')
            % Preserve the exact legacy offsets. Note that 41to80 contains
            % 12 available no-puff beta estimates in this condition; the
            % label refers to the experimental phase/trial range.
            assert(numel(idx) >= 92, ...
                'TP NoPuff requires at least 92 betas for legacy splits.');

            write_named_subset(idx(1:40),  'TPnoPuff1to40');
            write_named_subset(idx(1:10),  'TPnoPuff1to10');
            write_named_subset(idx(11:40), 'TPnoPuff11to40');
            write_named_subset(idx(41:52), 'TPnoPuff41to80');
            write_named_subset(idx(53:92), 'TPnoPuff81to120');
            write_named_subset(idx(53:82), 'TPnoPuff81to110');
        end
    end

    fprintf('Created beta-series images for %s\n', subj_abbrev);

    function write_named_subset(beta_idx, suffix)
        out = fullfile(cfg.paths.beta4D_dir, sprintf( ...
            '%s_betaseries_%s_%s.nii', subj_abbrev, ...
            cfg.version.basco, suffix));
        write_beta4d(curr_filelist, beta_idx, out);
    end
end
end

function protocol = load_protocol(protocol_dir, fname)
underscore = strfind(fname, '_');
assert(numel(underscore) >= 2, ...
    'Cannot derive animal identifier from filename: %s', fname);

% Preserve the legacy animal-ID extraction exactly.
animal_id = fname(underscore(1)+2:underscore(2)-1);
animal_dir = fullfile(protocol_dir, ['animal_' animal_id]);
files = dir(fullfile(animal_dir, ['animal_' animal_id '*.*']));
files = files(~[files.isdir]);
assert(numel(files) == 1, ...
    'Expected exactly one protocol file for animal %s in %s.', ...
    animal_id, animal_dir);

protocol = load(fullfile(files(1).folder, files(1).name));
assert(isfield(protocol, 'events'), ...
    'Protocol file for animal %s has no events variable.', animal_id);
end

function write_beta4d(curr_filelist, beta_indices, out_file)
if isempty(beta_indices)
    warning('Skipping empty beta-series subset: %s', out_file);
    return;
end

if isfile(out_file)
    delete(out_file);
end

for kk = 1:numel(beta_indices)
    ix = beta_indices(kk);
    V = spm_vol(deblank(curr_filelist(ix,:)));
    Vout = V;
    Vout.fname = out_file;
    Vout.n(1) = kk;
    spm_write_vol(Vout, spm_read_vols(V));
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
