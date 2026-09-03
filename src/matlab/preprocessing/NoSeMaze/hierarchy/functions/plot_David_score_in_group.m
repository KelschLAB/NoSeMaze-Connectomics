function f = plot_David_score_in_group(DS_info,names)
%% original design from Carla Filosa
% DS_info is output of DS_info = compute_DS_from_match_matrix(full_match_matrix);
% names should be in the order of the original match-matrix, not sorted by
% rank!

Dvs = DS_info.DS_sorted;

%%%% David's score plot
f=figure('name','David');
dp=plot(Dvs,'k--d','MarkerSize',6,'MarkerEdgeColor','k',...
    'MarkerFaceColor',[0.2 0.2 0.2]);
xlim([0.5,length(Dvs)+0.5])
ylim([min(Dvs)-1,max(Dvs)+1])
box off;
xticks(1:length(Dvs));
xticklabels(names(DS_info.DS_sortedIndex));
xtickangle(45);
ylabel('David`s Score')

set_fonts()
f.Units = 'centimeters';
f.Position = [3 3 7 5];
end