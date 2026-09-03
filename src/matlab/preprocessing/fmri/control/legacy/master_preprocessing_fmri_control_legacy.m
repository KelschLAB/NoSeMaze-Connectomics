%% master_preprocessing_reappraisal_control_2023_jr.m
% PREPROCESSING MOUSE DATA, PARAVISION 6 DIR-STRUCTURE

% Jonathan Reinwald 11/2020
% Main preprocessing script for fMRI data (EPIs and 3Ds) including:
% - path definition
% - pv-conversion (wwf_reform_bruker3)
% - reading scanlist/filelist creation
% - deletion of dummies
% - 3D brain extraction
% - fieldmap correction
% - realignment and unwarping
% - motiondiagnosis
% - slice-time correction
% - coreg. Func to 3D, then template
% - bias correction and normalization
% - smoothing

%% Set MATLAB-path for script-folders and -subfolders
clear all
clc

addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'))
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
% addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/spm12_animal'))
% addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/03-MRI'))

%% ------------------ Predefinition of pathes ----------------------------%

% Predefine main working directory
rawdir='/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/03-MRI/05-reappraisal_control_2023/01-fMRI_data';
procdir='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/02-preprocessing';
cd(procdir)

% Predefine path of scanlist
scans='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/03-filelists/ScanList_reappraisal_control_2023.csv';%path of scan list as a csv

% Predefine path for mouse brain atlas (3D and mask)
Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
Pmask='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brainmask_rs1x1x1_polish.nii';

%% ------------------ Converting of original files -----------------------%
% - unzip the files before
% - use wwf_reform_bruker3.m as it is a more recent version than Lei's
% pvconv
% - scripts are located in
% /home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/pvconv_wwf
if 1==0
    addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/pvconv_wwf'));
    rawdata = '/home/jonathan.reinwald/ICON_Autonomouse/02-raw-data/03-MRI/05-reappraisal_control_2023/01-fMRI_data';
    outputdir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/02-preprocessing';
    wwf_reform_bruker3(rawdata,outputdir);
end


%% ------------------ 3D, FM, EPI READING FROM SCAN list -----------------%
if 1==0
    % Reading of csv-file
    [subj_ID,subj_name,examn,series]=textread(scans,'%s %s %s %u','delimiter',',','headerlines',1); % type
    
    % Gives you the unique animal-names (ZI_M...) based on the csv-file
    [regu,IA,IC]=unique(subj_ID);
    % Gives you the corresponding animal-number (PD..)
    subu=subj_name(IA);
    
    % replace subsequent lines that are absolute identical by double
    if 1==0
        for ix=1:(size(subj_ID,1)-1)
            if strcmp(deblank(char(examn(ix))),deblank(char(examn(ix+1))))
                examn{ix+1}='double';
                if strcmp(deblank(char(examn(ix))),deblank(char(examn(ix+2))))
                    examn{ix+2}='triple';
                    if strcmp(deblank(char(examn(ix))),deblank(char(examn(ix+3))))
                        examn{ix+3}='quadruple';
                    end
                end
            end
        end
    end
    
    if 1==0
        path_all=cellstr(spm_select('ExtFPListRec', procdir, '^[zZ][iI].*reorient.nii'));
        
        for jscan=1:size(subj_ID,1)
            episcan_reappraisal(jscan)=strcmp(deblank(char(examn(jscan))),'EPI_FID_1.1_22Slc');
            scan3d(jscan)=contains(deblank(char(examn(jscan))),'TurboRARE3D');
            fmapscan_1(jscan)=strcmp(deblank(char(examn(jscan))),'Fieldmap_1');
            fmapscan_2(jscan)=strcmp(deblank(char(examn(jscan))),'Fieldmap_2');
        end
        
        epiind=find(episcan_reappraisal);
        for jepi=1:numel(epiind)
            indc=regexp(path_all,[char(subj_ID(epiind(jepi))),'.*/', num2str(series(epiind(jepi))),'/']);
            for jscan=1:size(indc,1)
                if ~isempty(indc{jscan})
                    Pfunc_reappraisal(jepi)=path_all(jscan);
                end
            end
        end
        
        ind3d=find(scan3d);
        for j3d=1:numel(ind3d)
            indc=regexp(path_all,[char(subj_ID(ind3d(j3d))),'.*/', num2str(series(ind3d(j3d))),'/']);
            for jscan=1:size(indc,1)
                if ~isempty(indc{jscan})
                    P3d(j3d)=path_all(jscan);
                end
            end
        end
        
        fmapind=find(fmapscan_1);
        for jmap=1:numel(fmapind)
            indc=regexp(path_all,[char(subj_ID(fmapind(jmap))),'.*/', num2str(series(fmapind(jmap))),'/Z'],'ignorecase');  %%% CAVE: Z is added to not find the file in the folder p2
            for jscan=1:size(indc,1)
                if ~isempty(indc{jscan})
                    [path, file, ext]=fileparts(char(path_all(jscan)));
                    Pdmap_1{jmap}=path;
                end
            end
        end
        
        fmapind=find(fmapscan_2);
        for jmap=1:numel(fmapind)
            indc=regexp(path_all,[char(subj_ID(fmapind(jmap))),'.*/', num2str(series(fmapind(jmap))),'/Z'],'ignorecase');  %%% CAVE: Z is added to not find the file in the folder p2
            for jscan=1:size(indc,1)
                if ~isempty(indc{jscan})
                    [path, file, ext]=fileparts(char(path_all(jscan)));
                    Pdmap_2{jmap}=path;
                end
            end
        end
        
        % %     for jphy=1:length(Pfunc_reappraisal);
        % %         % Reappraisal
        % %         [fpath,~,~]=fileparts(Pfunc_reappraisal{jphy})
        % %         [fpath,fname,~]=fileparts(fpath)
        % %         if length(fname)==1
        % %             Pphysio_reappraisal(jphy,:)=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/04-physio/' num2str(fpath(end-1:end)) '-#0' num2str(fname) '.txt'];
        % %         elseif length(fname)==2
        % %             Pphysio_reappraisal(jphy,:)=['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/04-physio/' num2str(fpath(end-1:end)) '-#' num2str(fname) '.txt'];
        % %         end
        % %     end
    end
    save('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/03-filelists/filelist_ICON_reappraisal_control_2023_jr.mat','P3d','Pdmap_1','Pdmap_2','Pfunc_reappraisal')
    
end

%% -------------------- Load filelist ------------------------------------%

%% Set MATLAB-path for script-folders and -subfolders
% addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts'))
% addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))
% spm fmri

load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/03-filelists/filelist_ICON_reappraisal_control_2023_jr.mat','P3d','Pdmap_1','Pdmap_2','Pfunc_reappraisal')

%% -------------------- Check Scans for matching position ----------------%
% if scans are not in the same position, e.g. because between EPI and 3D
% the animal was moved, use coregister (estimate) to get them into the same
% position CAVE: be sure to do this for all ... EPI volumes

