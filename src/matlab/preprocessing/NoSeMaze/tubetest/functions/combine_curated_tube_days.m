function full_hierarchy = combine_curated_tube_days(eventPlotDir,canonicalIDs)
% COMBINE_CURATED_TUBE_DAYS Combine manually curated daily competition data.
%
% eventPlotDir contains LOG_*/Data.mat and optional:
%   include_events.mat  variable include
%   exclude_events.mat  variable exclude
%   invert_events.mat   variable invert
%
% For manually inverted events, winner_ID and loser_ID are swapped before
% the curated match matrix is rebuilt.

arguments
    eventPlotDir (1,:) char
    canonicalIDs cell = {}
end

if ~isfolder(eventPlotDir)
    error('Event plot directory not found:\n%s',eventPlotDir);
end

includeEvents = load_event_list(fullfile(eventPlotDir,'include_events.mat'),'include');
excludeEvents = load_event_list(fullfile(eventPlotDir,'exclude_events.mat'),'exclude');
invertEvents = load_event_list(fullfile(eventPlotDir,'invert_events.mat'),'invert');

dataFiles = dir(fullfile(eventPlotDir,'*','Data.mat'));
if isempty(dataFiles)
    error('No */Data.mat files found below:\n%s',eventPlotDir);
end

[~,order] = sort(string({dataFiles.folder}));
dataFiles = dataFiles(order);

if isempty(canonicalIDs)
    first = load(fullfile(dataFiles(1).folder,dataFiles(1).name),'hierarchy_data');
    canonicalIDs = cellstr(string(first.hierarchy_data.ID(:)));
else
    canonicalIDs = cellstr(string(canonicalIDs(:)));
end

nAnimals = numel(canonicalIDs);
full_hierarchy = repmat(struct(),1,numel(dataFiles));

for dayIndex = 1:numel(dataFiles)

    inputFile = fullfile(dataFiles(dayIndex).folder,dataFiles(dayIndex).name);
    loaded = load(inputFile,'hierarchy_data');

    if ~isfield(loaded,'hierarchy_data')
        error('Missing hierarchy_data in:\n%s',inputFile);
    end

    hd = loaded.hierarchy_data;
    alignedInfo = cell(nAnimals,nAnimals);

    for oldWinner = 1:size(hd.match_info,1)
        for oldLoser = 1:size(hd.match_info,2)

            events = hd.match_info{oldWinner,oldLoser};
            if isempty(events)
                continue;
            end

            for eventIndex = 1:numel(events)

                event = events(eventIndex);
                eventID = [];
                if isfield(event,'unique_event_ID')
                    eventID = event.unique_event_ID;
                end

                isMulti = isfield(event,'multiple_animals') && ...
                    logical(event.multiple_animals);

                if isMulti && ~event_is_listed(eventID,includeEvents)
                    continue;
                end

                if event_is_listed(eventID,excludeEvents)
                    continue;
                end

                if event_is_listed(eventID,invertEvents)
                    oldWinnerID = event.winner_ID;
                    event.winner_ID = event.loser_ID;
                    event.loser_ID = oldWinnerID;
                    event.already_inverted = true;
                else
                    event.already_inverted = false;
                end

                newWinner = find(strcmp(canonicalIDs,char(string(event.winner_ID))),1);
                newLoser = find(strcmp(canonicalIDs,char(string(event.loser_ID))),1);

                if isempty(newWinner) || isempty(newLoser)
                    continue;
                end

                if isempty(alignedInfo{newWinner,newLoser})
                    alignedInfo{newWinner,newLoser} = event;
                else
                    alignedInfo{newWinner,newLoser}(end+1) = event;
                end
            end
        end
    end

    alignedMatrix = zeros(nAnimals,nAnimals);
    for winner = 1:nAnimals
        for loser = 1:nAnimals
            alignedMatrix(winner,loser) = numel(alignedInfo{winner,loser});
        end
    end

    full_hierarchy(dayIndex).ID = canonicalIDs;
    full_hierarchy(dayIndex).match_matrix = alignedMatrix;
    full_hierarchy(dayIndex).match_info = alignedInfo;

    if isfield(hd,'Data'); full_hierarchy(dayIndex).Data = hd.Data; else; full_hierarchy(dayIndex).Data = table(); end
    if isfield(hd,'Data_filtered'); full_hierarchy(dayIndex).Data_filtered = hd.Data_filtered; else; full_hierarchy(dayIndex).Data_filtered = table(); end
    if isfield(hd,'input'); full_hierarchy(dayIndex).input = hd.input; else; full_hierarchy(dayIndex).input = ''; end

    full_hierarchy(dayIndex).source_file = inputFile;
    full_hierarchy(dayIndex).day_index = dayIndex;
end
end


function values = load_event_list(filePath,varName)
values = [];
if ~isfile(filePath); return; end
loaded = load(filePath,varName);
if isfield(loaded,varName)
    values = loaded.(varName);
    values = values(:);
end
end


function tf = event_is_listed(eventID,eventList)
if isempty(eventID) || isempty(eventList)
    tf = false;
elseif isnumeric(eventID) && isnumeric(eventList)
    tf = ismember(eventID,eventList);
else
    tf = ismember(string(eventID),string(eventList));
end
end
