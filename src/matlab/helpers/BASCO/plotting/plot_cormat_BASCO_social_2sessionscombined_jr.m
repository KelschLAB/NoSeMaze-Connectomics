%% plot_cormat_BASCO_social_2sessionscombined_jr.m
% Jonathan Reinwald, 01/2023
% Script for plotting:
% -

%% Clearing
clear all
close all

%% Set script pathes
addpath(genpath('/home/jonathan.reinwald/MATLAB'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'));
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/04-helpers'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/nnet'));

%% Define directories
% Working Directory
workdir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/06-social_2sessionscombined/06-FC/01-BASCO/cormat_v1/beta4D';
% Output directory
outputdir = '/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/06-social_2sessionscombined/04-FC/01-BASCO/01-Cormat';
mkdir(outputdir);

%%
% Make filelist for cormat and roidata mat-files
[cormat_files,dirs] = spm_select('List',workdir,'^cormat*')
[roidatamat_files,dirs] = spm_select('List',workdir,'^roidata*')
% Load roidata.mat to make ROI-names
load([workdir filesep deblank(roidatamat_files(1,:))]);
names = {subj(1).roi.name};

%% Loop over cormat conditions (e.g. Lavender, Puff, ...)
if 1==1
    for ix = 1:size(cormat_files,1)
        % Load Cormat
        load([workdir filesep deblank(cormat_files(ix,:))]);
        % Make title-name
        clear curr_name find_
        [fdir,fname,fext] = fileparts(deblank(cormat_files(ix,:)));
        find_ = strfind(fname,'_');
        curr_name = fname(find_(2)+1:end);
        % Make mean connectivity matrix
        clear cormat_3D
        cormat_3D = cat(3,cormat{:});
        % Plot
        fig=figure('visible', 'off');
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
        imagesc(mean(cormat_3D,3));
        set(gca,'dataAspectRatio',[1 1 1])
        ax=gca;
        set(gca,'TickLabelInterpreter','none');
        ax.CLim=[-1,1];
        ax.Colormap=jet;
        ax.XTick=[1:length(names)];
        ax.XTickLabel=names;
        ax.YTick=[1:length(names)];
        ax.YTickLabel=names;
        rotateXLabels(ax,90);
        % Title
        tt = title(curr_name);
        tt.Interpreter='none';
        colorbar;
        
        % Save
        if 1==1
            [wd_file,wd_name,wd_ext] = fileparts(workdir);
            [wd_file,wd_name,wd_ext] = fileparts(wd_file);
            print('-dpsc',fullfile([outputdir filesep],['MeanCormatALLConditions_' wd_name '_' date '.ps']) ,'-r400','-append')
        end
        close(fig);
    end
end

%% Loop over cormat conditions (e.g. Lavender, Puff, ...)
if 1==1
    for ix = 1:size(cormat_files,1)
        % Load Cormat_1
        clear cormat_1 cormat
        load([workdir filesep deblank(cormat_files(ix,:))]);
        cormat_1 = cormat;
        for jx = 1:size(cormat_files,1)
            % Load Cormat_2
            clear cormat_2 cormat
            load([workdir filesep deblank(cormat_files(jx,:))]);
            cormat_2 = cormat;
            
            % Make title-name
            clear curr_name find_1 find_2 fdir1 fname1 fext1 fdir2 fname2 fext2
            [fdir1,fname1,fext1] = fileparts(deblank(cormat_files(ix,:)));
            find_1 = strfind(fname1,'_');
            [fdir2,fname2,fext2] = fileparts(deblank(cormat_files(jx,:)));
            find_2 = strfind(fname2,'_');
            curr_name = [fname1(find_1(2)+1:end) ' > ' fname2(find_2(2)+1:end)];
            
            % fdr definition
            fdr=0.05;
            
            % Loop over t-tests
            for sx = 1:2
                if sx==1
                    clear T p p2 fdrmat meanval stdab
                    [T p p2 fdrmat meanval stdab] = lei_ttest2(cormat_1,cormat_2,fdr);
                elseif sx==2
                    clear T p p2 fdrmat meanval stdab
                    [T p p2 fdrmat meanval stdab] = lei_pairedtt(cormat_1,cormat_2, fdr );
                end
                % Plot Matrix
                fig1=figure('visible', 'off');
                set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
                imagesc(T);
                set(gca,'dataAspectRatio',[1 1 1])
                ax=gca;
                set(gca,'TickLabelInterpreter','none');
                ax.CLim=[-5,5];
                ax.Colormap=jet;
                ax.XTick=[1:length(names)];
                ax.XTickLabel=names;
                ax.YTick=[1:length(names)];
                ax.YTickLabel=names;
                rotateXLabels(ax,90);
                if sx==1
                    % Title
                    tt = title([curr_name ' unpaired']);
                    tt.Interpreter='none';
                    colorbar;
                elseif sx==2
                    % Title
                    tt = title([curr_name ' paired']);
                    tt.Interpreter='none';
                    colorbar;
                end
                grid on
                % Mark FDR_corrected values
                for x=1:size(T,1)
                    for y=x:size(T,2) %size(T,2);
                        if (x == y)
                            xv=[x- 0.5 x-0.5 x+.5 x+.5];yv=[y-.5 y+.5 y+.5 y-.5];
                            patch(xv,yv,[1 1 1])
                        end
                        %                     if (p2(y,x)<0.05)
                        %                         text((x-1)+.6,y+.1,sprintf('%2.1f',T(y,x)),'color',[1 1 1], ...
                        %                             'fontsize',7) ;
                        %                     end
                        if fdrmat(y,x)
                            xv=[x- 0.5 x-0.5 x+.5 x+.5 x-.5];yv=[y-.5 y+.5 y+.5 y-.5 y-.5];
                            line(xv,yv,'linewidth',2,'color',[0 0 0]);
                        end
                    end
                end
                
                % Save
                if 1==1
                    [wd_file,wd_name,wd_ext] = fileparts(workdir);
                    [wd_file,wd_name,wd_ext] = fileparts(wd_file);
                    print('-dpsc',fullfile([outputdir filesep],['Mean_' wd_name '_' fname1(find_1(2)+1:end) '_' date '.ps']) ,'-r400','-append')
                end
                
                
                % Plot
                fig2=figure('visible', 'off');
                set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
                schemaball(names, (fdrmat+fdrmat').*T, 10,[-5,5])
                if sx==1
                    % Title
                    tt = title([curr_name ' unpaired']);
                    tt.Interpreter='none';
                    
                elseif sx==2
                    % Title
                    tt = title([curr_name ' paired']);
                    tt.Interpreter='none';
                    
                end
                
                % Save
                if 1==1
                    [wd_file,wd_name,wd_ext] = fileparts(workdir);
                    [wd_file,wd_name,wd_ext] = fileparts(wd_file);
                    print('-dpsc',fullfile([outputdir filesep],['Mean_' wd_name '_' fname1(find_1(2)+1:end) '_' date '.ps']) ,'-r400','-append')
                end
                
                close all
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%



