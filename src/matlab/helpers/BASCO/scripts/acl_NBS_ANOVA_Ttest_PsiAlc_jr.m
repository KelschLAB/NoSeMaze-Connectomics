function [resNBS]=acl_NBS_ANOVA_Ttest_PsiAlc_jr(cormat,Patlas,names,gr1,GroupLabel1,gr2,GroupLabel2,subjects,outputdir,outputname,input_type,thres,exchange_vector)

% Gx=gr
S=cat(3,cormat{:});
type=input_type
% contrast={'[0,1]' '[0,-1]'};
% contrast={'[0,1,0,0]' '[0,-1,0,0]' '[0,0,1,0]' '[0,0,-1,0]' '[0,0,0,1]' '[0,0,0,-1]'};
contrast={'[0,1]' '[0,-1]'};
% contrast={'[0,1,-1,0,0]' '[0,0,0,1,-1]' '[0,1,-1,-1,1]'};
% contrast={'[1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]','[-1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]','[0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]','[0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]','[0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]','[0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]'};

% contrast={'[0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]'};
contrast_names={'Drug'};

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
% % % GLM=zeros(size(Mat,3),length(GroupLabel1)*length(GroupLabel2)+1);
% % % GLM(:,1)=1;
% % % unique_gr1=unique(gr1);
% % % unique_gr2=unique(gr2);
% % % 
% % % GLM_counter = 1;
% % % for jx = 1:length(GroupLabel1)
% % %     GLM(contains(gr1,unique_gr1(jx)),GLM_counter+1)=1;
% % %     GLM_counter = GLM_counter+1;
% % % end
% % % 
% % % for ix = 1:length(GroupLabel2)
% % %     GLM(contains(gr2,unique_gr2(ix)),GLM_counter+1)=1;
% % %     GLM_counter = GLM_counter+1;
% % % end

%%GLM after https://www.nitrc.org/forum/forum.php?thread_id=8346&forum_id=3444
% unique_gr1=unique(gr1);
% unique_gr2=unique(gr2);
% % 
% % 
% GLM=zeros(size(Mat,3),size(Mat,3)/2+3);
% GLM(contains(gr1,unique_gr1(1)),1)=1; % Psi
% GLM(contains(gr2,unique_gr2(1)),2)=1; % Subgroup ALC
% GLM(:,3)=GLM(:,1).*GLM(:,2);
% subj_uni = unique(subjects);
% for ix=1:length(subj_uni)
%     GLM(find(subjects==subj_uni(ix)),ix+3)=1;
% end

% 
GLM=zeros(size(Mat,3),2);
GLM(:,1)=1;
unique_gr1=unique(gr1);


GLM(contains(gr1,unique_gr1(1)),2)=1;
GLM(contains(gr1,unique_gr1(2)),2)=-1;

% GLM(:,4)=GLM(:,2).*GLM(:,3);

% GLM=zeros(size(Mat,3),2);
% GLM(:,1)=1;
% unique_gr1=unique(gr1);
% unique_gr2=unique(gr2);
% 
% GLM(contains(gr1,unique_gr1(1)),2)=1;
% GLM(contains(gr1,unique_gr1(2)),2)=-1;




% GLM=zeros(size(Mat,3),5);
% % GLM(:,1)=1;
% unique_gr1=unique(gr1);
% unique_gr2=unique(gr2);
% 
% GLM(:,1)=1;
% GLM(contains(gr1,unique_gr1(1)),2)=1;
% GLM(contains(gr1,unique_gr1(2)),3)=1;
% GLM(contains(gr2,unique_gr2(1)),4)=1;
% GLM(contains(gr2,unique_gr2(2)),5)=1;

csvwrite(fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('GLM.txt')),GLM)

csvwrite(fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('ExchangeBlock.txt')),exchange_vector)

%% Threshold definition
pT=thres
pF=thres
thr_F = finv(pF,3-2,size(GLM,1)/2-2);%thr_size-2);%
thr_t = tinv(pT,size(GLM,1)-2);%thr_size-2);%

%% load UI.mat
load /home/jonathan.reinwald/DATKO/analyses/functional_analyses/NBS/UI.mat



