function create_betaseries_BASCO_jr(Pfunc_all,main_dir,vname);
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
load([main_dir filesep 'output' filesep 'out_estimated_reappraisal_' vname '.mat']);

% define paths...
protocol_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/01-processed_protocol_files';

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
        %% Write sub-files for Lavender and TP NoPuff
        %% LAVENDER:
        if strcmp(anaobj{1,1}.Ana{1,1}.AnaDef.Cond{jx},'Lavender')
            %%
            counter = 1;
            for ix = 1:40
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_Odor1to40.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            %%
            counter = 1;
            for ix = 1:10
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_Odor1to10.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            %%
            counter = 1;
            for ix = 11:40
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_Odor11to40.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            %%
            counter = 1;
            for ix = 41:80
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_Odor41to80.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            %%
            counter = 1;
            for ix = 81:120
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_Odor81to120.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            %%
            counter = 1;
            for ix = 81:110
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_Odor81to110.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            %%
            counter = 1;
            for ix = [find([events.puff_or_not])]
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_Odor_TPPuff.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            %%
            counter = 1;
            vector_Odor_TPNoPuff=[find([events.puff_or_not]==0)];
            vector_Odor_TPNoPuff = vector_Odor_TPNoPuff(vector_Odor_TPNoPuff>40 & vector_Odor_TPNoPuff<81);
            
            for ix = vector_Odor_TPNoPuff
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_Odor_TPNoPuff.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            %% TP NoPuff:
        elseif strcmp(anaobj{1,1}.Ana{1,1}.AnaDef.Cond{jx},'TP NoPuff')
            %%
            counter = 1;
            for ix = start_num:start_num+39
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_TPnoPuff1to40.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            %%
            counter = 1;
            for ix = start_num:start_num+9
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_TPnoPuff1to10.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end
            %%
            counter = 1;
            for ix = start_num+10:start_num+39
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_TPnoPuff11to40.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end            
            %%
            counter = 1;
            for ix = start_num+40:start_num+40+11
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_TPnoPuff41to80.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end            
            %%
            counter = 1;
            for ix = start_num+40+11+1:start_num+40+11+40
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_TPnoPuff81to120.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end 
                        %%
            counter = 1;
            for ix = start_num+40+11+1:start_num+40+11+30
                V = spm_vol(deblank(curr_filelist(ix,:)));
                V_all = V;
                [fdir, fname, ext]=fileparts(V.fname);
                V_all.fname = fullfile(beta4D_dir,[subjAbrev '_betaseries_' vname '_TPnoPuff81to110.nii'])
                V_all.n(1)=counter;
                spm_write_vol(V_all,spm_read_vols(V));
                % Update counter
                counter = counter+1;
            end 
        end
        %%
    end
end
