%% master_BASCO_social_2sessionscombined_jr.m
% Reinwald, Jonathan 01/2023

%% Preparation
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINITIONS
%% Define Version Name
% NOTE: metainfo.mat with detailed information about the version name
% (including EPI, onsets, covariates and duration) is saved on 
% /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/06-FC/01-BASCO/input
vname = 'v1'; %% CAVE: check regressorsSuffix !!!
% bi-/unihemispheric atlas
separated_hemisphere = 0;

%% Define paths and regressors/covariates (from the GLM-folder!) ...
% metainfo are saved in respective pathes (check those for info about
% regressors and covariates)
% SOCIAL DEFEAT
% metainfo are saved in respective pathes
regressorsDir_sd = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/02-regressors/';
regressorsSuffix_sd = '_v1.mat';
% SOCIAL HIERARCHY
% metainfo are saved in respective pathes
regressorsDir_sh = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/02-regressors/';
regressorsSuffix_sh = '_v1.mat';% 2.4 s 

% covarDir_sd = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/05-GLM/01-covariates/';
% % if covarSuffix is _v0.mat, no covariates are used
% covarSuffix_sd = '_v1.mat';
% covarDir_sh = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/01-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
% covarSuffix_sh = '_v1.mat';

% HRF selection
HRF_estimateLength = 'from2sHRF-GLM'; % 'from1sHRF-GLM';
HRF_onset = 'withoutOnset'; % 'withoutOnset';
HRF_infopath = [HRF_onset '_' HRF_estimateLength];
HRF_TCbased = 'longTC' % 'meanTCbased'; % 'longTC'
HRF_name = ['HRF' HRF_TCbased '_' HRF_infopath];

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/03-filelists/filelist_ICON_social_defeat_jr.mat')
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/03-filelists/filelist_ICON_social_hierarchy_jr.mat')

% selection of EPI
% epiPrefix = 'wave_10cons_med1000_msk_wrst_a1_u_despiked_del5_'; % No smoothing before cormat creation
epiPrefix = 'wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5_'; % Smoothed version for e.g. seedanalysis
epiSuffix = '_c1_c2t_wds';

%% Define BASCO

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set pathes for scripts
% SPM12
addpath(genpath('/home/jonathan.reinwald/Programs/spm12/'));
% BASCO and marsbar toolboxes
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/marsbar/'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/BASCO/'));
% load animal HRF
addpath(genpath(['/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal/' HRF_TCbased '/hrf_' HRF_infopath]));

%% Path definition
main_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/06-social_2sessionscombined/06-FC/01-BASCO';
input_dir = fullfile(main_dir,'input');
if exist(input_dir)~=7
    mkdir(input_dir);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 1: Create Input
% Creation of onsets_v*.txt (Onsets) and rp_regressors_motcsf_der_v*.txt
% (Covariates) and copying of EPI into the respective animal folder in input_dir 



% Switch
if 1==0
    % Subscript
    despiked=1;
    create_input_BASCO_2sessionscombined_jr(Pfunc_social_defeat,Pfunc_social_hierarchy,input_dir,regressorsDir_sd,regressorsDir_sh,epiPrefix,epiSuffix,regressorsSuffix_sd,regressorsSuffix_sh,vname,HRF_name,despiked);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 2: Run BASCO
% Creation of onsets_v*.txt (Onsets) and rp_regressors_motcsf_der_v*.txt
% (Covariates) and copying of EPI into the respective animal folder in input_dir 

% Switch
if 1==0
    % Subscript
    cd('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/03-FC/01-BASCO/');
    % Run BASCO toolbox
    BASCO
    
%     disp(sprintf('Did you already run the BASCO toolbox manually? \n If not, please do so (see below for instructions). \n If yes, press enter, please, and the script will continue!'));
%     disp(sprintf('Help BASCO: \n 1. Press "Model specification and estimation" \n 2. Select your anadef.m-file (e.g. anadef_reappraisal.m) \n 3. Select your metainfo_vX.mat-file that you created in the previous step!'));
%     pause;
%     disp('Script continues...');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 3: Create betaseries
% Reset pathes (as marsbar is including SPM pathes)
% SPM12
addpath(genpath('/home/jonathan.reinwald/Programs/spm12/'));
% load animal HRF
addpath(genpath(['/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal/' HRF_TCbased '/hrf_' HRF_infopath]));

% Switch
if 1==0
    create_betaseries_BASCO_social_2sessionscombined_jr(Pfunc_social_defeat,Pfunc_social_hierarchy,main_dir,vname);  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 4: Create correlation matrices
% Switch
if 1==1
    % Predefine atlas
    %% combinded hemispheres
    Ptxt = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/AllenBrain_2021_v2_inPax_merged_jr.txt';
    Patlas = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/AllenBrain_2021_v2_inPax_merged.nii';
    %% separated hemispheres
%     Ptxt = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/05-AllenBrain_separatedHemispheres_2022/AllenBrain_20220627_inPax_merged_jr.txt';
%     Patlas = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/05-AllenBrain_separatedHemispheres_2022/AllenBrain_20220627_inPax_merged_jr.nii';
    create_cormat_BASCO_social_defeat_jr(Pfunc_social_hierarchy,Ptxt,Patlas,main_dir,vname);
end










