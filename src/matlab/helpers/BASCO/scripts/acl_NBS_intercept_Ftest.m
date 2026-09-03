function resNBS=acl_NBS_intercept_Ftest(UI,tstat,thres_t,thres_F,type,contrast)

% contrast={'[0 1 0]' '[0 0 1]' '[0 1 1]'};
sizev=type

nbs=[];
h=[];
global nbs
% UI.perms.ui='5000';
% 
% UI.contrast.ui=contrast{1};
% UI.size.ui=sizev{1};
% UI.thresh.ui=num2str(thres_t);
% 
% UI.alpha.ui='.025'; %Bonferroni correction
% 
% NBSrun(UI,h)
% [N_CNT1,CON_MAT1,PVAL1]=NBSstats(nbs.STATS);
% 
% UI.contrast.ui=contrast{2};
% UI.size.ui=sizev{1};
% UI.thresh.ui=num2str(thres_t);
% 
% NBSrun(UI,h)
% [N_CNT2,CON_MAT2,PVAL2]=NBSstats(nbs.STATS);
% 
% R1=zeros(size(tstat,1),size(tstat,2));
% 
% for n=1:N_CNT1
%     R1=R1+CON_MAT1{n};
% end
% 
% R2=zeros(size(tstat,1),size(tstat,2));
% 
% for n=1:N_CNT2
%     R2=R2+CON_MAT2{n};
% end


% resNBS.stat=tstat;

% resNBS.T_R1=R1;
% resNBS.T_R2=R2;
% resNBS.CON_MAT1=CON_MAT1;
% resNBS.CON_MAT2=CON_MAT2;
% resNBS.PVAL1=PVAL1;
% resNBS.PVAL2=PVAL2;

UI.contrast.ui=contrast;
UI.size.ui=sizev{1};
UI.thresh.ui=num2str(thres_F);

UI.perms.ui='5000';

UI.alpha.ui='.05';

UI.test.ui='F-test';

NBSrun(UI,h)
[F_N_CNT,F_CON_MAT,F_PVAL]=NBSstats(nbs.STATS);

R_F=zeros(size(tstat,1),size(tstat,2));
for n=1:F_N_CNT
    R_F=R_F+F_CON_MAT{n};
end

resNBS.F_R=R_F;
resNBS.F_CON_MAT=F_CON_MAT;
resNBS.F_PVAL=F_PVAL;



