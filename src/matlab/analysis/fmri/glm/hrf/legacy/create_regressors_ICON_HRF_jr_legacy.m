%% create_regressors_ICON_HRF_jr.m
% Reinwald, Jonathan 06/2021

% Info:
% - create regressors of interest (ROIs) including parametric modulation (if used) as an input for the firstlevel GLM


%% Preparation
clear all;
close all;

% set path for scripts
addpath(genpath('/home/jonathan.reinwald/ICON_HRF/01-scripts'))

% define paths...
protocol_dir = '/home/jonathan.reinwald/ICON_HRF/03-processed-data/01-processed_protocol_files';
outputdir='/home/jonathan.reinwald/ICON_HRF/04-analyses/01-GLM/02-regressors';
if exist(outputdir)==0
    mkdir(outputdir);
end
cd(outputdir);

% define number of blocks
NumBlocks = 5;

% load filelist
load('/home/jonathan.reinwald/ICON_HRF/03-processed-data/03-filelists/filelist_ICON_hrf_jr.mat','P3d','Pdmap','Pfunc','Pfunc_subjName')

% predefine odor_delay
% = delay between fv_on and the perception of the odor at the port
% estimated using the mini-PID (e.g. ~500 ms) --> ask Mirko/Laurens
odor_delay = 0.7;

