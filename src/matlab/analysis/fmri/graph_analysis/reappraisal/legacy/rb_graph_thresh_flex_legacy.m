function gstruc_mat=rb_graph_thresh_flex(cormat,cutoffarray,normalize,calcat)

% _flex version is more flexible as it alllows to choose from various sets
% of graph metrics instead of always calculating everything.
%
% Graph analysis using rb_new_graph_individual_flex for a series of thresholds 
%
% !!! useful version giving back (N_thresholds x N_subjects) structure array !!!
%
% cormat = cell array of connectivity matrices (NsubxNwin), Nwin=1 for 
% cutoffarray = array of relative cutoff values (percentage of heighest
%               weight edges preserved)
% normalize = 'max': normalze to maximum weight, 'bin': binarize, 'none': don't normalize
% calcat = cell array with categories of graph properties to calculate
%           'all' : calculate all
%           'smallworld' : Clustering coeff, characteristic path length, small world index
%           'efficiency' : global and local efficiencies
%           'centrality' : degree, strength, betweennness centrality
%           'modularity' : modularity, participation index
%           'norm' : generate random networks and normalized versions of
%                   properties chosen by other options
%
% gstruc = structure with graph properties 
%       .l_[  ] = local properties
%       .g_[  ] = global properties
%       .o_[  ] = other stuff
%

Nthr=length(cutoffarray);
Nsub=size(cormat,1);
Nwin=size(cormat,2);

parpool(36)

if Nwin>Nthr

    for jsub=1:Nsub
        for jthr=1:Nthr

            parfor jwin=1:Nwin
                disp(['Calculating graph metrics for Subject ' num2str(jsub) ', Threshold: ' num2str(cutoffarray(jthr)) ', Win: ' num2str(jwin)]);
                gstruc_mat(jthr,jsub,jwin)=rb_graph_individual_flex(cormat{jsub,jwin},cutoffarray(jthr),normalize,calcat);
            end
        end

    end

    delete(gcp)

else
    for jsub=1:Nsub
        disp(['Calculating graph metrics for subject ' num2str(jsub)]);
        for jwin=1:Nwin

            parfor jthr=1:Nthr
                disp(['Threshold: ' num2str(cutoffarray(jthr)) ', Win: ' num2str(jwin)]);
                gstruc_mat(jthr,jsub,jwin)=rb_graph_individual_flex(cormat{jsub,jwin},cutoffarray(jthr),normalize,calcat);
            end
        end

    end

    delete(gcp)
end
