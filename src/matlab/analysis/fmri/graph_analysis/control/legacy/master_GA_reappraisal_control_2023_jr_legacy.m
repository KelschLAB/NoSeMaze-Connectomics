%% master_GA_reappraisal_control_2023_jr.m
% Jonathan Reinwald, 05/2021
% !!! IMPORTANT !!! cormat.mat-files are ordered by the animal number 
% (e.g. M11, M12, ...) as the betaseries for the cormat calculation are 
% selected with spm_select in the respective folder --> result files
% (gstruc and auc_struc) are also ordered by animal number

% -
%% Clearing
clear all
% close all

%% Selection of input
% cormat version
cormat_version = 'cormat_v7';
% bi-/unihemispheric atlas
separated_hemisphere = 0; % 2: 
% binarized/non-binarized network
binarization_method = 'max'; % 'max'
connectedness_val = 'connected';


%% Set script pathes
addpath(genpath('/home/jonathan.reinwald/MATLAB'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'));
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/04-helpers'));
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'));
addpath(genpath('/home/jonathan.reinwald/Documents/MATLAB/nnet'));
% add GA scripts
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/05-GitLab'));
% add brain connectivity toolbox
addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/2019_03_03_BCT'));

%% Load filelist
if 1==1
load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/03-filelists/filelist_ICON_reappraisal_control_2023_jr.mat')
end

%% Define directories
% Working Directory
if separated_hemisphere==2
    workdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/06-FC/01-BASCO/' cormat_version '/beta4D' filesep 'separated_v2_2023_hemisphere'];
%     workdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/' cormat_version '/beta4D'];
elseif separated_hemisphere==1
    workdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/06-FC/01-BASCO/' cormat_version '/beta4D' filesep 'separated_hemisphere'];
%     workdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/' cormat_version '/beta4D'];
elseif separated_hemisphere==0
    workdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/06-FC/01-BASCO/' cormat_version '/beta4D' filesep 'combined_hemisphere'];
%     workdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/06-FC/01-BASCO/' cormat_version '/beta4D'];
end
% Output directory
if separated_hemisphere==2
    outputdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version filesep 'separated_v2_2023_hemisphere' filesep binarization_method '_' connectedness_val];
elseif separated_hemisphere==1
    outputdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version filesep 'separated_hemisphere' filesep binarization_method '_' connectedness_val];
elseif separated_hemisphere==0
    outputdir = ['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/07-GA/01-gstruct_files/' cormat_version filesep 'combined_hemisphere' filesep binarization_method '_' connectedness_val];
end
mkdir(outputdir);

