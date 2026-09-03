function mtx = diacut(CIJ, cutoff)
% DIACUT Threshold a symmetric matrix while preserving connectedness.
%
% INPUT
%   CIJ
%       Symmetric connection/adjacency matrix.
%   cutoff
%       Target fraction of edges retained.
%
% OUTPUT
%   mtx
%       Thresholded connected symmetric matrix.
%
% Historical implementation by Mika Rubinov, used in the reappraisal graph
% analysis. The algorithm removes the weakest removable edges while testing
% whether their removal disconnects the graph.

n = length(CIJ);

% Use lower triangular matrix and remove diagonal.
mtx = tril(CIJ .* ~eye(n));

index = sortrows([find(mtx), mtx(find(mtx))], 2);
index = index(:, 1);  % weakest -> strongest edge indices

remainder = length(index);
total_edges = n^2 / 2;

while (remainder / total_edges) > cutoff

    if isempty(index)
        break;
    end

    [u, v] = ind2sub(n, index(1));

    matrix = mtx + mtx';
    matrix(u, v) = 0;

    neib = find(matrix(u, :));

    while true

        new_neib = setdiff(find(sum(matrix(neib, :), 1)), neib); %#ok<FNDSB>

        if isempty(new_neib)

            % Removing the edge would disconnect the graph.
            break;

        elseif any(new_neib == v)

            % Graph stays connected; remove the edge.
            mtx(u, v) = 0;
            remainder = remainder - 1;
            break;

        else

            neib = [neib, new_neib]; %#ok<AGROW>
        end
    end

    index(1) = [];
end

mtx = mtx + mtx';

end
