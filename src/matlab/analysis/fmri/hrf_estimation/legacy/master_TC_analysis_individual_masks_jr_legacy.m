%% master_TC_analysis_individual_masks_jr
% Reinwald, Jonathan 12/2021
% "master_TC_analysis_jr" calculates the mean timecourse for specified regions
% of interest (ROIs)

% Preparation:
% Run master_GLM_residuals_jr.m before to create the residual nii-files

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

% HRF selection
hrf_new=1;

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

% general result directory
maskDir_base = '/home/jonathan.reinwald/ICON_HRF/04-analyses/01-GLM/03-results';
% outputDirName
regressorsSuffix_mask = '_v1.mat';
date_mask='03-Aug-2021';
if hrf_new == 1
    maskDir = [maskDir_base filesep 'NewHRF_EPI_' epiPrefix(1:15) '___ROI_' regressorsSuffix_mask(2:end-4) '___COV_' covarSuffix(2:3) '____Orth_' num2str(orth) '_' date_mask];
else
    maskDir = [maskDir_base filesep 'EPI_' epiPrefix(1:15) '___ROI_' regressorsSuffix_mask(2:end-4) '___COV_' covarSuffix(2:3) '____Orth_' num2str(orth) '_' date_mask];
end

% firstlevel directory
firstleveldir = [resultsDir filesep outputDirName filesep 'firstlevel_residuals'];
% protocol directory
protocol_dir = '/home/jonathan.reinwald/ICON_HRF/03-processed-data/01-processed_protocol_files';

% definition whether to use der or not
DerDisp=[0 0];

% sessect selection
sessions = [1:11];

% highres
highres_val = 6;

% define odor delay
odor_delay = 0.7;

% load filelist
load('/home/jonathan.reinwald/ICON_HRF/03-processed-data/03-filelists/filelist_ICON_hrf_jr.mat','P3d','Pdmap','Pfunc','Pfunc_subjName')

% Define session path ...
dirlist = dir(firstleveldir);
dirlist = dirlist(contains({dirlist.name},'ZI_M'));
numbersess = numel(dirlist);

% savedir
if hrf_new==1
    newdir = [resultsDir filesep outputDirName filesep 'meanTC' filesep 'individual_odor_mask_2sHRF'];
elseif hrf_new==0
    newdir = [resultsDir filesep outputDirName filesep 'meanTC' filesep 'individual_odor_mask_1sHRF'];
end
mkdir(newdir);


