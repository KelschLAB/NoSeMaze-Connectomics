% path definition
main_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/06-social_2sessionscombined/06-FC/01-BASCO/';
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
main_dir = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/06-social_2sessionscombined/06-FC/01-BASCO/'
basco_path = fileparts(which('BASCO'));
AnaDef.Img                  = 'nii';
AnaDef.Img4D                = true;      % true: 4D Nifti
AnaDef.units                = 'secs';    % unit 'scans' or 'secs'
AnaDef.RT                   = 1.2;          % repetition time in seconds
AnaDef.fmri_t               = 22;
AnaDef.fmri_t0              = 1;
AnaDef.OutDir               = ['betaseries_' vname];  % output directory
AnaDef.Prefix               = metainfo(1).EPI;
AnaDef.OnsetModifier        = 0; % subtract this number from the onset-matrix (unit: scans)

AnaDef.VoxelAnalysis        = true;  
AnaDef.ROIAnalysis          = false; % ROI level analysis (estimate model on ROIs for network analysis)
AnaDef.ROIDir               = fullfile(basco_path,'rois','AllenMouse'); % select all ROIs in this directory
AnaDef.ROIPrefix            = 'MNI_';
AnaDef.ROINames             = fullfile(basco_path,'rois','AllenMouse','AALROINAMES.txt'); % txt.-file containing ROI names
AnaDef.ROISummaryFunction   = 'mean'; % 'mean' or 'median'

AnaDef.SpecMask             = '/home/jonathan.reinwald/ICON_Autonomouse/03-processed-data/03-MRI/04-helpers/01-atlas/04-AllenBrain_2021_v2/mask_noCB_noBS_polished.nii';

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
AnaDef.Outfile              = fullfile(main_dir,'output',['out_estimated_social_2sessionscombined_' vname '.mat']);

cSubj = 0; % subject counter

data_dir = fullfile(main_dir,'input'); % directory containing all subject folders

% load subject-folder names
cd(data_dir);
vp_all = dir('ZI_*');
vp = {vp_all.name};

% load regressors
clear find_ suffix_onsets duration regressors
find_=strfind(metainfo(1).onsets,'_');
suffix_onsets = metainfo(1).onsets(find_(1):end);
load(fullfile(metainfo(1).onset_dir,[vp{1},suffix_onsets]));
regressors_1 = regressors;
find_=strfind(metainfo(2).onsets,'_');
suffix_onsets = metainfo(2).onsets(find_(1):end);
load(fullfile(metainfo(2).onset_dir,[vp{1},suffix_onsets]));
regressors_2 = regressors;

% define NumCond and Condition names
AnaDef.NumCond              = [length(regressors_1),length(regressors_2)];         % number of conditions
AnaDef.Cond{1}                 = {regressors_1.name}; % names of conditions
AnaDef.Cond{2}                 = {regressors_2.name};

% all subjects
for i=1:length(vp)
    cSubj = cSubj+1;
    AnaDef.Subj{cSubj}.DataPath = fullfile(data_dir,vp{i}); 
    AnaDef.Subj{cSubj}.NumRuns  = 2;
    AnaDef.Subj{cSubj}.RunDirs  = {'run1','run2'};
    AnaDef.Subj{cSubj}.Onsets   = {'onsetsRUN1.txt','onsetsRUN2.txt'};
    AnaDef.Subj{cSubj}.Duration{1} = [regressors_1.duration];
    AnaDef.Subj{cSubj}.Duration{2} = [regressors_2.duration]
    AnaDef.Subj{cSubj}.Covariates = {metainfo(1).covariates,metainfo(2).covariates};
end

%
AnaDef.NumSubjects = cSubj;

% Add ROI names and duration to metainfo
metainfo(1).ROI_name = {regressors_1.name};
metainfo(1).duration = [regressors_1.duration];
for k=1:length({regressors_1.name})
    metainfo(1).numb_onsets(k) = length(regressors_1(k).onset);
end
metainfo(2).ROI_name = {regressors_2.name};
metainfo(2).duration = [regressors_2.duration];
for k=1:length({regressors_2.name})
    metainfo(2).numb_onsets(k) = length(regressors_1(k).onset);
end

% save metainfo
save(metainfo_filepath,'metainfo');


