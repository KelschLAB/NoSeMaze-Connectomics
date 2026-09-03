function gstruc_mat = rb_graph_thresh_flex( ...
    cormat, cutoffarray, normalize, calcat)
% RB_GRAPH_THRESH_FLEX Calculate graph metrics across thresholds.
%
% INPUT
%   cormat
%       Nsubject x Nwindow cell array of connectivity matrices.
%
%   cutoffarray
%       Relative density thresholds.
%
%   normalize
%       Passed unchanged to rb_graph_individual_flex:
%         'max'  normalize to maximum weight
%         'bin'  binarize
%         'none' no normalization
%
%   calcat
%       Graph-metric categories passed unchanged to
%       rb_graph_individual_flex.
%
% OUTPUT
%   gstruc_mat
%       Nthreshold x Nsubject x Nwindow structure array.
%
% Scientific calculations are unchanged from the historical function.
% The only implementation change is parallel-pool handling: the original
% code unconditionally opened 36 workers and then deleted the pool. The
% cleaned version reuses an existing pool or opens the local default pool,
% and closes only a pool that it created itself.

assert(iscell(cormat), 'cormat must be a cell array.');
assert(~isempty(cormat), 'cormat is empty.');
assert(~isempty(cutoffarray), 'cutoffarray is empty.');

assert(exist('rb_graph_individual_flex', 'file') == 2, ...
    ['rb_graph_individual_flex.m is not available on the MATLAB path. ' ...
     'This function contains the actual graph-metric definitions.']);

Nthr = numel(cutoffarray);
Nsub = size(cormat, 1);
Nwin = size(cormat, 2);

%% Parallel pool

pool = gcp('nocreate');
createdPool = isempty(pool);

if createdPool
    pool = parpool('local'); %#ok<NASGU>
end

cleanupPool = onCleanup(@() close_created_pool(createdPool));

%% Calculation

if Nwin > Nthr

    for jsub = 1:Nsub
        for jthr = 1:Nthr

            parfor jwin = 1:Nwin

                fprintf( ...
                    'Subject %d, threshold %.3f, window %d\n', ...
                    jsub, ...
                    cutoffarray(jthr), ...
                    jwin ...
                );

                gstruc_mat(jthr, jsub, jwin) = ...
                    rb_graph_individual_flex( ...
                        cormat{jsub, jwin}, ...
                        cutoffarray(jthr), ...
                        normalize, ...
                        calcat ...
                    );
            end
        end
    end

else

    for jsub = 1:Nsub

        fprintf('Calculating graph metrics for subject %d\n', jsub);

        for jwin = 1:Nwin

            parfor jthr = 1:Nthr

                fprintf( ...
                    'Threshold %.3f, window %d\n', ...
                    cutoffarray(jthr), ...
                    jwin ...
                );

                gstruc_mat(jthr, jsub, jwin) = ...
                    rb_graph_individual_flex( ...
                        cormat{jsub, jwin}, ...
                        cutoffarray(jthr), ...
                        normalize, ...
                        calcat ...
                    );
            end
        end
    end
end

clear cleanupPool;

end


function close_created_pool(createdPool)

if createdPool
    pool = gcp('nocreate');

    if ~isempty(pool)
        delete(pool);
    end
end

end
