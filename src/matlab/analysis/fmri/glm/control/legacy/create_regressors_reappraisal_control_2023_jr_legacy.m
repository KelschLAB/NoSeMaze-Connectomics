%% create_regressors_reappraisal_control_2023_jr.m
% Reinwald, Jonathan 01/2021

% Info:
% - create regressors of interest (ROIs) including parametric modulation (if used) as an input for the firstlevel GLM


%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'))

% define paths...
protocol_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/01-processed_protocol_files';
outputdir='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/05-GLM/02-regressors';

% load filelist
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/03-filelists/filelist_ICON_reappraisal_control_2023_jr.mat')

% predefine odor_delay
% = delay between fv_on and the perception of the odor at the port
% estimated using the mini-PID (e.g. 600 to 700 ms)
odor_delay = 0.4+0.9;
%% Odor delay: 0.4+0.9 (3/4TR)
% v5 regressor for GLM
% v16 regressor for FC; 
% cormat_v8 (input: wave_10cons_med1000new_msk_s6_wrst_a1_u_despiked_del5_)
% cormat_v7 (input: DVARS)
% cormat_v6 (input: wave_10cons_med1000new_msk_wrst_a1_u_despiked_del5_)
%% Odor delay: 0.4+0.6 (1/2TR)
% v4 regressor for GLM
% v17 regressor for FC; 
% cormat_v5 (input: wave_10cons_med1000new_msk_wrst_a1_u_despiked_del5_)
%% Odor delay: 0.425+1.2 (1/2TR)
% v3 regressor for GLM
% v18 regressor for FC; 
% cormat_v3 (input: wave_10cons_med1000new_msk_wrst_a1_u_despiked_del5_)
% cormat_v4 (input: DVARSscrub_0_1_lin_wave_10cons_med1000new_msk_wrst_a1_u_despiked_del5_)
%% Odor delay: 0.425 + 0.275 (==0.7 --> wie in task)
% v2 for GLM
% ???
%% Odor delay: 0.425
% v22 regressor for GLM
% v19 regressor for FC; 
% cormat_v1 (input: wave_10cons_med1000new_msk_s6_wrst_a1_u_despiked_del5_)
% cormat_v2 (input: wave_10cons_med1000new_msk_wrst_a1_u_despiked_del5_)

