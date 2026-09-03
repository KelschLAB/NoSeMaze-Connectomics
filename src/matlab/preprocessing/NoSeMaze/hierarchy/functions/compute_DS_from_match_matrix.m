function DS_data = compute_DS_from_match_matrix(match_matrix)
% COMPUTE_DS_FROM_MATCH_MATRIX Compute David's score.

n = size(match_matrix,1);
interactionMatrix = match_matrix + match_matrix';

P = nan(n);
hasInteraction = interactionMatrix>0;
P(hasInteraction) = match_matrix(hasInteraction)./interactionMatrix(hasInteraction);
P(1:n+1:end) = NaN;

W = sum(P,2,'omitnan')';
L = sum(P,1,'omitnan');

W2 = nan(n,n);
L2 = nan(n,n);

for i = 1:n
    W2(i,:) = P(i,:).*W;
    L2(i,:) = P(:,i)'.*L;
end

w2 = sum(W2,2,'omitnan')';
l2 = sum(L2,2,'omitnan')';

DS = W+w2-L-l2;
[DSv,DSi] = sort(DS,'descend');

DS_data.DS = DS;
DS_data.DS_sorted = DSv;
DS_data.DS_sortedIndex = DSi;
DS_data.match_matrix = match_matrix;
end
