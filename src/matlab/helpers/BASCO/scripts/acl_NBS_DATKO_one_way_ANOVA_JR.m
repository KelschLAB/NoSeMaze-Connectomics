function acl_NBS_DATKO_one_way_ANOVA_JR(cormat,Patlas,gr,names,GroupLabel,outputdir,outputname,input_type,thres,contrast)

Gx=gr
S=cat(3,cormat{:});
type=input_type

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
Mat=S(:,:,find(gr>0));
gr=gr(find(gr>0));
save(fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('MatRS_Corr_zFisher.mat')),'Mat')

%% GLM (design matrix)
GLM=zeros(size(Mat,3),length(GroupLabel));
GLM(:,1)=1;
unique_gr=unique(gr);

for ix = 1:(length(GroupLabel)-1)
    GLM(find(gr==unique_gr(ix)),ix+1)=1;
    GLM(find(gr==unique_gr(ix+1)),ix+1)=-1;
end;

csvwrite(fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('GLM.txt')),GLM)

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

%% ANOVA

% Grouping with GroupLabels
gr_new=cell(length(gr),1);
for ix = 1:length(GroupLabel)
     gr_new(gr==unique_gr(ix)) = GroupLabel(ix);
end

for r1=1:size(Mat,1);
    for r2=1:size(Mat,2);
        yy=(squeeze(Mat(r1,r2,:)));
%         [Tt(r1,r2),pt(r1,r2)]=ttest2(yy(strcmp(gr_new,GroupLabel(1))),yy(strcmp(gr_new,GroupLabel(2))));
        [p(r1,r2),tbl{r1,r2},stats{r1,r2}] = anova1(yy,gr_new,'off');
        % F-Values
        F(r1,r2)=tbl{r1,r2}{2,5};
        [comparison{r1,r2},means{r1,r2},h{r1,r2},gnames{r1,r2}] = multcompare(stats{r1,r2},'ctype','bonferroni','Display','off');
    end;
end;

% resNBS=acl_NBS_intercept_DATKO_jr(UI,F,thr_t,thr_F,type);%-tstat.*(p<.05)
resNBS=acl_NBS_intercept(UI,F,thr_t,thr_F,type);


% clear stats
% stats.stat=F;
% stats.fdr=resNBS.F_R+resNBS.F_R';
% stats.type='F-stat';
% stats.maxS=15;

clear stats
stats.stat=resNBS.stat;
stats.fdr=resNBS.T_R1+resNBS.T_R1'+resNBS.T_R2+resNBS.T_R2';
stats.type='t-stat';
stats.maxS=5;


clear stats
stats.stat=F;
stats.fdr=resNBS.F_R+resNBS.F_R';
stats.type='F-stat';
stats.maxS=15;

fsz=5;

f21=figure('Visible','on');
f21.Position=get(0,'ScreenSize');
f21.PaperUnits='normalized';
f21.PaperPosition=[0 0 1 1];
f21.PaperOrientation='landscape';

f22=figure('Visible','on');
f22.Position=get(0,'ScreenSize');
f22.PaperUnits='normalized';
f22.PaperPosition=[0 0 1 1];
f22.PaperOrientation='landscape';

set(0,'CurrentFigure',f21);subplot(1,1,1);acl_mk_plot(stats,names,fsz,'jet');title(['T-Test']);

set(0,'CurrentFigure',f22);schemaball(repmat(names,1,1),stats.stat.*stats.fdr, 10,[0 30]);title(['T-Test'],'fontsize',10);

saveas(f21,[fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type))) '/' ['F-Test']],'tif');
saveas(f22,[fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type))) '/' ['F-Test'] '_schemaball'],'tif');

close all;
