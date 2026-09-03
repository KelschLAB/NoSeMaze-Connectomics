function auc_struc=rb_gstruc_2_auc(gstruc,thr_minind,thr_maxind)

% calculate aereas under the curve for graph metrics over a range of
% thresholds

[x y]=size(gstruc);

if (x==1)&&(y==1)
    disp('Old version of gstruc. Use rb_gstruc_old2new.m to get a clean useful version of your gstruc !')
    gstruc_n=rb_gstruc_old2new(gstruc);
else
    gstruc_n=gstruc;
end

[Nthr,Nsub]=size(gstruc_n);

fn=fieldnames(gstruc_n);
Nfn=length(fn);

for jfn=1:Nfn
    fn_cur=fn{jfn};

    if strcmp(fn_cur(1:2),'g_') || strcmp(fn_cur(1:2),'l_')
        for jsub=1:Nsub
            grmat=[gstruc_n(thr_minind:thr_maxind,jsub).(fn_cur)];
            auc_cur=mean(grmat,2);
            auc_struc(jsub).(fn_cur)=auc_cur;
            auc_struc(jsub).o_thr_range=[gstruc_n(thr_minind:thr_maxind,jsub).o_cutoffs];
        end
    end
end
