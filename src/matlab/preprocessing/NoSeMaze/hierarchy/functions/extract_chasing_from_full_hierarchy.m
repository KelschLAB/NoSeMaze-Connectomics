function full_hierarchy = extract_chasing_from_full_hierarchy(full_hierarchy,ops)
% EXTRACT_CHASING_FROM_FULL_HIERARCHY Single close-following/chasing only.
%
% Multiple/double-chasing analyses are intentionally excluded.

if nargin<2; ops = struct(); end
if ~isfield(ops,'threshold_lag_at_detector'); ops.threshold_lag_at_detector = 1.5; end
if ~isfield(ops,'threshold_lag_through_tube'); ops.threshold_lag_through_tube = 2; end

%% Refilter daily data

for day = 1:numel(full_hierarchy)

    Data = full_hierarchy(day).Data;
    Data = sortrows(Data,'Animal','ascend');

    if height(Data)>1
        deltaDetection = diff(Data.Time_sec);
        doubleDetections = [ ...
            diff(Data.Detector)==0 & ...
            deltaDetection<1 & ...
            strcmp(Data.Animal(1:end-1),Data.Animal(2:end)); ...
            false];
    else
        doubleDetections = false(height(Data),1);
    end

    Data_filtered = Data(~doubleDetections,:);
    startIndex = find([true;~doubleDetections]);
    Data_filtered.Detection_start = ...
        Data.Time_sec(startIndex(1:height(Data_filtered)));

    full_hierarchy(day).Data_filtered = sortrows(Data_filtered,'Time_sec','ascend');
end

filtered = vertcat(full_hierarchy.Data_filtered);

counter = 1;
for day = 1:numel(full_hierarchy)
    n = height(full_hierarchy(day).Data_filtered);
    if n==0; continue; end
    rows = counter:(counter+n-1);
    filtered.Detection_start(rows) = ...
        filtered.Detection_start(rows)+(day-1)*24*60*60;
    counter = counter+n;
end

filtered = sortrows(filtered,'Detection_start');
filtered(~ismember(string(filtered.Animal),string(full_hierarchy(1).ID)),:) = [];

chasingIndex = [];

for tubeID = 1:2

    tf = filtered(filtered.tube==tubeID,:);
    tf(tf.Detector==0,:) = [];

    if height(tf)<4; continue; end

    p1 = strfind(abs(diff(tf.Detector))',[0 1 0]);

    p2 = find( ...
        string(tf.Animal(1:end-3))~=string(tf.Animal(2:end-2)) & ...
        string(tf.Animal(1:end-3))==string(tf.Animal(3:end-1)) & ...
        string(tf.Animal(3:end-1))~=string(tf.Animal(4:end)) & ...
        string(tf.Animal(2:end-2))==string(tf.Animal(4:end)))';

    idx = p1(ismember(p1,p2));

    if isempty(idx); continue; end

    deltaEntry = tf.Detection_start(idx+1)-tf.Detection_start(idx);
    deltaExit = tf.Detection_start(idx+3)-tf.Detection_start(idx+2);
    deltaVictim = tf.Detection_start(idx+2)-tf.Detection_start(idx);
    deltaChaser = tf.Detection_start(idx+3)-tf.Detection_start(idx+1);

    idx = idx( ...
        deltaEntry<ops.threshold_lag_at_detector & ...
        deltaExit<ops.threshold_lag_at_detector & ...
        deltaVictim<ops.threshold_lag_through_tube & ...
        deltaChaser<ops.threshold_lag_through_tube);

    chasingIndex = [chasingIndex; ...
        find(ismember(filtered.Detection_start,tf.Detection_start(idx)))]; %#ok<AGROW>
end

chasingIndex = sort(unique(chasingIndex));

for day = 1:numel(full_hierarchy)
    full_hierarchy(day).match_matrix_chasing = ...
        zeros(size(full_hierarchy(day).match_matrix));
    full_hierarchy(day).match_info_chasing = ...
        cell(size(full_hierarchy(day).match_info));
end

uniqueDays = unique(filtered.Day,'stable');

for day = 1:min(numel(uniqueDays),numel(full_hierarchy))

    cur = chasingIndex(ismember(filtered.Day(chasingIndex),uniqueDays{day}));

    for ii = 1:numel(cur)

        r = cur(ii);
        if r+3>height(filtered); continue; end

        loser = char(string(filtered.Animal(r)));
        winner = char(string(filtered.Animal(r+1)));

        loserID = find(strcmp(string(full_hierarchy(1).ID),loser),1);
        winnerID = find(strcmp(string(full_hierarchy(1).ID),winner),1);

        if isempty(loserID) || isempty(winnerID) || strcmp(loser,winner)
            continue;
        end

        full_hierarchy(day).match_matrix_chasing(winnerID,loserID) = ...
            full_hierarchy(day).match_matrix_chasing(winnerID,loserID)+1;

        n = full_hierarchy(day).match_matrix_chasing(winnerID,loserID);

        info.winner_entry_time = filtered.Time_sec(r+1);
        info.loser_entry_time = filtered.Time_sec(r);
        info.winner_exit_time = filtered.Time_sec(r+3);
        info.loser_exit_time = filtered.Time_sec(r+2);
        info.winner_ID = winner;
        info.loser_ID = loser;
        info.winner_entry_Detector = filtered.Detector(r+1);
        info.winner_exit_Detector = filtered.Detector(r+3);
        info.loser_entry_Detector = filtered.Detector(r);
        info.loser_exit_Detector = filtered.Detector(r+2);

        full_hierarchy(day).match_info_chasing{winnerID,loserID}(n) = info;
        clear info
    end
end
end
