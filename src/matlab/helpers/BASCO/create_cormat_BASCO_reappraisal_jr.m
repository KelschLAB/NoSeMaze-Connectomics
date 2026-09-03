function create_cormat_BASCO_reappraisal_jr(Pfunc_all,Ptxt,Patlas,main_dir,vname)

%% Path definition
% cormat directory
cormat_dir = fullfile(main_dir,['cormat_' vname]);
% beta 4D dir
beta4D_dir = fullfile(cormat_dir,'beta4D');
cd(cormat_dir);

%% Create suffix-list
% Use first animal for selection
[fdir,fname,fext] = fileparts(Pfunc_all{1});
clear find_ temp_name temp_list
find_=strfind(fname,'_');
temp_name = fname(1:find_(2)-1);
% Create temp-list
temp_list  = dir([beta4D_dir filesep temp_name '_betaseries*.*']);
% Create suffix_list
for jx=1:length(temp_list)
    clear find_
    find_=strfind(temp_list(jx).name,'_');
    suffix_list{jx}=temp_list(jx).name(find_(4)+1:end-4);
end

%% Cormat creation
% Loop over suffix_list
for jx=1:length(suffix_list)
    Pcur = spm_select('ExtFPlistrec',beta4D_dir,['ZI*.*betaseries_' vname '_' suffix_list{jx} '.nii'],1);
    [cormat  subj]=wwf_covmat_hres_jr(Ptxt,Pcur,Patlas);
    save([beta4D_dir filesep 'cormat_' vname '_' suffix_list{jx} '.mat'],'cormat');
    save([beta4D_dir filesep 'roidata_' vname '_' suffix_list{jx} '.mat'],'subj');
end

