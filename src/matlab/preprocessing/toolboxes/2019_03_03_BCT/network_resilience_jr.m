function [R_targ,R_rnd,E_norm,E_norm_rnd,E_comp,C_comp,R_comp,R_comp_size] = network_resilience_jr(CIJ)



% adapted from Petra V�rtes' code by UBraun CIMH 2014


nnodes=length(CIJ);          % number of nodes
[deg] = degrees_und(CIJ);    % degree of nodes

ind_deg=sortrows([deg',(1:nnodes)'],1);  % JR: vector ind_deg: first column=degree; second column=index
ind_deg=flipud(ind_deg);    % nodes sorted by degree
rp = randperm(nnodes);      % random order for random attack

for i=1:size(CIJ,1); % changed by JR: 100 to size(CIJ,1)
    CIJ_new=CIJ;
    nn_rem=round((i/size(CIJ,1))*nnodes); %node to remove in every step % changed by JR: 100 to size(CIJ,1)
    % start targeted attack
    nodes_rem=ind_deg(1:nn_rem,2);
    CIJ_new(nodes_rem,:)=[];
    CIJ_new(:,nodes_rem)=[];
    E(i)=efficiency_wei(CIJ_new); % changed by JR: due to weighted network
    
    A=double(CIJ_new>0);
    if ~isempty(A);
        B = jr_largestcomponent(A);
    else
        B = 0;
    end;
    % size of largest component
    C(i)=length(B);
    if ~isempty(A);
        E_effcomp(i)=efficiency_wei(CIJ_new(B,B));
    else
        E_effcomp(i)=0;
    end;
    clear B;
    

        % start random attack
    CIJ_new=CIJ;
    nodes_rem_rand=rp(1:nn_rem);
    CIJ_new(nodes_rem_rand,:)=[];
    CIJ_new(:,nodes_rem_rand)=[];
    E_rand(i)=efficiency_wei(CIJ_new); % changed by JR due to weighted network
end;


E_comp=E_effcomp./max(E);
targ_lim=find(isnan(E_comp));
lim=targ_lim(1)-1;
R_comp=trapz(E_comp(1:lim));

C_comp=C./size(CIJ,1);
R_comp_size=trapz(C(1:size(CIJ,1)));


E_norm=E./max(E);
E_norm_rnd=E_rand/max(E);
clear targ_lim
% targ_lim=find(E_norm==0); %find(isnan(E_norm))
% if targ_lim==[]
    targ_lim=find(isnan(E_norm_rnd));
% end
lim=targ_lim(1)-1;
R_targ = trapz(E_norm(1:lim));
clear rnd_lim
% rnd_lim=find(E_norm_rnd==0); %isnan(E_norm_rnd)
% if rnd_lim==[]
    rnd_lim=find(isnan(E_norm_rnd));
% end
lim_rnd=rnd_lim(1)-1;
R_rnd = trapz(E_norm_rnd(1:lim_rnd));
