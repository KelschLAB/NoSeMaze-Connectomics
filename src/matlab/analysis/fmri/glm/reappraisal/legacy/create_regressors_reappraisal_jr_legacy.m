%% create_regressors_reappraisal_jr.m
% Reinwald, Jonathan 01/2021

% Info:
% - create regressors of interest (ROIs) including parametric modulation (if used) as an input for the firstlevel GLM


%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'))

% define paths...
protocol_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/01-processed_protocol_files';
outputdir='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/05-GLM/02-regressors';

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/03-filelists/filelist_ICON_reappraisal_jr.mat');

% predefine odor_delay
% = delay between fv_on and the perception of the odor at the port
% estimated using the mini-PID (e.g. 600 to 700 ms)
odor_delay = 0.7;

%% For investigation of motion artifacts using "split-half" test
% load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/01-preprocessing/01-motion/plot_CorrMotionToParadigm/puff_on_frames_lowMot.mat');
load('/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/01-reappraisal/01-preprocessing/01-motion/plot_CorrMotionToParadigm/FD_late_highlowMot.mat');

%% Loop over animals
for subj = 1:length(Pfunc_reappraisal)
    % clear variables
    clear protocol_file regressors
    
    %% 1. find and load processed protocol file
    [fpath,fname,ext]=fileparts(Pfunc_reappraisal{subj});
    protocol_file = dir([protocol_dir filesep 'animal_' fname(5:6) filesep 'animal_' fname(5:6) '*.*']);
    load([protocol_file.folder filesep protocol_file.name]);
    
    %% 2. write information into regressors-file
    % select those manually
    
% % %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     %% Lavender
% % %     regressors(1).name = 'OdorON_Bl1_1to10';
% % %     % Onset: CAVE: if onset is an odor, add the delay!;
% % %     regressors(1).onset = [events(1:10).fv_on_del5]+odor_delay;
% % %     % 0 = event-related; value=block;
% % %     regressors(1).duration = 0;
% % %     % Parametric modulation
% % %     regressors(1).pm = [];
% % %     
% % %     %% Lavender
% % %     regressors(2).name = 'OdorON_Bl1_11to40';
% % %     % Onset: CAVE: if onset is an odor, add the delay!;
% % %     regressors(2).onset = [events(11:40).fv_on_del5]+odor_delay;
% % %     % 0 = event-related; value=block;
% % %     regressors(2).duration = 0;
% % %     % Parametric modulation
% % %     regressors(2).pm = [];
% % %     
% % %     %% Lavender
% % %     regressors(3).name = 'OdorON_Bl2_NoPuff';
% % %     % Onset: CAVE: if onset is an odor, add the delay!;
% % %     regressors(3).onset = [events([find([events(41:80).puff_or_not]==0)+40]).fv_on_del5]+odor_delay;
% % %     % 0 = event-related; value=block;
% % %     regressors(3).duration = 0;
% % %     % Parametric modulation
% % %     regressors(3).pm = [];
% % %     
% % %     %% Lavender
% % %     regressors(4).name = 'OdorON_Bl2_Puff';
% % %     % Onset: CAVE: if onset is an odor, add the delay!;
% % %     regressors(4).onset = [events([events.puff_or_not]==1).fv_on_del5]+odor_delay;
% % %     % 0 = event-related; value=block;
% % %     regressors(4).duration = 0;
% % %     % Parametric modulation
% % %     regressors(4).pm = [];
% % %     
% % %     
% % %     %% Lavender
% % %     regressors(5).name = 'OdorON_Bl3';
% % %     % Onset: CAVE: if onset is an odor, add the delay!;
% % %     regressors(5).onset = [events(81:120).fv_on_del5]+odor_delay;
% % %     % 0 = event-related; value=block;
% % %     regressors(5).duration = 0;
% % %     % Parametric modulation
% % %     regressors(5).pm = [];
% % %     
% % %     
% % %     %% Time-Point of Puff
% % %     regressors(6).name = 'OdorOFF_Bl1_1to10';
% % %     % Onset: CAVE: if onset is an odor, add the delay!;
% % %     regressors(6).onset = [events(1:10).fv_on_del5]+odor_delay+2.4;
% % %     % 0 = event-related; value=block;
% % %     regressors(6).duration = 0;
% % %     % Parametric modulation
% % %     regressors(6).pm = [];
% % %     
% % %     %% Time-Point of Puff
% % %     regressors(7).name = 'OdorOFF_Bl1_11to40';
% % %     % Onset: CAVE: if onset is an odor, add the delay!;
% % %     regressors(7).onset = [events(11:40).fv_on_del5]+odor_delay+2.4;
% % %     % 0 = event-related; value=block;
% % %     regressors(7).duration = 0;
% % %     % Parametric modulation
% % %     regressors(7).pm = [];
% % %     
% % %     %% Time-Point of Puff
% % %     regressors(8).name = 'OdorOFF_Bl2_NoPuff';
% % %     % Onset: CAVE: if onset is an odor, add the delay!;
% % %     regressors(8).onset = [events([find([events(41:80).puff_or_not]==0)+40]).fv_on_del5]+odor_delay+2.4;
% % %     % 0 = event-related; value=block;
% % %     regressors(8).duration = 0;
% % %     % Parametric modulation
% % %     regressors(8).pm = [];
% % %     
% % %     %% Time-Point of Puff
% % %     regressors(9).name = 'OdorOFF_Bl2_Puff';
% % %     % Onset: CAVE: if onset is an odor, add the delay!;
% % %     regressors(9).onset = [events([events.puff_or_not]==1).fv_on_del5]+odor_delay+2.4;
% % %     % 0 = event-related; value=block;
% % %     regressors(9).duration = 0;
% % %     % Parametric modulation
% % %     regressors(9).pm = [];
% % %     
% % %     
% % %     %% Time-Point of Puff
% % %     regressors(10).name = 'OdorOFF_Bl3';
% % %     % Onset: CAVE: if onset is an odor, add the delay!;
% % %     regressors(10).onset = [events(81:120).fv_on_del5]+odor_delay+2.4;
% % %     % 0 = event-related; value=block;
% % %     regressors(10).duration = 0;
% % %     % Parametric modulation
% % %     regressors(10).pm = [];
% % %         
% % %     suffix = 'v25';
    
    
    
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %% Lavender
%             regressors(1).name = 'Lavender';
%             % Onset: CAVE: if onset is an odor, add the delay!;
%             regressors(1).onset = [events.fv_on_del5]+odor_delay;
%             % 0 = event-related; value=block;
%             regressors(1).duration = 2.4;
%             % Parametric modulation
%             regressors(1).pm = [];
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %% Traditional regressor Puff
%             % Time-Point of Puff
%             regressors(2).name = 'Puff';
%             % Onset: no delay for the airpuff
%             regressors(2).onset = [events([events.puff_or_not]==1).puff_time_del5];
%             % 0 = event-related; value=block;
%             regressors(2).duration = 0;
%             % Parametric modulation
%             regressors(2).pm = [];
%             
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             %% Traditional regressor No Puff
%             % Time-Point of Puff
%             regressors(3).name = 'TP NoPuff';
%             % Onset: no delay for the airpuff
%             regressors(3).onset = [events([events.puff_or_not]==0).puff_time_del5];
%             % 0 = event-related; value=block;
%             regressors(3).duration = 0;
%             % Parametric modulation
%             regressors(3).pm = [];
%             
%             suffix = 'v23';

    %
