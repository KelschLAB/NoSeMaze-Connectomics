%% do_NBS_ttest2andFtest_DATKO_jr.m

%% Path definition and loading of cormat, names and pathlist
clear all
addpath(genpath('/data2/jonathan/DATKO/scripts/NBS'));

% path of cormat-/names-files
cormat_path='/home/jonathan.reinwald/DATKO/analyses/functional_analyses/covmat/SIGMA_atlas_unilateral_ORIGINAL/'
% load cormat- and names-files
load([cormat_path filesep 'cormat.mat']);
load([cormat_path filesep 'names_110_newabrev.mat']);

% load pathlist
load('/home/jonathan.reinwald/DATKO/data/MRI_data/pathlist_DATKO.mat')

% load animalinfo
load('/home/jonathan.reinwald/DATKO/data/MRI_data/animalinfo_DATKO.mat')

% load atlas
Patlas='/home/jonathan.reinwald/DATKO/helpers/atlas/SIGMA_Wistar_Rat_Brain_TemplatesAndAtlases_Version1/SIGMA_Rat_Brain_Atlases/SIGMA_Anatomical_Atlas/SIGMA_Anatomical_Brain_Atlas_Version1_reorient_jr_merged.nii';
% Patlas = '/home/jonathan.reinwald/DATKO/helpers/atlas_creation/Kopie von unilateral_atlas/SIGMA_atlas_JR_unilateral.nii';

outputdir='/data2/jonathan/DATKO/results/NBS/ttest2ANDftest/26regions'
mkdir(outputdir);

% load d_struct:
load('/data2/jonathan/DATKO/data/MRI_data/d_struct/SIGMA_atlas_JR_unilateral_original/d_struct_DATKO.mat');

selection=[4,6,14,15,16,17,42:45,47:48,53,[4,6,14,15,16,17,42:45,47:48,53]+55];
% selection=[1:110];
names=names(selection);
for ix=1:length(cormat);
    cormat{ix}=cormat{ix}(selection,selection);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% selection of batches
batch_names={'Batch 1','Batch 2','Batch 3'};
batch_number_sel=[1,2,3];



% selection of covariate (different isoflurane levels) (yes/no)
% covariate=[];% do not include isoflurane level as covariate
covariate=[d.isoflurane];% include isoflurane level as covariate

% exclusion of isoflurane (yes/no)
without_iso=0;% all sessions
% without_iso=1;% only sessions without isoflurane selected

%% Predefinition of NBS parameters and input
outputname='T-TestAndF-Test'
input_type={'Intensity'}
thres=.95

% Timepoint 1 is selected
% Select first timepoint
tp = ([animal.timepoint]==1)
iso = [animal.isoflurane]
% Genotype Code
% Define genotype_code (1,2,3) for the three genotypes DAT +/+, DAT -/+, DAT -/-:
genotype_all = ([animal.genotype]);
genotype_names = unique([animal.genotype]);
genotype_code = zeros(length(genotype_all),1);
for ix = 1:length(genotype_names);
    genotype_code(contains(genotype_all,genotype_names{ix})) = ix;
end;
Gx = genotype_code.*tp'; 
%% 
if without_iso == 1;
    Gx = genotype_code.*([animal.isoflurane]==.5)'.*tp';
end
% Cormat in 3D
S=cat(3,cormat{:});

%% Reduced Matrix / group vector only consisting of all animals at timepoint 1
% Matrix
Mat=S(:,:,find(Gx==1 | Gx==2 | Gx==3));
% Group Vector
group_cov=Gx(Gx==1|Gx==2|Gx==3);
covar=[animal.isoflurane];
% Covariate
covar=covar(find(Gx==1| Gx==2 | Gx==3));

%% Matrix correction for the differences in isoflurane using mancovan
% addpath(genpath('/home/jonathan.reinwald/Documents/MATLAB/mancovan_496/'))
% The effect of the differences of the isoflurane doses is regressed out of
% the correlation matrix 
if without_iso ~= 1;
    for r1=1:size(Mat,1)
        for r2=1:size(Mat,2)
            if Mat(r1,r2,:)==Mat(r1,r2,1);
                T_mancova{r1,r2}=0; p_mancova{r1,r2}=1; FANCOVAN{r1,r2}=0; pANCOVAN{r1,r2}=[]; stats{r1,r2}.B(1)=NaN;
            else
                [T_mancova{r1,r2}, p_mancova{r1,r2}, FANCOVAN{r1,r2}, pANCOVAN{r1,r2}, stats{r1,r2}] =mancovan(squeeze([Mat(r1,r2,:)]),group_cov,covar');
            end
            tstat_manc(r1,r2)=T_mancova{r1,r2}(1);
            p_manc(r1,r2)=p_mancova{r1,r2}(1);
            if isnan(stats{r1,r2}.B(1));
                Mat_corr(r1,r2,[1:size(Mat,3)])=1;
            else
                Mat_corr(r1,r2,:)=stats{r1,r2}.Y-stats{r1,r2}.B(4)*stats{r1,r2}.X(:,4);
            end
        end
    end
end
% cormat reduced (only animals tp1)
for ix=1:size(Mat,3); 
    if without_iso ~= 1;
        cormat_red_corr{ix} = Mat_corr(:,:,ix);
    end
    cormat_red{ix} = Mat(:,:,ix);
end

%% Plotting of mean_matrices
if 1==0
    f99=figure('Visible','on');
    f99.Position=get(0,'ScreenSize');
    f99.PaperUnits='normalized';
    f99.PaperPosition=[0 0 1 1];
    f99.PaperOrientation='landscape';
    for jx=1:length(genotype_names)
        subplot(2,3,jx);
        imagesc(squeeze(mean(squeeze(Mat_corr(:,:,group_cov==jx)),3)));
        ax=gca;
        ax.CLim=[-1,1];
        ax.Colormap=jet;
        
        ax.XTick=[1:length(names)];
        ax.XTickLabel=names;
        ax.YTick=[1:length(names)];
        ax.YTickLabel=names;
        rotateXLabels(ax,60);
        ax.FontSize=4;
        tt=title([genotype_names{jx} ' corrected for iso']);
        tt.FontSize=10;
        
        subplot(2,3,jx+3);
        imagesc(squeeze(mean(squeeze(Mat(:,:,group_cov==jx)),3)));
        ax=gca;
        ax.CLim=[-1,1];
        ax.Colormap=jet;
        
        ax.XTick=[1:length(names)];
        ax.XTickLabel=names;
        ax.YTick=[1:length(names)];
        ax.YTickLabel=names;
        rotateXLabels(ax,60);
        ax.FontSize=4;
        tt=title([genotype_names{jx}]);
        tt.FontSize=10;
    end
end
% saveas(f99,[fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type))) '/' ['Mean_Matrices']],'tif');

% cormat_red = cormat_red(group_cov~=2 )
% group_cov = group_cov(group_cov~=2)
% genotype_names(2)=[];
%% NBS
if without_iso==1;
    acl_NBS_ttest_DATKO_jr(cormat_red,Patlas,group_cov,names,genotype_names,outputdir,outputname,input_type,thres,batch_number_sel,covariate,without_iso)
elseif without_iso~=1;
    acl_NBS_ttest_DATKO_jr(cormat_red_corr,Patlas,group_cov,names,genotype_names,outputdir,outputname,input_type,thres,batch_number_sel,covariate,without_iso)
end   

