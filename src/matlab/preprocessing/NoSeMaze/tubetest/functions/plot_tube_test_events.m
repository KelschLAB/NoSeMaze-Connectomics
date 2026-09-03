function plot_tube_test_events(hierarchy_data)
% PLOT_TUBE_TEST_EVENTS Save one QC image per extracted competition.
%
% red   = winner-entry detector
% green = winner-exit / loser detector
% blue  = other detector

matchMatrix = hierarchy_data.match_matrix;
matchInfo = hierarchy_data.match_info;
Data = hierarchy_data.Data;

if isfield(hierarchy_data,'save_dir') && ~isfolder(hierarchy_data.save_dir)
    mkdir(hierarchy_data.save_dir);
end

for winnerIndex = 1:size(matchMatrix,1)
    for loserIndex = 1:size(matchMatrix,2)

        events = matchInfo{winnerIndex,loserIndex};
        if isempty(events)
            continue;
        end

        for eventIndex = 1:numel(events)

            f = plot_single_event(Data,events(eventIndex));

            if isfield(hierarchy_data,'save_dir')
                outputName = sprintf('%svs%s_%03d_event%s.png', ...
                    hierarchy_data.ID{winnerIndex}, ...
                    hierarchy_data.ID{loserIndex}, ...
                    eventIndex, ...
                    char(string(events(eventIndex).unique_event_ID)));

                exportgraphics(f, ...
                    fullfile(hierarchy_data.save_dir,outputName), ...
                    'Resolution',150);
            end

            close(f);
        end
    end
end
end


function f = plot_single_event(Data,eventInfo)

edges = round(eventInfo.winner_entry_time-15 : 0.5 : ...
    eventInfo.winner_exit_time+15,1);

if numel(edges)<2
    edges = [eventInfo.winner_entry_time-15 eventInfo.winner_exit_time+15];
end

centers = edges(1:end-1)+diff(edges)/2;

relevant = Data(Data.Time_sec>edges(1) & Data.Time_sec<edges(end),:);

winnerHeat = zeros(1,numel(centers));
loserHeat = zeros(1,numel(centers));

winnerRows = strcmp(string(relevant.Animal),string(eventInfo.winner_ID));
loserRows = strcmp(string(relevant.Animal),string(eventInfo.loser_ID));

winnerHeat(histcounts(relevant.Time_sec(winnerRows & ...
    relevant.Detector==eventInfo.winner_entry_Detector),edges)>0) = 1;
winnerHeat(histcounts(relevant.Time_sec(winnerRows & ...
    relevant.Detector==eventInfo.winner_exit_Detector),edges)>0) = 2;

loserHeat(histcounts(relevant.Time_sec(loserRows & ...
    relevant.Detector==eventInfo.winner_entry_Detector),edges)>0) = 1;
loserHeat(histcounts(relevant.Time_sec(loserRows & ...
    relevant.Detector==eventInfo.winner_exit_Detector),edges)>0) = 2;

uniqueIDs = unique(cellstr(string(Data.Animal)));
uniqueIDs(ismember(string(uniqueIDs), ...
    [string(eventInfo.winner_ID) string(eventInfo.loser_ID)])) = [];

othersHeat = zeros(numel(uniqueIDs),numel(centers));

for animalIndex = 1:numel(uniqueIDs)

    rows = strcmp(string(relevant.Animal),string(uniqueIDs{animalIndex}));

    othersHeat(animalIndex,histcounts(relevant.Time_sec(rows & ...
        relevant.Detector==eventInfo.winner_entry_Detector),edges)>0) = 1;

    othersHeat(animalIndex,histcounts(relevant.Time_sec(rows & ...
        relevant.Detector==eventInfo.winner_exit_Detector),edges)>0) = 2;

    othersHeat(animalIndex,histcounts(relevant.Time_sec(rows & ...
        relevant.Detector~=eventInfo.winner_entry_Detector & ...
        relevant.Detector~=eventInfo.winner_exit_Detector),edges)>0) = 3;
end

f = figure('Visible','off','Color','white','Position',[100 100 900 520]);
tiledlayout(f,10,1,'TileSpacing','compact');

ax1 = nexttile(1,[3 1]);
imagesc(ax1,centers,1:2,[winnerHeat;loserHeat],[0 3]);
yticks(ax1,[1 2]);
yticklabels(ax1,{eventInfo.winner_ID,eventInfo.loser_ID});
xlabel(ax1,'Seconds');
title(ax1,sprintf('Event ID: %s; multiple animals: %d', ...
    char(string(eventInfo.unique_event_ID)),logical(eventInfo.multiple_animals)), ...
    'Interpreter','none');
format_axis(ax1);

ax2 = nexttile(5,[6 1]);
if isempty(uniqueIDs)
    axis(ax2,'off');
    text(ax2,0.5,0.5,'No other animals in event window', ...
        'HorizontalAlignment','center');
else
    imagesc(ax2,centers,1:numel(uniqueIDs),othersHeat,[0 3]);
    yticks(ax2,1:numel(uniqueIDs));
    yticklabels(ax2,uniqueIDs);
    xlabel(ax2,'Seconds');
    format_axis(ax2);
end

colormap(f,[1 1 1; 1 0 0; 0 1 0; 0 0 1]);
end


function format_axis(ax)
set(ax,'FontSize',9,'FontName','Arial');
ax.XLabel.FontSize = 9;
ax.YLabel.FontSize = 9;
ax.Title.FontSize = 8;
end
