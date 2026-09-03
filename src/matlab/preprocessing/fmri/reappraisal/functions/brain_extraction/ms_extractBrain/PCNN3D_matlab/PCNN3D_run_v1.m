%% PCNN3D auto brain extraction
% save as *_mask.nii.gz
% requires nifti toolbox
%
% 2017/07/27 ver1.0
%
% Kai-Hsiang Chuang, QBI/UQ

%% init setup
% datpath='/Volumes/anatomy.nii.gz'; % data path 
% datpath=[pwd filesep 'ZI_M161221A_1_1_20161221_092757_04_reorient.nii']
datpath=spm_select
%%
BrSize=[350,550]*1000; % brain size range for mouse (mm3). If you use 10x data, this should be 10x too
% BrSize=[350,450]*1000;
%BrSize=[1200,4400]; % brain size range for RAT (mm3)
StrucRadius=3; % use =3 for low resolution

%% run PCNN
[nii] = load_untouch_nii(datpath);
mtx=size(nii.img); nii.img = cast(nii.img, 'double');
voxdim=nii.hdr.dime.pixdim(2:4);
[I_border, G_I, optG] = PCNN3D(nii.img, StrucRadius, voxdim, BrSize);
V=zeros(mtx);
for n=1:mtx(3)
    V(:,:,n)=I_border{optG}{n};
end

%% save data
disp(['Saving mask at ',datpath(1:end-7),'_mask.nii.gz....'])
nii.img=nii.img.*V;
save_untouch_nii(nii,[datpath(1:end-4),'_mask.nii.gz'])

disp('Done')