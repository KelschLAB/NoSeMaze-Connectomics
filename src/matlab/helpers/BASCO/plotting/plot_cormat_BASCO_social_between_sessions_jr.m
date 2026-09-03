%% plot_cormat_BASCO_social_between_sessions_jr.m
% Reinwald, Jonathan, 24.01.2023
% Info:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% cormat selection
cormat_selection = 'v2'; % unsmoothed data
% cormat_selection = 'v1'; % smoothed data

% subject selection (CAVE: 22 subjects vor SH, 24 subjects for SD)
subfolders_sd = dir('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/02-preprocessing');
mySubjects_sd = {subfolders_sd(contains({subfolders_sd.name},'ZI_')).name};

subfolders_sh = dir('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing');
mySubjects_sh = {subfolders_sh(contains({subfolders_sh.name},'ZI_')).name};

subfolders_reappraisal = dir('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing');
mySubjects_reappraisal = {subfolders_reappraisal(contains({subfolders_reappraisal.name},'ZI_')).name};

selection_reappraisal = logical(ismember(mySubjects_reappraisal,mySubjects_sh).*ismember(mySubjects_reappraisal,mySubjects_sd));
selection_sd = logical(ismember(mySubjects_sd,mySubjects_sh).*ismember(mySubjects_sd,mySubjects_reappraisal));
selection_sh = logical(ismember(mySubjects_sh,mySubjects_sd).*ismember(mySubjects_sh,mySubjects_reappraisal));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load cormats for reappraisal task 
cormat_path_reappraisal = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/cormat_v10/beta4D/combined_hemisphere/'];

load(fullfile(cormat_path_reappraisal,'cormat_v10_Odor11to40.mat'));
myCormats(1).cormat = cormat(selection_reappraisal);
myCormats(1).name = 'Odor11-40_reappraisal';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load cormats for social defeat task and reduce to animals in social hierarchy task
cormat_path_sd = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/02-social_defeat/06-FC/01-BASCO/cormat_' cormat_selection '/beta4D/'];

load(fullfile(cormat_path_sd,['cormat_' cormat_selection '_CD1-familiar_11to30.mat']));
myCormats(2).cormat = cormat(selection_sd);
myCormats(2).name = 'CD1fam';

load(fullfile(cormat_path_sd,['cormat_' cormat_selection '_CD1-unknown_11to30.mat']));
myCormats(3).cormat = cormat(selection_sd);
myCormats(3).name = 'CD1unk';

load(fullfile(cormat_path_sd,['cormat_' cormat_selection '_129-sv-female_11to30.mat']));
myCormats(4).cormat = cormat(selection_sd);
myCormats(4).name = '129sv';

%% load cormats for social hierarchy task
cormat_path_sh = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/06-FC/01-BASCO/cormat_' cormat_selection '/beta4D/'];

load(fullfile(cormat_path_sh,['cormat_' cormat_selection '_C57Bl6-High_11to30.mat']));
myCormats(5).cormat = cormat(selection_sh);
myCormats(5).name = 'C57Bl6-High';

load(fullfile(cormat_path_sh,['cormat_' cormat_selection '_C57Bl6-Low_11to30.mat']));
myCormats(6).cormat = cormat(selection_sh);
myCormats(6).name = 'C57Bl6-Low';

% load names for axes
load(fullfile(cormat_path_sh,'roidata_v2_C57Bl6-High.mat'))
names={subj(1).roi.name};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plots
%% I. Mean plots
fig99=figure('visible', 'on');
fig99.Position = [100 100 640 800];

% Loop over myCormats
for i=1:length(myCormats)
    % subplot
    subplot(2,3,i);
    imagesc(mean(cat(3,myCormats(i).cormat{:}),3));
    set(gca,'dataAspectRatio',[1 1 1])
    ax=gca;
    set(gca,'TickLabelInterpreter','none');
    ax.CLim=[-1,1];
    ax.Colormap=jet;
    ax.XTick=[1:length(names)];
    ax.XTickLabel=names;
    ax.YTick=[1:length(names)];
    ax.YTickLabel=names;
    ax.FontSize=4;
    rotateXLabels(ax,90);
    % Title
    tt = title(myCormats(i).name);
    tt.Interpreter='none';
    colorbar;
end
    
counter=1;
for r1=1:length(myCormats)
    for r2=r1+1:length(myCormats)
        clear T p p2 fdrmat meanval stdab
        [T p p2 fdrmat meanval stdab] = lei_pairedtt(myCormats(r1).cormat,myCormats(r2).cormat, 0.05);
        figure(counter+1); imagesc(T); ax=gca; ax.CLim=[-5,5];colormap('jet');
        ax=gca; ax.YTick=1:52; ax.YTickLabel=names;
        ax.XTick=1:52; ax.XTickLabel=names;
        rotateXLabels(ax,90)
        ax.FontSize=6
        colormap('jet');
        title([myCormats(r1).name ' VS ' myCormats(r2).name]);
        counter=counter+1;
    end
end