%             % Late TP
%             regressors(3).name = 'Late TP1 HighMot (Odor+6s)';
%             % Onset: CAVE: if onset is an odor, add the delay!;
%             regressors(3).onset = [events([FD_late_high(subj,1:2:240)]).fv_on_del5]+odor_delay+5*1.2;
%             [events([FD_late_high(subj,1:2:240)]).fv_on_del5]+odor_delay+5*1.2;
%             % 0 = event-related; value=block;
%             regressors(3).duration = 1.2;
%             % Parametric modulation
%             regressors(3).pm = [];
%     
%             % Late TP
%             regressors(4).name = 'Late TP1 LowMot (Odor+6s)';
%             % Onset: CAVE: if onset is an odor, add the delay!;
%             regressors(4).onset = [events([FD_late_low(subj,1:2:240)]).fv_on_del5]+odor_delay+5*1.2;
%             % 0 = event-related; value=block;
%             regressors(4).duration = 1.2;
%             % Parametric modulation
%             regressors(4).pm = [];
%     
%             % Late TP
%             regressors(5).name = 'Late TP2 HighMot (Odor+7.2s)';
%             % Onset: CAVE: if onset is an odor, add the delay!;
%             regressors(5).onset = [events([FD_late_high(subj,2:2:240)]).fv_on_del5]+odor_delay+6*1.2;
%             % 0 = event-related; value=block;
%             regressors(5).duration = 1.2;
%             % Parametric modulation
%             regressors(5).pm = [];
%     
%             % Late TP
%             regressors(6).name = 'Late TP2 LowMot (Odor+7.2s)';
%             % Onset: CAVE: if onset is an odor, add the delay!;
%             regressors(6).onset = [events([FD_late_low(subj,2:2:240)]).fv_on_del5]+odor_delay+6*1.2;
%             % 0 = event-related; value=block;
%             regressors(6).duration = 1.2;
%             % Parametric modulation
%             regressors(6).pm = [];
%     
%             % define suffix of the respective .mat-files
%             suffix = 'v20';
    %
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     %% Traditional regressor Puff with PM
    %     %% Time-Point of Puff
    %     regressors(2).name = 'TP Puff';
    %     % Onset: no delay for the airpuff
    %     regressors(2).onset = [events.puff_time_del5];
    %     % 0 = event-related; value=block;
    %     regressors(2).duration = 1;
    %
    %     % Parametric modulation
    %     regressors(2).pm.name = 'PM TP Puff with Puff_or_Not';
    %     regressors(2).pm.vector = [events.puff_or_not];
    %     suffix = 'v2';
    
    
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     % Motion investigation split-half test (lower vs. higher than mean FD)
    %     % Time-Point of Puff
    %     regressors(2).name = 'Puff_LowMotion';
    %     %     Onset: no delay for the airpuff
    %     puff_on_vec = [events([events.puff_or_not]==1).puff_time_del5];
    %     regressors(2).onset = puff_on_vec(puff_on_frames_lowMot(subj,:)==1);
    %     %     0 = event-related; value=block;
    %     regressors(2).duration = 1;
    %
    %     % Time-Point of Puffaddpath /home/jonathan.reinwald/Documents/MATLAB/spm12/;
    %     regressors(3).name = 'Puff_HighMotion';
    %     %     Onset: no delay for the airpuff
    %     puff_on_vec = [events([events.puff_or_not]==1).puff_time_del5];
    %     regressors(3).onset = puff_on_vec(puff_on_frames_lowMot(subj,:)==0);
    %     %     0 = event-related; value=block;
    %     regressors(3).duration = 1;
    %     suffix = 'v3';
    
    %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %         %% Lavender
    %         regressors(1).name = 'Lavender';
    %         % Onset: CAVE: if onset is an odor, add the delay!;
    %         regressors(1).onset = [events.fv_on_del5]+odor_delay;
    %         % 0 = event-related; value=block;
    %         regressors(1).duration = 2.4;
    %         % Parametric modulation
    %         regressors(1).pm.name = 'Lavender with 1 0 -1';
    %         regressors(1).pm.vector = [ones(1,40),zeros(1,40),-1*ones(1,40)];
    %
    %         %% Traditional regressor Puff
    %         %% Time-Point of Puff
    %         regressors(2).name = 'Puff';
    %         % Onset: no delay for the airpuff
    %         regressors(2).onset = [events([events.puff_or_not]==1).puff_time_del5];
    %         % 0 = event-related; value=block;
    %         regressors(2).duration = 1;
    %         % define suffix of the respective .mat-files
    %         suffix = 'v4';
    
    %     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     %% Lavender
    %     regressors(1).name = 'Lavender';
    %     % Onset: CAVE: if onset is an odor, add the delay!;
    %     regressors(1).onset = [events.fv_on_del5]+odor_delay;
    %     % 0 = event-related; value=block;
    %     regressors(1).duration = 2.4;
    %     % Parametric modulation
    %     regressors(1).pm = [];
    %
    %     %% Traditional regressor Puff with PM
    %     %% Time-Point of Puff
    %     regressors(2).name = 'TP Puff';
    %     % Onset: no delay for the airpuff
    %     regressors(2).onset = [events.puff_time_del5];
    %     % 0 = event-related; value=block;
    %     regressors(2).duration = 1;
    %
    %     % Parametric modulation
    %     regressors(2).pm(1).name = 'PM TP Puff with PuffEarly vs PuffLate';
    %     regressors(2).pm(1).vector = [ones(1,40),zeros(1,40),-1*ones(1,40)];
    %     % define suffix of the respective .mat-files
    %     suffix = 'v5';
    
    %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %             %% Lavender
    %             regressors(1).name = 'Lavender + 1 TR';
    %             % Onset: CAVE: if onset is an odor, add the delay!;
    %             regressors(1).onset = [events.fv_on_del5]+odor_delay+1.2;
    %             % 0 = event-related; value=block;
    %             regressors(1).duration = 1.2;
    %             % Parametric modulation
    %             regressors(1).pm.name = 'Lavender with 1 0 -1';
    %             regressors(1).pm.vector = [ones(1,40),zeros(1,40),-1*ones(1,40)];
    %
    %             %% Traditional regressor Puff
    %             %% Time-Point of Puff
    %             regressors(2).name = 'Puff';
    %             % Onset: no delay for the airpuff
    %             regressors(2).onset = [events([events.puff_or_not]==1).puff_time_del5];
    %             % 0 = event-related; value=block;
    %             regressors(2).duration = 1;
    %             % define suffix of the respective .mat-files
    %             suffix = 'v6';
    
    %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %             %% Lavender
    %             regressors(1).name = 'Lavender_Bl1';
    %             % Onset: CAVE: if onset is an odor, add the delay!;
    %             regressors(1).onset = [events(1:40).fv_on_del5]+odor_delay;
    %             % 0 = event-related; value=block;
    %             regressors(1).duration = 2.4;
    %             % Parametric modulation
    %             regressors(1).pm = [];
    %
    %             %% Lavender
    %             regressors(2).name = 'Lavender_Bl2_NoPuff';
    %             % Onset: CAVE: if onset is an odor, add the delay!;
    %             regressors(2).onset = [events([find([events(41:80).puff_or_not]==0)+40]).fv_on_del5]+odor_delay;
    %             % 0 = event-related; value=block;
    %             regressors(2).duration = 2.4;
    %             % Parametric modulation
    %             regressors(2).pm = [];
    %
    %             %% Lavender
    %             regressors(3).name = 'Lavender_Bl2_Puff';
    %             % Onset: CAVE: if onset is an odor, add the delay!;
    %             regressors(3).onset = [events([events.puff_or_not]==1).fv_on_del5]+odor_delay;
    %             % 0 = event-related; value=block;
    %             regressors(3).duration = 2.4;
    %             % Parametric modulation
    %             regressors(3).pm = [];
    %
    %
    %             %% Lavender
    %             regressors(4).name = 'Lavender_Bl3';
    %             % Onset: CAVE: if onset is an odor, add the delay!;
    %             regressors(4).onset = [events(81:120).fv_on_del5]+odor_delay;
    %             % 0 = event-related; value=block;
    %             regressors(4).duration = 2.4;
    %             % Parametric modulation
    %             regressors(4).pm = [];
    %
    %
    %             %% Time-Point of Puff
    %             regressors(5).name = 'TP_Puff_Bl1';
    %             % Onset: CAVE: if onset is an odor, add the delay!;
    %             regressors(5).on/home/jonathan.reinwald/ICON_Autonomouse/results/reappraisal/fMRI/motion/paradigm_motion_correlation/set = [events(1:40).puff_time_del5];
    %             % 0 = event-related; value=block;
    %             regressors(5).duration = 1;
    %             % Parametric modulation
    %             regressors(5).pm = [];
    %
    %             %% Time-Point of Puff
    %             regressors(6).name = 'TP_Puff_Bl2_NoPuff';
    %             % Onset: CAVE: if onset is an odor, add the delay!;
    %             regressors(6).onset = [events([find([events(41:80).puff_or_not]==0)+40]).puff_time_del5];
    %             % 0 = event-related; value=block;
    %             regressors(6).duration = 1;
    %             % Parametric modulation
    %             regressors(6).pm = [];
    %
    %             %% Time-Point of Puff
    %             regressors(7).name = 'TP_Puff_Bl2_Puff';
    %             % Onset: CAVE: if onset is an odor, add the delay!;
    %             regressors(7).onset = [events([events.puff_or_not]==1).puff_time_del5];
    %             % 0 = event-related; value=block;
    %             regressors(7).duration = 1;
    %             % Parametric modulationTP_Puff_Bl2_Puff
    %             regressors(7).pm = [];
    %
    %
    %             %% Time-Point of Puff
    %             regressors(8).name = 'TP_Puff_Bl3';
    %             % Onset: CAVE: if onset is an odor, add the delay!;
    %             regressors(8).onset = [events(81:120).puff_time_del5];
    %             % 0 = event-related; value=block;
    %             regressors(8).duration = 1;
    %             % Parametric modulation
    %             regressors(8).pm = [];
    %
    %             suffix = 'v8';
    
    
    % %     %              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %% Lavender
