%% master_BASCO_reappraisal_jr.m

%% Preparation
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINITIONS
%% Define Version Name
% NOTE: metainfo.mat with detailed information about the version name
% (including EPI, onsets, covariates and duration) is saved on 
% /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/input
vname = 'v11'; %% CAVE: check regressorsSuffix !!!
% bi-/unihemispheric atlas
separated_hemisphere = 0;

%% Define paths and regressors/covariates (from the GLM-folder!) ...
% metainfo are saved in respective pathes (check those for info about
% regressors and covariates)
regressorsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/02-regressors/';
regressorsSuffix = '_v19.mat';

% HRF selection
HRF_estimateLength = 'from2sHRF-GLM'; % 'from1sHRF-GLM';
HRF_onset = 'withoutOnset'; % 'withoutOnset';
HRF_infopath = [HRF_onset '_' HRF_estimateLength];
HRF_TCbased = 'longTC' % 'meanTCbased'; % 'longTC'
HRF_name = ['HRF' HRF_TCbased '_' HRF_infopath];

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat')

% selection of EPI
% epiPrefix = 'DVARSscrub_0_1_lin_wave_10cons_med1000_msk_wrst_a1_u_despiked_del5_'; % No smoothing before cormat creation
epiPrefix = 'wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5_'; % Smoothed version for e.g. seedanalysis
epiSuffix = '_c1_c2t_wds';
% epiPrefix = 'med1000_msk_wrst_a1_u_del5_';
% epiSuffix = '_c1_c2t';

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
main_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO';
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
    create_input_BASCO_jr(Pfunc_reappraisal,input_dir,regressorsDir,epiPrefix,epiSuffix,regressorsSuffix,vname,HRF_name,despiked);    
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
    create_betaseries_BASCO_reappraisal_jr(Pfunc_reappraisal,main_dir,vname);  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 4: Create correlation matrices
% Switch
if 1==1
    % Predefine atlas
    %% combinded hemispheres
%     Ptxt = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/AllenBrain_2021_v2_inPax_merged_jr.txt';
%     Patlas = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/AllenBrain_2021_v2_inPax_merged.nii';
    %% separated hemispheres
%     Ptxt = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/05-AllenBrain_separatedHemispheres_2022/AllenBrain_20220627_inPax_merged_jr.txt';
%     Patlas = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/05-AllenBrain_separatedHemispheres_2022/AllenBrain_20220627_inPax_merged_jr.nii';
    %% separated hemispheres v2 2023
    Ptxt = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/08-AllenBrain_2023_v2_separatedHemispheres/AllenBrain_2023_v2_separatedHemispheres_inPax_merged_jr.txt';
    Patlas = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/08-AllenBrain_2023_v2_separatedHemispheres/AllenBrain_2023_v2_separatedHemispheres_inPax_merged_jr.nii';
    create_cormat_BASCO_reappraisal_jr(Pfunc_reappraisal,Ptxt,Patlas,main_dir,vname);
end










