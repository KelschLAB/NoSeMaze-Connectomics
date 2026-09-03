function mtx = diacut(CIJ, cutoff)
% input:  
%           CIJ  = connection/adjacency matrix
%           cutoff = cutoff (percentage) or edges left after the removal of
%           weak connecting edges
% output: 
%           connection/adjacency matrix with threshold applied
%
%returns strongly connected matrix with the largest possible nodes
%assumes that input matrix is strongly connected and symmetric
%
%%Mika Rubinov, UNSW

n = length(CIJ);                              %use lower triangular matrix
mtx = tril(CIJ .* not(eye(n)));               %remove diagonal to obtain true existing edges
                                    
index = sortrows([find(mtx) mtx(find(mtx))], 2);
index = index(:,1);                         %indexes of edges from smallest to largest

remainder = length(index);                  %will decrease with edge removal
total_edges = n^2/2;                        %/2 as use only lower triangle instead of both

while (remainder/total_edges) > cutoff
    %fprintf('remainder/total)edges: %d\n',remainder/total_edges)
    if not(isempty(index))                  %if removable edges still exist
        %tests for connectedness without the edge
        [u v] = ind2sub(n, index(1));
        matrix = mtx + mtx';
        matrix(u,v) = 0;
        neib = find(matrix(u,:));
        
        while 1
            new_neib = setdiff(find(sum(matrix(neib,:),1)), neib);
            if isempty(new_neib)            %if graph disconnects without node
                break
            elseif any(new_neib == v);      %if graph stays connected without node
                mtx(u,v) = 0;
                remainder = remainder - 1;
                break
            else                            %keep searching
                neib = [neib new_neib];
            end
        end
      
        index(1) = [];
    else 
        break                               %if no removable edges left    
    end
end

% disp(remainder/total_edges);
mtx = (mtx + mtx');