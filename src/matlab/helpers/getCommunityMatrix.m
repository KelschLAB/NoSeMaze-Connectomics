function C = getCommunityMatrix(cs)
% 
% call:
% 
%      C = getCommunityMatrix(cs)
%      
% Given a community affiliation vector cs (obtained from some modularity or 
% community-detection code in the Brain Connectivity Toolbox [1], for example),
% of size 1-by-N, the code returns a N-by-N matrix where pairs of nodes 
% belonging to the same community are given the same number. Remember that 
% the actual number assigned to each community is arbitrary, and that each 
% node (and also each pair of nodes) can be assigned to only one community,
% i.e. the communities are non-overlapping. Diagonal elements are set to 0.
% 
% NOTE: in order to visualize the matrix, one may want first to convert the
%       zeros in NaNs, using C(C==0) = nan, and then pcolor(C)
%
% 
% INPUT
% 
%      cs   :   community affiliation vector <1 x N>
%      
% OUTPUT
% 
%      C    :   Community Matrix <N x N>
%      
%      
%
% References:
%
% [1] Brain Connectivity Toolbox: https://sites.google.com/site/bctnet/ 
% 
%
% R. G. Bettinardi
% ------------------------------------------------------------------------




N = length(cs);
C = zeros(N);

for i = 1:N
    for j = 1:N
        
        if cs(i) == cs(j), C(i,j) = cs(i); end
         
    end
end

C(1:N+1:end)=0;