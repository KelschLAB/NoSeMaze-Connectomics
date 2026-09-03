function create_input_BASCO_jr(Pfunc_all,input_dir,regressorsDir,epiPrefix,epiSuffix,regressorsSuffix,vname,HRF_name,despiked)
% 


%% Loop over animals/sessions
for subj = 1:length(Pfunc_all)
    % pre-clearing
    clear regressors Pfuncall subjAbrev
    
    %% ----------- Preparation of input within loop -----------------------
    [fdir, fname, ext]=fileparts(Pfunc_all{subj});
    clear find_
    find_=strfind(fname,'_');
    subjAbrev = fname(1:find_(2)-1);
    
    %% 1. Make input dir for specific animal
    clear subj_dir run_dir
    subj_dir = [input_dir filesep subjAbrev];
    if exist(subj_dir)~=7
        mkdir(subj_dir);
    end
    run_dir = [subj_dir filesep 'run1'];
    if exist(run_dir)~=7
        mkdir(run_dir);
    end

    %% 2. Load and copy functional data
    % data is copied to separate animal folders
    if contains(epiPrefix,'wave')
        Pfunc = spm_select('FPlist',[fdir filesep 'wavelet'],['^' epiPrefix fname epiSuffix '.nii']);
        Pfunc_destination = [run_dir filesep epiPrefix fname epiSuffix '.nii'];
        if ~isfile(Pfunc_destination)
            syscmd=['cp ' Pfunc ' ' Pfunc_destination ]
            system(syscmd);
        end
        metainfo(1).EPI = epiPrefix;
    elseif ~contains(epiPrefix,'wave')
        Pfunc = spm_select('FPlist',fdir,['^' epiPrefix fname epiSuffix '.nii']);
        Pfunc_destination = [run_dir filesep epiPrefix fname epiSuffix '.nii'];
        if ~isfile(Pfunc_destination)
            syscmd=['cp ' Pfunc ' ' Pfunc_destination ]
            system(syscmd);
        end
        metainfo(1).EPI = epiPrefix;
    end
    
    %% 3. Regressors of interest and Parametric Modulation
    % 3.1 Load regressors of interest (ROIs)
    load([regressorsDir subjAbrev regressorsSuffix],'regressors');
    fid = fopen([run_dir filesep 'onsets_' vname '.txt'],'wt');
    for ii=1:length(regressors)
        fprintf(fid,'%g\t',regressors(ii).onset);
        fprintf(fid,'\n');
    end
    fclose(fid)
    metainfo(1).onsets = ['regressors' regressorsSuffix];
    metainfo(1).onset_dir = regressorsDir;
    
    %% 4. Find and copy covariates (RPs, CSF, deriv)
    [fpath,fname,ext]=fileparts(Pfunc_all{subj});
    if despiked==0
        rp_file_original = [fpath filesep 'regressors_motcsf_der.txt'];
        rp_file_destination = [run_dir filesep 'rp_regressors_motcsf_der_' vname '.txt'];
    elseif despiked==1
        rp_file_original = [fpath filesep 'regressors_despiked_motcsf_der.txt'];
        rp_file_destination = [run_dir filesep 'rp_regressors_despiked_motcsf_der_' vname '.txt'];
    end
    syscmd=['cp ' rp_file_original ' ' rp_file_destination ]
    system(syscmd);   
    if despiked==0
        metainfo(1).covariates = ['rp_regressors_motcsf_der_' vname '.txt'];
    elseif despiked==1
        metainfo(1).covariates = ['rp_regressors_despiked_motcsf_der_' vname '.txt'];
    end
    metainfo(1).covariate_dir = rp_file_original;
    
    %% 5. HRF name
    metainfo(1).HRF = HRF_name;
end

% save metainfo
save([input_dir filesep 'metainfo_' vname '.mat'],'metainfo');