for r1=1:size(Mat,1)
    for r2=1:size(Mat,2)
        X1=(squeeze(Mat(r1,r2,find(GLM(:,2)==1))));
        X2=(squeeze(Mat(r1,r2,find(GLM(:,2)==-1))));
        [H,p(r1,r2),CI,STATS] =ttest2(X1,X2);
        tstat(r1,r2)=STATS.tstat;
    end
end

%% meas
if 1==0
for dg = 1:length(GroupLabel1)
    %% clearing
    clear subgr_all input_subgr subj_ID subj_ID_sel
    
    %% subject_IDs
    % subject ID vector
    subj_ID = subjects;
    % selection of subject IDs for current drug selection
    subj_ID_sel = subj_ID(contains(gr1,GroupLabel1{dg}));
    % sorting of subject IDs of selected measurements
    [subj_ID_sel_sorted,Idx_subj_ID_sel]=sort(subj_ID_sel,'ascend');
    
    %% input vector for subgr
    subgr_all = gr2;
    input_subgr = subgr_all(contains(gr1,GroupLabel1{dg}));
    
    %% sorting of input vector based on subject IDs
    subgroup = input_subgr(Idx_subj_ID_sel)';
    
    % Loop over first dimension from cormat
    for r1 = 1:size(Mat,1)
        % Loop over second dimension from cormat
        for r2 = 1:size(Mat,2)
            % clearing
            clear input_meas_temp
            % vector of interest
            input_meas_temp = squeeze(Mat(r1,r2,contains(gr1,GroupLabel1{dg})));
            % sorting
            input_meas_temp = input_meas_temp(Idx_subj_ID_sel);
            % put sorted input_meas_temp into input_meas
            meas{r1,r2}(:,dg)=input_meas_temp;
            %
            Meas = table([1 2]','VariableNames',{'Drug'});
        end
    end
end

%% 2. RM-ANOVA
% Loop over first dimension from cormat
for r1 = 1:size(Mat,1)
    % Loop over second dimension from cormat
    for r2 = 1:size(Mat,2)
        % clearing
        clear t rm ranovatbl
        % table
        t = table(subgroup,meas{r1,r2}(:,1),meas{r1,r2}(:,2),...
            'VariableNames',{'subgroup',GroupLabel1{1},GroupLabel1{2}});
        % Fit a repeated measures model, where the measurements (Psi and Sal) are the responses and the subgroup is the predictor variable.
        rm = fitrm(t,'Psi,Sal~subgroup','WithinDesign',Meas);
        % Perform repeated measures analysis of variance.
        ranovatbl = ranova(rm);
        % Create F- and p-value matrices for drug (within-factor) and
        % interaction (subgrou by drug)
        if r1==r2
            Fmat{1}(r1,r2)=NaN;
            pmat{1}(r1,r2)=NaN;
            Fmat{3}(r1,r2)=NaN;
            pmat{3}(r1,r2)=NaN;
        else
            Fmat{1}(r1,r2)=table2array(ranovatbl(1,4));
            pmat{1}(r1,r2)=table2array(ranovatbl(1,5));
            %
            Fmat{3}(r1,r2)=table2array(ranovatbl(2,4));
            pmat{3}(r1,r2)=table2array(ranovatbl(2,5));
        end
        
        % Between design
        anovatbl = anova(rm);
        if r1==r2
            Fmat{2}(r1,r2)=NaN;
            pmat{2}(r1,r2)=NaN;
        else
            Fmat{2}(r1,r2)=table2array(anovatbl(2,6));
            pmat{2}(r1,r2)=table2array(anovatbl(2,7));
        end
    end
end
end

Fmat{1}=tstat; Fmat{2}=tstat; Fmat{3}=tstat; 


for ix=1:length(contrast)
    UI.matrices.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('MatRS_Corr_zFisher.mat'));
    UI.design.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('GLM.txt'));
    UI.node_coor.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),'COG.txt');
    UI.contrast.ui=contrast{ix};
    UI.exchange.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type)),strcat('ExchangeBlock.txt'));
    
    
    resNBS{ix}=acl_NBS_intercept_Ttest(UI,Fmat{1},thr_t,thr_F,type,contrast{ix});%-tstat.*(p<.05)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% plot for T-test:

