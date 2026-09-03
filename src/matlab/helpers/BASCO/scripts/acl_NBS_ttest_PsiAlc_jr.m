function acl_NBS_ttest_PsiAlc_jr(cormat,Patlas,gr,names,GroupLabel,outputdir,outputname,input_type,thres,exchange_vector)

Gx=gr
S=cat(3,cormat{:});
type=input_type
contrast='[0,1]'

%% Cog.txt (coordinates)
if exist([outputdir filesep 'Atlas_parameter.mat'],'file') == 2
    load([outputdir filesep 'Atlas_parameter.mat']);
else
    [C, Cmm,  D] = acl_calculate_center(Patlas);
    save([outputdir filesep 'Atlas_parameter.mat'],'C','Cmm','D');
end

mkdir(fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type))))
csvwrite(fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),'COG.txt'),Cmm(1:size(S,1),:));

%% Connectivity matrices
clear Mat
Mat=S;
save(fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('MatRS_Corr_zFisher.mat')),'Mat')

%% GLM (design matrix)
GLM=zeros(size(Mat,3),length(GroupLabel));
GLM(:,1)=1;
unique_gr=unique(gr);

for ix = 1:(length(GroupLabel)-1)
    GLM(contains(gr,unique_gr(ix)),ix+1)=1;
    GLM(contains(gr,unique_gr(ix+1)),ix+1)=-1;
end;

csvwrite(fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('GLM.txt')),GLM)

csvwrite(fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('ExchangeBlock.txt')),exchange_vector)

%% Threshold definition
pT=thres
pF=thres
thr_F = finv(pF,2-1,size(GLM,1)-2);%thr_size-2);%
thr_t = tinv(pT,size(GLM,1)-2);%thr_size-2);%

%% load UI.mat
load /home/jonathan.reinwald/DATKO/analyses/functional_analyses/NBS/UI.mat

UI.matrices.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('MatRS_Corr_zFisher.mat'));
UI.design.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('GLM.txt'));
UI.node_coor.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),'COG.txt');
UI.contrast.ui=contrast;
UI.exchange.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('ExchangeBlock.txt'));

for r1=1:size(Mat,1)
    for r2=1:size(Mat,2)
        X1=(squeeze(Mat(r1,r2,find(GLM(:,2)==1))));
        X2=(squeeze(Mat(r1,r2,find(GLM(:,2)==-1))));
        [H,p(r1,r2),CI,STATS] =ttest2(X1,X2);
        tstat(r1,r2)=STATS.tstat;
    end;
end;

resNBS=acl_NBS_intercept(UI,tstat,thr_t,thr_F,type);%-tstat.*(p<.05)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot for T-test:

T = resNBS.stat;
resNBS.T=T;

clear stats
stats.stat=T;
stats.fdr=resNBS.T_R1+resNBS.T_R1'+resNBS.T_R2+resNBS.T_R2';
stats.type='t-stat';
stats.maxS=5;

fsz=5;

close all;
figure(2);
%     subplot(2,1,1);
acl_mk_plot(stats,names,fsz,'jet');
tt=title(['T-Test ' name_comparison{kx}]);
tt.Interpreter='none';

thres_num = num2str(thres);

if ~isempty(covariate);
    print('-dpsc',fullfile(outputdir,['NBS_T-Test_' name_comparison{kx} '_' num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
else
    print('-dpsc',fullfile(outputdir,['NBS_T-Test_' name_comparison{kx} '_' num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
end

figure(4);
%     subplot(2,1,2);
schemaball(repmat(names,1,1),stats.stat.*stats.fdr, 10,[0 30]);
tt=title(['T-Test ' name_comparison{kx}],'fontsize',10);
tt.Interpreter='none';

if ~isempty(covariate);
    print('-dpsc',fullfile(outputdir,['NBS_T-Test_' name_comparison{kx} '_' num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
else
    print('-dpsc',fullfile(outputdir,['NBS_T-Test_' name_comparison{kx} '_' num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot for F-test:
clear stats
stats.stat=F;
stats.fdr=resNBS.F_R+resNBS.F_R';
stats.type='F-stat';
stats.maxS=15;
resNBS.F=F;

fsz=5;

figure(3);
%     subplot(2,1,1);
acl_mk_plot(stats,names,fsz,'jet');
title(['F-Test DAT +/+, DAT +/-, DAT -/-']);

if ~isempty(covariate);
    print('-dpsc',fullfile(outputdir,['NBS_F-Test_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
    save([outputdir filesep 'resNBS_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.mat'],'resNBS','names');
    
else
    print('-dpsc',fullfile(outputdir,['NBS_F-Test_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
    save([outputdir filesep 'resNBS_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.mat'],'resNBS','names');
end

figure(4);
%     subplot(2,1,2);
schemaball(repmat(names,1,1),stats.stat.*stats.fdr, 10,[0 30]);
title(['F-Test DAT +/+, DAT +/-, DAT -/-'],'fontsize',10);

if ~isempty(covariate);
    print('-dpsc',fullfile(outputdir,['NBS_F-Test_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
    save([outputdir filesep 'resNBS_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.mat'],'resNBS','names');
    
else
    print('-dpsc',fullfile(outputdir,['NBS_F-Test_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
    save([outputdir filesep 'resNBS_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.mat'],'resNBS','names');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot for F-test:
clear stats
stats.stat=T;
stats.fdr=resNBS.F_R+resNBS.F_R';
stats.type='t-stat';
stats.maxS=5;
resNBS.F=T;

fsz=10;

figure(5);
%     subplot(2,1,1);
acl_mk_plot(stats,names,fsz,'jet');
title(['F-Test DAT +/+, DAT +/-, DAT -/-']);

if ~isempty(covariate);
    print('-dpsc',fullfile(outputdir,['NBS_FonT-Test_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
    save([outputdir filesep 'resNBS_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.mat'],'resNBS','names');
    
else
    print('-dpsc',fullfile(outputdir,['NBS_FonT-Test_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
    save([outputdir filesep 'resNBS_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.mat'],'resNBS','names');
end
close all;

