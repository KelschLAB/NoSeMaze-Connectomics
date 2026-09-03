

%% Preparation
clear all;
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEFINITIONS
%% Define Version Name
% NOTE: metainfo.mat with detailed information about the version name
% (including EPI, onsets, covariates and duration) is saved on 
% /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/06-FC/01-BASCO/input
vname = 'v2'; %% CAVE: check regressorsSuffix !!!

%% Define paths and regressors/covariates (from the GLM-folder!) ...
% metainfo are saved in respective pathes (check those for info about
% regressors and covariates)
regressorsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/02-regressors/';
regressorsSuffix = '_v1.mat';
covarDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/05-GLM/01-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix = '_v1.mat';

% HRF selection
HRF_estimateLength = 'from2sHRF-GLM'; % 'from1sHRF-GLM';
HRF_onset = 'withoutOnset'; % 'withoutOnset';
HRF_infopath = [HRF_onset '_' HRF_estimateLength];
HRF_TCbased = 'longTC' % 'meanTCbased'; % 'longTC'
HRF_name = ['HRF' HRF_TCbased '_' HRF_infopath];


% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/03-filelists/filelist_ICON_social_hierarchy_jr.mat')

% selection of EPI
% epiPrefix = 'wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5_';
epiPrefix = 'wave_10cons_med1000_msk_wrst_a1_u_despiked_del5_';
epiSuffix = '_c1_c2t_wds';

%% Define BASCO

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set pathes for scripts
% SPM12
addpath(genpath('/home/jonathan.reinwald/Programs/spm12/'));
% BASCO and marsbar toolboxes
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/marsbar/'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/BASCO/'));
% specific hrf
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal/'));
% add helpers
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/04-helpers/'));

%% Path definition
main_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/06-FC/01-BASCO';
input_dir = fullfile(main_dir,'input');
if exist(input_dir)~=7
    mkdir(input_dir);
end

% %% Save specific version:
% if exist([input_dir filesep 'metainfo.mat'])
%     load([input_dir filesep 'metainfo.mat']);
%     if sum(strcmp({metainfo.name},vname)) > 0
%         meta_counter = find(strcmp({metainfo.name},vname));
%     else        
%         meta_counter = length(metainfo)+1;
%         metainfo(meta_counter).name = vname;
%     end
%     save([input_dir filesep 'metainfo.mat'],'metainfo');
% else
%     meta_counter = 1;
%     metainfo(meta_counter).name = vname;
%     save([input_dir filesep 'metainfo.mat'],'metainfo');
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 1: Create Input
% Creation of onsets_v*.txt (Onsets) and rp_regressors_motcsf_der_v*.txt
% (Covariates) and copying of EPI into the respective animal folder in input_dir 

% Switch
if 1==1
   % Subscript
    despiked=1;
    create_input_BASCO_jr(Pfunc_social_hierarchy,input_dir,regressorsDir,epiPrefix,epiSuffix,regressorsSuffix,vname,HRF_name,despiked);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 2: Run BASCO
% Creation of onsets_v*.txt (Onsets) and rp_regressors_motcsf_der_v*.txt
% (Covariates) and copying of EPI into the respective animal folder in input_dir 

% Switch
if 1==1
    % Subscript
    cd('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI/03-FC/01-BASCO/');
    % Run BASCO toolbox
    % 
    BASCO
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% STEP 3: Create betaseries
% Reset pathes (as marsbar is including SPM pathes)
% SPM12
addpath(genpath('/home/jonathan.reinwald/Programs/spm12/'));
% specific hrf
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal/'));

% Switch
if 1==1
    create_betaseries_BASCO_social_hierarchy_jr(Pfunc_social_hierarchy,main_dir,vname);  
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
    create_cormat_BASCO_social_hierarchy_jr(Pfunc_social_hierarchy,Ptxt,Patlas,main_dir,vname);
end










