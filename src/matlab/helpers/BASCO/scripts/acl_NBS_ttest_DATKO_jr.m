function acl_NBS_ttest_DATKO_jr(cormat,Patlas,gr,names,GroupLabel,outputdir,outputname,input_type,thres,batch_number_sel,covariate,without_iso)

Gx=gr
S=cat(3,cormat{:});
type=input_type
contrast_pre='[0,1]'

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
UI.contrast.ui=contrast_pre;


GroupSelection{1}=[1,3];
GroupSelection{2}=[1,2];
GroupSelection{3}=[2,3];

name_comparison{1}='WT_vs_DAT-KO';
name_comparison{2}='WT_vs_DAT-HET';
name_comparison{3}='DAT-HET_vs_DAT-KO';

contrast{1}={'[0 1 1]' '[0 -1 -1]' '[0 1 1]'};
contrast{2}={'[0 1 0]' '[0 -1 0]' '[0 1 1]'};
contrast{3}={'[0 0 1]' '[0 0 -1]' '[0 1 1]'};

for kx=1:length(GroupLabel)
    clear h_tt p_tt ci_tt tstat_tt p tbl stats comparison means gnames resNBS T F
    
    %% ANOVA
    % Grouping with GroupLabels
    gr_new=cell(length(gr),1);
    for ix = 1:length(GroupLabel)
        gr_new(gr==unique_gr(ix)) = GroupLabel(ix);
    end
    
    for r1=1:size(Mat,1);
        for r2=1:size(Mat,2);
            yy=(squeeze(Mat(r1,r2,:)));
            [h_tt(r1,r2),p_tt(r1,r2),ci_tt{r1,r2},tstat_tt{r1,r2}]=ttest2(yy(strcmp(gr_new,GroupLabel(GroupSelection{kx}(1)))),yy(strcmp(gr_new,GroupLabel(GroupSelection{kx}(2)))));
            [p(r1,r2),tbl{r1,r2},stats{r1,r2}] = anova1(yy,gr_new,'off');
            % F-Values
            % CAVE: We shouldn't plot F-values later
            F(r1,r2)=tbl{r1,r2}{2,5};
            [comparison{r1,r2},means{r1,r2},h{r1,r2},gnames{r1,r2}] = multcompare(stats{r1,r2},'ctype','bonferroni','Display','off');
%             clear sel_1 sel_2
%             sel_1 = comparison{r1,r2}(:,1)==GroupSelection{kx}(1);
%             sel_2 = comparison{r1,r2}(:,2)==GroupSelection{kx}(2);
%             F
        end;
    end;
    
    %
    %     resNBS=acl_NBS_intercept(UI,tstat_tt,thr_t,thr_F,type,contrast{kx});
    
    %%%%%
    %% Connectivity matrices
    clear Mat_curr
    Mat_curr=S(:,:,find(gr==GroupSelection{kx}(1)|gr==GroupSelection{kx}(2)));
    gr_curr=gr(find(gr==GroupSelection{kx}(1)|gr==GroupSelection{kx}(2)));
    save(fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('MatRS_Corr_zFisher.mat')),'Mat_curr')
    
    %% GLM (design matrix)
    GLM_curr=zeros(size(Mat_curr,3),length(GroupLabel)-1);
    GLM_curr(:,1)=1;
    unique_gr_curr=unique(gr_curr);
    
    for ix = 1:(length(unique_gr_curr)-1)
        GLM_curr(find(gr_curr==unique_gr_curr(ix)),ix+1)=1;
        GLM_curr(find(gr_curr==unique_gr_curr(ix+1)),ix+1)=-1;
    end;
    
    csvwrite(fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('GLM.txt')),GLM_curr)
    
    %% Threshold definition
    pT=thres
    pF=thres
    thr_F = finv(pF,2-1,size(GLM_curr,1)-2);%thr_size-2);%
    thr_t = tinv(pT,size(GLM_curr,1)-2);%thr_size-2);%
    
    %% load UI.mat
    load /home/jonathan.reinwald/DATKO/analyses/functional_analyses/NBS/UI.mat
    
    UI.matrices.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('MatRS_Corr_zFisher.mat'));
    UI.design.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('GLM.txt'));
    UI.node_coor.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),'COG.txt');
    UI.contrast.ui=contrast_pre;
    
    
    
    resNBS=acl_NBS_intercept_DATKO_jr(UI,tstat_tt,thr_t,thr_F,type);%-tstat.*(p<.05)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% plot for T-test:
    for r1=1:size(Mat,1);
        for r2=1:size(Mat,2);
            T(r1,r2) = resNBS.stat{r1,r2}.tstat;
        end;
    end;
    resNBS.T=T;
    
    clear stats
    stats.stat=T;
    stats.fdr=resNBS.T_R1+resNBS.T_R1'+resNBS.T_R2+resNBS.T_R2';
    stats.type='t-stat';
    stats.maxS=5;
    
    fsz=5;
    
    close all;
    figure(1);
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
    
    figure(2);
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
end