%     regressors(6).name = 'Lavender_Bl1_1to10';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(6).onset = [events(1:10).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(6).duration = 2.4;
%     % Parametric modulation
%     regressors(6).pm = [];
%     
%     %% Lavender
%     regressors(7).name = 'Lavender_Bl1_11to40';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(7).onset = [events(11:40).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(7).duration = 2.4;
%     % Parametric modulation
%     regressors(7).pm = [];
%     
%     %% Lavender
%     regressors(8).name = 'Lavender_Bl2_NoPuff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(8).onset = [events([find([events(41:80).puff_or_not]==0)+40]).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(8).duration = 2.4;
%     % Parametric modulation
%     regressors(8).pm = [];
%     
%     %% Lavender
%     regressors(9).name = 'Lavender_Bl2_Puff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(9).onset = [events([events.puff_or_not]==1).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(9).duration = 2.4;
%     % Parametric modulation
%     regressors(9).pm = [];
%     
%     
%     %% Lavender
%     regressors(10).name = 'Lavender_Bl3';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(10).onset = [events(81:120).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(10).duration = 2.4;
%     % Parametric modulation
%     regressors(10).pm = [];
%     
%     
%     %% Time-Point of Puff
%     regressors(1).name = 'TP_Puff_Bl1_1to10';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(1).onset = [events(1:10).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(1).duration = 0;
%     % Parametric modulation
%     regressors(1).pm = [];
%     
%     %% Time-Point of Puff
%     regressors(2).name = 'TP_Puff_Bl1_11to40';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(2).onset = [events(11:40).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(2).duration = 0;
%     % Parametric modulation
%     regressors(2).pm = [];
%     
%     %% Time-Point of Puff
%     regressors(3).name = 'TP_Puff_Bl2_NoPuff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(3).onset = [events([find([events(41:80).puff_or_not]==0)+40]).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(3).duration = 0;
%     % Parametric modulation
%     regressors(3).pm = [];
%     
%     %% Time-Point of Puff
%     regressors(4).name = 'TP_Puff_Bl2_Puff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(4).onset = [events([events.puff_or_not]==1).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(4).duration = 0;
%     % Parametric modulation
%     regressors(4).pm = [];
%     
%     
%     %% Time-Point of Puff
%     regressors(5).name = 'TP_Puff_Bl3';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(5).onset = [events(81:120).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(5).duration = 0;
%     % Parametric modulation
%     regressors(5).pm = [];
    
%     suffix = 'v27';
% % % % % % % % % % % % % % % % % % % %     

% % % % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % %     %% Lavender
% % %     regressors(1).name = 'Block_1';
% % %     % Onset: CAVE: if onset is an odor, add the delay!;
% % %     regressors(1).onset = [events(11).fv_on_del5]+odor_delay;
% % %     % 0 = event-related; value=block;
% % %     regressors(1).duration = [events(41).fv_on_del5]+odor_delay-[events(11).fv_on_del5]+odor_delay;
% % %     % Parametric modulation
% % %     regressors(1).pm = [];
% % %     
% % %     %% Lavender
% % %     regressors(2).name = 'Block_2';
% % %     % Onset: CAVE: if onset is an odor, add the delay!;
% % %     regressors(2).onset = [events(41).fv_on_del5]+odor_delay;
% % %     % 0 = event-related; value=block;
% % %     regressors(2).duration = [events(81).fv_on_del5]+odor_delay-[events(41).fv_on_del5]+odor_delay;
% % %     % Parametric modulation
% % %     regressors(2).pm = [];
% % %     
% % %     %% Lavender
% % %     regressors(3).name = 'Block_3';
% % %     % Onset: CAVE: if onset is an odor, add the delay!;
% % %     regressors(3).onset = [events(81).fv_on_del5]+odor_delay;
% % %     % 0 = event-related; value=block;
% % %     regressors(3).duration = [events(120).fv_off_del5]+odor_delay+10-[events(81).fv_on_del5]+odor_delay;
% % %     % Parametric modulation
% % %     regressors(3).pm = [];
% % %         
% % %     suffix = 'v28';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Lavender
    regressors(1).name = 'Lavender_Bl1_1to10';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(1).onset = [events(1:10).fv_on_del5]+odor_delay;
    % 0 = event-related; value=block;
    regressors(1).duration = 0;
    % Parametric modulation
    regressors(1).pm = [];
    
    %% Lavender
    regressors(2).name = 'Lavender_Bl1_11to40';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(2).onset = [events(11:40).fv_on_del5]+odor_delay;
    % 0 = event-related; value=block;
    regressors(2).duration = 0;
    % Parametric modulation
    regressors(2).pm = [];
    
    %% Lavender
    regressors(3).name = 'Lavender_Bl2_NoPuff';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(3).onset = [events([find([events(41:80).puff_or_not]==0)+40]).fv_on_del5]+odor_delay;
    % 0 = event-related; value=block;
    regressors(3).duration = 0;
    % Parametric modulation
    regressors(3).pm = [];
    
    %% Lavender
    regressors(4).name = 'Lavender_Bl2_Puff';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(4).onset = [events([events.puff_or_not]==1).fv_on_del5]+odor_delay;
    % 0 = event-related; value=block;
    regressors(4).duration = 0;
    % Parametric modulation
    regressors(4).pm = [];
    
    
    %% Lavender
    regressors(5).name = 'Lavender_Bl3_early';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(5).onset = [events(81:100).fv_on_del5]+odor_delay;
    % 0 = event-related; value=block;
    regressors(5).duration = 0;
    % Parametric modulation
    regressors(5).pm = [];
    
    %% Lavender
    regressors(6).name = 'Lavender_Bl3_late';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(6).onset = [events(101:120).fv_on_del5]+odor_delay;
    % 0 = event-related; value=block;
    regressors(6).duration = 0;
    % Parametric modulation
    regressors(6).pm = [];
    
    %% Lavender
    regressors(7).name = 'TP_Puff_Bl1_1to10';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(7).onset = [events(1:10).puff_time_del5];
    % 0 = event-related; value=block;
    regressors(7).duration = 0;
    % Parametric modulation
    regressors(7).pm = [];
    
    %% Time-Point of Puff
    regressors(8).name = 'TP_Puff_Bl1_11to40';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(8).onset = [events(11:40).puff_time_del5];
    % 0 = event-related; value=block;
    regressors(8).duration = 0;
    % Parametric modulation
    regressors(8).pm = [];
    
    %% Time-Point of Puff
    regressors(9).name = 'TP_Puff_Bl2_NoPuff';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(9).onset = [events([find([events(41:80).puff_or_not]==0)+40]).puff_time_del5];
    % 0 = event-related; value=block;
    regressors(9).duration = 0;
    % Parametric modulation
    regressors(9).pm = [];
    
    %% Time-Point of Puff
    regressors(10).name = 'TP_Puff_Bl2_Puff';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(10).onset = [events([events.puff_or_not]==1).puff_time_del5];
    % 0 = event-related; value=block;
    regressors(10).duration = 0;
    % Parametric modulation
    regressors(10).pm = [];
    
    %% Time-Point of Puff
    regressors(11).name = 'TP_Puff_Bl3_early';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(11).onset = [events(81:100).puff_time_del5];
    % 0 = event-related; value=block;
    regressors(11).duration = 0;
    % Parametric modulation
    regressors(11).pm = [];
        
    %% Time-Point of Puff
    regressors(12).name = 'TP_Puff_Bl3_late';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(12).onset = [events(101:120).puff_time_del5];
    % 0 = event-related; value=block;
    regressors(12).duration = 0;
    % Parametric modulation
    regressors(12).pm = [];
    
    suffix = 'v26';











%     % %     %              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %% Lavender
%     regressors(1).name = 'Lavender_Bl1_1to10';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(1).onset = [events(1:10).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(1).duration = 2.4;
%     % Parametric modulation
%     regressors(1).pm = [];
%     
%     %% Lavender
%     regressors(2).name = 'Lavender_Bl1_11to40';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(2).onset = [events(11:40).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(2).duration = 2.4;
%     % Parametric modulation
%     regressors(2).pm = [];
%     
%     %% Lavender
%     regressors(3).name = 'Lavender_Bl2_NoPuff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(3).onset = [events([find([events(41:80).puff_or_not]==0)+40]).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(3).duration = 2.4;
%     % Parametric modulation
%     regressors(3).pm = [];
%     
%     %% Lavender
%     regressors(4).name = 'Lavender_Bl2_Puff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(4).onset = [events([events.puff_or_not]==1).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(4).duration = 2.4;
%     % Parametric modulation
%     regressors(4).pm = [];
%     
%     
%     %% Lavender
%     regressors(5).name = 'Lavender_Bl3';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(5).onset = [events(81:120).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(5).duration = 2.4;
%     % Parametric modulation
%     regressors(5).pm = [];
%     
%     
%     %% Time-Point of Puff
%     regressors(6).name = 'TP_Puff_Bl1_1to10';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(6).onset = [events(1:10).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(6).duration = 0;
%     % Parametric modulation
%     regressors(6).pm = [];
%     
%     %% Time-Point of Puff
%     regressors(7).name = 'TP_Puff_Bl1_11to40';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(7).onset = [events(11:40).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(7).duration = 0;
%     % Parametric modulation
%     regressors(7).pm = [];
%     
%     %% Time-Point of Puff
%     regressors(8).name = 'TP_Puff_Bl2_NoPuff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(8).onset = [events([find([events(41:80).puff_or_not]==0)+40]).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(8).duration = 0;
%     % Parametric modulation
%     regressors(8).pm = [];
%     
%     %% Time-Point of Puff
%     regressors(9).name = 'TP_Puff_Bl2_Puff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(9).onset = [events([events.puff_or_not]==1).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(9).duration = 0;
%     % Parametric modulation
%     regressors(9).pm = [];
%     
%     
%     %% Time-Point of Puff
%     regressors(10).name = 'TP_Puff_Bl3';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(10).onset = [events(81:120).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(10).duration = 0;
%     % Parametric modulation
%     regressors(10).pm = [];
%         
%     suffix = 'v24';
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %% Lavender
%     regressors(1).name = 'Lavender_Bl1_1to20';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(1).onset = [events(1:20).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(1).duration = 0;
%     % Parametric modulation
%     regressors(1).pm = [];
% 
%     %% Lavender
%     regressors(2).name = 'Lavender_Bl1_21to40';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(2).onset = [events(21:40).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(2).duration = 0;
%     % Parametric modulation
%     regressors(2).pm = [];
% 
%     %% Lavender
%     regressors(3).name = 'Lavender_Bl2_NoPuff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(3).onset = [events([find([events(41:80).puff_or_not]==0)+40]).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(3).duration = 0;
%     % Parametric modulation
%     regressors(3).pm = [];
% 
%     %% Lavender
%     regressors(4).name = 'Lavender_Bl2_Puff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(4).onset = [events([events.puff_or_not]==1).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(4).duration = 0;
%     % Parametric modulation
%     regressors(4).pm = [];
% 
% 
%     %% Lavender
%     regressors(5).name = 'Lavender_Bl3_81to100';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(5).onset = [events(81:100).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(5).duration = 0;
%     % Parametric modulation
%     regressors(5).pm = [];
%     
%     %% Lavender
%     regressors(6).name = 'Lavender_Bl3_101to120';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(6).onset = [events(101:120).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(6).duration = 0;
%     % Parametric modulation
%     regressors(6).pm = [];
%    
%     %% Time-Point of Puff
%     regressors(7).name = 'TP_noPuff_Bl1_1to20';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(7).onset = [events(1:20).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(7).duration = 0;
%     % Parametric modulation
%     regressors(7).pm = [];
% 
%     %% Time-Point of Puff
%     regressors(8).name = 'TP_noPuff_Bl1_21to40';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(8).onset = [events(21:40).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(8).duration = 0;
%     % Parametric modulation
%     regressors(8).pm = [];
% 
%     %% Time-Point of Puff
%     regressors(9).name = 'TP_Puff_Bl2_NoPuff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(9).onset = [events([find([events(41:80).puff_or_not]==0)+40]).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(9).duration = 0;
%     % Parametric modulation
%     regressors(9).pm = [];
% 
%     %% Time-Point of Puff
%     regressors(10).name = 'TP_Puff_Bl2_Puff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(10).onset = [events([events.puff_or_not]==1).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(10).duration = 0;
%     % Parametric modulation
%     regressors(10).pm = [];
% 
% 
%     %% Time-Point of Puff
%     regressors(11).name = 'TP_noPuff_Bl3_81to100';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(11).onset = [events(81:100).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(11).duration = 0;
%     % Parametric modulation
%     regressors(11).pm = [];
% 
%     %% Time-Point of Puff
%     regressors(12).name = 'TP_noPuff_Bl3_101to120';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(12).onset = [events(101:120).puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(12).duration = 0;
%     % Parametric modulation
%     regressors(12).pm = [];
%     
%     suffix = 'v30';


%     
% %% Baseline
%     regressors(11).name = 'Baseline1to20';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(11).onset = [events(1:20).fv_on_del5]+8;
%     % 0 = event-related; value=block;
%     regressors(11).duration = 3;
%     % Parametric modulation
%     regressors(11).pm = [];
%     
%     %% Baseline
%     regressors(12).name = 'Baseline21to40';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(12).onset = [events(21:40).fv_on_del5]+8;
%     % 0 = event-related; value=block;
%     regressors(12).duration = 3;
%     % Parametric modulation
%     regressors(12).pm = [];
%     
%     %% Baseline
%     regressors(13).name = 'Baseline41to80NoPuff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(13).onset = [events([find([events(41:80).puff_or_not]==0)+40]).fv_on_del5]+8;
%     % 0 = event-related; value=block;
%     regressors(13).duration = 3;
%     % Parametric modulation
%     regressors(13).pm = [];
%     
%     %% Baseline
%     regressors(14).name = 'Baseline41to80Puff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(14).onset = [events([events.puff_or_not]==1).fv_on_del5]+8;
%     % 0 = event-related; value=block;
%     regressors(14).duration = 3;
%     % Parametric modulation
%     regressors(14).pm = [];    
%     
%     %% Baseline
%     regressors(15).name = 'Baseline81to120';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(15).onset = [events(81:120).fv_on_del5]+8;
%     % 0 = event-related; value=block;
%     regressors(15).duration = 3;
%     % Parametric modulation
%     regressors(15).pm = [];
%     
%     
%     
%     suffix = 'v15';    
    %             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %             %% Odor On
    %             regressors(1).name = 'Odor_On';
    %             % Onset: CAVE: if onset is an odor, add the delay!;
    %             regressors(1).onset = [events.fv_on_del5]+odor_delay;
    %             % 0 = event-related; value=block;
    %             regressors(1).duration = 1;
    %             % Parametric modulation
    %             regressors(1).pm = [];
    %
    %             %% Odor On
    %             regressors(2).name = 'Odor_Off';
    %             % Onset: CAVE: if onset is an odor, add the delay!;
    %             regressors(2).onset = [events.fv_off_del5]+odor_delay;
    %             % 0 = event-related; value=block;
    %             regressors(2).duration = 1;
    %             % Parametric modulation
    %             regressors(2).pm.name = 'Odor_Off';
    %             regressors(2).pm.vector = [zeros(1,20) ones(1,20) zeros(1,40) ones(1,20)*-1 zeros(1,20)];
    %
    %             %% Time-Point of Puff
    %             regressors(3).name = 'Puff';
    %             % Onset: CAVE: if onset is an odor, add the delay!;
    %             regressors(3).onset = [events([events.puff_or_not]==1).puff_time_del5];
    %             % 0 = event-related; value=block;
    %             regressors(3).duration = 1;
    %             % Parametric modulation
    %             regressors(3).pm = [];
    %
    %             suffix = 'v12';
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     %% Lavender
%     regressors(1).name = 'Lavender';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(1).onset = [events.fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(1).duration = 2.4;
%     % Parametric modulation
%     regressors(1).pm = [];
%     
%     %% Puff
%     regressors(2).name = 'TP Puff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(2).onset = [events.puff_time_del5];
%     % 0 = event-related; value=block;
%     regressors(2).duration = 1;
%     % Parametric modulation
%     regressors(2).pm = [];
%     
%     %% Time-Point of Puff
%     regressors(3).name = 'Baseline';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(3).onset = [events.fv_on_del5]+8;
%     % 0 = event-related; value=block;
%     regressors(3).duration = 3;
%     % Parametric modulation
%     regressors(3).pm = [];
%         
%                 suffix = 'v16';
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %% Load FD matrix
% load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022/meanTC/maskactivationv24Bl3vsBl1T01/FD_matrsess_all_BINS6_TRsbefore2.mat');
% load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/08-TC_analysis/03-results/HRFlongTC_withOnset_from2sHRF-GLM_EPI_wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5____ROI_v99___COV_v5___ORTH_1___17-Feb-2022/meanTC/maskactivationv24Bl3vsBl1T01/tc_matrsess_all_BINS6_TRsbefore2.mat');
% 
% %% Lavender
% clear curr_FD_Odor range
% range=[1:10];
% curr_FD_Odor=mean(squeeze(FD_matrsess_all(subj,range,3:4)),2);
% low_motion_trials=;
% high_motion_trials=;
% 
% regressors(1).name = 'Lavender_Bl1_1to10';
% % Onset: CAVE: if onset is an odor, add the delay!;
% regressors(1).onset = [events(1:10).fv_on_del5]+odor_delay;
% % 0 = event-related; value=block;
% regressors(1).duration = 2.4;
% % Parametric modulation
% regressors(1).pm = [];
% 
% %% Lavender
% regressors(2).name = 'Lavender_Bl1_11to40';
% % Onset: CAVE: if onset is an odor, add the delay!;
% regressors(2).onset = [events(11:40).fv_on_del5]+odor_delay;
% % 0 = event-related; value=block;
% regressors(2).duration = 2.4;
% % Parametric modulation
% regressors(2).pm = [];
% 
% %% Lavender
% regressors(3).name = 'Lavender_Bl2_NoPuff';
% % Onset: CAVE: if onset is an odor, add the delay!;
% regressors(3).onset = [events([find([events(41:80).puff_or_not]==0)+40]).fv_on_del5]+odor_delay;
% % 0 = event-related; value=block;
% regressors(3).duration = 2.4;
% % Parametric modulation
% regressors(3).pm = [];
% 
% %% Lavender
% regressors(4).name = 'Lavender_Bl2_Puff';
% % Onset: CAVE: if onset is an odor, add the delay!;
% regressors(4).onset = [events([events.puff_or_not]==1).fv_on_del5]+odor_delay;
% % 0 = event-related; value=block;
% regressors(4).duration = 2.4;
% % Parametric modulation
% regressors(4).pm = [];
% 
% 
% %% Lavender
% regressors(5).name = 'Lavender_Bl3';
% % Onset: CAVE: if onset is an odor, add the delay!;
% regressors(5).onset = [events(81:120).fv_on_del5]+odor_delay;
% % 0 = event-related; value=block;
% regressors(5).duration = 2.4;
% % Parametric modulation
% regressors(5).pm = [];
% 
% 
% %% Time-Point of Puff
% regressors(6).name = 'TP_Puff_Bl1_1to10';
% % Onset: CAVE: if onset is an odor, add the delay!;
% regressors(6).onset = [events(1:10).puff_time_del5];
% % 0 = event-related; value=block;
% regressors(6).duration = 0;
% % Parametric modulation
% regressors(6).pm = [];
% 
% %% Time-Point of Puff
% regressors(7).name = 'TP_Puff_Bl1_11to40';
% % Onset: CAVE: if onset is an odor, add the delay!;
% regressors(7).onset = [events(11:40).puff_time_del5];
% % 0 = event-related; value=block;
% regressors(7).duration = 0;
% % Parametric modulation
% regressors(7).pm = [];
% 
% %% Time-Point of Puff
% regressors(8).name = 'TP_Puff_Bl2_NoPuff';
% % Onset: CAVE: if onset is an odor, add the delay!;
% regressors(8).onset = [events([find([events(41:80).puff_or_not]==0)+40]).puff_time_del5];
% % 0 = event-related; value=block;
% regressors(8).duration = 0;
% % Parametric modulation
% regressors(8).pm = [];
% 
% %% Time-Point of Puff
% regressors(9).name = 'TP_Puff_Bl2_Puff';
% % Onset: CAVE: if onset is an odor, add the delay!;
% regressors(9).onset = [events([events.puff_or_not]==1).puff_time_del5];
% % 0 = event-related; value=block;
% regressors(9).duration = 0;
% % Parametric modulation
% regressors(9).pm = [];
% 
% 
% %% Time-Point of Puff
% regressors(10).name = 'TP_Puff_Bl3';
% % Onset: CAVE: if onset is an odor, add the delay!;
% regressors(10).onset = [events(81:120).puff_time_del5];
% % 0 = event-related; value=block;
% regressors(10).duration = 0;
% % Parametric modulation
% regressors(10).pm = [];
% 
% suffix = 'v24';
    
    
    save([outputdir filesep 'ZI_M' fname(5:6) '_' suffix],'regressors');
end

%% Update metainfo

% load metafile
if exist ([outputdir filesep 'metainfo_regressors.mat']);
    load([outputdir filesep 'metainfo_regressors.mat']);
else
    metainfo = table;
    save([outputdir filesep 'metainfo_regressors.mat'],'metainfo')
end

% prepare clear new table (T) to add to metainfo
T=table(string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''));
counter=1;

% Create space for v_suffix
T.Properties.VariableNames{1} = ['v_Abbrev'];

% Create space for regressors
for i = 2:3:43
    T.Properties.VariableNames{i} = ['Reg_' num2str(counter) '_' 'Name'];
    T.Properties.VariableNames{i+1} = ['Reg_' num2str(counter) '_' 'Dur'];
    T.Properties.VariableNames{i+2} = ['Reg_' num2str(counter) '_' 'PM'];
    counter=counter+1;
end

T.Properties.RowNames = cellstr(suffix);
%
T(1,1) = cellstr(suffix);

% create new table for current version
counter=2;
for i = 1:length(regressors);
    T(1,counter)=cellstr(regressors(i).name);
    T(1,counter+1)=table(regressors(i).duration);
    if isempty(regressors(i).pm)
        T(1,counter+2)=cellstr('-');
    else
        T(1,counter+2)=cellstr([regressors(i).pm.name]);
    end
    counter=counter+3
end

% add new table to metainfo file and save it
metainfo=[metainfo;T];
save([outputdir filesep 'metainfo_regressors.mat'],'metainfo');
writetable(metainfo,[outputdir filesep 'metainfo_regressors.csv'],'Delimiter',',','QuoteStrings',true);




