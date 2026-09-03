%% create_input_BASCO_reappraisal_jr.m
% Reinwald, Jonathan; 02/2021
%% Description
% Script for creating inputs of the BASCO toolbox
% 1.) a version name is defined and (with all information on the BASCO run)
% saved to the metainfo.mat file 
% 2.) regressors, covariates and EPI are selected from the respective folders
% 3.) in input: 1. animal folders are created; 2. run1 folder is created
% with the (1) respective EPI, an (2) onsets_v***.txt (timepoints of regressors of
% interest) and an (3) rp_regressors_motcsf_der_v***.txt (covariates to regress
% out)
% All these files are later used in the anadef_reappraisal.m

%% Preparation
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%
%% Define Version Name
% NOTE: metainfo.mat with detailed information about the version name
% (including EPI, onsets, covariates and duration) is saved on 
% /zi-flstorage/data/Jonathan/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/input
vname = 'v7';
%%%%%%%%%%%%%%%%%%%%%%

% set path for scripts
% SPM12
addpath(genpath('/home/jonathan.reinwald/Programs/spm12/'));
% BASCO and marsbar toolboxes
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts/'));
% specific hrf
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal/'));

% path definition
main_dir = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/';
data_dir = fullfile(main_dir,'input');
mkdir(data_dir);

%% Version:
if exist([data_dir filesep 'metainfo.mat'])
    load([data_dir filesep 'metainfo.mat']);
    if sum(strcmp({metainfo.name},vname)) > 0
        meta_counter = find(strcmp({metainfo.name},vname));
    else        
        meta_counter = length(metainfo)+1;
        metainfo(meta_counter).name = vname;
    end
    save([data_dir filesep 'metainfo.mat'],'metainfo');
else
    meta_counter = 1;
    metainfo(meta_counter).name = vname;
    save([data_dir filesep 'metainfo.mat'],'metainfo');
end

% define paths and regressors/covariates (from the GLM-folder!) ...
% metainfo are saved in respective pathes (check those for info about
% regressors and covariates)
regressorsDir = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/02-regressors/';
regressorsSuffix = '_v13.mat';
covarDir = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/01-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix = '_v1.mat';

% load filelist
load('/zi-flstorage/data/Jonathan/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat')

% selection of EPI
epiPrefix = 'wave_10cons_med1000_msk_s6_wrst_a1_u_del5_';
epiSuffix = '_c1_c2t_wds';

% subject selection
subjects = [1:24];

%% Loop over animals/sessions
for subj = 1:length(subjects)
    % pre-clearing
    clear regressors Pfuncall
    
    %% ----------- Preparation of input within loop -----------------------
    [fdir, fname, ext]=fileparts(Pfunc_reappraisal{subj});
    subjAbrev = fname(1:6)
    
    %% 1. Make input dir for specific animal
    mkdir([main_dir 'input'],subjAbrev)
    mkdir([main_dir 'input' filesep subjAbrev],'run1')
    
    %% 2. Load and copy functional data
    % data is copied to separate animal folders
    if contains(epiPrefix,'wave')
        Pfunc = spm_select('FPlist',[fdir filesep 'wavelet'],[epiPrefix fname epiSuffix '.nii']);
        Pfunc_destination = [main_dir 'input' filesep subjAbrev filesep 'run1' filesep epiPrefix fname epiSuffix '.nii'];
        if ~isfile(Pfunc_destination)
            syscmd=['cp ' Pfunc ' ' Pfunc_destination ]
            system(syscmd);
        end
        metainfo(meta_counter).EPI = 'wave';
    elseif ~contains(epiPrefix,'wave')
        Pfunc = spm_select('FPlist',fdir,[epiPrefix fname epiSuffix '.nii']);
        Pfunc_destination = [main_dir 'input' filesep subjAbrev filesep 'run1' filesep epiPrefix fname epiSuffix '.nii'];
        if ~isfile(Pfunc_destination)
            syscmd=['cp ' Pfunc ' ' Pfunc_destination ]
            system(syscmd);
        end
        metainfo(meta_counter).EPI = 'med1000';
    end
    
    %% 3. Regressors of interest and Parametric Modulation
    % 3.1 Load regressors of interest (ROIs)
    load([regressorsDir subjAbrev regressorsSuffix],'regressors');
    fid = fopen([main_dir 'input' filesep subjAbrev filesep 'run1' filesep 'onsets_' vname '.txt'],'wt');
    for ii=1:length(regressors)
        fprintf(fid,'%g\t',regressors(ii).onset);
        fprintf(fid,'\n');
    end
    fclose(fid)
    metainfo(meta_counter).onsets = ['regressors' regressorsSuffix];

    
    %% 4. Find and copy covariates (RPs, CSF, deriv)
    [fpath,fname,ext]=fileparts(Pfunc_reappraisal{subj});
    rp_file_original = [fpath filesep 'regressors_motcsf_der.txt'];
    rp_file_destination = [main_dir 'input' filesep subjAbrev filesep 'run1' filesep 'rp_regressors_motcsf_der_' vname '.txt'];
    syscmd=['cp ' rp_file_original ' ' rp_file_destination ]
    system(syscmd);   
    metainfo(meta_counter).covariates = 'regressors_motcsf_der.txt';

end

% save metainfo
save([data_dir filesep 'metainfo.mat'],'metainfo');

