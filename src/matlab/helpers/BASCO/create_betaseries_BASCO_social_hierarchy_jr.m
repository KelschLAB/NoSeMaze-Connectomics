function create_betaseries_BASCO_social_hierarchy_jr(Pfunc_all,main_dir,vname);
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
load([main_dir filesep 'output' filesep 'out_estimated_social_hierarchy_' vname '.mat']);

% define paths...
protocol_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/03-social_hierarchy/01-processed_protocol_files';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CREATE BETA-SERIES *.nii-files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Loop over animals/sessions
for subj = 1:length(Pfunc_all)
    %% Loop over conditions (e.g.
    % - every condition should get an own
    for jx = 1:length(anaobj{1,1}.Ana{1,1}.AnaDef.Cond)
        % pre-clearing
        clear regressors Pfuncall
        
        %% ----------- Preparation of input within loop -----------------------
        [fdir, fname, ext]=fileparts(Pfunc_all{subj});
        clear find_
        find_=strfind(fname,'_');
        subjAbrev = fname(1:find_(2)-1)
        
        %% 1. find and load processed protocol file
        [fpath,fname,ext]=fileparts(Pfunc_all{subj});
        protocol_file = dir([protocol_dir filesep 'animal_' fname(find_(1)+2:find_(2)-1) filesep 'animal_' fname(find_(1)+2:find_(2)-1) '*.*']);
        load([protocol_file.folder filesep protocol_file.name]);
        
        %% 1. Working directory of current animal and selected betaseries
        work_dir = fullfile(main_dir,'input',subjAbrev,['betaseries_' vname]);
        
        %% 2. Create filelist for betaseries
        curr_filelist = spm_select('FPList',work_dir,'^beta_*.*');
        
        %% 3. Create 4D image for betaseries
        % Define counter
        counter = 1;
        
        % Define starting point (start_num)
        if jx>1
            start_num_vec = [];
            for ix=1:(jx-1)
                start_num_vec = [start_num_vec,length(anaobj{1,1}.Ana{1,1}.AnaDef.RegCondVec{ix})];
            end
            start_num = sum(start_num_vec)+1;
        elseif jx==1
            start_num = 1;
        end
        
        % Define endpoint of the loop (end_num)
        if jx>1
            end_num_vec = [];
            for ix=1:jx
                end_num_vec = [end_num_vec,length(anaobj{1,1}.Ana{1,1}.AnaDef.RegCondVec{ix})];
            end
            end_num = sum(end_num_vec);
        elseif jx==1
            end_num = length(anaobj{1,1}.Ana{1,1}.AnaDef.RegCondVec{1});
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Write general conditions
        for ix = start_num:end_num
            V = spm_vol(deblank(curr_filelist(ix,:)));
            V_all = V;
            [fdir, fname, ext]=fileparts(V.fname);
            %%%%%%% added to deal with spaces in the naming
            clear find_space file_name
            find_space=strfind(anaobj{1,1}.Ana{1,1}.AnaDef.Cond{jx},' ');
            if ~isempty(find_space)
                file_name = anaobj{1,1}.Ana{1,1}.AnaDef.Cond{jx};
                file_name(find_space)='-';
            elseif isempty(find_space)
                file_name = anaobj{1,1}.Ana{1,1}.AnaDef.Cond{jx};
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
        %% CD1 familiar:
        if strcmp(anaobj{1,1}.Ana{1,1}.AnaDef.Cond{jx},'C57Bl6 Low')
            start_val = 0;
        elseif strcmp(anaobj{1,1}.Ana{1,1}.AnaDef.Cond{jx},'C57Bl6 High')
            start_val = 30;
        end
        
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
