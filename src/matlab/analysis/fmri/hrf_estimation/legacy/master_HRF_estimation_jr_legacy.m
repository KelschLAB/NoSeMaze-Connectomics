%% master_HRF_estimation_jr.m
% Reinwald, Jonathan; 08/2021

%% BASED on:
% Magdalena Boch, Sabrina Karl, Ronald Sladky, Ludwig Huber, Claus Lamm, Isabella C. Wagner,
% Tailored haemodynamic response function increases detection power of fMRI in awake dogs (Canis familiaris),
% NeuroImage, Volume 224, 2021, 117414, ISSN 1053-8119, https://doi.org/10.1016/j.neuroimage.2020.117414.
% (https://www.sciencedirect.com/science/article/pii/S1053811920308995)

%% General Idea:
% SPM-based GLM (regression) on the mean timecourses (y) of selected brain
% regions using HRF-convoluted onsets (all three durations). The
% convolution of the onsets is done with different HRFs, characterized by
% (flexible) HRF-parameters. R² characterizes the fit of the convolved
% onsets with the mean timecourse, so we use fminsearch to find the optimal
% HRF parameters to get the maximal R²-value. The whole process is done on
% single session level.

% The following input is needed:
% 1.) Mean timecourses (y) of respective regions from the roidata.mat-files in
% the TC-analysis-folder.
% 2.) Onsets as a binary vector --> maybe integrate high-resolution here

%% Preparation
% clearing
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/ICON_HRF/01-scripts'))
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))

% 1.) mean timecourse directory (SPM-firstlevel from TC analysis)
meantc_dir = '/home/jonathan.reinwald/ICON_HRF/04-analyses/02-TC_analysis/03-results/EPI_msk_s5_rwrst_a1___ROI_v99___COV_v1____Orth_1_29-Jul-2021/firstlevel_residuals'

% 2.) onset directory (SPM-firstlevel from GLM analysis)
onsets_dir = '/home/jonathan.reinwald/ICON_HRF/04-analyses/01-GLM/03-results/EPI_msk_s5_rwrst_a1___ROI_v1___COV_v1____Orth_1_03-Aug-2021/firstlevel'

% highres
highres = 1;

% with Onset delay ("zero-baseline" at beginning)
onset_active = 0;

