function [modp,q_max,Nmodu,q_all,affil_all,Nmodu_all]=rb_modp_best(cormat,N,Nmax,n,nmod)

% Historical modularity helper retained for provenance.
% It is NOT used by the streamlined manuscript graph pipeline.

for jmat=1:size(cormat,2)
    jtrial=1;
    jparti=1;

    while jtrial<=Nmax && jparti<=N
        jtrial=jtrial+1;
        [A,Q]=community_louvain(cormat{jmat});
        modnumber=max(A);

        if modnumber>=nmod
            affil(jparti,:)=A; %#ok<AGROW>
            q(jparti)=Q; %#ok<AGROW>
            jparti=jparti+1;
        end
    end

    [q_sort,qs_ind]=sort(q,'descend');
    affil_best=affil(qs_ind(1:n),:);

    for j=1:size(affil_best,2)
        for k=1:j
            for l=1:n
                comp(l)=isequal(affil_best(l,j),affil_best(l,k)); %#ok<AGROW>
            end
            cd=double(comp);

            modp1(j,k)=sum(cd)/n; %#ok<AGROW>
            modp1(k,j)=sum(cd)/n;
        end
    end

    Nmodu{jmat}=max(affil_best,[],2); %#ok<AGROW>
    q_max{jmat}=mean(q_sort(1:n)); %#ok<AGROW>
    modp{jmat}=modp1; %#ok<AGROW>
    affil_all{jmat}=affil; %#ok<AGROW>
    q_all{jmat}=q; %#ok<AGROW>
    Nmodu_all{jmat}=max(affil'); %#ok<AGROW>
end
end
