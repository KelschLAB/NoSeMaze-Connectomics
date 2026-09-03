%% master_preprocess_protocol_and_rhd.m
%% 

% Jonathan Reinwald 12/2020
% - protocollist (based on protocolfiles in Headerfiles_MRTprediction_JR)
% - rhdlist selects all rhd-files on zistna12
% - perform EPHYSPUPILprediction_protocol_JR → for details, see below
% - copy and sort _protocol_new.mat-files in new folder


%% Set pathes
addpath(genpath('/home/jonathan.reinwald/Documents/MATLAB'))


%% Definition of basic pathes
protocol_dir='/zi-flstorage/data/Jonathan/ICON_Autonomouse/EPHYS/paradigm_reappraisal/protocol_files' % Files are manually controlled, including only protocol.mat-files with rhd-files
rhd_dir='/zi-flstorage/data/Jonathan/ICON_Autonomouse/EPHYS/paradigm_reappraisal/rhd_files'
outputdir='/zi-flstorage/data/Jonathan/ICON_Autonomouse/EPHYS/paradigm_reappraisal/processed_protocol_files'
mkdir(outputdir)
rootdir='/zi-flstorage/data/Jonathan/ICON_Autonomouse/EPHYS/paradigm_reappraisal'

%% get all rhds and mats, create pairs of corresponding files, ...

rhdlist=getAllFiles(rhd_dir, '*.rhd',1);
% rhdlist_2=getAllFiles(rhd_dir_2, '*.rhd',1);
protocollist=getAllFiles(protocol_dir, '*protocol.mat', 1);
% rhdlist=[rhdlist_1; rhdlist_2];
nVolume=1600;

if 1==1
    process_protocol__reappraisal(protocollist,rhdlist,outputdir,rootdir,nVolume);
end


