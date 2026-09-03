%% master_preprocessing_hrf_jr.m
% PREPROCESSING MOUSE DATA, PARAVISION 6 DIR-STRUCTURE

% Jonathan Reinwald 07/2021
% Main preprocessing script for fMRI data (EPIs and 3Ds) including:
% - path definition
% - pv-conversion
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

%% set MATLAB-path for script-folders and -subfolders
clear all
close all
clc

addpath(genpath('/home/jonathan.reinwald/ICON_HRF/01-scripts'))
addpath(genpath('/home/jonathan.reinwald/Programs/spm12'))

%% ------------------ Predefinition of pathes ----------------------------%

% Predefine main working directory
rawdir='/home/jonathan.reinwald/ICON_HRF/02-raw-data/01-MRI/01-fMRI_data';
procdir='/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing';
cd(procdir)

% Predefine path of scanlist
scans='/home/jonathan.reinwald/ICON_HRF/03-processed-data/03-filelists/scanlist_hrf_jr.csv';%path of scan list as a csv

% Predefine path for mouse brain atlas (3D and mask)
Ptemp='/home/jonathan.reinwald/ICON_HRF/10-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
Pmask='/home/jonathan.reinwald/ICON_HRF/10-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brainmask_rs1x1x1_polish.nii';

%% ------------------ Converting of original files -----------------------%
if 1==0
    % Reading of csv-file
    [subj_ID,subj_name,study,examn,series,image_comm]=textread(scans,'%s %s %s %s %u %s','delimiter',',','headerlines',1); % type
    
    % Gives you the unique animal-names (ZI_M...) based on the csv-file
    
    [regu,IA,IC]=unique(subj_ID);
    % Gives you the corresponding animal-number (PD..)
    subu=subj_name(IA);
end
% % CAVE: first unzip files
% % Unzipping will create folders named PDXX_NAME_...._PvDatasets_FILES, in
% % which the folder ZI_M... contains the files we're interested
% if 1==0
%     for ix=1:size(regu,1)
%         % find and copy folder in PD.._ZI_M_...._PvDatasets_FILES and
%         % copies it to the rawData folder
%         syscmd=['find ' studydir filesep 'rawData -type d -name ' regu{ix} '*' ' -exec cp -r ''{}'' ' studydir filesep 'rawData' ' \;'];
%         system(syscmd)
%     end;
% end;

% % % % set path for pvconv
% % % addpath(genpath('/home/jonathan.reinwald/ICON_HRF/01-scripts/01-toolboxes/postproc_v1.0_r987'))
% % %
% % % % Conversion of files using pvconv
% % % if 1==0
% % %     for ix=1:size(regu,1)
% % %         % makes dir with ZI_M.._PD.. in studydir
% % %         syscmd=['mkdir ' procdir filesep regu{ix}];
% % %         system(syscmd);
% % %         % real conversion of the data-files to niftis(.nii)/matfiles(.mat)/brukerheader(.brkhdr) in the dir we created the step before
% % %         do_pvconv_jr([rawdir filesep],[procdir filesep regu{ix}], regu{ix})       % pvconv will create SPM compatible files (.mat, .brkhdr, .nii ...); lw
% % %     end
% % % end

%% ------------------ 3D, FM, EPI READING FROM SCAN list -----------------%

% replace subsequent lines that are absolute identical by double
if 1==0
    for ix=1:(size(subj_ID,1)-1);
        if strcmp(deblank(char(examn(ix))),deblank(char(examn(ix+1))));
            examn{ix+1}='double';
            if strcmp(deblank(char(examn(ix))),deblank(char(examn(ix+2))));
                examn{ix+2}='triple';
                if strcmp(deblank(char(examn(ix))),deblank(char(examn(ix+3))));
                    examn{ix+3}='quadruple';
                end
            end
        end
    end
end

if 1==0
    path_all=spm_select('ExtFPListRec', procdir, '^ZI.*reorient.nii',1);
    path_all=cellstr(path_all);
    
    for jscan=1:size(subj_ID,1)                                                                           % strcmp -> contains; 171216; strcmp for EPIs due to EPI tests in the scan list
        episcan(jscan)=strcmp(deblank(char(examn(jscan))),'EPI paradigma (E5)');                                % strcmp goes through examination column, each cell with input 'EPI 1300' gets the logical 1% strcmp goes through examination column, each cell with input 'EPI 1300' gets the logical 1
        scan3d(jscan)=contains(deblank(char(examn(jscan))),'TurboRARE3D_Awake_biggerFOV (E6)');
        fmapscan(jscan)=strcmp(deblank(char(examn(jscan))),'Fieldmap (E4)');
    end
    
    epiind=find(episcan);                                                                               % returns a vector containing the linear indices of each nonzero element in array episcan; lw
    for jepi=1:numel(epiind)
        indc=regexp(path_all,[char(subj_ID(epiind(jepi))),'.*/', num2str(series(epiind(jepi))),'/']);
        for jscan=1:size(indc,1)
            if ~isempty(indc{jscan})
                Pfunc(jepi)=path_all(jscan);                                                            %Pfunc contains the pathes of the EPIs; lw
                Pfunc_subjName(jepi)=subj_name(epiind(jepi));                                                            %Pfunc contains the pathes of the EPIs; lw
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
    
    fmapind=find(fmapscan);
    for jmap=1:numel(fmapind)
        indc=regexp(path_all,[char(subj_ID(fmapind(jmap))),'.*/', num2str(series(fmapind(jmap))),'/Z']);  %%% CAVE: Z is added to not find the file in the folder p2
        for jscan=1:size(indc,1)
            if ~isempty(indc{jscan})
                [path, file, ext]=fileparts(char(path_all(jscan)));
                Pdmap{jmap}=path; %Pmap{jmap}=path_all(jscan);
            end
        end
    end
    
    save('/home/jonathan.reinwald/ICON_HRF/03-processed-data/03-filelists/filelist_ICON_hrf_jr.mat','P3d','Pdmap','Pfunc','Pfunc_subjName')