%% LET'S GETTING STARTED ...
for sess=sessions
    
    %% Preparation of current session
    % get sessiondir ...
    sessiondir = [firstleveldir filesep dirlist(sess).name];
    
    % select ...
    Pcur=spm_select('FpList', sessiondir ,['^4D_residuals_' dirlist(sess).name '.nii']);
    
    % mask
    if hrf_new==1
        Pmsk_cur=spm_select('FpList',[maskDir filesep 'firstlevel' filesep dirlist(sess).name],[dirlist(sess).name '_odormask_2sHRF.nii']);
    elseif hrf_new==0
        Pmsk_cur=spm_select('FpList',[maskDir filesep 'firstlevel' filesep dirlist(sess).name],[dirlist(sess).name '_odormask_1sHRF.nii']);        
    end
    %% Get meanTc of current session ...
    cd(newdir);
    [tc roidata]=wwf_roi_tcours_old(Pmsk_cur,Pcur);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%  MEAN TC (actually just a control...)  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %% Modify tc ...
    
    % detrend data ...
    tc_detr = detrend(tc);
    
    % normalize data ..
    tc_detr_norm = zscore(tc_detr);
    
    % highres tc
    tc_detr_norm_highres = nan(1,length(tc_detr_norm)*highres_val);
    tc_detr_norm_highres(1,1:highres_val:(length(tc_detr_norm)*highres_val)) = tc_detr_norm;
    
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
    TRs_after = 40;
    TRs_before = 8;
    
    %% Using all rewarded/non-rewarded trials independent of post-licks
    % tc values are saved in matrsess_nonrew and matrsess_rew;
    % rows = trials, columns = frames
    %% Odor with 0.5s duration
    odoronset{1} = ceil(([events([events.fv_dur_del25]>0.45 & [events.fv_dur_del25]<0.55).fv_on_del25] + odor_delay)/(TR));
    odoronset_highres{1} = ceil(([events([events.fv_dur_del25]>0.45 & [events.fv_dur_del25]<0.55).fv_on_del25] + odor_delay)/(TR/highres_val));
    odoronset_precise{1} = (([events([events.fv_dur_del25]>0.45 & [events.fv_dur_del25]<0.55).fv_on_del25] + odor_delay)/(TR));
    
    odoroffset{1} = floor(([events([events.fv_dur_del25]>0.45 & [events.fv_dur_del25]<0.55).fv_off_del25] + odor_delay)/(TR));
    odoroffset_highres{1} = floor(([events([events.fv_dur_del25]>0.45 & [events.fv_dur_del25]<0.55).fv_off_del25] + odor_delay)/(TR/highres_val));
    odoroffset_precise{1} = (([events([events.fv_dur_del25]>0.45 & [events.fv_dur_del25]<0.55).fv_off_del25] + odor_delay)/(TR));    
    
    matrsess_tc{1} = [];
    matrsess_tc_highres{1}=[];
    tc_matrsess_all{1}.duration = '500 ms'
    
    %% Odor with 1s duration
    odoronset{2} = ceil(([events([events.fv_dur_del25]>0.95 & [events.fv_dur_del25]<1.05).fv_on_del25] + odor_delay)/(TR));
    odoronset_highres{2} = ceil(([events([events.fv_dur_del25]>0.95 & [events.fv_dur_del25]<1.05).fv_on_del25] + odor_delay)/(TR/highres_val));
    odoronset_precise{2} = (([events([events.fv_dur_del25]>0.95 & [events.fv_dur_del25]<1.05).fv_on_del25] + odor_delay)/(TR));
    
    odoroffset{2} = floor(([events([events.fv_dur_del25]>0.95 & [events.fv_dur_del25]<1.05).fv_off_del25] + odor_delay)/(TR));
    odoroffset_highres{2} = floor(([events([events.fv_dur_del25]>0.95 & [events.fv_dur_del25]<1.05).fv_off_del25] + odor_delay)/(TR/highres_val));
    odoroffset_precise{2} = (([events([events.fv_dur_del25]>0.95 & [events.fv_dur_del25]<1.05).fv_off_del25] + odor_delay)/(TR));    
    
    matrsess_tc{2} = [];
    matrsess_tc_highres{2}=[];
    tc_matrsess_all{2}.duration = '1000 ms'
    
    %% Odor with 2.4s duration
    odoronset{3} = ceil(([events([events.fv_dur_del25]>2.35 & [events.fv_dur_del25]<2.45).fv_on_del25] + odor_delay)/(TR));
    odoronset_highres{3} = ceil(([events([events.fv_dur_del25]>2.35 & [events.fv_dur_del25]<2.45).fv_on_del25] + odor_delay)/(TR/highres_val));
    odoronset_precise{3} = (([events([events.fv_dur_del25]>2.35 & [events.fv_dur_del25]<2.45).fv_on_del25] + odor_delay)/(TR));
    
    odoroffset{3} = floor(([events([events.fv_dur_del25]>2.35 & [events.fv_dur_del25]<2.45).fv_off_del25] + odor_delay)/(TR));
    odoroffset_highres{3} = floor(([events([events.fv_dur_del25]>2.35 & [events.fv_dur_del25]<2.45).fv_off_del25] + odor_delay)/(TR/highres_val));
    odoroffset_precise{3} = (([events([events.fv_dur_del25]>2.35 & [events.fv_dur_del25]<2.45).fv_off_del25] + odor_delay)/(TR));    
    
    matrsess_tc{3} = [];
    matrsess_tc_highres{3}=[];
    tc_matrsess_all{3}.duration = '2400 ms'
    
    for iii = 1:length(tc_matrsess_all)
        tc_matrsess_all{iii}.TRs_before = TRs_before;
        tc_matrsess_all{iii}.TRs_after = TRs_after;
        tc_matrsess_all{iii}.highres_val = highres_val;
        tc_matrsess_all{iii}.TROdor_onset = TRs_before + 1;
        tc_matrsess_all{iii}.TROdor_onset_highres = TRs_before*highres_val + 1;
    end
        
    for ii = 1:length(odoronset)
        for i = 1:numel(odoronset{ii})
            OnsetFrame_cur = odoronset{ii}(i); % frame of odor exposition
            OffsetFrame_cur = odoroffset{ii}(i);
            OnsetFrame_cur_highres = odoronset_highres{ii}(i); % frame of odor exposition
            OffsetFrame_cur_highres = odoroffset_highres{ii}(i); % frame of odor exposition

            if OnsetFrame_cur <= 1 % occured in one sess ...
                OnsetFrame_cur = 2;
            end
            
            Index_frames_cur = (OnsetFrame_cur-TRs_before):1:(OnsetFrame_cur+TRs_after); % index
            Index_frames_cur_highres = (OnsetFrame_cur_highres-(TRs_before*highres_val):1:(OnsetFrame_cur_highres+(highres_val-1)+TRs_after*highres_val)); % index

            % write tc values for current trial to matrsess ...
            matrsess_tc{ii}(i,:) = tc_detr_norm(Index_frames_cur);
            matrsess_tc_highres{ii}(i,:) = tc_detr_norm_highres(Index_frames_cur_highres);
            
            % write "odor" TC 
            odorsess_tc{ii}(i,1:length(Index_frames_cur)) = 0;
            odorsess_tc{ii}(i,TRs_before+1:TRs_before+1+(OffsetFrame_cur-OnsetFrame_cur)) = 1;
            odorsess_tc_highres{ii}(i,1:length(Index_frames_cur_highres)) = 0;
            odorsess_tc_highres{ii}(i,(TRs_before*highres_val+1):(TRs_before*highres_val+1+(OffsetFrame_cur_highres-OnsetFrame_cur_highres))) = 1;
            
        end
        tc_matrsess_all{ii}.mat(sess,:,:)=matrsess_tc{ii};
        tc_matrsess_all{ii}.mat_highres(sess,:,:)=matrsess_tc_highres{ii};
        
        tc_matrsess_all{ii}.odormat(sess,:,:)=odorsess_tc{ii};
        tc_matrsess_all{ii}.odormat_highres(sess,:,:)=odorsess_tc_highres{ii};
    end
end

% Save directory ...
save([newdir filesep 'tc_matrsess_all.mat'],'tc_matrsess_all');


