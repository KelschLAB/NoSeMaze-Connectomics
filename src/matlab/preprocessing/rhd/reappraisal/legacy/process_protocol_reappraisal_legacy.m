function  process_protocol__reappraisal(protocollist,rhdlist,outputdir,rootdir,nVolume) % [events, info, licks] =

%% get all rhds and mats, create pairs of corresponding files, ...

for ii=1:length(protocollist)
    [path,protocolname] = fileparts(protocollist{ii});
    find_=strfind(protocolname,'_'); % find all _ in string
    
    %   MAT=protocolname(1:(find_(1)+1));
    if length(find_)==3
        MAT=protocolname(1:(find_(2)-1));
    elseif length(find_)==4
        MAT=protocolname(1:(find_(2)-1));
    elseif length(find_)==5
        MAT=protocolname(1:(find_(3)-1));
    end
    
    RHD=find(contains(rhdlist, MAT));
    
    if ~isempty(RHD)
        pairs{1,ii}=protocollist{ii};
        pairs{2,ii}=rhdlist(RHD)';
    else
        error(['No intan recording found for ' num2str(MAT)])
    end
end

% % extract date of all sessions to be processed...
% date = protocolname(find_(1)+1:find_(2)-1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% LOOP STARTS HERE
for ii=1:size(pairs,2)
    ii
    % PREP: define all paths, subject(s), ...
    
    %matprotocol
    [pathstr,name,ext] = fileparts(pairs{1,ii});
    protocolfile = [name ext];
    protocolpath = [pathstr filesep];
    
    
    %intan
    % write intan files in a specific cell structure - important for RHDtoMat
    intan_files_fullpath = pairs{2,ii};
    Num_intan_files=numel(intan_files_fullpath);
    for rhd=1:Num_intan_files
        [~,name,ext]=fileparts(intan_files_fullpath{1,rhd});
        intan_files{1,rhd}=[name ext];
    end
    
    [pathstr,name,ext] = fileparts(intan_files_fullpath{1});
    intanfile = [name ext]; % kind of double information - not very elegant
    intanpath = [pathstr filesep];
    
    
    % -----
    % in case that we have to deal with double sessions (2 animals, same sess)
    % plus(+) in nomenclature marks double sessions!
    % example 'rw1+rw2'
    animals = any(strfind(protocolfile, '+'))+1;
    
    
    % subject(s) - double session or not?
    % + mkdir for every single subject in outputdir
    
    find_=strfind(protocolfile,'_'); % find all _ in string
    if animals > 1
        PosPlus = strfind(protocolfile,'+'); % indicator for double!
        subject{1} = protocolfile(1:(PosPlus(1)-1)); mkdir([outputdir filesep subject{1}]);
        subject{2} = protocolfile(PosPlus(1)+1:find_(1)-1); mkdir([outputdir filesep subject{2}]);
    else
        subject{1} = protocolfile(1:find_(2)-1); mkdir([outputdir filesep subject{1}]);
    end
    %
    load([protocolpath protocolfile]);
    
    
    %% takes ADC, Ditial protocols, extracts timing of odorant, reward, licks, saves in protocol.
    
    % takes into account if first event on digital channels is bug-like. after
    % that it parses timings up to last trial in protocolfile.
    
    
    %% conversion RHD to Mat
    
    % wraps all rhd files (if present) and creates an ADC.mat + digital.mat
    % extracts sample_rate
    [~,recording_params] = RhdToMat_lw(intanpath,intan_files,rootdir); % sample_rate = freq;
    %     RhdToMat_lw_old(intanpath,intan_files,rootdir); % sample_rate = freq;
    freq = recording_params.frequency_parameters.amplifier_sample_rate;
    %     freq=30000
    
    %% load ADCs, Digitals + mat protocol
    
    ADCs=(getAllFiles(rootdir, '*adc.mat',1))'; load(ADCs{1});
    DIGs=(getAllFiles(rootdir, '*digital.mat',1))'; load(DIGs{1});
    
    % move ADCs, Digitals to separate folder...
    ADCDIGdir=[outputdir filesep 'ANALOGS+DIGITALS'];
    mkdir(ADCDIGdir);
    movefile(ADCs{1},ADCDIGdir);
    movefile(DIGs{1},ADCDIGdir);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% I. Extraction of final valve timing (Odor trace)
    % recorded on channel 1
    
    % read fv trace of dchannel 1
    fvtrace=dchannels(:,1);
    
    % detect fv_on and fv_off
    fv_on=find(diff(fvtrace)==1)/freq;
    fv_off=find(diff(fvtrace)==-1)/freq;
    
    % calculate fv_dur (duration)
    fv_dur=fv_off-fv_on;
    
    % in case you start matlab protocol twice in one intan recording
    if length(find(fv_dur > 9)) > 1
        limits=find(fv_dur>9);
        fv_on([limits(1):1:limits(2)])= [];
        fv_off([limits(1):1:limits(2)])= [];
        fv_dur([limits(1):1:limits(2)])= [];
    end
    
    % remove false signals detected (e.g. at the end or at the beginning) by controlling the
    % fv_dur (here: 2.4 s)
    ToDelete= find( fv_dur > 3.25 | fv_dur < 2.35); %%% CAVE: CHANGE BACK AFTER FIRST SESSIONS
    
    if ~isempty(ToDelete)
        % Case 1: False signals at the end
        if ToDelete(1) > length(session.trialmatrix) && ToDelete(end) > length(session.trialmatrix)
            fv_on(ToDelete(1):ToDelete(end))= [];
            fv_off(ToDelete(1):ToDelete(end))= [];
            fv_dur(ToDelete(1):ToDelete(end))= [];
            % Case 2: False signals at the start
        elseif ToDelete(1) < 20 && ToDelete(end) < 20
            fv_on(1:ToDelete(end))= [];
            fv_off(1:ToDelete(end))= [];
            fv_dur(1:ToDelete(end))= [];
        else
            error(['Check false fv_onsets manually (~=MaxTrialNum) in ' protocolfile '.mat'])
        end
    end
    
    % CONTROL: detected number of fv onsets equal to trials passed?
    MaxTrialNum = length(session.trialmatrix);
    if length(fv_on) ~= MaxTrialNum
        error(['incorrect number of fv_onsets (~=MaxTrialNum) in ' protocolfile '.mat'])
    end
    
    % CONTROL: same number of fv ons and offs...
    if length(fv_on)~=length(fv_off)
        error(['unequal number of fv_on and fv_off in ' protocolfile '.mat'])
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% II. Extraction of valve timing for air-puff
    % recorded on channel 2
    
    % read puff trace of dchannel 2
    pufftrace=dchannels(:,2);
    
    % detect puff_on and puff_off
    puff_on=find(diff(pufftrace)==1)/freq;
    puff_off=find(diff(pufftrace)==-1)/freq;
    
    % calculate puff_dur (duration)
    puff_dur=puff_off-puff_on;
    
    % remove false signals detected (e.g. at the end) by controlling the
    % fv_dur (here: 0.1 s)
    ToDelete= find( puff_dur >0.015 | puff_dur < 0.005);
    
    puff_on(ToDelete)= [];
    puff_off(ToDelete)= [];
    puff_dur(ToDelete)= [];
    
    % CONTROL: detected number of fv onsets equal to trials passed?
    MaxPuffNum = sum([session.trialmatrix.air_lat]'~=0);
    if length(puff_on) ~= MaxPuffNum
        error(['incorrect number of fv_onsets (~=MaxTrialNum) in ' protocolfile '.mat'])
    end
    
    % CONTROL: same number of fv ons and offs...
    if length(puff_on)~=length(puff_off)
        error(['unequal number of fv_on and fv_off in ' protocolfile '.mat'])
    end
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% II. Extraction of EPI-trigger
    % recorded on channel 3
    
    % read trig trace of dchannel 3
    trigData=dchannels(:,3); % trigger scanner LW
    
    trigDatadiff=diff(trigData);
    trigNum=numel(find(trigDatadiff == -1));
    % We define trigTime as the onset of the trigger
    trigTime=find(trigDatadiff==-1)/freq;
    
    trigTime_on=find(trigDatadiff==-1)/freq;
    trigTime_off=find(trigDatadiff==1)/freq;
    
    % Sometimes the trig signal starts at the wrong baseline and changes
    % within the first milli-seconds, therefore check the size of
    % trigTime_on and trigTime_off and correct it, if necessary
    if size(trigTime_off,1)>size(trigTime_on,1);
        trigTime_off(1)=[];
        display(['First trigTime incorrect']);
    end;
    
    % estimation of intertrigger distance (trigDurTotal) based on trigger duration
    % (trigDur) and time between triggers (trigDurInter)
    trigDur=trigTime_off-trigTime_on;
    
    for zx=1:(size(trigTime_off,1)-1);
        trigDurInter(zx)=trigTime_on(zx+1)-trigTime_off(zx);
        trigDurTotal(zx)=trigDur(zx)+trigDurInter(zx);
        trigDurTotalOrig=trigDurTotal;
        if trigDurTotal(zx) < 1.19
            display(['trigDur of # ' num2str(zx) 'to small in' protocolfile '.mat']);
        end;
    end;
    
    %% 1. Get rid of adjustment triggers at the beginning and the end
    clear trigStartIx trigEndIx
    %% 1.1. Beginning of the EPI
    %%% if there are adjustments, get rid of the adjustment triggers
    % this is done such that the last unusually large trigger gap is taken
    % as a starting point
    if ~isempty(find(trigDurTotal>3.4,1))
        trigDurExceeded_all=find(trigDurTotal>3.4); % 3.4 is arbitrary, but was chosen because it is unlikely that the distance between two regular EPI triggers (as opposed to adjustment triggers) will be more than 3.4 (this could only happen if there are at least 2 adjacent gaps in the data each taking away a trigger)
        indx_AdjTrig_last=find(trigDurExceeded_all<nVolume,1,'last');
        trigStartIx=trigDurExceeded_all(indx_AdjTrig_last);
        trigTime([1:trigStartIx])= [];
        trigDurInter([1:trigStartIx])= [];
        trigDurTotal([1:trigStartIx])= [];
        trigDur([1:trigStartIx])= [];
        trigTime_on([1:trigStartIx])= [];
        trigTime_off([1:trigStartIx])= [];
    end
    %% 1.2. End of the EPI
    if ~isempty(find(trigDurTotal>3.4,1))
        trigDurExceeded_all=find(trigDurTotal>3.4); % 3.4 is arbitrary, but was chosen because it is unlikely that the distance between two regular EPI triggers (as opposed to adjustment triggers) will be more than 3.4 (this could only happen if there are at least 2 adjacent gaps in the data each taking away a trigger)
        indx_AdjTrig_last=find(trigDurExceeded_all>=nVolume,1,'first');
        trigEndIx=trigDurExceeded_all(indx_AdjTrig_last)+1;
        trigTime([trigEndIx:end])= [];
        trigDurInter([trigEndIx:end])= [];
        trigDurTotal([trigEndIx:end])= [];
        trigDur([trigEndIx:end])= [];
        trigTime_on([trigEndIx:end])= [];
        trigTime_off([trigEndIx:end])= [];
    end
    
    %%%
    outps=['trigger_check_figs_' date '.ps'];
    outtxt=['trigger_check_' date '.txt'];
    fid=fopen(outtxt,'a+'); %CC

    if exist('trigStartIx','var')
        trignMess=sprintf([subject{1} ': ' num2str(trigStartIx) ' adjustment triggers deleted']);
        fid=fopen(outtxt,'a+'); %CC
        fprintf(fid,'\t%s\n',trignMess);
    end
    
    if exist('trigEndIx','var')
        trignMess=sprintf([subject{1} ': ' num2str(length(trigEndIx)) ' triggers at end deleted']);
        fid=fopen(outtxt,'a+'); %CC
        fprintf(fid,'\t%s\n',trignMess);
    end
   
    %% 2. Check for enough Trigger Signals
    %first check if enough Triggers
    if length(trigTime_on) == nVolume
        trignMess=sprintf([subject{1} ': There are exactly as many trigger signals as volumes :-)']);
        fid=fopen(outtxt,'a+'); %CC
        fprintf(fid,'\t%s\n',trignMess);
    elseif length(trigTime_on) > nVolume
        trignMess=sprintf([subject{1} ': Too many trigger signals: ' num2str(length(trigTime_on) - nVolume) ' additional triggers']);
        fid=fopen(outtxt,'a+'); %CC
        fprintf(fid,'\t%s\n',trignMess);
    elseif length(trigTime_on) < nVolume
        trignMess=sprintf([subject{1} ': Not enough trigger signals: ' num2str(nVolume - length(trigTime_on)) ' missing']);
        fid=fopen(outtxt,'a+'); %CC
        fprintf(fid,'\t%s\n',trignMess); %CC
    end
    
    %% 3. Correct Triggers
    % Definition of TR
    TR = median(trigDurTotal);
    trigMedian=median(trigDur);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 3.1. Overview in plot:
    figure(25);
    clf
    axes
    hold on
    plot(trigDurTotalOrig*100, 'c' )
    plot([zeros(trigStartIx,1); trigTime_on], 'b' )
    title(subject{1},'Interpreter','none')
    legend( {'Trigger shift', 'Trigger interval * 100', 'Dummy start', 'Volume start'}, ...
        'Location', 'Best')
    title( {[subject{1} ': trigger median: ' num2str( trigMedian )], ...
        ['# of volumes: ' num2str(nVolume)],['# of triggers (after deletion of adj.): ' num2str(length(trigTime_on))]} )
    print(gcf,'-dpsc2','-append',outps) % make postcript file
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 3.2 Correction of too many triggers in a row:
    if length(trigTime_on) > nVolume
        trigI=diff(trigTime_on);
        TR_diff=trigI-TR;
        trigdis_err=find(abs(TR_diff) > 0.05);
        
        trigTime_on_orig = trigTime_on;
        trigTime_off_orig = trigTime_off;
        trigTime_orig=trigTime_on;
        trigDur_orig=trigTime_off-trigTime_on;
        trigDurInter_orig=trigDurInter;
        trigDurTotal_orig=trigDurTotal;
        
        %% Errors in a row
        if sum(diff(trigdis_err)) == length(trigdis_err)-1
            TRdur_errorintervall = round(sum(trigI(trigdis_err))/TR,2);
            if sum(trigI(trigdis_err))~=(trigTime_on(trigdis_err(end)+1)-trigTime_on(trigdis_err(1)))
                error(['Too many trigger, but not in a row']);
            end
            %% Correction:
            for ix=1:(TRdur_errorintervall-1);
                trigTime_on(trigdis_err(1)+ix) = trigTime_on(trigdis_err(1))+TR*ix;
                trigTime_off(trigdis_err(1)+ix) = trigTime_on(trigdis_err(1))+TR*ix+median(trigDur)*ix;
            end
            trigTime_on((trigdis_err(1)+TRdur_errorintervall):trigdis_err(end)) = [];
            trigTime_off((trigdis_err(1)+TRdur_errorintervall):trigdis_err(end)) = [];   
        end

        trigTime=trigTime_on;
        trigDur=trigTime_off-trigTime_on;
    
        for zx=1:(size(trigTime_off,1)-1);
            trigDurInter(zx)=trigTime_on(zx+1)-trigTime_off(zx);
            trigDurTotal(zx)=trigDur(zx)+trigDurInter(zx);
            if trigDurTotal(zx) < 1.19
                display(['trigDur of # ' num2str(zx) 'to small in' protocolfile '.mat']);
            end;
        end;
        
        % Correction plot:
        figure(25);
        clf
        axes
        hold on
        clear ix
        ax=gca; 
        ax.XLim = [trigTime_on_orig(trigdis_err(1)-3)-0.5,trigTime_on_orig(trigdis_err(end)+3)+0.5];
        ax.XTick = [trigTime_on_orig(trigdis_err(1)-3):trigTime_on_orig(trigdis_err(end)+3)];
        ax.XTickLabel = [trigTime_on_orig(trigdis_err(1)-3):trigTime_on_orig(trigdis_err(end)+3)];
        clear h h1
        counter=1;
        for ix = trigdis_err(1)-3:trigdis_err(1)+3+TRdur_errorintervall;
            h(counter)=plot([trigTime_on(ix),trigTime_on(ix)],[0,1]);
            h(counter).Color=[1 0.5 0];
            h(counter).LineWidth=1;
            hold on
            counter=counter+1;
        end
        counter=1;
        for ix = trigdis_err(1)-3:trigdis_err(end)+3;
            h1(counter)=line([trigTime_on_orig(ix),trigTime_on_orig(ix)],[0,1]);
            h1(counter).LineStyle='--';
            h1(counter).LineWidth=0.75;
            h1(counter).Color=[0 0 0];
            hold on
            counter=counter+1;
        end        

        title(subject{1},'Interpreter','none')
        legend([h(1),h1(1)],'Trigger Corrected','Trigger Orig', ...
            'Location', 'Best')
        print(gcf,'-dpsc2','-append',outps) % make postcript file
    end
    
    % correction of uncorrect trigDur
    ToCorrect=find(trigDurTotal<1.19);
    if ~isempty(ToCorrect);
        trigTime(ToCorrect(2))=[];
        trigTime_on(ToCorrect(2))=[];
        trigTime_off(ToCorrect(2))=[];
        display(['trigDur of # ' num2str(zx) 'corrected in' protocolfile '.mat']);
        trigDur=trigTime_off-trigTime_on;
        for zx=1:(size(trigTime_off,1)-1);
            trigDurInter(zx)=trigTime_on(zx+1)-trigTime_off(zx);
            trigDurTotal(zx)=trigDur(zx)+trigDurInter(zx);
            if trigDurTotal(zx) < 1.19
                error(['trigDurTotal of # ' num2str(zx) 'to small/large in' protocolfile '.mat']);
            end;
        end;
    end;
    
    for zx=1:size(trigDur,1);
        if trigDur(zx) > 0.027 | trigDur(zx) < 0.023
            display(['CAVE: trigDur of # ' num2str(zx) 'to small/large in' protocolfile '.mat']);
        end;
    end;
    trigInter=diff(trigTime);
    
    % remove false signals detected..
    ToDelete= find( trigInter >1.21 | trigInter < 1.19);
    
    % This is added since sometime triggers at the end of the scan are
    % found:
    ToDelete=ToDelete(find(ToDelete<1550));
    
    if ~isempty(ToDelete);
        trigTime([1:ToDelete(end)])= [];
        trigInter([1:ToDelete(end)])= [];
    end;
    
    trigDuringDummy=numel(find(trigTime<fv_on(1)));
    
    trigger.trigDuringDummy=trigDuringDummy;
    trigger.trigTime=trigTime;
    trigger.trigTime_on=trigTime_on;
    trigger.trigTime_off=trigTime_off;
    trigger.trigDurTotal=trigDurTotal;
    trigger.trigDur=trigDur;
    trigger.trigDurInter=trigDurInter;
    
    % %     % Loop for finding the acq_time of the EPI (from brkhdr), which we will
    % %     % need later
    % %     for ix=1:size(acq_time,2);
    % %         if length(protocolfile)==29;
    % %             index1=find(contains(acq_time(ix).name,[protocolfile(6:11)]));
    % %         elseif length(protocolfile)==34;
    % %             index1=find(contains(acq_time(ix).name,[protocolfile(11:16)]));
    % %         end;
    % %         index2=find(contains(acq_time(ix).name,[protocolfile(1:4)]));
    % %         if ~isempty(index1) & ~isempty(index2);
    % %             acq_time_EPI.start=acq_time(ix).start_seconds;
    % %             acq_time_EPI.index=ix;
    % %             acq_time_EPI.name=acq_time(ix).name;
    % %         end;
    % %     end;
    
    %     idx=find(trigDatadiff==-1,numb_of_volumes,'last'); % 2295 = number of volumes for sanity check; 1395 for main!
    scan_start_del5=trigTime(6); %tp when the aquisition of the 6th EPI starts LW
    
    % info for plot: first and last odor signals are artefacts:
    figure(1); subplot(4,1,1);
    plot(dchannels(:,3)+1.2); hold on; plot(dchannels(:,1));
    hold on; h1=line([trigTime(1)*freq trigTime(1)*freq],[0 2.2]); h1.Color=[0 1 1];h1.LineStyle='--';h1.LineWidth=1;
    hold on; h2=line([trigTime(6)*freq trigTime(6)*freq],[0 2.2]); h2.Color=[0 1 0];h2.LineStyle='-.';h2.LineWidth=1;
    hold on; h3=line([fv_off(end)*freq fv_off(end)*freq],[0 2.2]); h3.Color=[1 0 0];h3.LineWidth=1;
    hold on; h4=line([fv_on(1)*freq fv_on(1)*freq],[0 2.2]); h4.Color=[1 1 0];h1.LineStyle='-';h4.LineWidth=1;
    title(cellstr(protocolfile),'Interpreter', 'none');
    if ~isempty(ToCorrect);
        text(0,3,['trigDur of # ' num2str(ToCorrect) 'to small/large in' protocolfile '.mat']);
    end;
    
    subplot(4,1,2);
    plot(dchannels(:,3)+1.2); hold on; plot(dchannels(:,1));
    ax=gca;
    ax.XLim=[0 (fv_on(2)*freq)];
    hold on; h1=line([trigTime(1)*freq trigTime(1)*freq],[0 2.2]); h1.Color=[0 1 0];h1.LineStyle='--';h1.LineWidth=1;
    hold on; h2=line([trigTime(6)*freq trigTime(6)*freq],[0 2.2]); h2.Color=[0 1 0];h2.LineStyle='-.';h2.LineWidth=1;
    hold on; h3=line([fv_off(end)*freq fv_off(end)*freq],[0 2.2]); h3.Color=[1 1 0];h3.LineWidth=1;
    hold on; h4=line([fv_on(1)*freq fv_on(1)*freq],[0 2.2]); h4.Color=[1 1 0];h1.LineStyle='-';h4.LineWidth=1;
    title(cellstr(protocolfile),'Interpreter', 'none');
    
    subplot(4,1,3);
    plot(dchannels(:,3)+1.2); hold on; plot(dchannels(:,1));
    ax=gca;
    ax.XLim=[fv_off(end-1)*freq-10000 trigTime(end)*freq+10000];
    hold on; h1=line([trigTime(1)*freq trigTime(1)*freq],[0 2.2]); h1.Color=[0 1 0];h1.LineStyle='--';h1.LineWidth=1;
    hold on; h2=line([trigTime(6)*freq trigTime(6)*freq],[0 2.2]); h2.Color=[0 1 0];h2.LineStyle='-.';h2.LineWidth=1;
    hold on; h3=line([fv_off(end)*freq fv_off(end)*freq],[0 2.2]); h3.Color=[1 0 0];h3.LineWidth=1;
    hold on; h4=line([fv_on(1)*freq fv_on(1)*freq],[0 2.2]); h4.Color=[1 1 0];h1.LineStyle='-';h4.LineWidth=1;
    title(cellstr(protocolfile),'Interpreter', 'none');
    l=legend('EPI-trigger','Odor-On/Off','EPI-START','EPI-del5START','Paradigm-END','Paradigm-START','Location','southeast');
    l.FontSize=7;
    
    EPIframes_per_sesscion=sum(trigTime > fv_on(1) & trigTime < fv_off(end));
    MyText{1}=string(['EPI volumes during whole paradigm: ' num2str(EPIframes_per_sesscion)]);
    MyText{2}=string(['Scan Start (del5): ' num2str(scan_start_del5) 'ms']);
    MyText{3}=string(['Paradigm duration: ' num2str(fv_off(end)-fv_on(1)) 'ms']);
    MyText{4}=string(['Mean Trial duration: ' num2str((fv_off(end)-fv_on(1))/length(session.trialmatrix)) 'ms']);
    MyText{5}=string(['#Trig: ' num2str(length(trigTime)) ' ; Trig-Intervall (mean): ' num2str(mean(trigInter)) 'ms']);
    MyText{6}=string(['#FV: ' num2str(length(fv_on)) ' ; FV-Dur. (mean): ' num2str(mean(fv_dur)) 'ms']);
    
    MyBox = uicontrol('style','text')
    set(MyBox,'String',MyText)
    xpos=25
    ypos=25
    xsize=300
    ysize=100
    set(MyBox,'Position',[xpos,ypos,xsize,ysize])
    today = datetime('today');
    DateString = datestr(today)
    
    
    print('-dpsc',fullfile(outputdir,['Start_and_End_Control_Paradim_plus_EPI_' DateString '.ps']) ,'-bestfit','-r200','-append')
    
    close(figure(1));
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% del5-creation
    
    fv_on_del5=fv_on-scan_start_del5;
    if fv_on(1) < scan_start_del5;
        error(['first odor before end of dummies in ' protocolfile '.mat'])
    end;
    fv_off_del5=fv_off-scan_start_del5;
    puff_on_del5=puff_on-scan_start_del5;
    puff_off_del5=puff_off-scan_start_del5;
    trigTime_del5=trigTime-scan_start_del5;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% parse timing in table
    
    % PREPARATION:
    events=session.trialmatrix;
    
    % TRIAL 1 - 119
    for i=1:length(fv_on)-1
        
        % ODOR
        events(i).fv_on=fv_on(i);
        events(i).fv_off=fv_off(i);
        events(i).fv_dur=fv_dur(i);
        events(i).fv_on_del5=fv_on_del5(i);
        events(i).fv_off_del5=fv_off_del5(i);
        events(i).fv_dur_del5=fv_dur(i);
        
        % PUFF
        if any(puff_on_del5>fv_on_del5(i) & puff_on_del5<fv_on_del5(i+1))
            events(i).puff_time_del5=puff_on_del5(find(puff_on_del5>fv_on_del5(i) & puff_on_del5<fv_on_del5(i+1)));
            events(i).puff_or_not=1;
        elseif ~any(puff_on_del5>fv_on_del5(i) & puff_on_del5<fv_on_del5(i+1))
            events(i).puff_time_del5=fv_on_del5(i)+3.2;
            events(i).puff_or_not=0;
        end
    end
    
    % LAST TRIAL - treated separately
    i=length(fv_on);
    
    %ODORS
    events(i).fv_on=fv_on(i);
    events(i).fv_off=fv_off(i);
    events(i).fv_dur=fv_dur(i);
    events(i).fv_on_del5=fv_on_del5(i);
    events(i).fv_off_del5=fv_off_del5(i);
    events(i).fv_dur_del5=fv_dur(i);
    
    % PUFF
    if any(puff_on_del5>fv_on_del5(i) & puff_on_del5<(fv_on_del5(i)+events(i).ITI+2))
        events(i).puff_time_del5=puff_on_del5(find(puff_on_del5>fv_on_del5(i) & puff_on_del5<(fv_on_del5(i)+events(i).ITI+2)));
        events(i).puff_or_not=1;
    elseif ~any(puff_on_del5>fv_on_del5(i) & puff_on_del5<(fv_on_del5(i)+events(i).ITI+2))
        events(i).puff_time_del5=fv_on_del5(i)+3.2;
        events(i).puff_or_not=0;
    end
    
    %% create info
    
    if animals==1 % single sessions
        newname=protocolfile(1:end-4);
        info.ID=intanfile;
        info.animal=subject;
    end
    
    k=strfind(intanfile,'_20'); % CC (in order to get the proper date
    info.date=intanfile(k(1)+1:k(1)+6); % CC
    
    info.scan_start_del5=scan_start_del5;
    info.EPIframes_per_session=sum(trigTime > fv_on(1) & trigTime < fv_off(end));
    
    %% save updated protocol
    
    %save in subjdir...
    save([outputdir filesep subject{1} filesep newname '_new.mat'], 'events', 'info',  'session', 'freq', 'trigger');
    
    clear events info session intan_files intanpath
    
end