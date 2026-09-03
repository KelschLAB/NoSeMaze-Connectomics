% path definition
main_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/06-FC/01-BASCO/';
data_dir = fullfile(main_dir,'input');

% load metainfo file
cd(data_dir);
metainfo_filepath = spm_select
load(metainfo_filepath);

% define vname
[fdir,fname,fext]=fileparts(metainfo_filepath);
clear find_
find_ = strfind(fname,'_');
vname = fname(find_(1)+1:end);

% betaseries analysis definition for BASCO
main_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/07-reappraisal_control_2023/06-FC/01-BASCO/'
basco_path = fileparts(which('BASCO'));
AnaDef.Img                  = 'nii';
AnaDef.Img4D                = true;      % true: 4D Nifti
AnaDef.units                = 'secs';    % unit 'scans' or 'secs'
AnaDef.RT                   = 1.2;          % repetition time in seconds
AnaDef.fmri_t               = 22;
AnaDef.fmri_t0              = 1;
AnaDef.OutDir               = ['betaseries_' vname];  % output directory
AnaDef.Prefix               = metainfo.EPI;
AnaDef.OnsetModifier        = 0; % subtract this number from the onset-matrix (unit: scans)

AnaDef.VoxelAnalysis        = true;  
AnaDef.ROIAnalysis          = false; % ROI level analysis (estimate model on ROIs for network analysis)
AnaDef.ROIDir               = fullfile(basco_path,'rois','AllenMouse'); % select all ROIs in this directory
AnaDef.ROIPrefix            = 'MNI_';
AnaDef.ROINames             = fullfile(basco_path,'rois','AllenMouse','AALROINAMES.txt'); % txt.-file containing ROI names
AnaDef.ROISummaryFunction   = 'mean'; % 'mean' or 'median'

AnaDef.SpecMask             = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/01-reappraisal/02-preprocessing/DARTEL/mask_template_6_polished.nii';

AnaDef.HRFDERIVS            = [0 0];  % temporal and disperion derivatives: [0 0] or [1 0] or [1 1]

% regressors to include into design
AnaDef.MotionReg            = true;
AnaDef.CSFReg               = true;
AnaDef.DerivReg             = true;
AnaDef.GlobalMeanReg        = false;

% name of output-file (analysis objects)
if exist(fullfile(main_dir,'output'))~=7
    mkdir(fullfile(main_dir,'output'));
end
AnaDef.Outfile              = fullfile(main_dir,'output',['out_estimated_reappraisal_' vname '.mat']);

cSubj = 0; % subject counter

data_dir = fullfile(main_dir,'input'); % directory containing all subject folders

% load subject-folder names
cd(data_dir);
vp_all = dir('ZI_*');
vp = {vp_all.name};

% load regressors
clear find_ suffix_onsets duration
find_=strfind(metainfo.onsets,'_');
suffix_onsets = metainfo.onsets(find_(1):end);
regressors_file = spm_select('FPList',metainfo.onset_dir,['^' vp{1} '.*' suffix_onsets]);
load(regressors_file);
% load(fullfile(metainfo.onset_dir,[vp{1},suffix_onsets]));

% define NumCond and Condition names
AnaDef.NumCond              = length(regressors);         % number of conditions
AnaDef.Cond                 = {regressors.name}; % names of conditions
duration = [regressors.duration];

% all subjects
for i=1:length(vp)
    cSubj = cSubj+1;
    AnaDef.Subj{cSubj}.DataPath = fullfile(data_dir,vp{i}); 
    AnaDef.Subj{cSubj}.NumRuns  = 1;
    AnaDef.Subj{cSubj}.RunDirs  = {'run1'};
    AnaDef.Subj{cSubj}.Onsets   = {['onsets_' vname '.txt']};
    AnaDef.Subj{cSubj}.Duration = duration;
    AnaDef.Subj{cSubj}.Covariates = metainfo.covariates;
end

%
AnaDef.NumSubjects = cSubj;

% Add ROI names and duration to metainfo
metainfo.ROI_name = {regressors.name}
metainfo.duration = [regressors.duration];
for k=1:length({regressors.name})
    metainfo.numb_onsets(k) = length(regressors(k).onset);
end

% save metainfo
save(metainfo_filepath,'metainfo');