% T = resNBS.stat;
% resNBS.T=T;
% 
% clear stats
% stats.stat=T;
% stats.fdr=resNBS.T_R1+resNBS.T_R1'+resNBS.T_R2+resNBS.T_R2';
% stats.type='t-stat';
% stats.maxS=5;
% 
% fsz=5;
% 
% close all;
% figure(1);
% %     subplot(2,1,1);
% acl_mk_plot(stats,names,fsz,'jet');
% tt=title(['T-Test ' name_comparison{kx}]);
% tt.Interpreter='none';
% 
% thres_num = num2str(thres);
% 
% if ~isempty(covariate);
%     print('-dpsc',fullfile(outputdir,['NBS_T-Test_' name_comparison{kx} '_' num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
% else
%     print('-dpsc',fullfile(outputdir,['NBS_T-Test_' name_comparison{kx} '_' num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
% end
% 
% figure(2);
% %     subplot(2,1,2);
% schemaball(repmat(names,1,1),stats.stat.*stats.fdr, 10,[0 30]);
% tt=title(['T-Test ' name_comparison{kx}],'fontsize',10);
% tt.Interpreter='none';
% 
% if ~isempty(covariate);
%     print('-dpsc',fullfile(outputdir,['NBS_T-Test_' name_comparison{kx} '_' num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
% else
%     print('-dpsc',fullfile(outputdir,['NBS_T-Test_' name_comparison{kx} '_' num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% plot for F-test:
% clear stats
% stats.stat=F;
% stats.fdr=resNBS.F_R+resNBS.F_R';
% stats.type='F-stat';
% stats.maxS=15;
% resNBS.F=F;
% 
% fsz=5;
% 
% figure(3);
% %     subplot(2,1,1);
% acl_mk_plot(stats,names,fsz,'jet');
% title(['F-Test DAT +/+, DAT +/-, DAT -/-']);
% 
% if ~isempty(covariate);
%     print('-dpsc',fullfile(outputdir,['NBS_F-Test_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
%     save([outputdir filesep 'resNBS_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.mat'],'resNBS','names');
%     
% else
%     print('-dpsc',fullfile(outputdir,['NBS_F-Test_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
%     save([outputdir filesep 'resNBS_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.mat'],'resNBS','names');
% end
% 
% figure(4);
% %     subplot(2,1,2);
% schemaball(repmat(names,1,1),stats.stat.*stats.fdr, 10,[0 30]);
% title(['F-Test DAT +/+, DAT +/-, DAT -/-'],'fontsize',10);
% 
% if ~isempty(covariate);
%     print('-dpsc',fullfile(outputdir,['NBS_F-Test_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
%     save([outputdir filesep 'resNBS_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.mat'],'resNBS','names');
%     
% else
%     print('-dpsc',fullfile(outputdir,['NBS_F-Test_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
%     save([outputdir filesep 'resNBS_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.mat'],'resNBS','names');
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% plot for F-test:
% clear stats
% stats.stat=T;
% stats.fdr=resNBS.F_R+resNBS.F_R';
% stats.type='t-stat';
% stats.maxS=5;
% resNBS.F=T;
% 
% fsz=10;
% 
% figure(5);
% %     subplot(2,1,1);
% acl_mk_plot(stats,names,fsz,'jet');
% title(['F-Test DAT +/+, DAT +/-, DAT -/-']);
% 
% if ~isempty(covariate);
%     print('-dpsc',fullfile(outputdir,['NBS_FonT-Test_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
%     save([outputdir filesep 'resNBS_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_1___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.mat'],'resNBS','names');
%     
% else
%     print('-dpsc',fullfile(outputdir,['NBS_FonT-Test_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.ps']),'-r400','-append','-bestfit');
%     save([outputdir filesep 'resNBS_' name_comparison{kx} '_'  num2str(batch_number_sel) '___Covariate_0___ExcludeIso_' num2str(without_iso) '___' date '_thresh_' thres_num(3:4) '.mat'],'resNBS','names');
% end
% close all;