if 1==0
    for ix=1:size(Pfunc_reappraisal,2)
        [fpath,~,~]=fileparts(Pfunc_reappraisal{ix});
        Pfunc_cur=spm_select('ExtFPList',fpath,['^[zZ][iI].*._reorient.nii'],1);
        Pfunc_cur1=spm_select('ExtFPList',fpath,['^[zZ][iI].*._reorient.nii'],1600);
        fdir=Pdmap_1{ix};
        Pfdm_1=spm_select('ExtFPList',[fdir '/p2'],['^[zZ][iI].*.acq0_reorient.nii'],1);
        fdir=Pdmap_2{ix};
        Pfdm_2=spm_select('ExtFPList',[fdir '/p2'],['^[zZ][iI].*.acq0_reorient.nii'],1);
        fdir=Pdmap_1{ix};
        Pfdm_3=spm_select('ExtFPList',fdir,['^[zZ][iI].*.reorient.nii'],1);
        char_all=char([Pfunc_cur;Pfunc_cur1;P3d(ix);Pfdm_1;Pfdm_2;Pfdm_3]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% --------------- Delete first scans (not enough dummies) ---------------%

% Objective: Deletion of first scans (if necessary) since scanner needs
% time to reach equilibrium.
if 1==0
    Pfunc = Pfunc_reappraisal;
    % Show mean tc without deletion to judge quality
    if 1==0
        syscmd=['mkdir data_cor_hist'];
        system(syscmd);
        cd('data_cor_hist')%lw
        for ix=1:size(Pfunc,2)
            wwf_voxcor_lw(Pfunc{ix},'cor_hist',1.2); % TR = 1.3;
        end
        cd(procdir)
    end
    
    % Deletion of first 5 scans:
    if 1==0
        for ix=1:size(Pfunc,2)
            Pcur=deblank(Pfunc{ix});
            [fdir, fname, ext]=fileparts(Pcur);
            Pdo=spm_select('ExtFPList',fdir,['^' fname '.nii'],1);
            wwf_del_vol(Pdo,5);
        end
    end
    
    % Show corrected mean tc after deletion of dummies
    if 1==0
        syscmd=['mkdir data_cor_hist_del5'];
        system(syscmd);
        cd('data_cor_hist_del5')%lw
        
        for ix=1:size(Pfunc,2)
            [fdir, fname, ext]=fileparts(Pfunc{ix});
            Pcur=[fdir filesep 'del5_' fname ext];
            wwf_voxcor_lw(Pcur,'cor_hist_del5',1.2);
        end
        cd(procdir)
    end
end

% Visual control:
if 1==0
    for ix=1:size(P3d,2)
        [fdir, fname, ext]=fileparts(Pfunc_reappraisal{ix});
        Pfunc_cur=spm_select('ExtFPList',fdir,['^del5_' fname '.nii'],1);
        Pfunc_cur1=spm_select('ExtFPList',fdir,['^del5_' fname '.nii'],str2num(Pfunc_reappraisal{ix}(end-3:end))-5);
        char_all=char([P3d(ix);Pfunc_cur;Pfunc_cur1]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ------------------------- AFNI despiking ------------------------------%
% AFNI despike
if 1==0
    for ix=1:length(Pfunc_reappraisal)
        % Application on reappraisal data
        [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
        Pcur=spm_select('FpList', fpath , ['^del5_' fname '.nii']);
        Poutput=fullfile(fpath,['despiked_del5_' fname '.nii']);
        sysprompt=(['3dDespike -nomask -prefix ' Poutput ' ' Pcur]);
        system(sysprompt)
    end
end


%% ------------------------ Fieldmap Correction --------------------------%
%-------------------- Fieldmap "Filling" and "Masking" -------------------%
% - fieldmap_2 is used
% - preparation of the FM including dilation and filling of empty voxels
if 1==0
    for ix=1:3%size(Pdmap_1,2)
        % Creation of fpm_.._acq0_reorient_spm2.img
%         wwf_FieldMap_rat_reappraisal_control_2023_jr(Pdmap_1{ix});
        % Dilatation of fieldmap and filling of empty voxels in the edges of the fieldmap
        fdir=Pdmap_1{ix};
        clear Pfm
        Pfm_a=spm_select('FPList',fdir,['^ZI_.*._reorient.nii']);
        Pfm_b=spm_select('FPList',fdir,['^zi_.*._reorient.nii']);
        Pfm=[Pfm_a;Pfm_b];
        if 1==0
            fieldmap_fill_dilate_jr(Pfm);
        end
%         fieldmap_fill_2(fdir);
        if 1==1
            Pmcur=spm_select('FPlist',fdir,['^full_.*p1_reorient.nii$']) ;
            wwf_fix_fm_offset(Pmcur,P3d{ix}(1:end-2))
        end
    end
end

% first application of fieldmap (only on first image) to create u-file
if 1==0
    for ix=1:3%size(Pdmap_1,2)
        % Application on reappraisal data
        [fdir, fname, ext]=fileparts(Pfunc_reappraisal{ix});
        Pfunc_cur=spm_select('ExtFPList',fdir,['^despiked_del5_' fname '.nii'],1);
        wwf_appl_fieldmap_reappraisal_control_2023_jr(Pdmap_1{ix},Pfunc_cur,P3d{ix});
    end
end

% Visual control:
if 1==0
    for ix=1:3%size(P3d,2)
        [fdir, fname, ext]=fileparts(Pfunc_reappraisal{ix});
        Pfunc_cur1=spm_select('ExtFPList',fdir,['^despiked_del5_' fname '.nii'],1);
        Pfunc_cur2=spm_select('ExtFPList',fdir,['^udespiked_del5_' fname '.nii'],1);
        char_all=char([P3d(ix);Pfunc_cur1;Pfunc_cur2]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% --------------------- Realignment and Unwarping -----------------------%
% Registration to first image was recommended by Wolfgang:
% Control before running in do_unwarp_jr:
% 1. Select your preferred PB0map (vdm-map), e.g. ^vdm5_full_fpm_Z.*_spm2.img'
% 2. Choose registration to first or mean
% (matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm; 0=first; 1=mean).

if 1==0
    addpath(genpath('/home/jonathan.reinwald/MATLAB_jr/batches_jonathan_pwsi/'));
    addpath(genpath('/home/jonathan.reinwald/Programs/spm12'));
    for ix=1:size(Pdmap_1,2)
        % reappraisal
        Pcur=deblank(Pfunc_reappraisal{ix});
        [fdir, fname, ext]=fileparts(Pcur);
        Pfunc_cur=spm_select('ExtFPList',fdir,['^despiked_del5_' fname '.nii'],1);
        do_unwarp_jr(char(Pdmap_1(ix)),Pfunc_cur);
    end
end

% Visual control:
if 1==0
    for ix=1:size(P3d,2)
        Pdmap5=spm_select('ExtFPList',Pdmap_2{ix},['^vdm5_full_fpm_Z.*_spm2.img'],1);
        [fdir, fname, ext]=fileparts(Pfunc_reappraisal{ix});
        Pfunc_cur=spm_select('ExtFPList',fdir,['^u_del5_' fname '.nii'],1);
        Pfunc_cur3=spm_select('ExtFPList',fdir,['^u_del5_' fname '.nii'],str2num(Pfunc_reappraisal{ix}(end-3:end))-10);
        Pfunc_cur4=spm_select('ExtFPList',fdir,['^del5_' fname '.nii'],1);
        Pfunc_cur5=spm_select('ExtFPList',fdir,['^' fname '.nii'],str2num(Pfunc_reappraisal{ix}(end-3:end))-10);
        Pfunc_cur6=spm_select('ExtFPList',fdir,['^' fname '.nii'],1);
        char_all=char([P3d(ix);Pfunc_cur;Pfunc_cur3;Pfunc_cur4;Pfunc_cur5;Pfunc_cur6;Pdmap5]);
        spm_check_registration(char_all)
        input('weiter');
    end
end


% % % % % % % % % %% ------------------------ Checking of physio data ------------------------%
% % % % % % % % % if 1==0
% % % % % % % % %     % Reappraisal
% % % % % % % % %     if 1==0
% % % % % % % % %         mkdir([procdir filesep 'physiodiagnosis' filesep 'reappraisal'])
% % % % % % % % %         cd([procdir filesep 'physiodiagnosis' filesep 'reappraisal'])
% % % % % % % % %         for ix=1:size(Pfunc_reappraisal,2)
% % % % % % % % %             ndel_dummies=5;
% % % % % % % % %             [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
% % % % % % % % %             Pinput=spm_select('FPList',fpath, ['^u_del5.*' fname  '.nii']);
% % % % % % % % %             cc_check_physio_dummy(Pinput,Pphysio_reappraisal(ix,:),ndel_dummies)
% % % % % % % % %         end
% % % % % % % % %     end
% % % % % % % % %     % Resting-State
% % % % % % % % %     if 1==0
% % % % % % % % %         mkdir([procdir filesep 'physiodiagnosis' filesep 'rs'])
% % % % % % % % %         cd([procdir filesep 'physiodiagnosis' filesep 'rs'])
% % % % % % % % %         for ix=7%1:size(Pfunc_rs,2)
% % % % % % % % %             ndel_dummies=5;
% % % % % % % % %             [fpath, fname, ext]=fileparts(Pfunc_rs{ix});
% % % % % % % % %             Pinput=spm_select('FPList',fpath, ['^u_del5.*' fname  '.nii']);
% % % % % % % % %             cc_check_physio_dummy(Pinput,Pphysio_rs(ix,:),ndel_dummies)
% % % % % % % % %         end
% % % % % % % % %     end
% % % % % % % % % end
% % % % % % % % % 
% % % % % % % % % %% --------------------- AZTEC (Preparation and Run) ----------------------
% % % % % % % % % %------------------- loading the filter file ------------------------------
% % % % % % % % % % First run with std_filt and readout the borders for cardiac and
% % % % % % % % % % respiration data from the figures.
% % % % % % % % % 
% % % % % % % % % std_filt= [3 14 9 15];
% % % % % % % % % rsfilt = load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/physiodiagnosis/reappraisal/rs_filt_reappraisal.txt')
% % % % % % % % % 
% % % % % % % % % %--------------------------- physio script --------------------------------
% % % % % % % % % % Reappraisal
% % % % % % % % % if 1==0
% % % % % % % % %     cd([procdir filesep 'physiodiagnosis' filesep 'reappraisal'])
% % % % % % % % %     for ix=1:length(Pfunc_reappraisal)
% % % % % % % % %         filter=std_filt
% % % % % % % % %         filtnum=find(rsfilt(:,1)==ix);
% % % % % % % % %         if ~isempty(filtnum)
% % % % % % % % %             filter=rsfilt(filtnum,2:end);
% % % % % % % % %         else
% % % % % % % % %             filter=std_filt;
% % % % % % % % %         end
% % % % % % % % %         [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
% % % % % % % % %         Pinput=spm_select('FPList',fpath, ['^u_del5.*' fname  '.nii']);
% % % % % % % % %         [fpath, fname, ext]=fileparts(deblank(Pphysio_reappraisal(ix,:)));
% % % % % % % % %         Pphysio_input=fullfile(fpath,[fname '_rep' ext]);
% % % % % % % % %         do_script_physio(Pphysio_input,Pinput,filter)
% % % % % % % % %     end
% % % % % % % % % end
% % % % % % % % % 
% % % % % % % % % 
% % % % % % % % % rsfilt = load('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/physiodiagnosis/rs/rs_filt_rs.txt')
% % % % % % % % % 
% % % % % % % % % % Resting-State
% % % % % % % % % if 1==0
% % % % % % % % %     cd([procdir filesep 'physiodiagnosis' filesep 'rs'])
% % % % % % % % %     for ix=1:length(Pfunc_rs);
% % % % % % % % %         filter=std_filt
% % % % % % % % %         filtnum=find(rsfilt(:,1)==ix);
% % % % % % % % %         if ~isempty(filtnum)
% % % % % % % % %             filter=rsfilt(filtnum,2:end);
% % % % % % % % %         else
% % % % % % % % %             filter=std_filt;
% % % % % % % % %         end
% % % % % % % % %         [fpath, fname, ext]=fileparts(Pfunc_rs{ix});
% % % % % % % % %         Pinput=spm_select('FPList',fpath, ['^u_del5.*' fname  '.nii']);
% % % % % % % % %         [fpath, fname, ext]=fileparts(deblank(Pphysio_rs(ix,:)));
% % % % % % % % %         Pphysio_input=fullfile(fpath,[fname '_rep' ext]);
% % % % % % % % %         do_script_physio(Pphysio_input,Pinput,filter)
% % % % % % % % %     end
% % % % % % % % % end
% % % % % % % % % 
% % % % % % % % % if 1==0
% % % % % % % % %     cd([procdir filesep 'physiodiagnosis' filesep 'reappraisal'])
% % % % % % % % %     rb_print_physio_ffts_jr(Pfunc_reappraisal,Pphysio_reappraisal,'physio_overview_repaired')
% % % % % % % % % end;
% % % % % % % % % 
% % % % % % % % % if 1==0
% % % % % % % % %     cd([procdir filesep 'physiodiagnosis' filesep 'rs'])
% % % % % % % % %     rb_print_physio_ffts_jr(Pfunc_rs,Pphysio_rs,'physio_overview_repaired')
% % % % % % % % % end;
% % % % % % % % % 
% % % % % % % % % % ------------------------------ AZTEC -----------------------------------%
% % % % % % % % % if 1==0
% % % % % % % % %     for ix=1:length(Pfunc_reappraisal)
% % % % % % % % %         % Reappraisal
% % % % % % % % %         [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
% % % % % % % % %         Pcur=spm_select('ExtFPList',fpath,['^u_del5.*' fname  '.nii'],1);
% % % % % % % % %         do_aztec_awake_jr(Pcur);
% % % % % % % % %         % Resting-State
% % % % % % % % %         [fpath, fname, ext]=fileparts(Pfunc_rs{ix});
% % % % % % % % %         Pcur=spm_select('ExtFPList',fpath,['^u_del5.*' fname  '.nii'],1);
% % % % % % % % %         do_aztec_awake_jr(Pcur);
% % % % % % % % %     end
% % % % % % % % % end
% % % % % % % % % 
% % % % % % % % % %% ---------------- Preliminary Motiondiagnosis ------------------------- %
% % % % % % % % % threshold=0.05;
% % % % % % % % % if 1==0
% % % % % % % % %     for ix=1:size(Pfunc_reappraisal,2)
% % % % % % % % %         [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
% % % % % % % % %         rp=spm_load(spm_select('FPList',fpath,'^rp_despiked_del.*')) ;
% % % % % % % % %         % detrending
% % % % % % % % %         for i=1:size(rp,2)
% % % % % % % % %             [p,s,mu]=polyfit(1:size(rp,1),rp(:,i)',2);
% % % % % % % % %             tr=polyval(p,1:size(rp,1),[],mu);
% % % % % % % % %             rp(:,i)=rp(:,i)-tr';
% % % % % % % % %         end
% % % % % % % % %         [FD] = SNiP_framewise_displacement(rp);
% % % % % % % % %         figure;
% % % % % % % % %         plot([(FD)]);hold on; plot(repmat(mean(FD),size(FD)),'-k');
% % % % % % % % %         xlimv=get(gca,'xlim');
% % % % % % % % %         plot(repmat(threshold,size(FD)),'--k'),xlim(xlimv),ylim([0 3]);
% % % % % % % % %         plot(repmat(0.05,size(FD)),'--k');
% % % % % % % % %         set(gca,'ytick',([min(ylim):0.5:max(ylim)]),'fontsize',6);
% % % % % % % % %         ylabel('FD (mm)');
% % % % % % % % %         print('-dpsc',fullfile([procdir filesep 'motiondiagnosis'],'FWD.ps') ,'-r400','-append')
% % % % % % % % %         close(figure(10));
% % % % % % % % %         FD_mean(ix)=mean(FD);
% % % % % % % % %     end;
% % % % % % % % % end;

%% ---------------------- Slice-time correction ------------------------- %
if 1==1
    for ix=1:size(Pfunc_reappraisal,2)
        [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
        Pcur=spm_select('ExtFPList',fpath,['^u_despiked_del5_.*' fname  '.nii'],1);
        do_slice_time_reappraisal_jr(Pcur);
    end
end

% Visual control:
if 1==0
    for ix=1:size(P3d,2)
        [fpath fname ext]=fileparts(Pfunc_reappraisal{ix});
        Pfunc_cur=spm_select('ExtFPList',fpath,['^u_del5_.*' fname  '.nii'],str2num(Pfunc_reappraisal{ix}(end-3:end))-5);
        Pfdm=spm_select('ExtFPList',Pdmap{ix},['^ZI_.*.acq0_reorient_c2.nii'],1);
        char_all=char([Pfunc_cur;Pfunc_reappraisal(ix);P3d(ix);Pfdm]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ----------------- Coregistration of Func to 3D ------------------------%
%% LEFT OUT:
%% - except for animal ZI_M230906D
% E.g. if func and 3d are not completely in the same position (which is
% quite often the case in this dataset), this coregistration will help
% bringing them to the same position using NMI
if 1==0
    spm fmri
    for ix=[];%1:size(P3d,2)
        [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
        Pfunc_cur=spm_select('ExtFPList',fpath,['^a1_u_despiked_del5_.*' fname  '.nii'],1);
        do_coreg_func23d_lw(P3d{ix},Pfunc_cur)
    end
end

% Visual control
if 1==0
    for ix=1:size(Pfunc_reappraisal,2)
        [fpath fname ext]=fileparts(Pfunc_reappraisal{ix});
        Pfunc_old=spm_select('ExtFPList',fpath,['^a1_u_del5_.*' fname  '.nii'],1);
        Pfunc_cur=spm_select('ExtFPList',fpath,['^a1_u_del5_.*' fname  '_c1.nii'],1);
        Pfunc_cur1=spm_select('ExtFPList',fpath,['^a1_u_del5_.*' fname  '_c1.nii'],str2num(Pfunc_reappraisal{ix}(end-3:end))-5);
        char_all=char([Pfunc_old;Pfunc_cur;P3d(ix);Pfunc_cur1]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ----------------------- 3D Brain Extraction -------------------------- %
if 1==0
    for ix=1:size(P3d,2)
        Pcur=deblank(P3d{ix});
        [fdir fname ext]=fileparts(Pcur);
        Pex=spm_select('FPList',fdir,['^' fname '.nii']);
%         ms_PCNN3D_v2(Pex,[350, 600]*1000);
        BrainSizeLimits = [350,650]*1000;
        ms_do_brainExtraction(Pex,BrainSizeLimits)
    end
end

% Visual control and correction by choosing a more accurate iteration use ms_gui_checkBrainMasks.m
if 1==0
    spm fmri
    ms_gui_checkBrainMasks
end

%visual control:
if 1==0
    for ix=1:size(P3d,2)
        [fpath fname ext]=fileparts(P3d{ix});
        P3d_brain=spm_select('ExtFPList',fpath,['^ZI_.*._brain.nii'],1);
        char_all=char([P3d(ix);P3d_brain]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% --------------- Shifting of 3D and Func onto the template ------------ %
% Shift image to make coregistration (to temp) work (needs overlap).
% Brain extracted 3d is used in do_shift_auto_brain.
if 1==0
    for ix=1:size(Pfunc_reappraisal,2)
        [fpath,fname,~]=fileparts(Pfunc_reappraisal{ix});
        Pcur1=spm_select('FPlist',fpath,['^a1_u_despiked_del5_' fname '.nii']);
        Pcur2=spm_select('FPlist',fpath,['^a1_u_del5_' fname '.nii']);
        [fpath,fname,~]=fileparts(P3d{ix});
        P3dcur=spm_select('FPlist',fpath,['^' fname '.nii$']);
        Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
        do_shift_auto_brain_TwoPfunc_jr(P3dcur,Pcur1,Pcur2,Ptemp);
    end
end

% Visual control:
if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:size(P3d,2)
        [fpath,fname,~]=fileparts(P3d{ix});
        P3d_coreg=spm_select('ExtFPlist',fpath,['^st_' fname '_brain.nii'],1); %prefix depends on norm!
        [fpath,fname,~]=fileparts(Pfunc_reappraisal{ix});
        Pfunc_coreg=spm_select('ExtFPList',fpath,['a1_u_del5_' fname '.nii'],1); %prefix depends on norm!
        Pfunc_coreg1=spm_select('ExtFPList',fpath,['st_a1_u_del5_' fname '.nii'],1); %prefix depends on norm!
        char_all=char([cellstr(Ptemp);cellstr(P3d_coreg);cellstr(Pfunc_coreg);cellstr(Pfunc_coreg1)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ------------ Coregistration of 3D and Func data to template ---------- %
if 1==0
    spm fmri
    addpath(genpath('/home/jonathan.reinwald/MATLAB_jr/batches_jonathan_TTA'))
    for ix=1:size(Pfunc_reappraisal,2)
        [fpath,fname,~]=fileparts(Pfunc_reappraisal{ix});
        Pcur=spm_select('ExtFPlist',fpath,['^st_a1_u_despiked_del5_' fname '.nii'],1);
        Pcur1=spm_select('ExtFPlist',fpath,['^st_a1_u_del5_' fname '.nii'],1);
        [fpath,fname,~]=fileparts(P3d{ix});
        P3dcur=spm_select('ExtFPlist',fpath,['^st_' fname '_brain.nii']);
        P3d_whole_cur=spm_select('FPlist',fpath,['^st_' fname '.nii']);
        Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
        
        do_coreg_all2temp_2func_jr(P3dcur,P3d_whole_cur,Pcur,Pcur1,Ptemp)
    end
end

% Visual control:
if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:size(P3d,2)
        
        [fpath,fname,~]=fileparts(P3d{ix});
        P3d_coreg=spm_select('ExtFPlist',fpath,['^st_' fname '_brain_c2t.nii'],1); %prefix depends on norm!
        
        [fpath,fname,~]=fileparts(Pfunc_reappraisal{ix});
        Pfunc_coreg=spm_select('ExtFPList',fpath,['^st_a1_u_del5_' fname '_c2t.nii'],1); %prefix depends on norm!
        
        [fpath,fname,~]=fileparts(Pfunc_reappraisal{ix});
        Pfunc_coreg1=spm_select('ExtFPList',fpath,['^st_a1_u_del5_' fname '.nii'],1); %prefix depends on norm!
        
        char_all=char([cellstr(Ptemp);cellstr(P3d_coreg);cellstr(Pfunc_coreg);cellstr(Pfunc_coreg1)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ------------------------ Bias Correction of 3D ----------------------- %

if 1==0
    for ix=1:size(P3d,2)
        [fdir,fname,~]=fileparts(P3d{ix});
        Porig=spm_select('FPList',fdir,['^st_' fname '_c2t.nii']);
        Pex=spm_select('FPList',fdir,['^st_' fname '_brain_c2t.nii']);
        wwf_do_bias_jr(Pex,Porig);
    end
end

% Visual control:
if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:size(P3d,2)
        
        [fpath,fname,~]=fileparts(P3d{ix});
        P3d_coreg=spm_select('ExtFPlist',fpath,['^bc_st_' fname '_c2t.nii'],1); %prefix depends on norm!
        [fpath, fname, ext]=fileparts(P3d{ix});
        P3d_coreg1=spm_select('ExtFPlist',fpath,['^st_' fname '_brain_c2t.nii'],1); %prefix depends on norm!
        
        char_all=char([cellstr(Ptemp);cellstr(P3d_coreg);cellstr(P3d_coreg1)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ---------------- Segmentation to create new template -------------------%
if 1==0
    templates={
        '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/02-TPM_Markus/sGM_template_markus_inPax_msk.nii'
        '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/02-TPM_Markus/sWM_template_markus_inPax_msk.nii'
        '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/02-TPM_Markus/sCSF_template_markus_inPax_msk.nii'
        '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/02-TPM_Markus/sBackground_template_markus_msk.nii'
        };
    for ix=1:size(P3d,2)
        [fpath fname ext]=fileparts(P3d{ix});
        Pcur=spm_select('ExtFPList',fpath,['^bc_st_' fname '_c2t.nii'],1);
        jr_do_segmentation(Pcur,templates);
    end
end

if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    Ptemp1='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/02-TPM_Markus/sGM_template_markus_inPax_msk.nii';
    for ix=21%:size(P3d,2)
        [fpath, fname, ~]=fileparts(P3d{ix});
        Pfdm=spm_select('ExtFPList',fpath,['^c1bc_st_' fname '_brain_c2t.nii'],1);
        Pfdm1=spm_select('ExtFPList',fpath,['^c1bc_st_' fname '_c2t.nii'],1);
        char_all=char([Ptemp1;Ptemp;cellstr(Pfdm);cellstr(Pfdm1)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ---------------- DARTEL - initial import -------------------------------%
% reslicing of the c1bc_*_c1.nii; c2bc_*_c1.nii; c3bc_*_c1.nii;
% input: bc_.*._c1_seg_sn.mat
% output: in defined folder --> rc1bc_*_c1.nii; rc2bc_*_c1.nii; rc3bc_*_c1.nii;

% create input Pcur list and Pdir
if 1==0
    clear Pcur
    counter=1;
    for ix=1:size(P3d,2)   
        if ix==2 || ix==9 || ix==12
            [fpath, fname, ~]=fileparts(P3d{ix});
            Pcur{counter}=spm_select('FPList',fpath,['^bc_st_' fname '_brain_c2t_seg_sn.mat']);
            counter=counter+1;
        else
            [fpath, fname, ~]=fileparts(P3d{ix});
            Pcur{counter}=spm_select('FPList',fpath,['^bc_st_' fname '_c2t_seg_sn.mat']);
            counter=counter+1;
        end
    end
end

Pdir='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/02-preprocessing/DARTEL/';
if 1==0
    [fpath, fname, ~]=fileparts(Pfunc_reappraisal{1});
    P=spm_select('FPlist',fpath,['^st_a1_u_despiked_del5_' fname '_c2t.nii']);
    V=spm_vol(P);
    [BB,vx] = spm_get_bbox(V);
    vox=2.65625;
    jr_do_DARTEL_inital_import(Pcur,Pdir,vox)
end

if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:size(P3d,2)
        [fpath, fname, ~]=fileparts(P3d{ix});
        Pfdm=spm_select('ExtFPList',fpath,['^c1bc_st_' fname '_c2t.nii'],1);
        Pfdm1=spm_select('ExtFPList',fpath,['^bc_st_' fname '_c2t.nii'],1);
        Pfdm2=spm_select('FPList','/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/02-preprocessing/DARTEL/',['^rc1bc_st_' fname '_c2t.nii']);
        char_all=char(['/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/02-TPM_Markus/sGM_template_markus_inPax_msk.nii';cellstr(Pfdm);cellstr(Pfdm1);cellstr(Pfdm2);cellstr(Ptemp)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ---------------- Reslice of EPI to in-plane voxel size -----------------%
if 1==0
    spm fmri
    for ix=1:size(P3d,2)
        %% Pfunc reappraisal
        [fpath, fname, ~]=fileparts(Pfunc_reappraisal{ix});
        Pcur=spm_select('ExtFPlist',fpath,['^st_a1_u_del5_' fname '_c2t.nii'],1:16000);
        [~, fname, ext]=fileparts(P3d{ix});
        % Important: This is a reference image which was later created by
        % jr_do_DARTEL_inital_import.m with isotropic voxel-size
        Pref=spm_select('ExtFPlist','/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/02-preprocessing/DARTEL/',['^rc1bc_st_' fname '.*_c2t.nii'],1);
        Pinput=[cellstr(Pref);cellstr(Pcur)]
        do_reslice(Pinput,4);
    end
end

if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:size(Pfunc_reappraisal,2);
        [fpath fname ext]=fileparts(Pfunc_reappraisal{ix});
        Pcur_reappraisal1=spm_select('ExtFPlist',fpath,['^rst_a1_u_despiked_del5_' fname '_c2t.nii'],[1]);
        Pcur_reappraisal2=spm_select('ExtFPlist',fpath,['^rst_a1_u_despiked_del5_' fname '_c2t.nii'],[1545]);
        char_all=char([cellstr(Pcur_reappraisal1);cellstr(Pcur_reappraisal2);cellstr(Ptemp)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end


%% --------------- DARTEL - Run DARTEL (create Templates)------------------%
% create templates as a mean of all input files and the u_* files with the
% information about warping
% input: all rc1coreg_st5_*.nii and all rc2coreg_st5_*.nii;
% output: in Pwdir u_rc1coreg_st5_*.ni, template_1.nii to template_6.nii;

if 1==0
    clear Pcur1 Pcur2
    Pwdir='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/02-preprocessing/DARTEL/';
    Pcur1=spm_select('ExtFPList',Pwdir,['^rc1bc_st_.*_c2t.nii'],1);
    Pcur2=spm_select('ExtFPList',Pwdir,['^rc2bc_st_.*_c2t.nii'],1);
    jr_do_DARTEL_create_templates(Pcur1,Pcur2);
end

%% --------------- DARTEL - Normalize to MNI (3D) ------------------------%
% Idea: normalization of our template_6.nii to atlas template and warping
% of our inputs using the information from the flowfields (corresponding to
% the old warping)
% CAVE: spm_dartel_norm_fun_***_jr uses our template information --> be sure to
% have the correct one (rat/mouse)

% Output:
% modulated: smwc1bc_.*._c1.nii, smwc2bc_.*._c1.nii, smwc3bc_.*._c1.nii
% only warped: swc1bc_.*._c1.nii, swc2bc_.*._c1.nii, swc3bc_.*._c1.nii

if 1==0
    for ix = 1:size(P3d,2)
        clear job
        [fpath, fname, ext]=fileparts(P3d{ix});
        job.template = {'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/02-preprocessing/DARTEL/Template_6.nii'};
        job.data.subj.flowfield = { spm_select('FPlist','/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/02-preprocessing/DARTEL/',['^u_rc1bc_st_' fname '.*_c2t_Template.nii'])};
        if ix==2 || ix==9 || ix==12
            job.data.subj.images = {
                spm_select('FPlist',fpath,['^c1bc_st_' fname '_brain_c2t.nii'])...
                spm_select('FPlist',fpath,['^c2bc_st_' fname '_brain_c2t.nii'])...
                spm_select('FPlist',fpath,['^c3bc_st_' fname '_brain_c2t.nii'])...
                spm_select('FPlist',fpath,['^bc_st_' fname '_c2t.nii'])...
                };
        else        
            job.data.subj.images = {
                spm_select('FPlist',fpath,['^c1bc_st_' fname '_c2t.nii'])...
                spm_select('FPlist',fpath,['^c2bc_st_' fname '_c2t.nii'])...
                spm_select('FPlist',fpath,['^c3bc_st_' fname '_c2t.nii'])...
                spm_select('FPlist',fpath,['^bc_st_' fname '_c2t.nii'])...
                };
        end
        job.vox = [NaN NaN NaN];
        job.bb = [NaN NaN NaN; NaN NaN NaN];
        job.fwhm = [0 0 0];
        for jx=[0,1]
            job.preserve = jx;
            spm_dartel_norm_fun_mice_jr(job);
        end
    end
end


%% -------------- DARTEL - Normalize to MNI ----------------------------- %
% Idea: normalization of our template_6.nii to atlas template and warping
% of our inputs using the information from the flowfields (corresponding to
% the old warping)
% CAVE: spm_dartel_norm_fun_***_jr uses our template information --> be sure to
% have the correct one (rat/mouse)

% Output:
% modulated: smwc1bc_.*._c1.nii, smwc2bc_.*._c1.nii, smwc3bc_.*._c1.nii
% only warped: swc1bc_.*._c1.nii, swc2bc_.*._c1.nii, swc3bc_.*._c1.nii

if 1==0
    for ix = 1:length(Pfunc_reappraisal)
        %% Reappraisal
        clear job
        [fpath, fname, ext]=fileparts(P3d{ix});
        job.template = {'/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/02-preprocessing/DARTEL/Template_6.nii'};
        job.data.subj.flowfield = { spm_select('FPlist','/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/02-preprocessing/DARTEL/',['^u_rc1bc_st_' fname '.*_c2t_Template.nii'])};
        [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
        clear input_images
        input_images = {...
            spm_select('FPlist',fpath,['^rst_a1_u_del5_' fname '.*_c2t.nii']);...
            };
        P=spm_select('FPlist',fpath,['^rst_a1_u_del5_' fname '.*_c2t.nii']);...
            V=spm_vol(P);
        [BB,vx] = spm_get_bbox(V);
        
        job.data.subj.images = cellstr(input_images{1});
        job.vox = [NaN NaN NaN];
        job.bb = [NaN NaN NaN; NaN NaN NaN];
        job.fwhm = [0 0 0];
        job.preserve = 0;
        spm_dartel_norm_fun_mice_jr(job);
    end
end

if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix= 1:size(Pfunc_reappraisal,2)
        [fpath,fname,~]=fileparts(Pfunc_reappraisal{ix});
        Pcur_reappraisal1=spm_select('ExtFPlist',fpath,['^wrst_a1_u_despiked_del5_' fname '_c2t.nii'],[1]);
        Pcur_reappraisal2=spm_select('ExtFPlist',fpath,['^wrst_a1_u_despiked_del5_' fname '_c2t.nii'],[1545]);
        Pcur_reappraisal3=spm_select('ExtFPlist',fpath,['^rst_a1_u_despiked_del5_' fname '_c2t.nii'],[1]);
        [fpath,fname,~]=fileparts(P3d{ix});
        P3d1=spm_select('ExtFPlist',fpath,['^wbc_st_' fname '_c2t.nii'],[1]);
        P3d2=spm_select('ExtFPlist',fpath,['^bc_st_' fname '_c2t.nii'],[1]);
        P3d3=spm_select('ExtFPlist',fpath,['^wc1bc_st_' fname '_c2t.nii'],[1]);
        char_all=char([cellstr(Ptemp);P3d1;cellstr(Pcur_reappraisal1);cellstr(Pcur_reappraisal2);cellstr(Pcur_reappraisal3);P3d2;P3d3]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% OPTIONAL: CSF filtering and Regression of realignment parameters ----- %
% CSF filtering and regression of realign parameters, depending on the
% selection also with global signal regression or derivatives of the
% realignment parameters
% Prefix: regfilt_
% Regression of realignment parameters/CSF/derivatives...
if 1==0
    for ix=1:size(Pfunc_reappraisal,2)
        Pmask='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6_polished.nii';
        %% Reappraisal
        [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
        Pfunc_cur=spm_select('FPlist',fpath,['^wrst_a1_u_despiked_del5_' fname '_c2t.nii$']);
        [fpath, fname, ext]=fileparts(P3d{ix});
        if ix==2 || ix==9 || ix==12
            P3d_csf=spm_select('FPlist',fpath,['^wc3bc_st_' fname '_brain_c2t.nii$']);
            P_GM_mask=spm_select('FPlist',fpath,['^wc1bc_st_' fname '_brain_c2t.nii$']);
        else        
            P3d_csf=spm_select('FPlist',fpath,['^wc3bc_st_' fname '_c2t.nii$']);
            P_GM_mask=spm_select('FPlist',fpath,['^wc1bc_st_' fname '_c2t.nii$']);
        end
        qmcsf=0.9;
        execution=0;
        acl_regfilt_motcsf_awake_despiked_jr(Pfunc_cur,P3d_csf,P_GM_mask,Pmask,qmcsf,execution);
    end
end

%% ---------------------- Visual Check CSF_reg.---------------------------------- %
if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=17:size(P3d,2)
        
        [fpath, fname, ext]=fileparts(P3d{ix});
        P3d_norm=spm_select('ExtFPlist',fpath,['^wbc_st_' fname '_c2t.nii'],1);
        
        [fpath fname ext]=fileparts(Pfunc_reappraisal{ix});
        Pfunc_norm=spm_select('ExtFPList',fpath,['^wrst_a1_u_despiked_del5_' fname '_c2t.nii'],1);
          
        Pcsf_mask=spm_select('ExtFPList',fpath,'CSFreg.nii',1);
        
        char_all=char([cellstr(Ptemp);cellstr(P3d_norm);cellstr(Pfunc_norm); cellstr(Pcsf_mask)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ---------------- Motion assessment: 2nd realignment ------------------ %
if 1==0
    for ix=1:size(Pfunc_reappraisal,2)
        %% Reappraisal
        [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
        Pfunc_cur=spm_select('FPlist',fpath,['^wrst_a1_u_del5_' fname '_c1_c2t.nii$']);
        do_realign_est(Pfunc_cur);
        %% Resting-State
        [fpath, fname, ext]=fileparts(Pfunc_rs{ix});
        Pfunc_cur=spm_select('FPlist',fpath,['^wrst_a1_u_del5_' fname '_c1_c2t.nii$']);
        do_realign_est(Pfunc_cur);
    end
end

%% ---------------------- Motion Regressors ----------------------------- %
% creates a multiple regressor including standard rps, its derivatives,
% shifted derivatives -2, -1, +1 (for first level)

if 1==0
    for ix=1:size(Pfunc_reappraisal,2)
        %% Reappraisal
        [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
        rp=spm_load(spm_select('FPlist',fpath,'^rp_del5.*.txt'));
        rp_diff=[zeros(1,size(rp,2)); diff(rp)];
        rp_diff_minus2=[rp_diff([3:(str2num(Pfunc_reappraisal{ix}(end-3:end))-5)],:); zeros(2,size(rp_diff,2))];
        rp_diff_minus1=[rp_diff([2:(str2num(Pfunc_reappraisal{ix}(end-3:end))-5)],:); zeros(1,size(rp_diff,2))];
        rp_diff_plus1=[zeros(1,size(rp_diff,2));rp_diff([1:(str2num(Pfunc_reappraisal{ix}(end-3:end))-6)],:)];
        regressors_mot_der_shiftder_m2m1p1=[rp rp_diff rp_diff_minus2 rp_diff_minus1 rp_diff_plus1];
        dlmwrite(fullfile(fpath,strcat('regressors_mot_der_shiftder_m2m1p1.txt')),regressors_mot_der_shiftder_m2m1p1,'delimiter','\t','precision','%.6f')
        %% Resting-State
        [fpath, fname, ext]=fileparts(Pfunc_rs{ix});
        rp=spm_load(spm_select('FPlist',fpath,'^rp_del5.*.txt'));
        rp_diff=[zeros(1,size(rp,2)); diff(rp)];
        rp_diff_minus2=[rp_diff([3:(str2num(Pfunc_rs{ix}(end-3:end))-5)],:); zeros(2,size(rp_diff,2))];
        rp_diff_minus1=[rp_diff([2:(str2num(Pfunc_rs{ix}(end-3:end))-5)],:); zeros(1,size(rp_diff,2))];
        rp_diff_plus1=[zeros(1,size(rp_diff,2));rp_diff([1:(str2num(Pfunc_rs{ix}(end-3:end))-6)],:)];
        regressors_mot_der_shiftder_m2m1p1=[rp rp_diff rp_diff_minus2 rp_diff_minus1 rp_diff_plus1];
        dlmwrite(fullfile(fpath,strcat('regressors_mot_der_shiftder_m2m1p1.txt')),regressors_mot_der_shiftder_m2m1p1,'delimiter','\t','precision','%.6f')
    end
end

%% ------------ Create mask of DARTEL templates ------------------------- %
if 1==0
    P_template='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/Template_6.nii';
    master_create_mask_of_DARTELtemplate(P_template);
end

%% ------------ Motiondiagnosis Alex: DVARS and plots ------------------- %
if 1==0
    motiondir=[procdir filesep 'motiondiagnosis'];
    mkdir(motiondir);
    
    for ix=1:size(Pfunc_reappraisal,2);
        %% Reappraisal
        [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
        %                 EPI=spm_select('ExtFPlist',[fpath filesep 'wavelet'],['^wave_10cons_med1000_msk_s6_wrst_a1_u_del5_' fname '_c1_c2t_wds.nii']);
        EPI=spm_select('ExtFPlist',fpath,['^msk_s6_wrst_a1_u_del5_' fname '_c1_c2t.nii']);
        thres=0.10;
        mask='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6_polished.nii';
        outputdir=motiondir;
        acl_motiondiagnosis_jr_lw(EPI,thres,mask,outputdir,fname);
        %FD_all(:,ix)=FD>thres;
    end
end

%% --------- Smoothing (without band-pass filtering afterwards) ----------%
if 1==0
    for ix=1:size(Pfunc_reappraisal,2)
        %% Reappraisal
        [fpath fname ext]=fileparts(Pfunc_reappraisal{ix});
        Pcur=spm_select('ExtFPList',fpath,['^wrst_a1_u_del5_' fname '_c2t.nii$'],1);
        fwhm_cur=[6 6 6];
        do_smooth_lw(Pcur,fwhm_cur);
    end
end

%% ---------------------- Visual Check ---------------------------------- %
if 1==0
    Ptemp='/home/laurens.winkelmeier/Awake/helpers/atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:size(P3d,2);
        
        [fpath, fname, ext]=fileparts(P3d{ix});
        P3d_norm=spm_select('ExtFPlist',fpath,['^wbc_st_' fname '_brain_c2t.nii'],1);
        
        [fpath fname ext]=fileparts(Pfunc{ix});
        Pfunc_norm=spm_select('ExtFPList',fpath,['^wrst_a1_u_despiked_del5_' fname '_c1_c2t.nii'],1);
        
        Pfunc_smooth=spm_select('ExtFPList',fpath,['^s_wrst_a1_u_del5_' fname '_c1_c2t.nii'],1);
        
        
        char_all=char([cellstr(Ptemp);cellstr(P3d_norm);cellstr(Pfunc_norm); cellstr(Pfunc_smooth)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SCRUBBING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Scrubbing:
if 1==1
    addpath(genpath('/home/jonathan.reinwald/Programs/spm12/')); % if not marsbar makes problems
    for ix = 1:size(Pfunc_reappraisal,2)
        
        %% Load RP and calculate FD
        [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
        rp=spm_load(spm_select('FPList',fpath,'^rp_despiked_del.*')) ;
        
        % detrending
        for i=1:size(rp,2)
            [p,s,mu]=polyfit(1:size(rp,1),rp(:,i)',2);
            tr=polyval(p,1:size(rp,1),[],mu);
            rp(:,i)=rp(:,i)-tr';
        end
        
        % calculate FD
        [FD] = SNiP_framewise_displacement(rp); % includes devision by 10!
        
        % correct rp with factor 10
        rp_corr = [rp(:,1:3)./10,rp(:,4:6)];
        
        T=FD;
        threshold=0.10;
        method='lin';
        outpref='DVARSscrub_0';
        
        % for DVARS based scrubbing
        DVARS_dir='/home/jonathan.reinwald/ICON_Autonomouse/04-outputs/03-MRI/07-reappraisal_control_2023/01-preprocessing/01-motion/DVARS';
        load(fullfile(DVARS_dir,'DVARS_info.mat'),'DVARS_info');
        T=[0,DVARS_info.WD10_AFNI.DVARS_pvals(ix,:)<0.05]';
        
        [R,T,EPI]=scrubbing_jr(fpath,T,threshold,method,outpref);
        FD_all(ix,:) = FD;
        FD_toscrub(ix,:) = FD>threshold;
    end
    save('/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/02-preprocessing/motiondiagnosis/FD_despiked.mat','FD_all','FD_toscrub');
end


%% --------- Smoothing (without band-pass filtering afterwards) ----------%
if 1==0
    for ix=1:size(Pfunc_reappraisal,2)
        %% Reappraisal
        [fpath fname ext]=fileparts(Pfunc_reappraisal{ix});
        Pcur=spm_select('ExtFPList',fpath,['^wrst_a1_u_despiked_del5_' fname '_c2t.nii'],1);
        fwhm_cur=[6 6 6];
        do_smooth_lw(Pcur,fwhm_cur);
    end
end

%% -------------------- Wavelet Despiking ---------------------------------
%% -------------------- WD1: masking of EPIs ------------------------------
% Create folder for every animal and copy file to respective folder
if 1==1
    Pmask='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6_polished.nii';
    Vmask=spm_vol(Pmask);
    mask=spm_read_vols(Vmask);
    
    mask(isnan(mask))=0;
    for ix=1:size(Pfunc_reappraisal,2)
        %% Reappraisal
        if 1==1
            Pcur=deblank(Pfunc_reappraisal{ix});
            [fpath, fname, ext]=fileparts(Pcur);
            P=spm_select('ExtFPList',fpath,['^wrst_a1_u_despiked_del5_' fname '_c2t.nii'],[1:3000]);
            nimg=size(P,1);
            Vi=spm_vol(P);
            img_mtx=spm_read_vols(Vi);
            Vnew=Vi;
            for jx=1:nimg
                Vnew(jx).fname=[fpath '/msk_wrst_a1_u_despiked_del5_' fname '_c2t.nii']
                spm_write_vol(Vnew(jx),squeeze(img_mtx(:,:,:,jx)).*mask);
            end
        end
    end
end

%% -------------- WD2: Intensity Normalization to 1000 --------------------
% --> is this really necessary???
if 1==1
    for ix=1:size(Pfunc_reappraisal,2)
        %% Reappraisal
        [fpath fname ext]=fileparts(Pfunc_reappraisal{ix});
        Pfunccur=spm_select('FPlist',fpath,['^msk_wrst_a1_u_despiked_del5_' fname '_c2t.nii']);
        intensity_normalization_by100(Pfunccur);
% % %                 [fpath fname ext]=fileparts(Pfunc_reappraisal{ix});
% % %         Pfunccur=spm_select('FPlist',fpath,['^med1000new_msk_s6_wrst_a1_u_del5_' fname '_c2t.nii']);
% % %         V=spm_vol(Pfunccur);
% % %         img=spm_read_vols(V);
% % %         nullval(ix,1)=sum(sum(sum(sum(img<0))));        
% % %         Pfunccur=spm_select('FPlist',[fpath '/wavelet'],['^wave_10cons_med1000new_msk_s6_wrst_a1_u_del5_' fname '_c2t_wds.nii']);
% % %         V=spm_vol(Pfunccur);
% % %         img=spm_read_vols(V);
% % %         nullval(ix,2)=sum(sum(sum(sum(img<0))));
% % %         Pfunccur=spm_select('FPlist',[fpath '/wavelet'],['^wave_10cons_med1000_msk_s6_wrst_a1_u_del5_' fname '_c2t_wds.nii']);
% % %         V=spm_vol(Pfunccur);
% % %         img=spm_read_vols(V);
% % %         nullval(ix,3)=sum(sum(sum(sum(img<0))));
% % %         Pfunccur=spm_select('FPlist',[fpath '/wavelet'],['^wave_10cons_med1000new_msk_s6_wrst_a1_u_despiked_del5_' fname '_c2t_wds.nii']);
% % %         V=spm_vol(Pfunccur);
% % %         img=spm_read_vols(V);
% % %         nullval(ix,4)=sum(sum(sum(sum(img<0))));
% % %         Pfunccur=spm_select('FPlist',[fpath '/wavelet'],['^wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5_' fname '_c2t_wds.nii']);
% % %         V=spm_vol(Pfunccur);
% % %         img=spm_read_vols(V);
% % %         nullval(ix,5)=sum(sum(sum(sum(img<0))));
% % %         Pfunccur=spm_select('FPlist',fpath,['^med1000new_msk_s6_wrst_a1_u_despiked_del5_' fname '_c2t.nii']);
% % %         V=spm_vol(Pfunccur);
% % %         img=spm_read_vols(V);
    end
end



%% ---------------------- WD3: Actual WaveletDespiking --------------------
if 1==0
    % set path
    addpath(genpath('/home/jonathan.reinwald/ICON_Autonomouse/01-scripts/10-toolboxes/wavelet_despiking/'))
    
    for wdthresh=10%[10,20,30,50]%[30 50 70 100 20 40]
        parpool(5);
        parfor ix=1:size(Pfunc_reappraisal,2)
            %% Reappraisal
            [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
            newdir=[fpath '/wavelet/'];
            mkdir(newdir);
            cd(newdir)
            
            Pcur=spm_select('FpList', fpath , ['^med1000new_msk_wrst_a1_u_despiked_del5_' fname '_c2t.nii']);
            
            [fpath, fname, ext]=fileparts(Pcur);
            
            threshold = wdthresh;
            prefix = ['wave_' num2str(threshold) 'cons_'];
            WaveletDespike(Pcur,[prefix fname],'threshold',threshold,'chsearch','conservative','verbose',1,'LimitRAM',80);
            
            gunzip([newdir prefix fname '_wds.nii.gz']);
            delete([newdir prefix fname '_wds.nii.gz']);
            
            gunzip([newdir prefix fname '_noise.nii.gz']);
            delete([newdir prefix fname '_noise.nii.gz']);
            
            gunzip([newdir prefix fname '_EDOF.nii.gz']);
            delete([newdir prefix fname '_EDOF.nii.gz']);
        end
    end
end

%% --------- WD4: Smoothing (without band-pass filtering afterwards) ------
if 1==0
    for ix=1:size(Pfunc_reappraisal,2)
        %% Reappraisal
        [fpath fname ext]=fileparts(Pfunc_reappraisal{ix});
        Pcur=spm_select('ExtFPList',[fpath filesep 'wavelet/'],['^wave_10cons_med1000_msk_wrst_a1_u_del5_' fname '_c1_c2t_noise.nii$'],1);
        fwhm_cur=[6 6 12];
        do_smooth_lw(Pcur,fwhm_cur);
        %% Resting-State
        [fpath fname ext]=fileparts(Pfunc_rs{ix});
        Pcur=spm_select('ExtFPList',[fpath filesep 'wavelet/'],['^wave_30cons_med1000_msk_wrst_a1_u_del5_' fname '_c1_c2t_noise.nii$'],1);
        fwhm_cur=[6 6 12];
        do_smooth_lw(Pcur,fwhm_cur);
    end
end



%% --------- Smoothing (without band-pass filtering afterwards) ----------%
if 1==0
    for ix=1:size(Pfunc_reappraisal,2)
        %% Reappraisal
        [fpath fname ext]=fileparts(Pfunc_reappraisal{ix});
        Pcur=spm_select('ExtFPList',fpath,['^scrub_0_1_lin_med1000_msk_wrst_a1_u_del5_' fname '_c1_c2t.nii'],1);
        fwhm_cur=[6 6 12];
        do_smooth_lw(Pcur,fwhm_cur);
        %         %% Resting-State
        %         [fpath fname ext]=fileparts(Pfunc_rs{ix});
        %         Pcur=spm_select('ExtFPList',fpath,['^med1000_msk_wrst_a1_u_del5_' fname '_c1_c2t.nii'],1);
        %         fwhm_cur=[6 6 6];
        %         do_smooth_lw(Pcur,fwhm_cur);
    end
end






%% TEST DVARS
if 1==0
    for ix=1:size(Pfunc_reappraisal,2);
        outputdir='/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/motiondiagnosis'
        [fpath, fname, ext]=fileparts(P3d{ix});
        Pmask_GM=spm_select('ExtFPList',fpath,['^wc1bc_st_' fname '_c2t.nii'],1);
        Vmsk=spm_vol(Pmask_GM);
        mask_mtx=spm_read_vols(Vmsk);
        mask_mtx=mask_mtx>0.4;
        mask_mtx_size=size(mask_mtx);
        mask_mtx=reshape(mask_mtx,prod(mask_mtx_size(1:3)),1);
        
        [fpath, fname, ext]=fileparts(Pfunc_reappraisal{ix});
        EPI=spm_select('ExtFPlist',[fpath filesep 'wavelet'],['^wave_10cons_med1000_msk_s6_wrst_a1_u_despiked_del5_' fname '_c1_c2t_wds.nii'],[1:2000]);
        %         EPI=spm_select('ExtFPlist',[fpath],['^med1000_msk_s6_wrst_a1_u_despiked_del5_' fname '_c1_c2t.nii'],[1:2000]);
        %         EPI=spm_select('ExtFPlist',[fpath],['^med1000_msk_s6_scrub_0_1_lin_wrst_a1_u_del5_' fname '_c1_c2t.nii'],[1:2000]);
        %         EPI=spm_select('ExtFPlist',[fpath],['^med1000_msk_s6_regfilt_motcsfder_wrst_a1_u_del5_' fname '_c1_c2t.nii'],[1:2000]);
        V_EPI=spm_vol(EPI);
        mtx=spm_read_vols(V_EPI);
        mtxsz=size(mtx);
        
        MovPar=[spm_load(spm_select('FPList',fpath,'^rp_del5_Z.*.txt'))];
        MovPar=MovPar(:,1:6);
        
        mtx=reshape(mtx,prod(mtxsz(1:3)),prod(mtxsz(4)));
        
        mtxfunc=mtx(find(mask_mtx),:);
        
        [V{ix},Stat{ix}]=DSEvars(mtxfunc,'scale',1/100,'verbose',1);
        %[DVARS{ix},DVARS_Stat{ix}]=DVARSCalc(mtxfunc,'scale',1/100,'tail','both','VarType','hIQR','TestMethod','Z','TransPower',1/3,'RDVARS','verbose',1);
        [DVARS{ix},DVARS_Stat{ix}]=DVARSCalc(mtxfunc,'scale',1/100,'VarType','hIQR','TestMethod','X2','TransPower',1/3,'RDVARS','verbose',1);
        res{ix}=(DVARS_Stat{ix}.pvals<0.05./(mtxsz(4)-1));
        idx{ix}=find(DVARS_Stat{ix}.pvals<0.05./(mtxsz(4)-1));
        all_idx(ix,1)=numel(idx{ix});
        
        [FDts,FD_Stat]=FDCalc(MovPar);
        f_hdl=figure('position',[50,50,800,800]);
        
        fMRIDiag_plot_JR(V{ix},DVARS_Stat{ix},'Idx',idx{ix},'BOLD',mtxfunc,'FD',FDts/10,'AbsMov',[FD_Stat.AbsRot FD_Stat.AbsTrans],'figure',f_hdl);
        title(fname,'Interpreter','none')
        print('-dpsc',fullfile(outputdir,'DVARS_Nichols_FWD_X2.ps') ,'-r400','-append');
    end;
end






% for masked EPIS (csf ...)
if 1==0
    
    % define all thresholds you want to apply to data ...
    thresALL = [10 40 70];
    
    for tt = 1:numel(thresALL)
        
        for ix= [1 2 3 5 8] % first five entries array_valid_sessions ...
            [fpath, fname, ext]=fileparts(Pfunc{ix});
            newdir=[fpath '/wavelet_CSFmaskedEPIs/'];
            mkdir(newdir);
            cd(newdir)
            
            
            %fpath='/home/laurens.winkelmeier/awake/all_awake_MAIN/MRI/TEST_waveletDespiking/'
            
            
            Pcur=spm_select('FpList', fpath , ['^CSFmsk_wst_a_u_del5_' fname '_c1_c2t.nii']);
            
            [fpath, fname, ext]=fileparts(Pcur);
            
            threshold = thresALL(tt);
            prefix = ['wave_' num2str(threshold) '_'];
            WaveletDespike(Pcur,[prefix fname],'threshold',threshold);
            
            gunzip([newdir prefix fname '_wds.nii.gz']);
            delete([newdir prefix fname '_wds.nii.gz']);
            
            gunzip([newdir prefix fname '_noise.nii.gz']);
            delete([newdir prefix fname '_noise.nii.gz']);
            
            gunzip([newdir prefix fname '_EDOF.nii.gz']);
            delete([newdir prefix fname '_EDOF.nii.gz']);
            
        end
    end
    
end

