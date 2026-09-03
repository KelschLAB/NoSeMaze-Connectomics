%% master_plot_HRF_jr.m

%clearing
clear all
close all

% HRF directories
HRF_directory{1}.path = '/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal/longTC/hrf_withoutOnset_from2sHRF-GLM';
HRF_directory{1}.name = 'mouseHRF';
HRF_directory{1}.color = [0.5,0,0];

HRF_directory{2}.path = '/home/jonathan.reinwald/Programs/spm12';
HRF_directory{2}.name = 'humanHRF';
HRF_directory{2}.color = [0,0,0.5];

% figure
fig1=figure('visible', 'on');
set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.25,0.4]);

%% Loop over HRFs
for ix=1:length(HRF_directory)
    
    %
    hold on
    
    % addpath
    addpath(genpath(HRF_directory{ix}.path));
    cd(HRF_directory{ix}.path);
    
% %     if ix==1
% %         load('/home/jonathan.reinwald/ICON_HRF/04-analyses/03-HRF_estimation/longTC/withoutOnset_from1sHRF-GLM/hrf_info.mat');        
% %         % plot
% %         for kx=1:size(info.hrf_param_concatenated,1)
% %             hrf_all(kx,:)=spm_hrf(0.1,[info.hrf_param_concatenated(kx,1),info.hrf_param_concatenated(kx,2),info.hrf_param_concatenated(kx,3),info.hrf_param_concatenated(kx,3),info.hrf_param_concatenated(kx,4),0,32]);
% %         end
% %         sd=shadedErrorBar([0:1:320],nanmean(hrf_all),SEM_calc(hrf_all));
% %         sd(1).patch.EdgeColor='none';
% %         sd(1).patch.FaceColor=HRF_directory{ix}.color;
% %         sd(1).patch.FaceAlpha=.5;
% %         sd(1).mainLine.Color=HRF_directory{ix}.color;
% % %         sd(1).mainLine.LineWidth=1.5;
% %         sd(1).edge(1).Color='none';
% %         sd(1).edge(2).Color='none';
% %     end
    % plot
    hold on;
    pl(ix) = plot([0:1:320],spm_hrf(0.1));
    % save source data for plot
    SourceData = array2table([[0:.1:32];spm_hrf(0.1)']);
    writetable(SourceData,fullfile(HRF_directory{1}.path,['SourceData_HRFplot_' HRF_directory{ix}.name '.csv']),'WriteVariableNames',true,'WriteRowNames',true)
    % 
    pl(ix).LineWidth = 3;
    pl(ix).Color = HRF_directory{ix}.color;
    if ix>1
        pl(ix).LineStyle='--';
    end
    
    ax=gca;
    box(ax,'off');
    set(gca,'TickLabelInterpreter','none');
    
    ax.XTick=[0:10:320];
    ax.XTickLabel=[0:32];
    ax.XLabel.String='time [s]';
    ax.XLim=[0,150];
    
    ax.YLabel.String='A.U.';
    
    ax.FontSize=14;
    ax.LineWidth=2;
    
end

% legend
ll=legend([pl(1),pl(2)],HRF_directory{1}.name,HRF_directory{2}.name);

cd(HRF_directory{1}.path);

% print
print('-dpsc',fullfile(HRF_directory{1}.path,['HRF']),'-painters','-r400');
print('-dpdf',fullfile(HRF_directory{1}.path,['HRF']),'-painters','-r400');