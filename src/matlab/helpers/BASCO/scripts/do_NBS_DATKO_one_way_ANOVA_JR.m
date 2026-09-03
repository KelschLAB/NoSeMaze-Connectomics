%% Path definition and loading of cormat, names and pathlist
clear all
% path of cormat-/names-files
cormat_path='/home/jonathan.reinwald/DATKO/analyses/functional_analyses/covmat/SIGMA_atlas_unilateral_ORIGINAL/'
% cormat_path='/home/jonathan.reinwald/DATKO/analyses/functional_analyses/covmat/SIGMA_Anatomical_Brain_Atlas_Version1_reorient_jr_merged_noCerebellum_bpm_0.01_0.1_scrub_X2_spline_regfilt_motcsfgs_rswraaztec_or0_uZI_R191030A_2019_10_DATKO_1_1_20191030_091210_12_reorient_c1_reorient2'
% cormat_path='/home/jonathan.reinwald/DATKO/analyses/functional_analyses/covmat/hemireg_rb_bpm_0.01_0.1_scrub_X2_spline_regfilt_motcsfgs_rswraaztec_or0_uZI_R191030A_2019_10_DATKO_1_1_20191030_091210_12_reorient_c1_reorient2'
% load cormat- and names-files
load([cormat_path filesep 'cormat.mat']);
load([cormat_path filesep 'names_110.mat']);
% load([cormat_path filesep 'names_92_wrst_atlas_hemireg_rb.mat']);

% load pathlist
load('/home/jonathan.reinwald/DATKO/data/MRI_data/pathlist_DATKO.mat')

% load animalinfo
load('/home/jonathan.reinwald/DATKO/data/MRI_data/animalinfo_DATKO.mat')

% load atlas
Patlas='/home/jonathan.reinwald/DATKO/helpers/atlas/SIGMA_Wistar_Rat_Brain_TemplatesAndAtlases_Version1/SIGMA_Rat_Brain_Atlases/SIGMA_Anatomical_Atlas/SIGMA_Anatomical_Brain_Atlas_Version1_reorient_jr_merged.nii';
% Patlas='/home/jonathan.reinwald/DATKO/helpers/atlas/Schwarz_atlas_rat/wrst_atlas_hemireg_rb.nii';
Patlas = '/home/jonathan.reinwald/DATKO/helpers/atlas_creation/Kopie von unilateral_atlas/SIGMA_atlas_JR_unilateral.nii';

outputdir='/home/jonathan.reinwald/DATKO/analyses/functional_analyses/NBS/one_way_ANOVA'
mkdir(outputdir);

% load d_struct:
load('/home/jonathan.reinwald/DATKO/data/MRI_data/d_struct/SIGMA_atlas_JR_unilateral/max/d_struct_DATKO.mat');

%% Predefinition of NBS parameters and input
outputname='ANOVA'
input_type={'Extent'}
thres=.99
contrast='[0,1,1]'

% Define genotype_code (1,2,3) for the three genotypes DAT +/+, DAT -/+, DAT
% -/-:
genotype_all = ([animal.genotype]);
genotype_names = unique([animal.genotype]);
genotype_code = zeros(length(genotype_all),1);
for ix = 1:length(genotype_names);
    genotype_code(contains(genotype_all,genotype_names{ix})) = ix;
end;

% % If you want to exclude animals:

% Exclulde animal 9 and 15 (high connectivity)
if 1==0
    genotype_code(9)=0;
    genotype_code(15)=0;
    genotype_code(58)=0;
end

% Exclude Lithium
if 1==1
    timepoint = ([animal.timepoint]);
    genotype_code(timepoint==2)=0;
    outputdir=[outputdir '_noLithium'];
    mkdir(outputdir);
end

% Exclude isoflurane 
if 1==0
    isoflurane = ([animal.isoflurane]);
    genotype_code(isoflurane~=0.5)=0;
    outputdir=[outputdir '_noIso'];
    mkdir(outputdir);
end

