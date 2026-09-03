%% do_NBS_ttest2andFtest_PsiAlc_jr.m

%% Path definition and loading of cormat, names and pathlist
clear all
addpath(genpath('/data2/jonathan/PsiAlc/scripts/analyses/NBS'));

% path of cormat-/names-files
cormat_path='/data2/jonathan/PsiAlc/analyses/functional_analyses/cormat/sigma_bilateral_atlas44_scrubFD05_ReoRes2/'
% load cormat- and names-files
load([cormat_path filesep 'cormat_diff.mat']);
load([cormat_path filesep 'names_44.mat']);

% load pathlist
if 1==1
    load('/data2/jonathan/PsiAlc/data/pathlist_PsiAlc.mat');
end

% define atlas
Patlas='/data2/jonathan/DATKO/helpers/atlas_creation/bilateral_atlas/SIGMA_atlas_JR_bilateral.nii';

% define output directory
outputdir=fullfile(cormat_path,'results','NBS');
mkdir(outputdir);

% selection=[4     6     8     9    10    18    19    21    22    23    24    25    26    27    28    29    30    31 37];
%Fronto-Parietal: OF, PL, Cing1, Cing2, Ent, Ect, Peri, ParA, TempA, V1, V2, Aud1, Aud2
% selection=[3:8,16:35];
%         sub_sel1=[[4:8,33:42,44:48]%,[4:8,33:42,44:48]+55];
%         sub_sel2=[4:7,29:34,37:41];
%         sub_sel2=sub_sel1;
%         sub_name='DMN';% (OF,PL,Cing1/2,ParA,TempA,V1,V2,Aud1,Aud2,CA1-3,Sub,DG';
selection=[1:44];
names=names(selection);
for ix=1:length(cormat_diff);
    cormat_diff{ix}=cormat_diff{ix}(selection,selection);
end

% cormat_diff_cur = cormat_diff(contains([gr_cormat_diff(:).subgroup],'Alc'));
% gr_cormat_diff_cur = gr_cormat_diff(contains([gr_cormat_diff(:).subgroup],'Alc'));

%% Predefinition of NBS parameters and input
outputname='F-Test'
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
% exchange_vector=[];

%% NBS
[resNBS]=acl_NBS_ANOVA_Ftest_PsiAlc_jr(cormat_diff,Patlas,names,drug,drug_names,subgroup,subgroup_names,subjects,outputdir,outputname,input_type,thres,exchange_vector')

%% Matrix Plot
% Sorting for paired t-test
% Psi:
selection_gr1 = find(contains([gr_cormat_diff(:).drug],'Psi'));
% selection_gr1 = find(contains([gr_cormat_diff(:).drug],'Psi'));
[~,Indx_gr1]=sort([gr_cormat_diff(selection_gr1).subject],'ascend');
selection_gr1 = selection_gr1(Indx_gr1);
% Sal:
selection_gr2 = find(contains([gr_cormat_diff(:).drug],'Sal'));
% selection_gr2 = find(contains([gr_cormat_diff(:).drug],'Sal'));
[~,Indx_gr2]=sort([gr_cormat_diff(selection_gr2).subject],'ascend');
selection_gr2 = selection_gr2(Indx_gr2);

% Calculation of paired ttest
[T p p2 fdrmat meanval stdab]=lei_pairedtt(cormat_diff(selection_gr1),cormat_diff(selection_gr2),0.05);

% Close all
close all

% Figure
fig=figure(1);
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.5, 0.96]);
orient(fig,'landscape');
% subplot
subplot(2,1,1);
imagesc(T);
colormap jet;
colorbar;
axis image;
caxis([-5 5]);
set(gca,'TickLabelInterpreter','none','FontSize',6,'XTick',[1:1:size(T,1)],'XTickLabel',names,'YTick',[1:1:size(T,1)],'YTickLabel',names);
rotateXLabels(gca,90)

% Mark NBS significant results
p2 = resNBS{1,1}.F_R;
% grid on
for x=1:size(T,1)
    for y=1:size(T,2)
        if (x > y)
            xv=[x- 0.5 x-0.5 x+.5 x+.5];yv=[y-.5 y+.5 y+.5 y-.5];
            pt = patch(xv,yv,[1 1 1])
            pt.EdgeColor='none';
        end
        if p2(x,y) == 1
            xv=[x- 0.5 x-0.5 x+.5 x+.5 x-.5];yv=[y-.5 y+.5 y+.5 y-.5 y-.5];
            line(xv,yv,'linewidth',1.5,'color',[0 0 0]);
        end
    end
end
for x=1:size(T,1)
    for y=1:size(T,2)
        if (x == y)
            xv=[x- 0.5 x-0.5 x+.5 x+.5];yv=[y-.5 y+.5 y+.5 y-.5];
            pt = patch(xv,yv,[0.8 0.8 0.8]);
            pt.EdgeColor=[0.8 0.8 0.8];
        end
    end
end
box off;
tt=title(['Paired t-test, Psi vs. Sal, both groups, NBS-thresh: ' num2str(thres)]);
tt.FontSize=12;


% Subplot
subplot(2,1,2);
schemaball(repmat(names,1,1),(p2.*T), 10,[-5 5]);


% print
print('-dpsc',fullfile(outputdir,'NBS_PsiVsSal_combinedGroup'),'-r400','-append','-fillpage');
print('-dpdf',fullfile(outputdir,'NBS_PsiVsSal_combinedGroup'),'-r400','-fillpage');





