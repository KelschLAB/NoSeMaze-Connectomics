function [list_of_files,sample_rate]= RhdToMat_lw(rhd_path,rhd_files,rootdir)
%% Max Scheller, 12.03.2016. Uses a modified version of the import-function supplied by Intan that outputs the smallest, precise data type (uint16).
% loads multiple .rhd-files, combines into (uint16[samples, channels]) _E(nnn)_continuous.mat, _digital.mat
% Important: array_map channel numbering has to start from zero, not one.
%
% External Intan-reader boundary:
%   BundleSession.m, LengthRhd.m and IntanImport.m originate from the
%   historical Intan import environment and are not reimplemented here.

% RAM and HDD usage is minimized by using uint16/int8 as datatype, using
% files for individual n-trodes and reading/writing the .rhd-files as they
% come.

%% DW08/18 adjusted

requiredReaders = {'BundleSession','LengthRhd','IntanImport'};
missingReaders = requiredReaders( ...
    cellfun(@(f) isempty(which(f)),requiredReaders) ...
);

if ~isempty(missingReaders)
    error([ ...
        'Required Intan-reader functions are not on the MATLAB path:\n%s\n\n' ...
        'Install/add the historical Intan reader used for this dataset.' ...
    ],strjoin(missingReaders,newline));
end

if nargin ~= 3
    error([ ...
        'RhdToMat_lw requires rhd_path, rhd_files, and rootdir. ' ...
        'Interactive raw-data selection is intentionally not part of the ' ...
        'public preprocessing entry point.' ...
    ]);
end

session_bundle = BundleSession(rhd_files, rhd_path);

for session=1:numel(session_bundle)
    
    rhdsortedfiles=session_bundle{session};
    
    
%     create folder for processed data
      str=strfind(rhd_files{1},'_');      % look for first _ 
      subj_cur = rhd_files{1}(1:str(1)-1);
      ident =  rhd_files{1}(1:str(2)-1);  % for saving data 
      
      cd(rootdir);
      
      
     
      

    %% looking for array map
    % consider structfind-implementation to check for channel map or assign
%     % default
%     maps = m.maps;
%     array_map=maps.(animal).array_map;
%     num_of_ntrodes=size(array_map,2);
%     
    %% allocate space on hdd for blockwise writing (because appending in a file is not possible)
    
    [~,sample_rate,~,~,~]=LengthRhd(rhd_path, rhdsortedfiles{1});
    
    session_length=0;
    for ii=1:numel(rhdsortedfiles)
        num_of_samples{ii}=LengthRhd(rhd_path, rhdsortedfiles{ii});
        session_length=session_length+num_of_samples{ii};
    end
%     
%     for ii=1:num_of_ntrodes
%         channels=uint16(zeros(session_length, numel(array_map{ii}))); %check if right format
%         filename{ii}=[ident '_E' sprintf('%03d',ii) '_continuous.mat'];
%         save(filename{ii}, 'channels', '-v7.3');
%         save(filename{ii}, 'sample_rate', '-append');
%         ntrode_file{ii}=matfile(filename{ii}, 'Writable', true);
%     end
    
    clear channels
    
    [~,~,num_of_digital_inputs,~,~]=LengthRhd(rhd_path, rhdsortedfiles{1});
    dchannels=zeros(session_length, num_of_digital_inputs);
    save([ident '_digital.mat'], 'dchannels', '-v7.3');
    save([ident '_digital.mat'], 'sample_rate', '-append');
    digital_file=matfile([ident '_digital.mat'], 'Writable', true);
    
    clear  dchannels
    
    %Creating space for sniff-data
    [~,~,~,~,num_board_adc_channels]=LengthRhd(rhd_path, rhdsortedfiles{1});
    adcchannels=zeros(session_length, num_board_adc_channels);
    save([ident '_adc.mat'], 'adcchannels', '-v7.3');
    save([ident '_adc.mat'], 'sample_rate', '-append');
    adc_file=matfile([ident '_adc.mat'], 'Writable', true);
    
%     %Creating space for Medians --> medians for all tetrodes, medians1/2 for 128-channel recording site-specific?
%     medians=uint16(zeros(num_of_samples{1}, 1));
%     save([ident '_misc.mat'], 'medians', '-v7.3');
%     
%     medians1=uint16(zeros(num_of_samples{1}, 1));
%     save([ident '_misc.mat'], 'medians1', '-append');
%     
%     medians2=uint16(zeros(num_of_samples{1}, 1));
%     save([ident '_misc.mat'], 'medians2', '-append');
%     
%     misc_file=matfile([ident '_misc.mat'], 'Writable', true);
    
    
    
    %%
    time1 = tic;
    

    
    for i = 1:numel(rhdsortedfiles)
        
        disp('reading...')
        [~, d_data, board_adc_data,~,sample_rate] = IntanImport(rhdsortedfiles{i}, rhd_path);
        board_adc_data=(board_adc_data)';
%         idx=cell2mat(array_map)+1;
%         aa_data=a_data(:,idx);
        
%         med_data = median(aa_data,2);
%         
%         if size(aa_data,2)==128
%             med_data1 = median(aa_data(:,1:64),2);
%             med_data2 = median(aa_data(:,65:128),2);
%         end
     
        if i==1
            first_index=1;
            last_index=num_of_samples{1};
        else
            first_index=last_index+1;
            last_index=last_index+num_of_samples{i};
        end
        
        tic
        
        list_of_files=[];
        
        %% write the appropriate channels in the files of individual n-trodes
        
        disp('writing...')
%         for jj=1:num_of_ntrodes
%             ntrode_file{jj}.channels(first_index:last_index,:)=a_data(:,array_map{jj}+1);
%         end
        digital_file.dchannels(first_index:last_index,:)=d_data;
%         misc_file.medians(first_index:last_index,:)=med_data;
%         if size(aa_data,2)==128
%             misc_file.medians1(first_index:last_index,:)=med_data1;
%             misc_file.medians2(first_index:last_index,:)=med_data2;
%         end
        if exist('board_adc_data','var')
            if ~isempty(board_adc_data)
                adc_file.adcchannels(first_index:last_index,:)=board_adc_data;
            end
        end
%         if session==1
%             list_of_files=filename;
%         else
%             list_of_files=[list_of_files filename];
%         end
        
        
        toc
    end
    fclose('all') %close all files to prevent error when batch-processing a large number of sessions.
end

disp('Total time for conversion from rhd to mat: ')
toc(time1)
