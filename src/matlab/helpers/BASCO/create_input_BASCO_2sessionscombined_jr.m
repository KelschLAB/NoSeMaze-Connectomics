function create_input_BASCO_2sessionscombined_jr(Pfunc_1,Pfunc_2,input_dir,regressorsDir_1,regressorsDir_2,epiPrefix,epiSuffix,regressorsSuffix_1,regressorsSuffix_2,vname,HRF_name,despiked)
% 

% subject selection (CAVE: 22 subjects for SH, 24 subjects for SD)
[fdir_1,~,~]=fileparts(Pfunc_1{1});
[fdir_1,~,~]=fileparts(fdir_1);
[fdir_1,~,~]=fileparts(fdir_1);
subfolders_1 = dir(fdir_1);
mySubjects_1 = {subfolders_1(contains({subfolders_1.name},'ZI_')).name};

[fdir_2,~,~]=fileparts(Pfunc_2{1});
[fdir_2,~,~]=fileparts(fdir_2);
[fdir_2,~,~]=fileparts(fdir_2);
subfolders_2 = dir('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing');
mySubjects_2 = {subfolders_2(contains({subfolders_2.name},'ZI_')).name};

selection_1 = ismember(mySubjects_1,mySubjects_2);
subjects = [1:length(mySubjects_2)];

Pfunc_1=Pfunc_1(selection_1);


%% Loop over animals/sessions
for subj = 1:length(Pfunc_1)
    % pre-clearing
    clear regressors subjAbrev
    
    %% ----------- Preparation of input within loop -----------------------
    [fdir, fname, ext]=fileparts(Pfunc_1{subj});
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
        Pfunc = spm_select('FPlist',fdir,[epiPrefix fname epiSuffix '.nii']);
        Pfunc_destination = [run_dir filesep epiPrefix fname epiSuffix '.nii'];
        if ~isfile(Pfunc_destination)
            syscmd=['cp ' Pfunc ' ' Pfunc_destination ]
            system(syscmd);
        end
        metainfo(1).EPI = epiPrefix;
    end
    
    %% 3. Regressors of interest and Parametric Modulation
    % 3.1 Load regressors of interest (ROIs)
    load([regressorsDir_1 subjAbrev regressorsSuffix_1],'regressors');
    fid = fopen([run_dir filesep 'onsetsRUN1.txt'],'wt');
    for ii=1:length(regressors)
        fprintf(fid,'%g\t',regressors(ii).onset);
        fprintf(fid,'\n');
    end
    fclose(fid)
    metainfo(1).onsets = ['regressors' regressorsSuffix_1];
    metainfo(1).onset_dir = regressorsDir_1;
    
    %% 4. Find and copy covariates (RPs, CSF, deriv)
    [fpath,fname,ext]=fileparts(Pfunc_1{subj});
    if despiked==0
        rp_file_original = [fpath filesep 'regressors_motcsf_der.txt'];
        rp_file_destination = [run_dir filesep 'rp_regressors_motcsf_der_RUN1.txt'];
    elseif despiked==1
        rp_file_original = [fpath filesep 'regressors_despiked_motcsf_der.txt'];
        rp_file_destination = [run_dir filesep 'rp_regressors_despiked_motcsf_der_RUN1.txt'];
    end
    syscmd=['cp ' rp_file_original ' ' rp_file_destination ]
    system(syscmd);   
    if despiked==0
        metainfo(1).covariates = ['rp_regressors_motcsf_der_RUN1.txt'];
    elseif despiked==1
        metainfo(1).covariates = ['rp_regressors_despiked_motcsf_der_RUN1.txt'];
    end
    metainfo(1).covariate_dir = rp_file_original;
    
    %% 5. HRF name
    metainfo(1).HRF = HRF_name;
end

for subj = 1:length(Pfunc_2)
    % pre-clearing
    clear regressors subjAbrev
    
    %% ----------- Preparation of input within loop -----------------------
    [fdir, fname, ext]=fileparts(Pfunc_2{subj});
    clear find_
    find_=strfind(fname,'_');
    subjAbrev = fname(1:find_(2)-1);
    
    %% 1. Make input dir for specific animal
    clear subj_dir run_dir
    subj_dir = [input_dir filesep subjAbrev];
    if exist(subj_dir)~=7
        mkdir(subj_dir);
    end
    run_dir = [subj_dir filesep 'run2'];
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
        Pfunc = spm_select('FPlist',fdir,[epiPrefix fname epiSuffix '.nii']);
        Pfunc_destination = [run_dir filesep epiPrefix fname epiSuffix '.nii'];
        if ~isfile(Pfunc_destination)
            syscmd=['cp ' Pfunc ' ' Pfunc_destination ]
            system(syscmd);
        end
        metainfo(2).EPI = epiPrefix;
    end
    
    %% 3. Regressors of interest and Parametric Modulation
    % 3.1 Load regressors of interest (ROIs)
    load([regressorsDir_2 subjAbrev regressorsSuffix_2],'regressors');
    fid = fopen([run_dir filesep 'onsetsRUN2.txt'],'wt');
    for ii=1:length(regressors)
        fprintf(fid,'%g\t',regressors(ii).onset);
        fprintf(fid,'\n');
    end
    fclose(fid)
    metainfo(2).onsets = ['regressors' regressorsSuffix_2];
    metainfo(2).onset_dir = regressorsDir_2;
    
    %% 4. Find and copy covariates (RPs, CSF, deriv)
    [fpath,fname,ext]=fileparts(Pfunc_2{subj});
    if despiked==0
        rp_file_original = [fpath filesep 'regressors_motcsf_der.txt'];
        rp_file_destination = [run_dir filesep 'rp_regressors_motcsf_der_RUN2.txt'];
    elseif despiked==1
        rp_file_original = [fpath filesep 'regressors_despiked_motcsf_der.txt'];
        rp_file_destination = [run_dir filesep 'rp_regressors_despiked_motcsf_der_RUN2.txt'];
    end
    syscmd=['cp ' rp_file_original ' ' rp_file_destination ]
    system(syscmd);   
    if despiked==0
        metainfo(2).covariates = ['rp_regressors_motcsf_der_RUN2.txt'];
    elseif despiked==1
        metainfo(2).covariates = ['rp_regressors_despiked_motcsf_der_RUN2.txt'];
    end
    metainfo(2).covariate_dir = rp_file_original;
    
    %% 5. HRF name
    metainfo(2).HRF = HRF_name;
end

% save metainfo
save([input_dir filesep 'metainfo_' vname '.mat'],'metainfo');