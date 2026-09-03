%% master_TC_analysis_HRF_jr
% Reinwald, Jonathan 06/2021
% "master_TC_analysis_jr" calculates the mean timecourse for specified regions
% of interest (ROIs)

% Preparation:
% Run master_GLM_residuals_jr.m before to create the residual nii-files

%% Preparation
clear all;
% close all;
clc;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_HRF/01-scripts/01-MRI/03-TC_analysis'))
addpath(genpath('/home/jonathan.reinwald/ICON_HRF/01-scripts/10-toolboxes/spm12_animal'))

% define paths and regressors/covariates ...
regressorsSuffix = '_v99.mat';
orth = 1;
covarSuffix = '_v1.mat';
% date definition
date = '29-Jul-2021'

% selection of EPI
epiPrefix = 'msk_s5_rwrst_a1_u_del25_';
% epiPrefix = 'msk_s5_regfilt_motcsfder_wrst_a1_u_del25_';
epiSuffix = '_c2t';

% general result directory
resultsDir = '/home/jonathan.reinwald/ICON_HRF/04-analyses/02-TC_analysis/03-results';
% outputDirName
outputDirName = ['EPI_' epiPrefix(1:15) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix(2:3) '____Orth_' num2str(orth) '_' date];

% firstlevel directory
firstleveldir = [resultsDir filesep outputDirName filesep 'firstlevel_residuals'];
% protocol directory
protocol_dir = '/home/jonathan.reinwald/ICON_HRF/03-processed-data/01-processed_protocol_files';

% definition whether to use der or not
DerDisp=[0 0];

% sessect selection
sessions = [1:11];

% define odor delay
odor_delay = 0.7;

% load filelist
load('/home/jonathan.reinwald/ICON_HRF/03-processed-data/03-filelists/filelist_ICON_hrf_jr.mat','P3d','Pdmap','Pfunc','Pfunc_subjName')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ------------------------- FIRST-LEVEL ANALYSIS ---------------------- %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Select your binary masks for ROI-definitions
% select as many masks as you want
% cd('/home/jonathan.reinwald/ICON_RPE/helpers/atlas/Templates_Renee/Mouse_ROIs/bilateral');
% [Pmsk,~]=spm_select(Inf,'any','Select Mask',[],pwd,'.*..nii');
%    
Pmsk_all={'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_T001_ROI_v22.nii',........
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_T001_ROI_v24.nii',........
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/AON.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Cing.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/DPA.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/FP.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/I_dors.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/IL.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/I_post.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/I_ventr.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Nacc.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/OB.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/OF.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Otu.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/Pir.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/PL.nii',....
    '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/TT.nii',....
    };