% hrf_new (selection of masks based on 2s HRF (hrf_new=1) or 1s HRF
% (hrf_new=0)
hrf_new = 0;

% session selection
sessions = [1:11];

region='odormask'; %'AON_inPax_smoothed'%'olf_bulb_inPax_smoothed';%'APC_inPax_reduced';%'olf_tubercle_smoothed';%'olf_bulb_inPax_smoothed';%'AON_inPax_smoothed''AON_inPax_smoothed'%

% load filelist
load('/home/jonathan.reinwald/ICON_HRF/03-processed-data/03-filelists/filelist_ICON_hrf_jr.mat','P3d','Pdmap','Pfunc','Pfunc_subjName')

% define different starting points (p(1),p(2),p(5),p(6)
% limits:
% delay of response
p1_steps=[1:0.5:4];
% delay of undershoot
p2_steps=[4:3:10];
% dispersion of response and undershoot
p3_steps=[0.5:0.5:1.5];
% ratio of response to undershoot
p4_steps=[3:1.75:10];
% only of onset is active
if onset_active == 1
    % onset (seconds)
    p5_steps=[0.2:0.4:1];
end
% create x0-matrix
clear x0
counter = 1;
for i_p1=1:length(p1_steps)
    for i_p2=1:length(p2_steps)
        for i_p3=1:length(p3_steps)
            for i_p4=1:length(p4_steps)
                % onset active: 5 onsetstarting points
                if onset_active == 1
                    for i_p5=1:length(p5_steps)
                        x0(counter,1)=p1_steps(i_p1);
                        x0(counter,2)=p2_steps(i_p2);
                        x0(counter,3)=p3_steps(i_p3);
                        x0(counter,4)=p4_steps(i_p4);
                        x0(counter,5)=p5_steps(i_p5);
                        counter=counter+1;
                    end
                % onset inactive: 4 starting points
                elseif onset_active == 0
                    x0(counter,1)=p1_steps(i_p1);
                    x0(counter,2)=p2_steps(i_p2);
                    x0(counter,3)=p3_steps(i_p3);
                    x0(counter,4)=p4_steps(i_p4);
                    counter=counter+1;
                end
            end
        end
    end
end

% pre-clearing
clear meanTC mask_temp SPM_file

%% Preparation of input for parfor loop
for sess = 1:length(sessions)
    
    %% ----------- Preparation of input within loop -----------------------
    [fdir, fname, ext]=fileparts(Pfunc{sess});
    sessAbrev = fname(1:11)
    
    %% 1. Load mean timecourse
    % load roidata.mat
    if ~contains(region,'odormask')
        mask_temp{sess} = load([meantc_dir filesep sessAbrev filesep '4D_residuals_' sessAbrev '_' region '_roidata.mat']);
    elseif contains(region,'odormask') & hrf_new==1
        mask_temp{sess} = load([meantc_dir filesep sessAbrev filesep '4D_residuals_' sessAbrev '_' sessAbrev '_' region '_2sHRF_roidata.mat']);
    elseif contains(region,'odormask') & hrf_new==0
        mask_temp{sess} = load([meantc_dir filesep sessAbrev filesep '4D_residuals_' sessAbrev '_' sessAbrev '_' region '_1sHRF_roidata.mat']);
    end
    % calculate mean timecourse
    meanTC{sess} = mean(mask_temp{sess}.roidata.tc);
    
    %% 2. SPM.mat file
    % load SPM.mat
    SPM_file{sess} = load([onsets_dir filesep sessAbrev filesep 'SPM.mat']);
    %% high resolution
    if highres == 1
        % calculate onset vector (high resolution) from SPM.Sess.U(1).u
        % (binarized onsets for different durations)
        onsets{sess} = SPM_file{sess}.SPM.Sess.U(1).u + SPM_file{sess}.SPM.Sess.U(2).u + SPM_file{sess}.SPM.Sess.U(3).u;
        % clear of the first 32 timepoints that SPM automatically added is
        onsets{sess}(1:32,:)=[];
        % make a full vector
        onsets{sess}=full(onsets{sess});
    else
        %% Low resolution
        SPM_file{sess}.SPM.xBF.dt=SPM_file{sess}.SPM.xY.RT
        SPM_file{sess}.SPM.xBF.T=1
        U = spm_get_ons(SPM,1);
        onsets{sess} = U(1).u+U(2).u+U(3).u;
        onsets{sess}=full(onsets{sess});
        onsets{sess}(1:32,:)=[];
    end
end

%% 3. Settings for TR, T, T0
tr = 0.265; % repetition time
T = 6; % number of slices
T0 = 1; % slice time correction to first slice

%% Loop over animals/sessions
% parpool(12);
% par
for sess = 1:length(sessions)
    [rsq_all(sess,:),hrf_param_all(sess,:,:)]=master_fmin(meanTC{sess},onsets{sess},tr,T,T0,x0,highres);
end
delete(gcp);

% concatenation hrf and rsq
hrf_param_concatenated=[];
rsq_concatenated=[];
for ix=1:size(hrf_param_all,1)
    hrf_param_concatenated=[hrf_param_concatenated;squeeze(hrf_param_all(ix,rsq_all(ix,:)'>mean(rsq_all(ix,:)'),:))];
    rsq_concatenated=[rsq_concatenated;rsq_all(ix,rsq_all(ix,:)'>mean(rsq_all(ix,:)'))'];
end

% estimation of hrf_val
hrf_val=mean(hrf_param_concatenated(rsq_concatenated>0,:));
figure(1);
if onset_active==1
    plot([0:1:320],spm_hrf(0.1,[hrf_val(1),hrf_val(2),hrf_val(3),hrf_val(3),hrf_val(4),hrf_val(5),32]));
elseif onset_active==0
    plot([0:1:320],spm_hrf(0.1,[hrf_val(1),hrf_val(2),hrf_val(3),hrf_val(3),hrf_val(4),0,32]));    
end
ax=gca;
ax.XLabel.String='time [s]';
ax.XTick=[0:50:320];
ax.XTickLabel={[0:50:320]./10};

% save directory
if hrf_new==1 && size(x0,2)==5
    saveDir=['/home/jonathan.reinwald/ICON_HRF/04-analyses/03-HRF_estimation' filesep 'longTC' filesep 'withOnset_from2sHRF-GLM'];
elseif hrf_new==0 && size(x0,2)==5
    saveDir=['/home/jonathan.reinwald/ICON_HRF/04-analyses/03-HRF_estimation' filesep 'longTC' filesep 'withOnset_from1sHRF-GLM'];
elseif hrf_new==1 && size(x0,2)==4
    saveDir=['/home/jonathan.reinwald/ICON_HRF/04-analyses/03-HRF_estimation' filesep 'longTC' filesep 'withoutOnset_from2sHRF-GLM'];
elseif hrf_new==0 && size(x0,2)==4
    saveDir=['/home/jonathan.reinwald/ICON_HRF/04-analyses/03-HRF_estimation' filesep 'longTC' filesep 'withoutOnset_from2sHRF-GLM'];
end
mkdir(saveDir);

% info-file
info.startingpoints = x0;
info.hrf_param_all = hrf_param_all;
info.hrf_param_concatenated = hrf_param_concatenated;
info.hrf_val = hrf_val;
info.rsq_all=rsq_all;
info.rsq_concatenated=rsq_concatenated;
info.mean_rsq=mean(rsq_concatenated(rsq_concatenated>0));

% save
save([saveDir filesep 'hrf_info.mat'],'info');
print('-dpsc',[saveDir filesep 'HRF_plot'],'-r400','-fillpage');
print('-dpdf',[saveDir filesep 'HRF_plot'],'-r400','-fillpage');

function [rsq,hrf_param]=master_fmin(meanTC,onsets,tr,T,T0,x0,highres)
%% ----------- Find optimal parameters using fminsearch -----------
% script based on estimate_GLM_model, modified: only 4 variable
% input parameters; works on high resolution (X = onsets should be
% in high resolution); T as an additional input defining the higher
% resolution (tr/T), T-times higher resolution;
%

% definition of function with input
if highres == 1
    fun = @(x)-1.*estimate_GLM_model_highres(meanTC, onsets, tr, T, T0, x);
else
    fun = @(x)-1.*estimate_GLM_model_lowres(meanTC, onsets, tr, x);
end
% set options (maximum number of evaluations)
options = optimset('MaxFunEvals',100000);

% activate for illustration of minsearch
% options = optimset('PlotFcns',@optimplotfval);

% Loop over start points
for ix = 1:size(x0,1)
    %% FMINSEARCH
    % actual fminsearch with different starting parameters
    x = fminsearch(fun,x0(ix,:),options);
    % % %             %% FMINCON
    % % %             % setting of boundaries
    % % %             lb = [1,3,0,1,0]; ub=[4,7,1,10,1];%             lb = [1,1,1]; ub=[5,7,10];
    % % %             % actual fmincon with different starting parameters
    % % %             x_2 = fmincon(fun,x0{ix},[1,-1,0,0,0.5],[0],[],[],lb,ub);
    
    % saving and plotting of the respective optimum (x or x_2) running the
    % function manually with the optifun = @(x)mal input
    if highres == 1
        [r2s bs X_hrf] = estimate_GLM_model_highres(meanTC, onsets, tr, T, T0, x);
        % % %                 [r2s_2 bs X_hrf] = estimate_GLM_model_highres(meanTC, onsets, tr, T, T0, x_2);
    else
        [r2s bs X_hrf] = estimate_GLM_model_lowres(meanTC, onsets, tr, x);
        % % %                 [r2s_2 bs X_hrf] = estimate_GLM_model_lowres(meanTC, onsets, tr, x_2);
    end
    
    % save r²-values in vector
    rsq(ix) = r2s;
    % % %             rsq_2(sess,ix) = r2s_2;
    % save the hrf_parameters
    hrf_param(ix,:) = x;
    % % %             hrf_param_all_2(ix,:,sess) = x_2;
    % plot for illustration
    %             plot(spm_hrf(0.1,[hrf_param_all(ix,1,sess),hrf_param_all(ix,2,sess),1,1,hrf_param_all(ix,3,sess),0,32]));
    % % %             plot(spm_hrf(0.265,[hrf_param_all(ix,1,sess),hrf_param_all(ix,2,sess),hrf_param_all(ix,3,sess),hrf_param_all(ix,3,sess),hrf_param_all(ix,4,sess),hrf_param_all(ix,5,sess),32]));
    % % %             hold on;
    %             plot(spm_hrf(0.1,[hrf_param_all_2(ix,1,sess),hrf_param_all_2(ix,2,sess),1,1,hrf_param_all_2(ix,3,sess),0,32]),'--');
    % % %             plot(spm_hrf(0.265,[hrf_param_all_2(ix,1,sess),hrf_param_all_2(ix,2,sess),hrf_param_all_2(ix,3,sess),hrf_param_all(ix,3,sess),hrf_param_all_2(ix,4,sess),hrf_param_all(ix,5,sess),32]),'--');
    
    % % %             ax=gca; ax.XLim=[0,100];
    % % %             hold on;
end
end