% Exclude
if 1==0
    timepoint = ([animal.timepoint]);
    genotype_code(genotype_code==1)=0;
    genotype_code(genotype_code==2)=0;
    genotype_code(genotype_code==3)=1;
    genotype_code(logical((genotype_code==1).*(timepoint==2)'))=2;
    outputdir=[outputdir '_onlyDATKO_t1vst2'];
    mkdir(outputdir);
    genotype_names(3)=[];
    contrast='[0,1]'
end

% Only HET and WT w/o Lithium
if 1==0
    timepoint = ([animal.timepoint]);
    genotype_code(genotype_code==3)=0;
    genotype_code(logical((timepoint==2)'))=0;
    outputdir=[outputdir '_onlyHETandWT'];
    mkdir(outputdir);
    genotype_names(3)=[];
    contrast='[0,1]'
end

% Only DAT -/- and WT w/o Lithium
if 1==0
    timepoint = ([animal.timepoint]);
    genotype_code(genotype_code==2)=0;
    genotype_code(logical((timepoint==2)'))=0;
    outputdir=[outputdir '_onlyKOandWT'];
    mkdir(outputdir);
    genotype_names(2)=[];
    contrast='[0,1]'
end

% Only DAT -/- and WT w/o Lithium
if 1==0
    batchcode=[animal(:).batch];
    batch_sel=strcmp('Batch 3',batchcode);
    timepoint = ([animal.timepoint]);   
    genotype_code(genotype_code==1)=0;
    genotype_code(genotype_code==2)=0;
    genotype_code(logical((timepoint==2)'.*(genotype_code==3)))=1;
    genotype_code(1:47)=0;
    outputdir=[outputdir '_onlyKOandWT_Amphetamine'];
    mkdir(outputdir);
    genotype_names(2)=[];
    contrast='[0,1]'
end
    


%% Plotting of mean_matrices
for ix=1:length(cormat); 
    cormat_p(:,:,ix)=cormat{1,ix}; 
end

genotype_code_short=unique(genotype_code);


for jx=1:length(genotype_names); 
    mean_mat(:,:,jx)=mean(cormat_p(:,:,genotype_code==genotype_code_short(jx+1)),3); 
end;

f99=figure('Visible','on');
f99.Position=get(0,'ScreenSize');
f99.PaperUnits='normalized';
f99.PaperPosition=[0 0 1 1];
f99.PaperOrientation='landscape';
for jx=1:length(genotype_names); 
    subplot(2,2,jx); 
    imagesc(squeeze(mean_mat(:,:,jx)));cc=colorbar;colormap('parula');cc.Limits=[0 1];
    ax=gca;
    ax.XTick=[1:length(names)];
    ax.XTickLabel=names;
    ax.YTick=[1:length(names)];
    ax.YTickLabel=names;
    rotateXLabels(ax,60);
    ax.FontSize=4;
    tt=title(genotype_names{jx});
    tt.FontSize=10;
end;

% saveas(f99,[fullfile(outputdir,char(strcat(outputname,'_GroupComparison_',input_type))) '/' ['Mean_Matrices']],'tif');

% selection=[4:7,14:17,42:45,47:48,53,54,[4:7,14:17,42:45,47:48,53,54]+55];
% selection=[4:7,14:25,42:45,47:48,53,54,[4:7,14:17,42:45,47:48,53,54]+55];
% selection=[4,6,15,16,17,42:45,47:48,53,[4,6,15,16,17,42:45,47:48,53]+55];
selection=[4,6,14,15,16,17,42:45,47:48,53,[4,6,14,15,16,17,42:45,47:48,53]+55];
names=names(selection);
for ix=1:length(cormat);
    cormat{ix}=cormat{ix}(selection,selection);
end

%% NBS
% acl_NBS_DATKO_T_Test_JR(cormat,Patlas,genotype_code,names,genotype_names,outputdir,outputname,input_type,thres,contrast)

acl_NBS_DATKO_one_way_ANOVA_JR(cormat,Patlas,genotype_code,names,genotype_names,outputdir,outputname,input_type,thres,contrast)
