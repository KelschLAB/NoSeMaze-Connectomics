function create_betaseries_BASCO_social_2sessionscombined_jr(Pfunc_1,Pfunc_2,main_dir,vname);
% Reinwald, Jonathan; 02/2021

% path definition
% cormat directory
cormat_dir = fullfile(main_dir,['cormat_' vname]);
if exist(cormat_dir)~=7
    mkdir(cormat_dir);
end
% beta 4D dir
beta4D_dir = fullfile(cormat_dir,'beta4D');
if exist(beta4D_dir)~=7
    mkdir(beta4D_dir);
end
cd(cormat_dir);

% load anaobj
load([main_dir filesep 'output' filesep 'out_estimated_social_2sessionscombined_' vname '.mat']);

% define paths...
protocol_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/06-social_2sessionscombined/01-processed_protocol_files';

% subject selection (CAVE: 22 subjects for SH, 24 subjects for SD)
[fdir_1,~,~]=fileparts(Pfunc_1{1});
[fdir_1,~,~]=fileparts(fdir_1);
[fdir_1,~,~]=fileparts(fdir_1);
subfolders_1 = dir(fdir_1);
mySubjects_1 = {subfolders_1(contains({subfolders_1.name},'ZI_')).name};

[fdir_2,~,~]=fileparts(Pfunc_2{1});
[fdir_2,~,~]=fileparts(fdir_2);
[fdir_2,~,~]=fileparts(fdir_2);
subfolders_2 = dir('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/02-preprocessing');
mySubjects_2 = {subfolders_2(contains({subfolders_2.name},'ZI_')).name};

selection_1 = ismember(mySubjects_1,mySubjects_2);
subjects = [1:length(mySubjects_2)];

Pfunc_all=Pfunc_1(selection_1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CREATE BETA-SERIES *.nii-files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop over animals/sessions
for subj = 1:length(Pfunc_all)
    %% Loop over runs
    for irun=1:anaobj{1}.Ana{1}.AnaDef.NumRuns
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Write betaseries OVER ALL PATTERNS in the respective run
        % pre-clearing
        clear regressors Pfuncall
        
        %% ----------- Preparation of input within loop -----------------------
        [fdir, fname, ext]=fileparts(Pfunc_all{subj});
        clear find_
        find_=strfind(fname,'_');
        subjAbrev = fname(1:find_(2)-1)
        
        %% 1. Working directory of current animal and selected betaseries
        work_dir = fullfile(main_dir,'input',subjAbrev,['betaseries_' vname]);
        
        %% 2. Create filelist for betaseries
        curr_filelist = spm_select('FPList',work_dir,'^beta_*.*');
        
        start_num = anaobj{1}.Ana{1}.AnaDef.RegCond.Run{irun}.Cond{1}(1);
        end_num = anaobj{1}.Ana{1}.AnaDef.RegCond.Run{irun}.Cond{end}(end);
        
        counter=1; 
        
        for ix = start_num:end_num
            V = spm_vol(deblank(curr_filelist(ix,:)));
            V_all = V;
            [fdir, fname, ext]=fileparts(V.fname);
            %%%%%%%
            V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_AllConditions_run' num2str(irun) '.nii'])
            V_all.n(1)=counter;
            spm_write_vol(V_all,spm_read_vols(V));
            % Update counter
            counter = counter+1;
        end
        
        for ix = start_num+10:end_num
            V = spm_vol(deblank(curr_filelist(ix,:)));
            V_all = V;
            [fdir, fname, ext]=fileparts(V.fname);
            %%%%%%%
            V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_11toEndConditions_run' num2str(irun) '.nii'])
            V_all.n(1)=counter;
            spm_write_vol(V_all,spm_read_vols(V));
            % Update counter
            counter = counter+1;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Loop over conditions (e.g.
        % - every condition should get an own
        for jx = 1:length(anaobj{1,1}.Ana{1,1}.AnaDef.Cond{irun})
            % pre-clearing
            clear regressors Pfuncall
            
            %% ----------- Preparation of input within loop -----------------------
            [fdir, fname, ext]=fileparts(Pfunc_all{subj});
            clear find_
            find_=strfind(fname,'_');
            subjAbrev = fname(1:find_(2)-1)
            
            %% 1. Working directory of current animal and selected betaseries
            work_dir = fullfile(main_dir,'input',subjAbrev,['betaseries_' vname]);
            
            %% 2. Create filelist for betaseries
            curr_filelist = spm_select('FPList',work_dir,'^beta_*.*');
            
            %% 3. Create 4D image for betaseries
            % Define counter
            counter = 1;
            
            % definition of start and end number
            start_num = anaobj{1}.Ana{1}.AnaDef.RegCond.Run{irun}.Cond{jx}(1);
            end_num = anaobj{1}.Ana{1}.AnaDef.RegCond.Run{irun}.Cond{jx}(end);
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Write general conditions
            for ix = start_num:end_num
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                %%%%%%% added to deal with spaces in the naming
                clear find_space file_name
                find_space=strfind(anaobj{1,1}.Ana{1,1}.AnaDef.Cond{irun}{jx},' ');
                if ~isempty(find_space)
                    file_name = anaobj{1,1}.Ana{1,1}.AnaDef.Cond{irun}{jx};
                    file_name(find_space)='-';
                elseif isempty(find_space)
                    file_name = anaobj{1,1}.Ana{1,1}.AnaDef.Cond{irun}{jx};
                end
                %%%%%%%
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_' file_name '.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %% Write sub-files for CD1 familiar, CD1 unknown, 129 sv female
            start_val = anaobj{1}.Ana{1}.AnaDef.RegCond.Run{irun}.Cond{jx}(1)-1;
            
            %%
            counter = 1;
            for ix = [1:10]+start_val
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_' file_name '_1to10.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            %%
            counter = 1;
            for ix = [11:20]+start_val
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_' file_name '_11to20.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            %%
            counter = 1;
            for ix = [21:30]+start_val
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_' file_name '_21to30.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            %%
            counter = 1;
            for ix = [11:30]+start_val
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_' file_name '_11to30.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            
        end
    end
end
