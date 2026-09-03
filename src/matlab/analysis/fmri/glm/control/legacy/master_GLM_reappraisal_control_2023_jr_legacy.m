%% master_GLM_reappraisal_control_2023_jr.m
% Reinwald, Jonathan; 09/2023

% PREPARATION:
% before running this script to create regressors and covariates:
% - create_regressors_reappraisal_jr.m --> creates regressors in /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/02-regressors
% - create_covariates_reappraisal_jr.m --> creates regressors in /home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/01-covariates/

%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))

% define paths and regressors/covariates ...
% metainfo are saved in respective pathes
regressorsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/05-GLM/02-regressors/';
regressorsSuffix_sel{1} = '_v26.mat';
% regressorsSuffix_sel{2} = '_v98.mat';
% regressorsSuffix_sel{3} = '_v97.mat'; % Blocks of 20 at first and last 40
% regressorsSuffix_sel{4} = '_v98.mat'; 
% regressorsSuffix_sel{5} = '_v94.mat';% for checking the order
% regressorsSuffix_sel{5} = '_v89.mat'; % with correct trial number
% regressorsSuffix_sel{6} = '_v90.mat';
% regressorsSuffix_sel{7} = '_v91.mat';
% regressorsSuffix_sel{8} = '_v92.mat';

covarDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/05-GLM/01-covariates/';
% if covarSuffix is _v0.mat, no covariates are used
covarSuffix = '_v1.mat';

% orthogonolization (for PM)
orth = 1;

% Loop over different regressors of interest
for regrIdx = 1:length(regressorsSuffix_sel)
    
    % current regressor of interest
    regressorsSuffix = regressorsSuffix_sel{regrIdx};
    
    % HRF selection
%     HRF_onset = 'hrf_philipplebhardt';
    
    HRF_estimateLength = 'from2sHRF-GLM'; % 'from1sHRF-GLM';
    HRF_onset = 'withoutOnset'; % 'withoutOnset';
    HRF_infopath = [HRF_onset '_' HRF_estimateLength];
    HRF_TCbased = 'longTC' % 'meanTCbased'; % 'longTC'
    
    % selection of EPI
%     epiPrefix = 'msk_s6_wrst_a1_u_despiked_del5_';
    epiPrefix = 'wave_10cons_med1000new_msk_s6_wrst_a1_u_despiked_del5_';
    
    %     epiPrefix = 'med1000_msk_s6_wrst_a1_u_del5_';
    epiSuffix = '_c2t_wds';
%     epiSuffix = '_c2t';

    % definition whether to use der or not
    DerDisp=[0 0];
    
    % general result directory
    resultsDir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/05-GLM/03-results';
    
%     outputDirName
    if contains(epiSuffix,'noise')
        outputDirName = ['HRF' HRF_TCbased '_' HRF_infopath '_' epiSuffix(end-4:end) '_EPI_' epiPrefix(1:end) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix(2:3) '___ORTH_' num2str(orth) '___' date];
    elseif ~contains(epiSuffix,'noise') && sum(DerDisp)==0
        outputDirName = ['HRF' HRF_TCbased '_' HRF_infopath '_EPI_' epiPrefix(1:end) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix(2:3) '___ORTH_' num2str(orth)  '___DERDISP' num2str(sum(DerDisp)>0) '___' date];
    elseif ~contains(epiSuffix,'noise') && sum(DerDisp)>0
        outputDirName = ['HRF' HRF_TCbased '_' HRF_infopath '_EPI_' epiPrefix(1:end) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix(2:3) '___ORTH_' num2str(orth)  '___DERDISP' num2str(sum(DerDisp)>0) '___' date];
    end