% Pmsk_all={'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v22___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_T001_ROI_v22.nii',........
%     '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v24___COV_v1___ORTH_1___DERDISP0___20-Jan-2023/secondlevel/TP_NoPuff_Bl3_vs_TP_NoPuff_Bl1_11to40/mask_T001_ROI_v24.nii',........
%     };
% Pmsk_all={'/home/jonathan.reinwald/ICON_HRF/10-helpers/03-atlas_Renee/bilateral/olf_tubercle_smoothed.nii',....
%     '/home/jonathan.reinwald/ICON_HRF/10-helpers/03-atlas_Renee/bilateral/APC_inPax_reduced.nii',....
%     '/home/jonathan.reinwald/ICON_HRF/10-helpers/03-atlas_Renee/bilateral/NAc_inPax_smoothed.nii',....
%     '/home/jonathan.reinwald/ICON_HRF/10-helpers/03-atlas_Renee/bilateral/AON_inPax_smoothed.nii',....
%     '/home/jonathan.reinwald/ICON_HRF/10-helpers/03-atlas_Renee/bilateral/olf_bulb_inPax_smoothed.nii'
% '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/I_dors.nii',....
%     '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/I_post.nii',....
%     '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v1/I_ventr.nii',....
% Pmsk_all={'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v24___COV_v1___06-Jan-2022/secondlevel/TP_NoPuff_Bl3 vs TP_NoPuff_Bl1_11to40/mask_activation_Ins_T3_v24.nii',....
%     '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/03-results/HRFlongTC_withoutOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrs___ROI_v22___COV_v1___06-Jan-2022/secondlevel/TP_NoPuff_Bl3 vs TP_NoPuff_Bl1_11to40/mask_activation_Ins_T3_v22.nii',....

Pmsk=char(Pmsk_all);

%% Loop over selected masks
for Nmask = 1:size(Pmsk,1)
    % clearing
    clear tc_matrsess_all 
    
    % Get mask name ...
    Pmsk_cur = Pmsk(Nmask,:);
    [~, fname_mask, ~]=fileparts(Pmsk_cur);
    fname_mask = strrep(fname_mask,'_','');
    
    % Define session path ...
    dirlist = dir(firstleveldir);
    dirlist = dirlist(contains({dirlist.name},'ZI_M'));
    numbersess = numel(dirlist);
    
    % Save directory ...
    newdir = [resultsDir filesep outputDirName filesep 'meanTC' filesep fname_mask];
    mkdir(newdir);
    % addon = ' - 12 rps '
    
    %%  LET'S GETTING STARTED ...
    for sess=sessions
        
        %% Preparation of current session
        % get sessiondir ...
        sessiondir = [firstleveldir filesep dirlist(sess).name];
        
        % select ...
        Pcur=spm_select('FpList', sessiondir ,['^4D_residuals_' dirlist(sess).name '.nii']);
        
        %% Get meanTc of current session ...
        
        [tc roidata]=wwf_roi_tcours_old(Pmsk_cur,Pcur);
        
        
        %% Modify tc ...
        
        % detrend data ...
        tc_detr = detrend(tc);
        
        % normalize data ..
        tc_detr_norm = zscore(tc_detr);
        
        %% Parse different odors
        % 1. find and load processed protocol file
        clear Pfunc_sess
        % find Pfunc according to 4d (CAVE: DIFFERENT ORDER DUE TO 4D
        % selection using dir)
        Pfunc_sess = find(contains(Pfunc,dirlist(sess).name));
        [fpath,fname,ext]=fileparts(Pfunc{Pfunc_sess});
        % select all file in the respective animal folder
        protocol_file = dir([protocol_dir filesep 'animal_' Pfunc_subjName{Pfunc_sess}(2:end) ]);
        % select the correct file from the protocol_files using the date of the
        % acquisition
        clear selectionNumb
        selectionNumb = find(contains({protocol_file.name},fname(5:10)));
        load([protocol_file(selectionNumb).folder filesep protocol_file(selectionNumb).name]);
        
        
        % 2. TR definition
        TR = 0.265;
        
        % 3. Define number of frames you want to add to the odor volume for analysis per trial ...
        Nfr_before = 4;
        Nfr_after = 30;
        
        %% Using all rewarded/non-rewarded trials independent of post-licks
        % tc values are saved in matrsess_nonrew and matrsess_rew;
        % rows = trials, columns = frames
        %% Odor with 0.5s duration
        odoronset{1} = ceil(([events([events.fv_dur_del25]>0.45 & [events.fv_dur_del25]<0.55).fv_on_del25] + odor_delay)/(TR));
        odoronset_precise{1} = (([events.fv_on_del25] + odor_delay)/(TR));
        matrsess_tc{1} = [];matrsess_FD{1} = [];matrsess_csf{1} = [];
        tc_matrsess_all{1}.duration = '500 ms'
        
        %% Odor with 1s duration
        odoronset{2} = ceil(([events([events.fv_dur_del25]>0.95 & [events.fv_dur_del25]<1.05).fv_on_del25] + odor_delay)/(TR));
        odoronset_precise{2} = (([events.fv_on_del25] + odor_delay)/(TR));
        matrsess_tc{2} = [];matrsess_FD{2} = [];matrsess_csf{2} = [];
        tc_matrsess_all{2}.duration = '1000 ms'
        
        %% Odor with 2.4s duration
        odoronset{3} = ceil(([events([events.fv_dur_del25]>2.35 & [events.fv_dur_del25]<2.55).fv_on_del25] + odor_delay)/(TR));
        odoronset_precise{3} = (([events.fv_on_del25] + odor_delay)/(TR));
        matrsess_tc{3} = [];matrsess_FD{3} = [];matrsess_csf{3} = [];
        tc_matrsess_all{3}.duration = '2400 ms'
        
        % create FD matrix
        clear SPM rp_xX csf_xX FD 
        load([sessiondir filesep 'SPM.mat']);
        rp_xX = contains(SPM.xX.name,'rp') & ~contains(SPM.xX.name,'deriv');
        rp = SPM.xX.X(:,rp_xX);
        FD = SNiP_framewise_displacement(rp);
        csf_xX = contains(SPM.xX.name,'csf') & ~contains(SPM.xX.name,'deriv');
        csf = SPM.xX.X(:,csf_xX);
        
        for ii = 1:length(odoronset)
            for i = 1:numel(odoronset{ii})
                OnsetFrame_cur = odoronset{ii}(i); % frame of odor exposition
                if OnsetFrame_cur <= 1 % occured in one sess ...
                    OnsetFrame_cur = 2;
                end
                Index_frames_cur = (OnsetFrame_cur-Nfr_before):1:(OnsetFrame_cur+Nfr_after); % index
                % write tc values for current trial to matrsess ...
                matrsess_tc{ii}(i,:) = tc_detr_norm(Index_frames_cur);
                matrsess_FD{ii}(i,:) = FD(Index_frames_cur);
                matrsess_csf{ii}(i,:) = csf(Index_frames_cur);
            end
            tc_matrsess_all{ii}.mat(sess,:,:)=matrsess_tc{ii};
            FD_matrsess_all{ii}.mat(sess,:,:)=matrsess_FD{ii};
            CSF_matrsess_all{ii}.mat(sess,:,:)=matrsess_csf{ii};
        end
        
        
        
    end
    save([newdir filesep 'tc_matrsess_all.mat'],'tc_matrsess_all','FD_matrsess_all','CSF_matrsess_all');
end