%%
% Make filelist for cormat and roidata mat-files
[cormat_files,dirs] = spm_select('List',workdir,'^cormat*')
[roidatamat_files,dirs] = spm_select('List',workdir,'^roidata*')
% Load roidata.mat to make ROI-names
load([workdir filesep deblank(roidatamat_files(1,:))]);
names = {subj(1).roi.name};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop over cormat conditions (e.g. Lavender, Puff, ...)
if 1==1
    for ix = [7,10]%    [2,7,12,17]%[2,6,9,11,15]%1:size(cormat_files,1)
        clear gstruc cormat
        % Load Cormat
        load([workdir filesep deblank(cormat_files(ix,:))]);
        % Make title-name
        clear curr_name find_
        [fdir,fname,fext] = fileparts(deblank(cormat_files(ix,:)));
        find_ = strfind(fname,'_');
        curr_name = fname(find_(2)+1:end);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% The following is adapted from rb_network_example.m
        % by Jonathan Reinwald, 05/2021
        
        %%  ---------- delete diagonal elements of cormats -----------------
        if 1==0
            % Loop over cormat
            for jmat=1:numel(cormat)
                cormat{jmat}=cormat{jmat}.*~eye(size(cormat{jmat}));
            end
            % Save cormat
            save([outputdir filesep deblank(cormat_files(ix,:))],'cormat','names');
        end
        
        %% ------ analyze positive/negative weights seperatly or use absolute values ----------
        % NB: for correlation networks this is a necessary step of the analysis, as some network
        % properties can not be calculated (or don't make sense) if negative weights are involved
        % For wavelet coherence it's unneccessary - only positive weights in the first place
        
        % positive edges seperately
        if 1==0
            % Load cormat
            load([outputdir filesep deblank(cormat_files(ix,:))],'cormat','names');
            % Loop over cormat
            for jmat=1:numel(cormat)
                cormat{jmat}=cormat{jmat}.*(cormat{jmat}>0).*sign(cormat{jmat});
            end
            % Save cormat
            save([outputdir filesep fname '_p.mat'],'cormat','names');
        end
        
        % negative edges separately (absolute weights of negative edges)
        if 1==0
            % Load cormat
            load([outputdir filesep deblank(cormat_files(ix,:))],'cormat','names');
                        % Loop over cormat
            for jmat=1:numel(cormat)
                cormat{jmat}=cormat{jmat}.*(cormat{jmat}<0).*sign(cormat{jmat});
            end
            % Save cormat
            save([outputdir filesep fname '_n.mat'],'cormat','names');
        end
        
        % absolute values of everything
        if 1==0
            % Load cormat
            load([outputdir filesep deblank(cormat_files(ix,:))],'cormat','names');
                        % Loop over cormat
            for jmat=1:numel(cormat)
                cormat{jmat}=abs(cormat{jmat});
            end   
            % Save cormat
            save([outputdir filesep fname '_a.mat'],'cormat','names');
        end     
        
% % %         %% --------------- Fisher Z-scores ------------------------
% % %         if 1==0
% % %             % Load cormat
% % %             load([outputdir filesep deblank(cormat_files(ix,:))],'cormat','names');  
% % %             % Loop over cormat
% % %             for jmat=1:numel(cormat)
% % %                 cormat{jmat}=fisherz(cormat{jmat});
% % %             end
% % %             % Save cormat
% % %             save([outputdir filesep fname '_ztrans.mat'],'cormat','names');
% % %         end      
        
        %% ------ Calculate network properties over a range of thresholds        
        % Normalization methods: 'max': normalze to maximum weight, 'bin': binarize, 'none': don't normalize
        normalize = binarization_method; % choose normalization procedure, see help rb_graph_thresh_flex for options
        
        if 1==0
            % Load cormat
            clear cormat
            load([outputdir filesep fname '_p.mat'],'cormat','names');
            % Define thresholds
            cutoffs = [0.1:0.01:0.5]; % density thresholds, just a minimal example - adjust to your needs!!!
            
            % Choose graph metrics
            if strcmp(connectedness_val,'connected')
                calcat={'all'}; % chose which graph metrics to calculate, see help rb_graph_thresh_flex for options
            else
                calcat={'smallworld','efficiency','centrality','modularity','norm','swpcalc','resiliencecalc'};
            end
    
            % Transpose cormat before Running
            cormat=cormat';
            
            % Calculation of graph metrics
            gstruc = rb_graph_thresh_flex(cormat,cutoffs,normalize,calcat);
            % Save gstruc
            save([outputdir filesep 'gstruc_' curr_name '_p.mat'],'gstruc');
        end
        
        
        %% ------------ calculate AUC ------------------------------
        if 1==1
            % calculate averages of graph metrics over a range of thresholds
            % (choice of threshold is arbitrary)
            
            % Load gstruc
            load([outputdir filesep 'gstruc_' curr_name '_p.mat'],'gstruc');
            
            % thresholds to take into calculation for AUC. These are indices for
            % positions in the threshold vector!
            minthr_ind=1;
            maxthr_ind=41;
            
            % Calculation of AUC
            auc_struc=rb_gstruc_2_auc(gstruc,minthr_ind,maxthr_ind);
            % Save gstruc
            save([outputdir filesep 'auc_struc_' curr_name '_' num2str(minthr_ind+9) 'to' num2str(maxthr_ind+9) '_p.mat'],'auc_struc');
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

