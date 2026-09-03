function [resNBS]=acl_NBS_ANOVA_Ftest_Interaction_PsiAlc_jr(cormat,Patlas,names,gr1,GroupLabel1,outputdir,outputname,input_type,thres)

% Gx=gr
S=cat(3,cormat{:});
type=input_type
contrast={'[0,1]' '[0,-1]'};

contrast_names={'InteractionPos','InteractionNeg'};

%% Cog.txt (coordinates)
if exist([outputdir filesep 'Atlas_parameter.mat'],'file') == 2
    load([outputdir filesep 'Atlas_parameter.mat']);
else
    [C, Cmm,  D] = acl_calculate_center(Patlas);
    save([outputdir filesep 'Atlas_parameter.mat'],'C','Cmm','D');
end

mkdir(fullfile(outputdir,char(strcat(outputname,'_GroupComparisonInteraction_',input_type))))
csvwrite(fullfile(outputdir,char(strcat(outputname,'_GroupComparisonInteraction_',input_type)),'COG.txt'),Cmm(1:size(S,1),:));

%% Connectivity matrices
clear Mat
Mat=S;
save(fullfile(outputdir,char(strcat(outputname,'_GroupComparisonInteraction_',input_type)),strcat('MatRS_Corr_zFisher.mat')),'Mat')

%% GLM (design matrix)
GLM=zeros(size(Mat,3),2);
GLM(:,1)=1;
unique_gr1=unique(gr1);

GLM(contains(gr1,unique_gr1(1)),2)=1;
GLM(contains(gr1,unique_gr1(2)),2)=-1;

csvwrite(fullfile(outputdir,char(strcat(outputname,'_GroupComparisonInteraction_',input_type)),strcat('GLM.txt')),GLM)

%% Threshold definition
pT=thres
pF=thres
thr_F = finv(pF,2-1,size(GLM,1)-1);%thr_size-2);%
thr_t = tinv(pT,size(GLM,1)-1);%thr_size-2);%

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
    UI.matrices.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparisonInteraction_',input_type)),strcat('MatRS_Corr_zFisher.mat'));
    UI.design.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparisonInteraction_',input_type)),strcat('GLM.txt'));
    UI.node_coor.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparisonInteraction_',input_type)),'COG.txt');
    UI.contrast.ui=contrast{ix};
    UI.exchange.ui=fullfile(outputdir,char(strcat(outputname,'_GroupComparisonInteraction_',input_type)),strcat('ExchangeBlock.txt'));
    
    
    resNBS{ix}=acl_NBS_intercept_Ftest(UI,Fmat{1},thr_t,thr_F,type,contrast{ix});%-tstat.*(p<.05)
end