end

%% -------------------- Load filelist ------------------------------------%

%% set MATLAB-path for script-folders and -subfolders
%
if 1==1
    load('/home/jonathan.reinwald/ICON_HRF/03-processed-data/03-filelists/filelist_ICON_hrf_jr.mat','P3d','Pdmap','Pfunc','Pfunc_subjName')
end

%% -------------------- Correct fieldmaps for left/right  ----------------%
% Fieldmaps sometimes show left-right shift in the position which is
% corrected by wwf_correct_fm_pos.m
if 1==0
    for ix=1:size(Pdmap,2)
        wwf_correct_fm_pos(Pdmap{ix});
    end
end


%% -------------------- Check Scans for matching position ----------------%
% if scans are not in the same position, e.g. because between EPI and 3D
% the animal was moved, use coregister (estimate) to get them into the same
% position CAVE: be sure to do this for all ... EPI volumes

if 1==0
    spm fmri
    for ix=1:size(Pfunc,2)
        [fpath fname ext]=fileparts(Pfunc{ix});
        Pfunc_cur=spm_select('ExtFPList',fpath,['^ZI_.*._reorient.nii'],1);
        Pfunc_cur1=spm_select('ExtFPList',fpath,['^ZI_.*._reorient.nii'],400);
        fdir=Pdmap{ix};
        Pfdm=spm_select('ExtFPList',fdir,['^ZI_.*.acq0_reorient_cf.nii'],1);
        Pfdm2=spm_select('ExtFPList',[fdir filesep 'p2'],['^ZI_.*.acq0_reorient_cf.nii'],1);
        char_all=char([Pfunc_cur;Pfunc_cur1;P3d(ix);Pfdm;Pfdm2]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% --------------- Delete first scans (not enough dummies) ---------------%

% Objective: Deletion of first scans (if necessary) since scanner needs
% time to reach equilibrium.
if 1==0
    % Show mean tc without deletion to judge quality
    if 1==1
        syscmd=['mkdir data_cor_hist'];
        system(syscmd);
        cd('data_cor_hist')%lw
        for ix=1:size(Pfunc,2)
            wwf_voxcor_lw(Pfunc{ix},'cor_hist',0.265); % TR = 1.3;
        end
        cd(procdir)
    end
    
    % Deletion of first 5 scans:
    if 1==1
        for ix=1:size(Pfunc,2);
            Pcur=deblank(Pfunc{ix});
            [fdir, fname, ext]=fileparts(Pcur);
            Pdo=spm_select('ExtFPList',fdir,['^' fname '.nii'],1);
            wwf_del_vol(Pdo,25);
        end
    end
    
    % Show corrected mean tc after deletion of dummies
    if 1==1
        syscmd=['mkdir data_cor_hist_del25'];
        system(syscmd);
        cd('data_cor_hist_del25')%lw
        
        for ix=1:size(Pfunc,2);
            [fdir, fname, ext]=fileparts(Pfunc{ix});
            Pcur=[fdir filesep 'del25_' fname ext];
            wwf_voxcor_lw(Pcur,'cor_hist_del25',1.2);
        end
        cd(procdir)
    end
end

% Visual control:
if 1==0
    for ix=1:size(P3d,2);
        [fdir, fname, ext]=fileparts(Pfunc{ix});
        Pfunc_cur=spm_select('ExtFPList',fdir,['^del25_' fname '.nii'],1);
        Pfunc_cur1=spm_select('ExtFPList',fdir,['^del25_' fname '.nii'],str2num(Pfunc{ix}(end-3:end))-5);
        char_all=char([P3d(ix);Pfunc_cur;Pfunc_cur1]);
        spm_check_registration(char_all)
        input('weiter');
    end
end


%% ------------------------ Fieldmap Correction --------------------------%
%-------------------- Fieldmap "Filling" and "Masking" -------------------%
% - fieldmap_2 is used
% - preparation of the FM including dilation and filling of empty voxels
if 1==0
    for ix=1:size(Pdmap,2)
        % Creation of fpm_.._acq0_reorient_spm2.img
        wwf_FieldMap_miceCF_jr(Pdmap{ix});
        % Dilatation of fieldmap and filling of empty voxels in the edges of the fieldmap
        fdir=Pdmap{ix};
        clear Pfm
        Pfm=spm_select('FPList',fdir,['^fpm_ZI.*._acq0_reorient_cf_spm2.img']);
        fieldmap_fill_dilate_jr(Pfm);
        clear Pfm
    end
end

% first application of fieldmap (only on first image) to create u-file
if 1==0
    spm fmri
    for ix=1:size(Pdmap,2)
        % Application on social_defeat data
        [fdir, fname, ext]=fileparts(Pfunc{ix});
        Pfunc_cur=spm_select('ExtFPList',fdir,['^del25_' fname '.nii'],1);
        wwf_appl_fieldmapCF(Pdmap{ix},Pfunc_cur,P3d{ix});
    end
end

% Visual control:
if 1==0
    for ix=1:size(P3d,2);
        [fdir, fname, ext]=fileparts(Pfunc{ix});
        Pfunc_cur=spm_select('ExtFPList',fdir,['^del25_' fname '.nii'],1);
        Pfunc_cur1=spm_select('ExtFPList',fdir,['^udel25_' fname '.nii'],1);
        char_all=char([Pfunc_cur;Pfunc_cur1;P3d(ix)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end


%% --------------------- Realignment and Unwarping -----------------------%
% % % % Realignment changes the del-files, therefore I save the del-files as
% % % % "orig_del" before realignment and unwarping.
% % % if 1==0;
% % %     for ix=1:size(Pdmap_2,2);
% % %         Pcur=deblank(Pfunc{ix});
% % %         [fdir, fname, ext]=fileparts(Pcur);
% % %         cd(fdir);
% % %         %         Pcur3=(['del25_' fname '.mat']);
% % %         %         syscmd=['rm ' Pcur3];
% % %         %         system(syscmd);
% % %         Pcur1=(['del25_' fname '.nii']);
% % %         Pcur2=(['orig_del25_' fname '.nii']);
% % %         syscmd=['cp ' Pcur1 ' ' Pcur2 ]
% % %         %alternativly: ['find -name ' Pcur1 ' -exec cp {} ' Pcur2 ' \;'];
% % %         system(syscmd)
% % %     end
% % % end

% Registration to first image was recommended by Wolfgang:
% Control before running in do_unwarp_jr:
% 1. Select your preferred PB0map (vdm-map), e.g. ^vdm5_full_fpm_Z.*_spm2.img'
% 2. Choose registration to first or mean
% (matlabbatch{1}.spm.spatial.realignunwarp.eoptions.rtm; 0=first; 1=mean).

if 1==0
    for ix=1:size(Pdmap,2);
        % social_defeat
        Pcur=deblank(Pfunc{ix});
        [fdir, fname, ext]=fileparts(Pcur);
        Pfunc_cur=spm_select('ExtFPList',fdir,['^del25_' fname '.nii'],1);
        do_unwarp_jr(char(Pdmap(ix)),Pfunc_cur);
    end
end

% Visual control:
if 1==0
    for ix=1:size(P3d,2);
        Pdmap5=spm_select('ExtFPList',Pdmap{ix},['^vdm5_full_fpm_Z.*_cf_spm2.img'],1);
        [fdir, fname, ext]=fileparts(Pfunc{ix});
        Pfunc_cur=spm_select('ExtFPList',fdir,['^u_del25_' fname '.nii'],1);
        Pfunc_cur3=spm_select('ExtFPList',fdir,['^u_del25_' fname '.nii'],str2num(Pfunc{ix}(end-3:end))-10);
        Pfunc_cur4=spm_select('ExtFPList',fdir,['^del25_' fname '.nii'],1);
        Pfunc_cur5=spm_select('ExtFPList',fdir,['^' fname '.nii'],str2num(Pfunc{ix}(end-3:end))-10);
        Pfunc_cur6=spm_select('ExtFPList',fdir,['^' fname '.nii'],1);
        char_all=char([P3d(ix);Pfunc_cur;Pfunc_cur3;Pfunc_cur4;Pfunc_cur5;Pfunc_cur6;Pdmap5]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ---------------- Preliminary Motiondiagnosis ------------------------- %
threshold=0.05;
if 1==0
    for ix=1:size(Pfunc,2)
        [fpath, fname, ext]=fileparts(Pfunc{ix});
        rp=spm_load(spm_select('FPList',fpath,'^rp_del.*')) ;
        % detrending
        for i=1:size(rp,2)
            [p,s,mu]=polyfit(1:size(rp,1),rp(:,i)',2);
            tr=polyval(p,1:size(rp,1),[],mu);
            rp(:,i)=rp(:,i)-tr';
        end
        [FD] = SNiP_framewise_displacement(rp);
        figure;
        plot([(FD)]);hold on; plot(repmat(mean(FD),size(FD)),'-k');
        xlimv=get(gca,'xlim');
        plot(repmat(threshold,size(FD)),'--k'),xlim(xlimv),ylim([0 3]);
        plot(repmat(0.05,size(FD)),'--k');
        set(gca,'ytick',([min(ylim):0.5:max(ylim)]),'fontsize',6);
        ylabel('FD (mm)');
        mkdir(fullfile([procdir filesep 'motiondiagnosis']))
        print('-dpsc',fullfile([procdir filesep 'motiondiagnosis'],'FWD.ps') ,'-r400','-append')
        close(figure(10));
        FD_mean(ix)=mean(FD);
    end
end

%% ---------------------- Slice-time correction ------------------------- %
if 1==0
    for ix=1:size(Pfunc,2);
        [fpath, fname, ext]=fileparts(Pfunc{ix});
        Pcur=spm_select('ExtFPList',fpath,['^u_del25.*' fname  '.nii'],1);
        do_slice_time_hrf_jr(Pcur);
    end
end

% Visual control:
if 1==0
    for ix=1:size(P3d,2);
        [fpath fname ext]=fileparts(Pfunc{ix});
        Pfunc_cur=spm_select('ExtFPList',fpath,['^a1_u_del25_.*' fname  '.nii'],str2num(Pfunc{ix}(end-3:end))-5);
        Pfdm=spm_select('ExtFPList',Pdmap{ix},['^ZI_.*.acq0_reorient_cf.nii'],1);
        char_all=char([Pfunc_cur;Pfunc(ix);P3d(ix);Pfdm]);
        spm_check_registration(char_all)
        input('weiter');
    end
end


%% ------------------------ Bias Correction of 3D ----------------------- %

if 1==0
    for ix=1:size(P3d,2)
        [fdir fname ext]=fileparts(P3d{ix});
        Porig=spm_select('FPList',fdir,['^' fname '.nii']);
        Pex=spm_select('FPList',fdir,['^' fname '.nii']);
        wwf_do_bias_jr(Pex,Porig);
    end
end

%% ----------------------- 3D Brain Extraction -------------------------- %
if 1==0
    for ix=1:2%size(P3d,2)
        Pcur=deblank(P3d{ix});
        [fdir fname ext]=fileparts(Pcur);
        Pex=spm_select('FPList',fdir,['^bc_' fname '.nii']);
        ms_do_brainExtraction(Pex,[350, 600]*1000);
    end
end

% Visual control and correction by choosing a more accurate iteration use ms_gui_checkBrainMasks.m
if 1==0
    ms_gui_checkBrainMasks
end

%visual control:
if 1==0
    for ix=1:size(P3d,2);
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
    for ix=1:size(Pfunc,2);
        [fpath fname1 ext]=fileparts(Pfunc{ix});
        Pcur=spm_select('FPlist',fpath,['^a1_u_del25_' fname1 '.nii']);
        [fpath fname2 ext]=fileparts(P3d{ix});
        P3dcur=spm_select('FPlist',fpath,['^' fname2 '.nii$']);
        Ptemp='/home/jonathan.reinwald/ICON_HRF/10-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
        do_shift_auto_brain_jr_lw(P3dcur,Pcur,Ptemp);
    end
end

% Visual control:
if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_HRF/10-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:size(P3d,2);
        [fpath, fname, ext]=fileparts(P3d{ix});
        P3d_coreg=spm_select('ExtFPlist',fpath,['^st_' fname '_brain.nii'],1); %prefix depends on norm!
        [fpath fname ext]=fileparts(Pfunc{ix});
        Pfunc_coreg=spm_select('ExtFPList',fpath,['st_a1_u_del25_' fname '.nii'],1); %prefix depends on norm!
        char_all=char([cellstr(Ptemp);cellstr(P3d_coreg);cellstr(Pfunc_coreg)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ------------ Coregistration of 3D and Func data to template ---------- %
if 1==0
    for ix=1:size(Pfunc,2)
        [fpath, fname, ext]=fileparts(Pfunc{ix});
        Pcur=spm_select('ExtFPlist',fpath,['^st_a1_u_del25_' fname '.nii'],1);
        [fpath, fname, ext]=fileparts(P3d{ix});
        P3dcur=spm_select('ExtFPlist',fpath,['^st_' fname '_brain.nii']);
        P3d_whole_cur=spm_select('FPlist',fpath,['^st_' fname '.nii']);
        Ptemp='/home/jonathan.reinwald/ICON_HRF/10-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
        do_coreg_all2temp_pain_lw(P3dcur,P3d_whole_cur,Pcur,Ptemp)
    end
end

% Visual Control
if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_HRF/10-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:size(P3d,2)
        
        [fpath, fname, ext]=fileparts(P3d{ix});
        P3d_coreg=spm_select('ExtFPlist',fpath,['^st_' fname '_brain_c2t.nii'],1); %prefix depends on norm!
        
        [fpath fname ext]=fileparts(Pfunc{ix});
        Pfunc_coreg=spm_select('ExtFPList',fpath,['^st_a1_u_del25_' fname '_c2t.nii'],1); %prefix depends on norm!
        
        [fpath fname ext]=fileparts(Pfunc{ix});
        Pfunc_coreg1=spm_select('ExtFPList',fpath,['^st_a1_u_del25_' fname '_c2t.nii'],8175); %prefix depends on norm!
        
        char_all=char([cellstr(Ptemp);cellstr(P3d_coreg);cellstr(Pfunc_coreg);cellstr(Pfunc_coreg1)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ------------------------ Bias Correction of 3D ----------------------- %

if 1==0
    for ix=1:size(P3d,2)
        [fdir fname ext]=fileparts(P3d{ix});
        Porig=spm_select('FPList',fdir,['^st_' fname '_c2t.nii']);
        Pex=spm_select('FPList',fdir,['^st_' fname '_brain_c2t.nii']);
        wwf_do_bias_jr(Pex,Porig);
    end
end

%% ---------------- Segmentation to create new template -------------------%
if 1==0
    templates={
        '/home/jonathan.reinwald/ICON_HRF/10-helpers/02-TPM_Markus/sGM_template_markus_inPax_msk.nii'
        '/home/jonathan.reinwald/ICON_HRF/10-helpers/02-TPM_Markus/sWM_template_markus_inPax_msk.nii'
        '/home/jonathan.reinwald/ICON_HRF/10-helpers/02-TPM_Markus/sCSF_template_markus_inPax_msk.nii'
        '/home/jonathan.reinwald/ICON_HRF/10-helpers/02-TPM_Markus/sBackground_template_markus_msk.nii'
        };
    for ix=1:size(P3d,2);
        [fpath fname ext]=fileparts(P3d{ix});
        Pcur=spm_select('ExtFPList',fpath,['^bc_st_' fname '_c2t.nii'],1);
        jr_do_segmentation(Pcur,templates);
    end
end

%% ---------------- DARTEL - initial import -------------------------------%
% reslicing of the c1bc_*_c1.nii; c2bc_*_c1.nii; c3bc_*_c1.nii;
% input: bc_.*._c1_seg_sn.mat
% output: in defined folder --> rc1bc_*_c1.nii; rc2bc_*_c1.nii; rc3bc_*_c1.nii;

% create input Pcur list and Pdir
if 1==0
    clear Pcur
    for ix=[1:size(P3d,2)];
        [fpath fname ext]=fileparts(P3d{ix});
        Pcur{ix}=spm_select('FPList',fpath,['^bc_st_' fname '_c2t_seg_sn.mat']);
    end
end

Pdir='/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing/DARTEL';
if 1==0
    [fpath, fname, ext]=fileparts(Pfunc{1});
    P=spm_select('FPlist',fpath,['^st_a1_u_del25_' fname '_c2t.nii']);
    V=spm_vol(P);
    [BB,vx] = spm_get_bbox(V);
    vox=2.5
    jr_do_DARTEL_inital_import(Pcur,Pdir,vox)
end;

if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_HRF/10-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:size(P3d,2);
        [fpath fname ext]=fileparts(P3d{ix});
        Pfdm=spm_select('ExtFPList',fpath,['^c1bc_st_.*_c2t.nii'],1);
        Pfdm1=spm_select('ExtFPList',fpath,['^bc_st_.*_c2t.nii'],1);
        Pfdm2=spm_select('FPList','/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing/DARTEL',['^rc1bc_st_.*_c2t.nii']);
        char_all=char([cellstr(Pfdm);cellstr(Pfdm2);cellstr(Ptemp)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% ---------------- Reslice of EPI to in-plane voxel size -----------------%
if 1==0
    for ix=1:length(Pfunc)
        [fpath, fname, ext]=fileparts(Pfunc{ix});
        Pcur=spm_select('ExtFPlist',fpath,['^st_a1_u_del25_' fname '_c2t.nii'],1:16000);
        [fpath, fname, ext]=fileparts(P3d{ix});
        % Important: This is a reference image which was later created by
        % jr_do_DARTEL_inital_import.m with isotropic voxel-size
        Pref=spm_select('ExtFPlist','/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing/DARTEL',['^rc1bc_st_' fname '_c2t.nii'],1);
        Pinput=[cellstr(Pref);cellstr(Pcur)];
        do_reslice(Pinput,4);
    end
end;

%% --------------- DARTEL - Run DARTEL (create Templates)------------------%
% create templates as a mean of all input files and the u_* files with the
% information about warping
% input: all rc1coreg_st5_*.nii and all rc2coreg_st5_*.nii;
% output: in Pwdir u_rc1coreg_st5_*.ni, template_1.nii to template_6.nii;

if 1==0
    clear Pcur1 Pcur2
    Pwdir='/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing/DARTEL/';
    Pcur1=spm_select('ExtFPList',Pwdir,['^rc1bc_st_.*_c2t.nii'],1);
    Pcur2=spm_select('ExtFPList',Pwdir,['^rc2bc_st_.*_c2t.nii'],1);
    jr_do_DARTEL_create_templates(Pcur1,Pcur2);
end

%% --------------- DARTEL - Normalize to MNI ------------------------------%
% Idea: normalization of our template_6.nii to atlas template and warping
% of our inputs using the information from the flowfields (corresponding to
% the old warping)
% CAVE: spm_dartel_norm_fun_***_jr uses our template information --> be sure to
% have the correct one (rat/mouse)

% Output:
% modulated: smwc1bc_.*._c1.nii, smwc2bc_.*._c1.nii, smwc3bc_.*._c1.nii
% only warped: swc1bc_.*._c1.nii, swc2bc_.*._c1.nii, swc3bc_.*._c1.nii

if 1==0
    for ix = 1:length(P3d);
        clear job
        [fpath, fname, ext]=fileparts(P3d{ix});
        job.template = {'/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing/DARTEL/Template_6.nii'};
        job.data.subj.flowfield = { spm_select('FPlist','/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing/DARTEL/',['^u_rc1bc_st_' fname '_c2t_Template.nii'])};
        job.data.subj.images = {
            spm_select('FPlist',fpath,['^c1bc_st_' fname '_c2t.nii'])...
            spm_select('FPlist',fpath,['^c2bc_st_' fname '_c2t.nii'])...
            spm_select('FPlist',fpath,['^c3bc_st_' fname '_c2t.nii'])...
            };
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
    for ix = 1:length(P3d);
        clear job
        [fpath, fname, ext]=fileparts(P3d{ix});
        job.template = {'/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing/DARTEL/Template_6.nii'};
        job.data.subj.flowfield = { spm_select('FPlist','/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing/DARTEL/',['^u_rc1bc_st_' fname '_c2t_Template.nii'])};
        [fpath, fname, ext]=fileparts(Pfunc{ix});
        clear input_images
        input_images = {...
            spm_select('FPlist',fpath,['^rst_a1_u_del25_' fname '_c2t.nii']);...
            };
        P=spm_select('FPlist',fpath,['^rst_a1_u_del25_' fname '_c2t.nii']);...
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

%% ---------------- Reslice of EPI to original voxel size -----------------%
if 1==0
    if 1==1
        for ix=1:length(Pfunc)
            [fpath, fname, ext]=fileparts(Pfunc{ix});
            Pcur=spm_select('FPlist',fpath,['^rwrst_a1_u_del25_' fname '_c2t.nii']);
            delete(Pcur)
            Pcur=spm_select('FPlist',fpath,['^rwrst_a1_u_del25_' fname '_c2t.mat']);
            delete(Pcur);
        end
        delete(gcp)
        parpool(12)
        parfor ix=1:length(Pfunc)
            [fpath, fname, ext]=fileparts(Pfunc{ix});
            Pcur=spm_select('ExtFPlist',fpath,['^wrst_a1_u_del25_' fname '_c2t.nii'],1:10000);
            % Important: This is a reference image which was later created by
            % jr_do_DARTEL_inital_import.m with isotropic voxel-size
            Pref='/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing/ZI_M201014C_HRF_1_1_20201014_122701/5/REFERENCE_st_a1_u_del25_ZI_M201014C_HRF_1_1_20201014_122701_05_reorient_c2t.nii,1';
            Pinput=[cellstr(Pref);cellstr(Pcur)];
            do_reslice(Pinput,4);
        end
        delete(gcp)
    end
    for ix=1:length(Pfunc)
        clear Pinput
        [fpath, fname, ext]=fileparts(P3d{ix});
        P3d_csf=spm_select('FPlist',fpath,['^wc3bc_st_' fname '_c2t.nii$']);
        P_GM_mask=spm_select('FPlist',fpath,['^wc1bc_st_' fname '_c2t.nii$']);
        Pmask='/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing/DARTEL/mask_template_6_polished.nii';
        Pref='/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing/ZI_M201014C_HRF_1_1_20201014_122701/5/REFERENCE_st_a1_u_del25_ZI_M201014C_HRF_1_1_20201014_122701_05_reorient_c2t.nii,1';
        Pinput=[cellstr(Pref);P3d_csf;P_GM_mask;P_GM_mask];
        do_reslice(Pinput,0);
    end
end

%% OPTIONAL: CSF filtering and Regression of realignment parameters ----- %
% CSF filtering and regression of realign parameters, depending on the
% selection also with global signal regression or derivatives of the
% realignment parameters
% Prefix: regfilt_
% Regression of realignment parameters/CSF/derivatives...
if 1==0
%     delete(gcp)
%     parpool(12)
%     parfor ix=1:size(Pfunc,2)
for ix=1:size(Pfunc,2)
        Pmask='/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing/DARTEL/rmask_template_6_polished.nii';
        %% Social
        [fpath, fname, ext]=fileparts(Pfunc{ix});
        Pfunc_cur=spm_select('FPlist',fpath,['^wrst_a1_u_del25_' fname '_c2t.nii$']);
        [fpath, fname, ext]=fileparts(P3d{ix});
        P3d_csf=spm_select('FPlist',fpath,['^wc3bc_st_' fname '_c2t.nii$']);
        P_GM_mask=spm_select('FPlist',fpath,['^wc1bc_st_' fname '_c2t.nii$']);
        qmcsf=0.9;
        execution=1;
        acl_regfilt_motcsf_awake_jr(Pfunc_cur,P3d_csf,P_GM_mask,Pmask,qmcsf,execution);
    end
    delete(gcp)
end

% % %% ---------------- Motion assessment: 2nd realignment ------------------ %
% %
% % if 1==0
% %     for ix=1:length(Pfunc);
% %         [fpath, fname, ext]=fileparts(Pfunc{ix});
% %         Pfunc_cur=spm_select('FPlist',fpath,['^wst_a1_u_del25_' fname '_c1_c2t.nii$']);
% %         do_realign_est(Pfunc_cur);
% %     end
% % end

% % %% ---------------------- Motion Regressors ----------------------------- %
% % % creates a multiple regressor including standard rps, its derivatives,
% % % shifted derivatives -2, -1, +1 (for first level)
% %
% % if 1==0
% %     for ix=1:size(Pfunc,2)
% %         %% Social Defeat
% %         [fpath, fname, ext]=fileparts(Pfunc{ix});
% %         rp=spm_load(spm_select('FPlist',fpath,'^rp_del25.*.txt'));
% %         rp_diff=[zeros(1,size(rp,2)); diff(rp)];
% %         rp_diff_minus2=[rp_diff([3:(str2num(Pfunc{ix}(end-3:end))-5)],:); zeros(2,size(rp_diff,2))];
% %         rp_diff_minus1=[rp_diff([2:(str2num(Pfunc{ix}(end-3:end))-5)],:); zeros(1,size(rp_diff,2))];
% %         rp_diff_plus1=[zeros(1,size(rp_diff,2));rp_diff([1:(str2num(Pfunc{ix}(end-3:end))-6)],:)];
% %         regressors_mot_der_shiftder_m2m1p1=[rp rp_diff rp_diff_minus2 rp_diff_minus1 rp_diff_plus1];
% %         dlmwrite(fullfile(fpath,strcat('regressors_mot_der_shiftder_m2m1p1.txt')),regressors_mot_der_shiftder_m2m1p1,'delimiter','\t','precision','%.6f')
% %     end
% % end

%% ------------ Create mask of DARTEL templates ------------------------- %
if 1==0
    P_template='/home/jonathan.reinwald/ICON_HRF/03-processed-data/01-MRI/02-social_defeat/02-preprocessing/DARTEL/Template_6.nii';
    master_create_mask_of_DARTELtemplate(P_template);
end

% % %% ------------ Motiondiagnosis Alex: DVARS and plots ------------------- %
% % if 1==0
% %     motiondir=[procdir filesep 'motiondiagnosis'];
% %     mkdir(motiondir);
% %
% %     for ix=1:size(Pfunc,2);
% %         %% social_defeat
% %         [fpath, fname, ext]=fileparts(Pfunc{ix});
% %         EPI=spm_select('ExtFPlist',fpath,['^wrst_a1_u_del25_' fname '_c1_c2t.nii']);
% %         thres=0.10;
% %         mask='/home/jonathan.reinwald/ICON_HRF/03-processed-data/01-MRI/02-social_defeat/02-preprocessing/DARTEL/mask_template_6_polished.nii';
% %         outputdir=motiondir;
% %         acl_motiondiagnosis_jr_lw(EPI,thres,mask,outputdir,fname);
% %     end
% % end
%% ---------------- Reslice of EPI to original voxel size -----------------%
if 1==0
    if 1==1
%         for ix=1:length(Pfunc)
%             [fpath, fname, ext]=fileparts(Pfunc{ix});
%             Pcur=spm_select('FPlist',fpath,['^rwrst_a1_u_del25_' fname '_c2t.nii']);
%             delete(Pcur)
%             Pcur=spm_select('FPlist',fpath,['^rwrst_a1_u_del25_' fname '_c2t.mat']);
%             delete(Pcur);
%         end
        delete(gcp)
        parpool(12)
        parfor ix=1:length(Pfunc)
            [fpath, fname, ext]=fileparts(Pfunc{ix});
            Pcur=spm_select('ExtFPlist',fpath,['^regfilt_motcsfder_wrst_a1_u_del25_' fname '_c2t.nii'],1:10000);
            % Important: This is a reference image which was later created by
            % jr_do_DARTEL_inital_import.m with isotropic voxel-size
            Pref='/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing/ZI_M201014C_HRF_1_1_20201014_122701/5/REFERENCE_st_a1_u_del25_ZI_M201014C_HRF_1_1_20201014_122701_05_reorient_c2t.nii,1';
            Pinput=[cellstr(Pref);cellstr(Pcur)];
            do_reslice(Pinput,4);
        end
        delete(gcp)
    end
end


%% --------- Smoothing (without band-pass filtering afterwards) ----------%
if 1==1
    if 1==0
        parpool(12)
        parfor ix=1:size(Pfunc,2)
            %
            [fpath fname ext]=fileparts(Pfunc{ix});
            Pcur=spm_select('ExtFPList',fpath,['^rwrst_a1_u_del25_' fname '_c2t.nii$'],1);
            fwhm_cur=[5 5 5];
            do_smooth_lw(Pcur,fwhm_cur);
        end
        delete(gcp)
    end
    if 1==1
        parpool(12)
        parfor ix=1:size(Pfunc,2)
            %
            [fpath fname ext]=fileparts(Pfunc{ix});
            if exist([fpath filesep 'regfilt_motcsfder_rwrst_a1_u_del25_' fname '_c2t.nii.gz'],'file')
                gunzip([fpath filesep 'regfilt_motcsfder_rwrst_a1_u_del25_' fname '_c2t.nii.gz']);
            end
            Pcur=spm_select('ExtFPList',fpath,['^rregfilt_motcsfder_wrst_a1_u_del25_' fname '_c2t.nii$'],1);
            fwhm_cur=[5 5 5];
            do_smooth_lw(Pcur,fwhm_cur);
        end
        delete(gcp)
    end
end

%% ---------------------- Visual Check ---------------------------------- %
if 1==0
    Ptemp='/home/jonathan.reinwald/ICON_HRF/03-processed-data/01-MRI/04-helpers/01-atlas/01-Dorr_atlas/DLtemplate_brain_rs1x1x1.nii';
    for ix=1:size(P3d,2);
        
        [fpath, fname, ext]=fileparts(P3d{ix});
        P3d_norm=spm_select('ExtFPlist',fpath,['^wbc_st_' fname '_brain_c2t.nii'],1);
        
        [fpath fname ext]=fileparts(Pfunc{ix});
        Pfunc_norm=spm_select('ExtFPList',fpath,['^wst_a_u_del25_' fname '_c1_c2t.nii'],1);
        
        Pfunc_smooth=spm_select('ExtFPList',fpath,['^s_wst_a_u_del25_' fname '_c1_c2t.nii'],1);
        
        
        char_all=char([cellstr(Ptemp);cellstr(P3d_norm);cellstr(Pfunc_norm); cellstr(Pfunc_smooth)]);
        spm_check_registration(char_all)
        input('weiter');
    end
end

%% -------------------- Wavelet Despiking ---------------------------------
%% -------------------- WD1: masking of EPIs ------------------------------
% Create folder for every animal and copy file to respective folder
if 1==1
    Pmask='/home/jonathan.reinwald/ICON_HRF/03-processed-data/02-preprocessing/DARTEL/rmask_template_6_polished.nii';
    Vmask=spm_vol(Pmask);
    mask=spm_read_vols(Vmask);
    
    mask(isnan(mask))=0;
    for ix=1:size(Pfunc,2)
        if 1==1
            Pcur=deblank(Pfunc{ix});
            [fpath, fname, ext]=fileparts(Pcur);
            P=spm_select('ExtFPList',fpath,['^s5_rwrst_a1_u_del25_' fname '_c2t.nii'],[1:10000]);
            nimg=size(P,1);
            Vi=spm_vol(P);
            img_mtx=spm_read_vols(Vi);
            Vnew=Vi;
%             parpool(8)
            for jx=1:nimg
                Vnew(jx).fname=[fpath '/msk_s5_rwrst_a1_u_del25_' fname '_c2t.nii'];
                spm_write_vol(Vnew(jx),squeeze(img_mtx(:,:,:,jx)).*mask);
            end
%             delete(gcp)
        end
        if 1==1
            Pcur=deblank(Pfunc{ix});
            [fpath, fname, ext]=fileparts(Pcur);
            P=spm_select('ExtFPList',fpath,['^s5_rregfilt_motcsfder_wrst_a1_u_del25_' fname '_c2t.nii'],[1:10000]);
            nimg=size(P,1);
            Vi=spm_vol(P);
            img_mtx=spm_read_vols(Vi);
            Vnew=Vi;
%             parpool(8)
            for jx=1:nimg
                Vnew(jx).fname=[fpath '/msk_s5_rregfilt_motcsfder_wrst_a1_u_del25_' fname '_c2t.nii']
                spm_write_vol(Vnew(jx),squeeze(img_mtx(:,:,:,jx)).*mask);
            end
%             delete(gcp)
        end
    end
end

% % Create folder for every animal and copy file to respective folder
% if 1==0
%     for ix=1:size(Pfunc,2);
%         %% social_defeat
%         Pcur=deblank(Pfunc{ix});
%         [fpath, fname, ext]=fileparts(Pcur);
%         ICA_dir = '/home/jonathan.reinwald/ICON_HRF/data/social_defeat/fMRI/preprocessing/ICA';
%         mkdir(ICA_dir);
%         mkdir([ICA_dir filesep 'social_defeat' filesep fname]);
%         Pcur1=spm_select('FPList',fpath,['^msk_s_wrst_a1_u_del25_' fname '_c1_c2t.nii']);
%         Pcur2=([ICA_dir filesep 'social_defeat' filesep fname]);
%         syscmd=['cp ' Pcur1 ' ' Pcur2 ]
%         %alternativly: ['find -name ' Pcur1 ' -exec cp {} ' Pcur2 ' \;'];
%         system(syscmd)
%         %% Resting-State
%         Pcur=deblank(Pfunc_rs{ix});
%         [fpath, fname, ext]=fileparts(Pcur);
%         ICA_dir = '/home/jonathan.reinwald/ICON_HRF/data/social_defeat/fMRI/preprocessing/ICA';
%         mkdir(ICA_dir);
%         mkdir([ICA_dir filesep 'rs' filesep fname]);
%         Pcur1=spm_select('FPList',fpath,['^msk_s_wrst_a1_u_del25_' fname '_c1_c2t.nii']);
%         Pcur2=([ICA_dir filesep 'rs' filesep fname]);
%         syscmd=['cp ' Pcur1 ' ' Pcur2 ]
%         %alternativly: ['find -name ' Pcur1 ' -exec cp {} ' Pcur2 ' \;'];
%         system(syscmd)
%     end
% end
%
%
%
% if 1==0
%     for ix=1:size(Pfunc,2);
%         %% social_defeat
%         [fdir, fname, ext]=fileparts(Pfunc{ix});
%         EPI=spm_select('FPList',fdir,['^s_wrst_a1_u_del25_' fname '_c1_c2t.nii']);
%         Pmask='/home/jonathan.reinwald/ICON_HRF/03-processed-data/01-MRI/02-social_defeat/02-preprocessing/DARTEL/mask_template_6_polished.nii';%resliced 2 norm EPI; binary of template
%         acl_ICADenoising_decomposition_jr_lw(fdir,EPI,Pmask)
%         %% Resting-State
%         [fdir, fname, ext]=fileparts(Pfunc_rs{ix});
%         EPI=spm_select('FPList',fdir,['^s_wrst_a1_u_del25_' fname '_c1_c2t.nii']);
%         Pmask='/home/jonathan.reinwald/ICON_HRF/03-processed-data/01-MRI/02-social_defeat/02-preprocessing/DARTEL/mask_template_6_polished.nii';%resliced 2 norm EPI; binary of template
%         acl_ICADenoising_decomposition_jr_lw(fdir,EPI,Pmask)
%     end;
% end;

%% -------------- WD2: Intensity Normalization to 1000 --------------------
% --> is this really necessary???
if 1==0
    for ix=1:size(Pfunc,2)
        %% social_defeat
        [fpath fname ext]=fileparts(Pfunc{ix});
        Pfunccur=spm_select('FPlist',fpath,['^msk_s6_wrst_a1_u_del25_' fname '_c1_c2t.nii']);
        intensity_normalization(Pfunccur);
    end
end


%% ---------------------- WD3: Actual WaveletDespiking --------------------
if 1==0
    % set path
    addpath(genpath('/home/jonathan.reinwald/ICON_HRF/01-scripts/01-toolboxes/wavelet_despiking/'))
    
    for wdthresh=[10]%[10,20,30,50]%[30 50 70 100 20 40]
        for ix=2:size(Pfunc,2)
            %% social_defeat
            [fpath, fname, ext]=fileparts(Pfunc{ix});
            newdir=[fpath '/wavelet/'];
            mkdir(newdir);
            cd(newdir)
            
            %fpath='/home/laurens.winkelmeier/awake/all_awake_MAIN/MRI/TEST_waveletDespiking/'
            %       Pcur=spm_select('FpList', fpath , ['^msk_s_wst5_a_u_del25_' fname '_c1_c2t_icaden25.nii']); % CC 190918 instead of: Pcur=spm_select('FpList', fpath , ['^wst5_a_u_del25_' fname '_c1_c2t.nii']);
            Pcur=spm_select('FpList', fpath , ['^med1000_msk_s6_wrst_a1_u_del25_' fname '_c1_c2t.nii']);
            
            [fpath, fname, ext]=fileparts(Pcur);
            
            threshold = wdthresh;
            prefix = ['wave_' num2str(threshold) 'cons_'];
            WaveletDespike(Pcur,[prefix fname],'threshold',threshold,'chsearch','harsh','verbose',1,'LimitRAM',80);
            
            gunzip([newdir prefix fname '_wds.nii.gz']);
            delete([newdir prefix fname '_wds.nii.gz']);
            
            gunzip([newdir prefix fname '_noise.nii.gz']);
            delete([newdir prefix fname '_noise.nii.gz']);
            
            gunzip([newdir prefix fname '_EDOF.nii.gz']);
            delete([newdir prefix fname '_EDOF.nii.gz']);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Appendix ICA!
% Create folder for every animal and copy file to respective folder
if 1==0
    Pmask='/home/jonathan.reinwald/ICON_HRF/03-processed-data/01-MRI/02-social_defeat/02-preprocessing/DARTEL/mask_template_6_polished.nii';
    Vmask=spm_vol(Pmask);
    mask=spm_read_vols(Vmask);
    
    mask(isnan(mask))=0;
    for ix=1:size(Pfunc,2)
        %% social_defeat
        Pcur=deblank(Pfunc{ix});
        [fpath, fname, ext]=fileparts(Pcur);
        P=spm_select('ExtFPList',fpath,['^s_wrst_a1_u_del25_' fname '_c1_c2t.nii'],[1:3000]);
        nimg=size(P,1);
        Vi=spm_vol(P);
        img_mtx=spm_read_vols(Vi);
        Vnew=Vi;
        for jx=1:nimg
            Vnew(jx).fname=[fpath '/msk_s_wrst_a1_u_del25_' fname '_c1_c2t.nii']
            spm_write_vol(Vnew(jx),squeeze(img_mtx(:,:,:,jx)).*mask);
        end
    end
end

% Create folder for every animal and copy file to respective folder
if 1==0
    for ix=1:size(Pfunc,2);
        %% social_defeat
        Pcur=deblank(Pfunc{ix});
        [fpath, fname, ext]=fileparts(Pcur);
        ICA_dir = '/home/jonathan.reinwald/ICON_HRF/03-processed-data/01-MRI/02-social_defeat/02-preprocessing/ICA';
        mkdir(ICA_dir);
        mkdir([ICA_dir filesep 'social_defeat' filesep fname]);
        Pcur1=spm_select('FPList',fpath,['^msk_s_wrst_a1_u_del25_' fname '_c1_c2t.nii']);
        Pcur2=([ICA_dir filesep 'social_defeat' filesep fname]);
        syscmd=['cp ' Pcur1 ' ' Pcur2 ]
        %alternativly: ['find -name ' Pcur1 ' -exec cp {} ' Pcur2 ' \;'];
        system(syscmd)
    end
end
