function f = plot_hierarchy_graph_in_group(DS_info,names)
%% original design from Carla Filosa
% DS_info is output of DS_info = compute_DS_from_match_matrix(full_match_matrix);
% names should be in the order of the original match-matrix, not sorted by
% rank!

[win, los]=find(DS_info.match_matrix);
for i=1:length(win)
    weight(i)=DS_info.match_matrix(win(i),los(i));
end

%%%%% Graph plot
G=digraph(win,los,weight);  
LWidths = 3*G.Edges.Weight/max(G.Edges.Weight);
f=figure('name','Graph');
p=plot(G,'LineWidth',LWidths,'NodeLabel',[],'Layout','force');
p.ArrowSize=6; p.EdgeColor='b';p.NodeColor=[.6 .6 .6];
p.NodeLabel=names;
p.NodeFontName = 'Arial';
p.NodeFontSize = 6;
p.MarkerSize = 10;
% color the nodes with rank
p.NodeCData = 1:numel(names);
% p.NodeCData = 10:10:100;
c=colorbar;
c.Label.String = 'rank';
set(c, 'YDir', 'reverse' );

set_fonts()
f.Units = 'centimeters';
f.Position = [3 3 12 6];

end