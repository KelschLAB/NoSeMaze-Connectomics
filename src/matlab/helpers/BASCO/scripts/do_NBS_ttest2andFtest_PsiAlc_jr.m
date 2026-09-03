%% do_NBS_ttest2andFtest_PsiAlc_jr.m

%% Path definition and loading of cormat, names and pathlist
clear all
addpath(genpath('/data2/jonathan/PsiAlc/scripts/analyses/NBS'));

% path of cormat-/names-files
cormat_path='/data2/jonathan/PsiAlc/analyses/functional_analyses/cormat/sigma_bilateral/'
% load cormat- and names-files
load([cormat_path filesep 'cormat_diff.mat']);
load([cormat_path filesep 'names_57.mat']);

% load pathlist
if 1==1
    load('/data2/jonathan/PsiAlc/data/pathlist_PsiAlc.mat');
end

% define atlas
Patlas='/data2/jonathan/DATKO/helpers/atlas_creation/unilateral_atlas/SIGMA_atlas_JR_unilateral.nii';

% define output directory
outputdir=fullfile(cormat_path,'results','NBS');
mkdir(outputdir);

% selection=[1:41];
%Fronto-Parietal: OF, PL, Cing1, Cing2, Ent, Ect, Peri, ParA, TempA, V1, V2, Aud1, Aud2
% selection=[5:6,29:34,37:41];
selection=[5     8    19    22    24    26    27    28    29    30    31    32    33    35    36];
%         sub_sel1=[[4:8,33:42,44:48]%,[4:8,33:42,44:48]+55];
%         sub_sel2=[4:7,29:34,37:41];
%         sub_sel2=sub_sel1;
%         sub_name='DMN';% (OF,PL,Cing1/2,ParA,TempA,V1,V2,Aud1,Aud2,CA1-3,Sub,DG';
% selection=[1:57];
names=names(selection);
for ix=1:length(cormat_diff);
    cormat_diff{ix}=cormat_diff{ix}(selection,selection);
end

cormat_diff = cormat_diff(contains([gr_cormat_diff(:).subgroup],'Alc'));
gr_cormat_diff = gr_cormat_diff(contains([gr_cormat_diff(:).subgroup],'Alc'));

%% Predefinition of NBS parameters and input
outputname='T-TestAndF-Test'
input_type={'Extent'}
thres=.95

% Cormat in 3D
cormat_3D=cat(3,cormat_diff{:});

% Group vector
subgroup = [gr_cormat_diff(:).subgroup];
subgroup_names = unique(subgroup);
drug = [gr_cormat_diff(:).drug];
drug_names = unique(drug);

% subjects for exchange block
subjects = [gr_cormat_diff(:).subject];
subjects_names = unique(subjects);
counter=1;
exchange_vector=zeros(1,length(subjects));
for ix = 1:length(subjects_names)
    find_indx = find(subjects==subjects_names(ix));
    exchange_vector(1,find_indx) = counter;
    counter=counter+1;
end




%% Plotting of mean_matrices
if 1==0
    f99=figure('Visible','on');
    f99.Position=get(0,'ScreenSize');
    f99.PaperUnits='normalized';
    f99.PaperPosition=[0 0 1 1];
    f99.PaperOrientation='landscape';
    for jx=1:length(group_names)
        subplot(2,3,jx);
        imagesc(squeeze(mean(squeeze(Mat_corr(:,:,group==jx)),3)));
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

%% NBS
acl_NBS_ttest_PsiAlc_jr(cormat_diff,Patlas,drug,names,drug_names,outputdir,outputname,input_type,thres,exchange_vector')


