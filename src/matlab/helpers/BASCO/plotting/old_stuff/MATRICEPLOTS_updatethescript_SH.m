%% plot_cormat_BASCO_social_hierarchy_jr.m
% Jonathan Reinwald, 05/2021
% Script for plotting:
% -

%% Clearing
clear all
close all

%% Set script pathes
addpath(genpath('/zi-flstorage/data/Jonathan/MATLAB'));
addpath(genpath('/zi-flstorage/data/Jonathan/ICON_Autonomouse/01-scripts/03-MRI'));
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/04-helpers'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'));
addpath(genpath('/home/jonathan.reinwald/Documents/MATLAB/nnet'));

%% Load filelist
if 1==1
    load('/zi-flstorage/data/Jonathan/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/03-filelists/filelist_ICON_social_hierarchy_jr.mat')
end

%% Define directories
% Working Directory
workdir = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/06-FC/01-BASCO/cormat_v2/beta4D';
% Output directory
outputdir = '/zi-flstorage/data/Jonathan/ICON_Autonomouse/04-outputs/03-MRI/03-social_hierarchy/04-FC/01-BASCO/01-Cormat';
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
        figure(1);
        set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
        imagesc(mean(cormat_3D,3));
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
    end
end

%% Loop over cormat conditions (e.g. Lavender, Puff, ...)
% % 1 'cormat_v1_Lavender.mat       '
% % 2 'cormat_v1_Odor11to40.mat     '
% % 3 'cormat_v1_Odor1to10.mat      '
% % 4 'cormat_v1_Odor1to20.mat      '
% % 5 'cormat_v1_Odor1to40.mat      '
% % 6 'cormat_v1_Odor21to40.mat     '
% % 7 'cormat_v1_Odor41to80.mat     '
% % 8 'cormat_v1_Odor81to120.mat    '
% % 9 'cormat_v1_Odor_TPNoPuff.mat  '
% % 10 'cormat_v1_Odor_TPPuff.mat    '
% % 11 'cormat_v1_TP-NoPuff.mat      '
% % 12 'cormat_v1_TP-Puff.mat        '
% % 13 'cormat_v1_TPnoPuff11to40.mat '
% % 14 'cormat_v1_TPnoPuff1to10.mat  '
% % 15 'cormat_v1_TPnoPuff1to20.mat  '
% % 16 'cormat_v1_TPnoPuff1to40.mat  '
% % 17 'cormat_v1_TPnoPuff21to40.mat '
% % 18 'cormat_v1_TPnoPuff41to80.mat '
% % 19 'cormat_v1_TPnoPuff81to120.mat'

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
                figure(1);
                set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.4,0.7]);
                imagesc(T);
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
                    print('-dpsc',fullfile([outputdir filesep],['Mean_' wd_name '_' fname1(find_1(2)+1:end) '_' date '.ps']) ,'-r400','-append','-bestfit')
                end
                
                
                % Plot
                figure(2);
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
                    print('-dpsc',fullfile([outputdir filesep],['Mean_' wd_name '_' fname1(find_1(2)+1:end) '_' date '.ps']) ,'-r400','-append','-bestfit')
                end
                
                close all
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%


comparison{1} = [15,6;12,3];
comparison{2} = [15,6;11,2];
comparison{3} = [15,6;13,4];

if 1==0
    for ix = 1:length(comparison)
        
        %% BLOCK AFTER PUFF
        % Load Cormat_Late
        clear cormat_L_tp cormat
        load([workdir filesep deblank(cormat_files(comparison{ix}(1,1),:))]);
        cormat_L_tp = cormat;
        % Load Cormat_Late
        clear cormat_L_od cormat
        load([workdir filesep deblank(cormat_files(comparison{ix}(1,2),:))]);
        cormat_L_od = cormat;
        % Make title-name
        clear curr_name_L find_1 find_2 fdir1 fname1 fext1 fdir2 fname2 fext2
        [fdir1,fname1,fext1] = fileparts(deblank(cormat_files(comparison{ix}(1,1),:)));
        find_1 = strfind(fname1,'_');
        [fdir2,fname2,fext2] = fileparts(deblank(cormat_files(comparison{ix}(1,2),:)));
        find_2 = strfind(fname2,'_');
        curr_name_L = [fname1(find_1(2)+1:end) ' > ' fname2(find_2(2)+1:end)];
        
        % Create Diff-Matrix
        clear cormat_L_diff
        for jx = 1:length(cormat_L_od)
            cormat_L_diff{jx} = cormat_L_tp{jx}-cormat_L_od{jx};
        end
        
        %% BLOCK BEFORE PUFF
        % Load Cormat_Late
        clear cormat_E_tp cormat
        load([workdir filesep deblank(cormat_files(comparison{ix}(2,1),:))]);
        cormat_E_tp = cormat;
        % Load Cormat_Late
        clear cormat_E_od cormat
        load([workdir filesep deblank(cormat_files(comparison{ix}(2,2),:))]);
        cormat_E_od = cormat;
        % Make title-name
        clear curr_name_E find_1 find_2 fdir1 fname1 fext1 fdir2 fname2 fext2
        [fdir1,fname1,fext1] = fileparts(deblank(cormat_files(comparison{ix}(2,1),:)));
        find_1 = strfind(fname1,'_');
        [fdir2,fname2,fext2] = fileparts(deblank(cormat_files(comparison{ix}(2,2),:)));
        find_2 = strfind(fname2,'_');
        curr_name_E = [fname1(find_1(2)+1:end) ' > ' fname2(find_2(2)+1:end)];
        
        % Create Diff-Matrix
        clear cormat_E_diff
        for jx = 1:length(cormat_L_od)
            cormat_E_diff{jx} = cormat_E_tp{jx}-cormat_E_od{jx};
        end
        
        % Lei T-Test
        fdr=0.05;
        
        % Loop over t-tests
        for sx = 1:2
            if sx==1
                clear T p p2 fdrmat meanval stdab
                [T p p2 fdrmat meanval stdab] = lei_ttest2(cormat_L_diff,cormat_E_diff,fdr);
            elseif sx==2
                clear T p p2 fdrmat meanval stdab
                [T p p2 fdrmat meanval stdab] = lei_pairedtt(cormat_L_diff,cormat_E_diff, fdr );
            end
            % Plot
            figure(1);
            set(gcf,'Units','Normalized','OuterPosition',[0,0.04,0.2,0.7]);
            imagesc(T);
            ax=gca;
            set(gca,'TickLabelInterpreter','none');
            ax.CLim=[-5,5];
            ax.Colormap=jet;
            ax.XTick=[1:50];
            ax.XTickLabel=names;
            ax.YTick=[1:50];
            ax.YTickLabel=names;
            rotateXLabels(ax,90);

            if sx==1
                    % Title
                    tt = title([curr_name_L ' > ' curr_name_E ' unpaired']);
                    tt.Interpreter='none';
                    colorbar;
                elseif sx==2
                    % Title
                    tt = title([curr_name_L ' > ' curr_name_E ' paired']);
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
                print('-dpsc',fullfile([outputdir filesep],['Diff_' wd_name '_' date '.ps']) ,'-r400','-append')
            end
        end
    end
end











