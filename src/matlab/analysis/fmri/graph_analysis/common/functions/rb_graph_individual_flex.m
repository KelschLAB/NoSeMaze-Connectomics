function gstruc = rb_graph_individual_flex(M, thr, normalize, calcat)
% RB_GRAPH_INDIVIDUAL_FLEX Primary manuscript graph metrics only.
%
% This public version intentionally computes ONLY the graph quantities used
% in the manuscript:
%
%   local:
%       l_strength
%       l_cc
%
%   global:
%       g_swp
%       g_delta_C
%       g_delta_L
%
% The public implementation contains only metrics used by this manuscript.
%
% Primary workflow:
%   1. connected density thresholding with diacut()
%   2. maximum-weight normalization
%   3. local weighted node strength
%   4. local weighted clustering coefficient
%   5. Muldoon small-world propensity, delta_C and delta_L
%
% IMPORTANT:
% The former custom *_JR outputs are deliberately NOT calculated:
%
%   g_swp_JR
%   g_delta_C_JR
%   g_delta_L_JR
%
% The manuscript analysis uses the direct outputs of
% small_world_propensity().
%
% INPUT
%   M          positive-weight symmetric connectivity matrix
%   thr        density threshold (fraction of edges retained)
%   normalize  historical normalization option; primary = 'max'
%   calcat     retained for compatibility; primary = {'manuscript'}
%
% OUTPUT
%   gstruc     graph metrics for one subject at one threshold

assert(ismatrix(M) && size(M,1) == size(M,2), ...
    'M must be a square connectivity matrix.');

assert(all(M(:) >= 0 | isnan(M(:))), ...
    'M contains negative weights; positive-edge preprocessing is required.');

assert(isscalar(thr) && thr >= 0 && thr <= 1, ...
    'thr must be between 0 and 1.');

if nargin < 4 || isempty(calcat)
    calcat = {'manuscript'};
end

assert(any(strcmp('manuscript', calcat)) || any(strcmp('all', calcat)), ...
    ['This streamlined public implementation supports the primary ' ...
     'manuscript graph metrics only.']);

%% Store original matrix and threshold

gstruc = struct();
gstruc.o_CIJ = M;
gstruc.o_cutoffs = thr;

if thr > 0

    assert(exist('diacut', 'file') == 2, ...
        'diacut.m is required for connected-network thresholding.');

    M_thr = diacut(M, thr);

else

    M_thr = M;
end

gstruc.o_CIJ_thresh = M_thr;

%% Historical primary normalization

switch normalize

    case 'max'

        M_thr = weight_conversion(M_thr, 'normalize');
        gstruc.o_CIJ_thr_nrm = M_thr;

    case 'bin'

        % Retained for interface compatibility, but not used in the primary
        % manuscript analysis.
        M_thr = double(M_thr > 0);
        gstruc.o_CIJ_bin = M_thr;

    case 'none'

        % No additional transformation.

    otherwise

        error('Normalization option must be "none", "bin", or "max".');
end

%% Local node strength

% Historical weighted implementation:
%   strength = sum(M_thr)
%
% Matrix is symmetric, therefore row/column sums are equivalent.
strength = sum(M_thr);
gstruc.l_strength = strength';

%% Local weighted clustering coefficient

switch normalize

    case 'bin'
        lcc = clustering_coef_bu(M_thr);

    otherwise
        lcc = clustering_coef_wu(M_thr);
end

gstruc.l_cc = lcc;

%% Small-world propensity, delta_C and delta_L

assert(exist('small_world_propensity', 'file') == 2, ...
    'small_world_propensity.m is required.');

if strcmp(normalize, 'bin')

    [SWP, delta_C, delta_L] = ...
        small_world_propensity(M_thr, 'bin');

else

    [SWP, delta_C, delta_L] = ...
        small_world_propensity(M_thr);
end

gstruc.g_swp = SWP;
gstruc.g_delta_C = delta_C;
gstruc.g_delta_L = delta_L;

end