%% Loop over animals
for sess = 1:length(Pfunc)
    % clear variables
    clear protocol_file regressors
    
    %% 1. find and load processed protocol file
    [fpath,fname,ext]=fileparts(Pfunc{sess});
    % select all file in the respective animal folder
    protocol_file = dir([protocol_dir filesep 'animal_' Pfunc_subjName{sess}(2:end) ]);
    % select the correct file from the protocol_files using the date of the
    % acquisition
    clear selectionNumb
    selectionNumb = find(contains({protocol_file.name},fname(5:10)));
    load([protocol_file(selectionNumb).folder filesep protocol_file(selectionNumb).name]);
    
    %% 2. write information into regressors-file
    % select those manually
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if 1==1
        %% Odor with 1s duration
        regressors(1).name = 'Odor_500ms';
        % Onset: CAVE: if onset is an odor, add the delay!;
        regressors(1).onset = [events([events.fv_dur_del25]>0.45 & [events.fv_dur_del25]<0.55).fv_on_del25]+odor_delay;
        % 0 = event-related; value=block;
        regressors(1).duration = 0.5;
        % Parametric modulation
        regressors(1).pm = [];
        
        %% Odor with 1s duration
        regressors(2).name = 'Odor_1000ms';
        % Onset: CAVE: if onset is an odor, add the delay!;
        regressors(2).onset = [events([events.fv_dur_del25]>0.95 & [events.fv_dur_del25]<1.05).fv_on_del25]+odor_delay;
        % 0 = event-related; value=block;
        regressors(2).duration = 1;
        % Parametric modulation
        regressors(2).pm = [];
        
        %% Odor with 1s duration
        regressors(3).name = 'Odor_2400ms';
        % Onset: CAVE: if onset is an odor, add the delay!;
        regressors(3).onset = [events([events.fv_dur_del25]>2.35 & [events.fv_dur_del25]<2.55).fv_on_del25]+odor_delay;
        % 0 = event-related; value=block;
        regressors(3).duration = 2.4;
        % Parametric modulation
        regressors(3).pm = [];
        
        suffix = 'v1';
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Odor
    if 1==0
        regressors(1).name = 'Odor';
        % Onset: CAVE: if onset is an odor, add the delay!;
        regressors(1).onset = [events.fv_on_del25]+odor_delay;
        % 0 = event-related; value=block;
        regressors(1).duration = 0;
        % Parametric modulation
        regressors(1).pm = [];
        
        suffix = 'v2';
        outputdir_version = [outputdir filesep suffix];
        if exist(outputdir_version)==0;
            mkdir(outputdir_version);
        end
    end
    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if 1==0
        %% Odor with 1s duration
        regressors(1).name = 'Odor_500ms';
        % Onset: CAVE: if onset is an odor, add the delay!;
        regressors(1).onset = [events([events.fv_dur_del25]>0.45 & [events.fv_dur_del25]<0.55).fv_on_del25]+odor_delay;
        % 0 = event-related; value=block;
        regressors(1).duration = 0;
        % Parametric modulation
        regressors(1).pm = [];
        
        %% Odor with 1s duration
        regressors(2).name = 'Odor_1000ms';
        % Onset: CAVE: if onset is an odor, add the delay!;
        regressors(2).onset = [events([events.fv_dur_del25]>0.95 & [events.fv_dur_del25]<1.05).fv_on_del25]+odor_delay;
        % 0 = event-related; value=block;
        regressors(2).duration = 0;
        % Parametric modulation
        regressors(2).pm = [];
        
        %% Odor with 1s duration
        regressors(3).name = 'Odor_2400ms';
        % Onset: CAVE: if onset is an odor, add the delay!;
        regressors(3).onset = [events([events.fv_dur_del25]>2.35 & [events.fv_dur_del25]<2.55).fv_on_del25]+odor_delay;
        % 0 = event-related; value=block;
        regressors(3).duration = 0;
        % Parametric modulation
        regressors(3).pm = [];
        
        suffix = 'v3';
        outputdir_version = [outputdir filesep suffix];
        if exist(outputdir_version)==0;
            mkdir(outputdir_version);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if 1==0
        %% Odor with .5 s duration
        clear myEvents
        myEvents = [events([events.fv_dur_del25]>0.45 & [events.fv_dur_del25]<0.55).fv_on_del25];
        
        counter=1;
        for bl = 1:NumBlocks
            % define start/end trial
            start_trial = (length(myEvents)/NumBlocks)*(bl-1)+1;
            end_trial = (length(myEvents)/NumBlocks)*bl;
            % name
            regressors(counter).name = ['Odor_500ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
            % Onset: CAVE: if onset is an odor, add the delay!;
            regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay;
            % 0 = event-related; value=block;
            regressors(counter).duration = 0.5;
            % Parametric modulation
            regressors(counter).pm = [];
            % update counter
            counter=counter+1;
        end
        
        %% Odor with 1s duration
        clear myEvents
        myEvents = [events([events.fv_dur_del25]>0.95 & [events.fv_dur_del25]<1.05).fv_on_del25];
        
        for bl = 1:NumBlocks
            % define start/end trial
            start_trial = (length(myEvents)/NumBlocks)*(bl-1)+1;
            end_trial = (length(myEvents)/NumBlocks)*bl;
            % name
            regressors(counter).name = ['Odor_1000ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
            % Onset: CAVE: if onset is an odor, add the delay!;
            regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay;
            % 0 = event-related; value=block;
            regressors(counter).duration = 1;
            % Parametric modulation
            regressors(counter).pm = [];
            % update counter
            counter=counter+1;
        end
        
        %% Odor with 2.4s duration
        clear myEvents
        myEvents = [events([events.fv_dur_del25]>2.35 & [events.fv_dur_del25]<2.55).fv_on_del25];
        
        for bl = 1:NumBlocks
            % define start/end trial
            start_trial = (length(myEvents)/NumBlocks)*(bl-1)+1;
            end_trial = (length(myEvents)/NumBlocks)*bl;
            % name
            regressors(counter).name = ['Odor_2400ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
            % Onset: CAVE: if onset is an odor, add the delay!;
            regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay;
            % 0 = event-related; value=block;
            regressors(counter).duration = 2.4;
            % Parametric modulation
            regressors(counter).pm = [];
            % update counter
            counter=counter+1;
        end
        
        suffix = 'v4';

        outputdir_version = [outputdir filesep suffix];
        if exist(outputdir_version)==0;
            mkdir(outputdir_version);
        end
    end
    
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if 1==1
%         %% Odor with .5 s duration
%         clear myEvents
%         myEvents = [events([events.fv_dur_del25]>0.45 & [events.fv_dur_del25]<0.55).fv_on_del25];
%         
%         counter=1;
%         for bl = 1:NumBlocks
%             % define start/end trial
%             start_trial = round((length(myEvents)/NumBlocks)*(bl-1)+1);
%             end_trial = round((length(myEvents)/NumBlocks)*bl);
%             % name
%             regressors(counter).name = ['Odor_500ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
%             % Onset: CAVE: if onset is an odor, add the delay!;
%             regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay;
%             % 0 = event-related; value=block;
%             regressors(counter).duration = 0.5;
%             % Parametric modulation
%             regressors(counter).pm = [];
%             % update counter
%             counter=counter+1;
%             % name
%             regressors(counter).name = ['TPafterOdor_500ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
%             % Onset: CAVE: if onset is an odor, add the delay!;
%             regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay+0.5+0.1;
%             % 0 = event-related; value=block;
%             regressors(counter).duration = 0;
%             % Parametric modulation
%             regressors(counter).pm = [];
%             % update counter
%             counter=counter+1;
%         end
%         
%         %% Odor with 1s duration
%         clear myEvents
%         myEvents = [events([events.fv_dur_del25]>0.95 & [events.fv_dur_del25]<1.05).fv_on_del25];
%         
%         for bl = 1:NumBlocks
%             % define start/end trial
%             start_trial = round((length(myEvents)/NumBlocks)*(bl-1)+1);
%             end_trial = round((length(myEvents)/NumBlocks)*bl);
%             % name
%             regressors(counter).name = ['Odor_1000ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
%             % Onset: CAVE: if onset is an odor, add the delay!;
%             regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay;
%             % 0 = event-related; value=block;
%             regressors(counter).duration = 1;
%             % Parametric modulation
%             regressors(counter).pm = [];
%             % update counter
%             counter=counter+1;
%             % name
%             regressors(counter).name = ['TPafterOdor_1000ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
%             % Onset: CAVE: if onset is an odor, add the delay!;
%             regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay+1+0.1;
%             % 0 = event-related; value=block;
%             regressors(counter).duration = 0;
%             % Parametric modulation
%             regressors(counter).pm = [];
%             % update counter
%             counter=counter+1;
%         end
%         
%         %% Odor with 2.4s duration
%         clear myEvents
%         myEvents = [events([events.fv_dur_del25]>2.35 & [events.fv_dur_del25]<2.55).fv_on_del25];
%         
%         for bl = 1:NumBlocks
%             % define start/end trial
%             start_trial = round((length(myEvents)/NumBlocks)*(bl-1)+1);
%             end_trial = round((length(myEvents)/NumBlocks)*bl);
%             % name
%             regressors(counter).name = ['Odor_2400ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
%             % Onset: CAVE: if onset is an odor, add the delay!;
%             regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay;
%             % 0 = event-related; value=block;
%             regressors(counter).duration = 2.4;
%             % Parametric modulation
%             regressors(counter).pm = [];
%             % update counter
%             counter=counter+1;
%             % name
%             regressors(counter).name = ['TPafterOdor_2400ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
%             % Onset: CAVE: if onset is an odor, add the delay!;
%             regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay+2.4+0.1;
%             % 0 = event-related; value=block;
%             regressors(counter).duration = 0;
%             % Parametric modulation
%             regressors(counter).pm = [];
%             % update counter
%             counter=counter+1;
%         end
%         
%         suffix = 'v6';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if 1==1
        %% Odor with .5 s duration
        clear myEvents
        myEvents = [events([events.fv_dur_del25]>0.45 & [events.fv_dur_del25]<0.55).fv_on_del25];
        
        counter=1;
        Block_Definition={[1:3],[4:10],[11:20],[21:30],[31:40],[41:50]};
        for bl = 1:length(Block_Definition)
            start_trial=Block_Definition{bl}(1);
            end_trial=Block_Definition{bl}(end);
            % define start/end trial
%             start_trial = round((length(myEvents)/NumBlocks)*(bl-1)+1);
%             end_trial = round((length(myEvents)/NumBlocks)*bl);
            % name
            regressors(counter).name = ['Odor_500ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
            % Onset: CAVE: if onset is an odor, add the delay!;
            regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay;
            % 0 = event-related; value=block;
            regressors(counter).duration = 0;
            % Parametric modulation
            regressors(counter).pm = [];
            % update counter
            counter=counter+1;
            % name
            regressors(counter).name = ['TPafterOdor_500ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
            % Onset: CAVE: if onset is an odor, add the delay!;
            regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay+0.5+0.1;
            % 0 = event-related; value=block;
            regressors(counter).duration = 0;
            % Parametric modulation
            regressors(counter).pm = [];
            % update counter
            counter=counter+1;
        end
        
        %% Odor with 1s duration
        clear myEvents
        myEvents = [events([events.fv_dur_del25]>0.95 & [events.fv_dur_del25]<1.05).fv_on_del25];
        
        for bl = 1:length(Block_Definition)
            start_trial=Block_Definition{bl}(1);
            end_trial=Block_Definition{bl}(end);
            % define start/end trial
%             start_trial = round((length(myEvents)/NumBlocks)*(bl-1)+1);
%             end_trial = round((length(myEvents)/NumBlocks)*bl);
            % name
            regressors(counter).name = ['Odor_1000ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
            % Onset: CAVE: if onset is an odor, add the delay!;
            regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay;
            % 0 = event-related; value=block;
            regressors(counter).duration = 0;
            % Parametric modulation
            regressors(counter).pm = [];
            % update counter
            counter=counter+1;
            % name
            regressors(counter).name = ['TPafterOdor_1000ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
            % Onset: CAVE: if onset is an odor, add the delay!;
            regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay+1+0.1;
            % 0 = event-related; value=block;
            regressors(counter).duration = 0;
            % Parametric modulation
            regressors(counter).pm = [];
            % update counter
            counter=counter+1;
        end
        
        %% Odor with 2.4s duration
        clear myEvents
        myEvents = [events([events.fv_dur_del25]>2.35 & [events.fv_dur_del25]<2.55).fv_on_del25];
        
        for bl = 1:length(Block_Definition)
            start_trial=Block_Definition{bl}(1);
            end_trial=Block_Definition{bl}(end);
            % define start/end trial
%             start_trial = round((length(myEvents)/NumBlocks)*(bl-1)+1);
%             end_trial = round((length(myEvents)/NumBlocks)*bl);
            % name
            regressors(counter).name = ['Odor_2400ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
            % Onset: CAVE: if onset is an odor, add the delay!;
            regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay;
            % 0 = event-related; value=block;
            regressors(counter).duration = 0;
            % Parametric modulation
            regressors(counter).pm = [];
            % update counter
            counter=counter+1;
            % name
            regressors(counter).name = ['TPafterOdor_2400ms_Bl' num2str(start_trial) 'to' num2str(end_trial)];
            % Onset: CAVE: if onset is an odor, add the delay!;
            regressors(counter).onset = myEvents(start_trial:end_trial)+odor_delay+2.4+0.1;
            % 0 = event-related; value=block;
            regressors(counter).duration = 0;
            % Parametric modulation
            regressors(counter).pm = [];
            % update counter
            counter=counter+1;
        end
        
        suffix = 'v7';

        outputdir_version = [outputdir filesep suffix];
        if exist(outputdir_version)==0;
            mkdir(outputdir_version);
        end
    end
        
    save([outputdir_version filesep fname(1:11) '_' suffix],'regressors');
end

%% Update metainfo

% load metafile
if exist ([outputdir_version filesep 'metainfo_regressors.mat']);
    load([outputdir_version filesep 'metainfo_regressors.mat']);
else
    metainfo = table;
    save([outputdir_version filesep 'metainfo_regressors.mat'],'metainfo')
end

% prepare clear new table (T) to add to metainfo
T=table(string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''),string(''),NaN,string(''));
counter=1;

% Create space for v_suffix
T.Properties.VariableNames{1} = ['v_Abbrev'];

% Create space for regressors
for i = 2:3:31;
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
save([outputdir_version filesep 'metainfo_regressors.mat'],'metainfo');
writetable(metainfo,[outputdir_version filesep 'metainfo_regressors.csv'],'Delimiter',',','QuoteStrings',true);



