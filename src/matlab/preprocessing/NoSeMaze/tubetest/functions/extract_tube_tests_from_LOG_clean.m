function hierarchy_data = extract_tube_tests_from_LOG_clean(inputFile)
% EXTRACT_TUBE_TESTS_FROM_LOG_CLEAN Extract dyadic tube competitions.
%
% Cleaned repository version of the historical NoSeMaze tube-test
% extraction code. Rows of match_matrix are winners; columns are losers.
%
% Historical thresholds retained:
%   duplicate detection: same animal + same detector + <0.5 s
%   maximum candidate tube time: 60 s
%   maximum competition duration: 15 s
%
% Multi-animal events are flagged here and curated later.

arguments
    inputFile (1,:) char
end

loaded = load(inputFile,'Data');
if ~isfield(loaded,'Data')
    error('Input file lacks Data:\n%s',inputFile);
end
Data = loaded.Data;

if isempty(Data)
    hierarchy_data = struct('ID',{{}},'match_matrix',[], ...
        'match_info',{{}},'Data',Data,'Data_filtered',Data,'input',inputFile);
    return;
end

required = {'Day','Time_sec','Detector','Animal'};
missing = setdiff(required,Data.Properties.VariableNames);
if ~isempty(missing)
    error('Data missing required column(s): %s',strjoin(missing,', '));
end

Data.Animal = cellstr(string(Data.Animal));
ID = unique(Data.Animal);

Data.raw_index = (1:height(Data))';
Data.tube = ones(height(Data),1);
Data.tube(Data.Detector==3 | Data.Detector==4) = 2;

%% Remove rapid repeated detections

Data = sortrows(Data,{'Animal','Time_sec'},{'ascend','ascend'});

if height(Data)>1
    deltaDetection = diff(Data.Time_sec);
    doubleDetections = [ ...
        diff(Data.Detector)==0 & ...
        deltaDetection<0.5 & ...
        strcmp(Data.Animal(1:end-1),Data.Animal(2:end)); ...
        false];
else
    doubleDetections = false(height(Data),1);
end

Data_filtered = Data(~doubleDetections,:);

startIndex = find([true;~doubleDetections]);
Data_filtered.Detection_start = ...
    Data.Time_sec(startIndex(1:height(Data_filtered)));

Data_filtered = sortrows(Data_filtered,'Time_sec','ascend');
Data = sortrows(Data,'Time_sec','ascend');

%% Extract competitions

nAnimals = numel(ID);
match_matrix = zeros(nAnimals,nAnimals);
match_info = cell(nAnimals,nAnimals);
eventCounter = 1;

for winnerIndex = 1:nAnimals

    winnerID = ID{winnerIndex};

    winnerDetections = Data_filtered( ...
        strcmp(Data_filtered.Animal,winnerID),:);

    winnerDetections.filtered_index = find( ...
        strcmp(Data_filtered.Animal,winnerID));

    % Historical candidate passage definition.
    winnerInTube = find(abs(diff(winnerDetections.Detector))==1);

    for eventIndex = 1:numel(winnerInTube)

        wr = winnerInTube(eventIndex);

        winnerEntryTime = winnerDetections.Detection_start(wr);
        winnerExitTime = winnerDetections.Time_sec(wr+1);
        winnerTimeSpentIn = winnerExitTime-winnerEntryTime;
        winnerEntryDetector = winnerDetections.Detector(wr);
        winnerExitDetector = winnerDetections.Detector(wr+1);
        winnerTube = winnerDetections.tube(wr);

        if winnerTimeSpentIn>60
            continue;
        end

        for loserIndex = 1:nAnimals

            if winnerIndex==loserIndex
                continue;
            end

            loserID = ID{loserIndex};

            loserDetections = Data_filtered( ...
                strcmp(Data_filtered.Animal,loserID),:);

            loserExitIndex = find( ...
                loserDetections.Time_sec>winnerEntryTime & ...
                loserDetections.Time_sec<winnerExitTime & ...
                loserDetections.Detector==winnerExitDetector);

            if isempty(loserExitIndex)
                continue;
            end

            currentLoserExit = loserExitIndex(end);

            if currentLoserExit<=1
                continue;
            end

            % Exclude simple following through the tube.
            if abs( ...
                    loserDetections.Detector(currentLoserExit-1) - ...
                    loserDetections.Detector(currentLoserExit))==1
                continue;
            end

            if winnerTimeSpentIn>15
                continue;
            end

            eventWindow = ...
                Data.Time_sec>winnerEntryTime & ...
                Data.Time_sec<winnerExitTime & ...
                Data.tube==winnerTube;

            multipleAnimalsFlag = ...
                numel(unique(Data.Animal(eventWindow)))>2;

            match_matrix(winnerIndex,loserIndex) = ...
                match_matrix(winnerIndex,loserIndex)+1;

            dyadCounter = match_matrix(winnerIndex,loserIndex);

            event = struct();
            event.winner_entry_time = winnerEntryTime;
            event.winner_exit_time = winnerExitTime;
            event.winner_entry_Detector = winnerEntryDetector;
            event.winner_exit_Detector = winnerExitDetector;
            event.winner_time_spent_in = winnerTimeSpentIn;
            event.winner_ID = winnerID;
            event.multiple_animals = multipleAnimalsFlag;

            dayText = erase(char(string(Data.Day{1})),{'-',' '});
            event.unique_event_ID = ...
                str2double([dayText num2str(eventCounter)]);

            event.loser_exit_time = ...
                loserDetections.Time_sec(currentLoserExit);
            event.loser_exit_Detector = ...
                loserDetections.Detector(currentLoserExit);
            event.loser_time_detected = ...
                loserDetections.Time_sec(currentLoserExit) - ...
                loserDetections.Detection_start(currentLoserExit);
            event.loser_ID = loserID;

            filteredCenter = winnerDetections.filtered_index(wr);
            filteredRows = max(1,filteredCenter-20): ...
                min(height(Data_filtered),filteredCenter+20);
            event.data_filtered = Data_filtered(filteredRows,:);

            rawCenter = winnerDetections.raw_index(wr);
            rawRows = max(1,rawCenter-20):min(height(Data),rawCenter+20);
            event.data = Data(rawRows,:);

            match_info{winnerIndex,loserIndex}(dyadCounter) = event;
            eventCounter = eventCounter+1;
        end
    end
end

hierarchy_data = struct();
hierarchy_data.ID = ID;
hierarchy_data.match_matrix = match_matrix;
hierarchy_data.match_info = match_info;
hierarchy_data.Data = Data;
hierarchy_data.Data_filtered = Data_filtered;
hierarchy_data.input = inputFile;
end