%% Loop over animals
for subj = 1:length(Pfunc_reappraisal)
    % clear variables
    clear protocol_file regressors
    
    %% 1. find and load processed protocol file
    [fpath,fname,ext]=fileparts(Pfunc_reappraisal{subj});
    if strcmp(fname(15:16),'xx')
        protocol_file = dir([protocol_dir filesep fname(13:14) '23_' fname(5:10) filesep fname(13:14) '23_' fname(5:10) '*.*']);
    elseif strcmp(fname(13:16),'3213') && strcmp(fname(5:11),'230906C')
        protocol_file = dir([protocol_dir filesep '3205_' fname(5:10) filesep '3205_' fname(5:10) '*.*']);
    else
        protocol_file = dir([protocol_dir filesep fname(13:16) '_' fname(5:10) filesep fname(13:16) '_' fname(5:10) '*.*']);
    end
    load([protocol_file.folder filesep protocol_file.name]);
    
    %% 2. write information into regressors-file
    % select those manually
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %% Lavender
%     regressors(1).name = 'Lavender_Bl1_1to10';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(1).onset = [events(1:10).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(1).duration = 0;
%     % Parametric modulation
%     regressors(1).pm = [];
%     
%     %% Lavender
%     regressors(2).name = 'Lavender_Bl1_11to40';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(2).onset = [events(11:40).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(2).duration = 0;
%     % Parametric modulation
%     regressors(2).pm = [];
%     
%     %% Lavender
%     regressors(3).name = 'Lavender_Bl2';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(3).onset = [events(41:80).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(3).duration = 0;
%     % Parametric modulation
%     regressors(3).pm = [];
%         
%     %% Lavender
%     regressors(4).name = 'Lavender_Bl3';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(4).onset = [events(81:120).fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(4).duration = 0;
%     % Parametric modulation
%     regressors(4).pm(1).name = 'TrialNumber'
%     regressors(4).pm(1).vector = [41-[1:40]];
%     
%     
%     %% Time-Point of Puff
%     regressors(5).name = 'TP_Puff_Bl1_1to10';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(5).onset = [events(1:10).fv_off_del5]+0.1+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(5).duration = 0;
%     % Parametric modulation
%     regressors(5).pm = [];
%     
%     %% Time-Point of Puff
%     regressors(6).name = 'TP_Puff_Bl1_11to40';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(6).onset = [events(11:40).fv_off_del5]+0.1+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(6).duration = 0;
%     % Parametric modulation
%     regressors(6).pm = [];
%     
%     %% Time-Point of Puff
%     regressors(7).name = 'TP_Puff_Bl2f';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(7).onset = [events(41:80).fv_off_del5]+0.1+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(7).duration = 0;
%     % Parametric modulation
%     regressors(7).pm = [];
%     
%     %% Time-Point of Puff
%     regressors(8).name = 'TP_Puff_Bl3';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(8).onset = [events(81:120).fv_off_del5]+0.1+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(8).duration = 0;
%     % Parametric modulation
%     regressors(8).pm(1).name = 'TrialNumber'
%     regressors(8).pm(1).vector = [41-[1:40]];
%            
%     suffix = 'v79';   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    regressors(3).name = 'Lavender_Bl2';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(3).onset = [events(41:80).fv_on_del5]+odor_delay;
    % 0 = event-related; value=block;
    regressors(3).duration = 0;
    % Parametric modulation
    regressors(3).pm = [];
        
    %% Lavender
    regressors(4).name = 'Lavender_Bl3_early';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(4).onset = [events(81:100).fv_on_del5]+odor_delay;
    % 0 = event-related; value=block;
    regressors(4).duration = 0;
    % Parametric modulation
    regressors(4).pm = [];

    %% Lavender
    regressors(5).name = 'Lavender_Bl3_late';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(5).onset = [events(101:120).fv_on_del5]+odor_delay;
    % 0 = event-related; value=block;
    regressors(5).duration = 0;
    % Parametric modulation
    regressors(5).pm = [];    
    
    %% Time-Point of Puff
    regressors(6).name = 'TP_Puff_Bl1_1to10';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(6).onset = [events(1:10).fv_off_del5]+0.1+odor_delay;
    % 0 = event-related; value=block;
    regressors(6).duration = 0;
    % Parametric modulation
    regressors(6).pm = [];
    
    %% Time-Point of Puff
    regressors(7).name = 'TP_Puff_Bl1_11to40';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(7).onset = [events(11:40).fv_off_del5]+0.1+odor_delay;
    % 0 = event-related; value=block;
    regressors(7).duration = 0;
    % Parametric modulation
    regressors(7).pm = [];
    
    %% Time-Point of Puff
    regressors(8).name = 'TP_Puff_Bl2';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(8).onset = [events(41:80).fv_off_del5]+0.1+odor_delay;
    % 0 = event-related; value=block;
    regressors(8).duration = 0;
    % Parametric modulation
    regressors(8).pm = [];
    
    %% Time-Point of Puff
    regressors(9).name = 'TP_Puff_Bl3_early';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(9).onset = [events(81:100).fv_off_del5]+0.1+odor_delay;
    % 0 = event-related; value=block;
    regressors(9).duration = 0;
    % Parametric modulation
    regressors(9).pm = [];
    
    %% Time-Point of Puff
    regressors(10).name = 'TP_Puff_Bl3_late';
    % Onset: CAVE: if onset is an odor, add the delay!;
    regressors(10).onset = [events(101:120).fv_off_del5]+0.1+odor_delay;
    % 0 = event-related; value=block;
    regressors(10).duration = 0;
    % Parametric modulation
    regressors(10).pm = [];
           
    suffix = 'v26';

%     %% Lavender
%     regressors(1).name = 'Lavender';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(1).onset = [events.fv_on_del5]+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(1).duration = 0;
%     % Parametric modulation
%     regressors(1).pm = [];
%     
%     %% Time-Point of Puff
%     regressors(2).name = 'TP_noPuff';
%     % Onset: CAVE: if onset is an odor, add the delay!;
%     regressors(2).onset = [events.fv_off_del5]+0.1+odor_delay;
%     % 0 = event-related; value=block;
%     regressors(2).duration = 0;
%     % Parametric modulation
%     regressors(2).pm = [];
% 
%     suffix = 'v16';
    
    if strcmp(fname(15:16),'xx')
        save([outputdir filesep 'ZI_M' fname(5:12) '3223_' suffix],'regressors');
    elseif strcmp(fname(13:16),'3213') && strcmp(fname(5:11),'230906C')
        save([outputdir filesep 'ZI_M' fname(5:12) '3205_' suffix],'regressors');
    else
        save([outputdir filesep 'ZI_M' fname(5:16) '_' suffix],'regressors');
    end  
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