% %     if ~contains(HRF_onset,'philipplebhardt');
% %         outputDirName = ['HRF' HRF_TCbased '_' HRF_infopath '_EPI_' epiPrefix(1:end) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix(2:3) '___ORTH_' num2str(orth) '___' date];
% %     else
% %         outputDirName = ['HRF' HRF_onset(5:end) '-GLM_EPI_' epiPrefix(1:end) '___ROI_' regressorsSuffix(2:end-4) '___COV_' covarSuffix(2:3) '___ORTH_' num2str(orth) '___' date];
% %     end
    
    % subject selection
    subjects = [1:24];
    
    % load filelist
    load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/03-filelists/filelist_ICON_reappraisal_control_2023_jr.mat')
    
    % start SPM fmri
    spm('CreateMenuWin','off');
    spm('CreateIntWin','off');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ------------------------- FIRST-LEVEL ANALYSIS ---------------------- %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if 1==1
        %% Loop over animals/sessions
        for subj = 1:length(subjects)
            tic
            % pre-clearing
            clear regressors Pfuncall
            
            %% ----------- Preparation of input within loop -----------------------
            [fdir, fname, ext]=fileparts(Pfunc_reappraisal{subj});
            subjAbrev = ['ZI_' fname(4:11)];
            
            %% 1. Create output directory
            outputDir = [resultsDir filesep outputDirName filesep 'firstlevel' filesep subjAbrev];
            if ~exist(outputDir)
                mkdir(outputDir)
            end
            
            %% 2. Load functional data
            if contains(epiPrefix,'wave');
                Pfuncall = spm_select('ExtFPlist',[fdir filesep 'wavelet'],['^' epiPrefix fname epiSuffix '.nii'],[1:2500]);
            elseif ~contains(epiPrefix,'wave');
                Pfuncall = spm_select('ExtFPlist',fdir,['^' epiPrefix fname epiSuffix '.nii'],[1:2500]);
            end
            
            %% 3. Regressors of interest and Parametric Modulation
            % 3.1 Load regressors of interest (ROIs)
            regressors_file = spm_select('FPList',regressorsDir,['^' subjAbrev '.*' regressorsSuffix]);
            load(regressors_file,'regressors');
            
            % 3.2 Create ROI input
            ROI_counter=1;
            for ix = 1:length(regressors)
                if ~isempty(regressors(ix).onset)
                    ROI(ROI_counter).name = regressors(ix).name;
                    ROI(ROI_counter).values = regressors(ix).onset;
                    ROI(ROI_counter).duration = regressors(ix).duration;
                    if ~isempty(regressors(ix).pm)
                        PM_counter=1;
                        for zx = 1:length(regressors(ix).pm)
                            ROI(ROI_counter).PM(PM_counter).name = regressors(ix).pm(zx).name;
                            ROI(ROI_counter).PM(PM_counter).vector = regressors(ix).pm(zx).vector;
                            ROI(ROI_counter).PM(PM_counter).ROI_numb = ix;
                            PM_counter=PM_counter+1;
                        end
                    end
                    ROI_counter=ROI_counter+1;
                end
            end
            
            %% 4. Covariates
            % 4.1 Load covariate regressors (motion, CSF, ...)
            if ~(contains(covarSuffix,'_v0'))
                covariates_file = spm_select('FPList',covarDir,['^' subjAbrev '.*' covarSuffix]);    
                load(covariates_file,'covar');
                % 4.2 Save covariate input 0and names
                R = [covar.value];
                names = {covar.name};
                save([outputDir filesep 'cov.mat'],'R','names')
                COV = [outputDir filesep 'cov.mat'];
            elseif contains(covarSuffix,'_v0')
                COV = [];
            end
            
            %% 5. Explicit mask
%             explicit_mask = '/zi-flstorage/data/jonathan/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6_polished.nii';
            explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';
            
            %% 6. Define microtime resolution (fmri_t) and microtime onset (fmri_t0)
            nSlices = 22;
            refSlice = 1;
            fmri_t = 22;
            fmri_t0 = 1;
            
            %% 7. Masking threshold and TR
            mask_thres = 0;
            TR = 1.2;
            
            %% --------------------------- SPM GLM --------------------------------
            if 1==1
                % load animal HRF
                if ~contains(HRF_onset,'philipplebhardt')
                    addpath(genpath(['/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal/' HRF_TCbased '/hrf_' HRF_infopath]));
                else
                    addpath(genpath(['/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal/hrf_philipplebhardt']));
                end
                
                % run first-level analysis
                do_firstlevel_jr(Pfuncall,ROI,COV,DerDisp,explicit_mask,fmri_t,fmri_t0,TR,outputDir,mask_thres,orth)
            end
            toc
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% ------------------------ SECOND-LEVEL ANALYSIS ---------------------- %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if 1==1
        %% 1. Create output directory
        outputDir_secondlevel = [resultsDir filesep outputDirName filesep 'secondlevel'];
        if ~exist(outputDir_secondlevel)
            mkdir(outputDir_secondlevel)
        end
        
        %% 2. Load contrast_names.mat
        load([resultsDir filesep outputDirName filesep 'firstlevel' filesep 'contrast_info.mat'],'contrast_info');
        
        %% 3. Explicit mask
%         explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6.nii';
        explicit_mask = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';
        
        
        %% 4. Define firstlevel-result directory
        firstlevelDir = [resultsDir filesep outputDirName filesep 'firstlevel'];
        
        
        do_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask)
    end
end










