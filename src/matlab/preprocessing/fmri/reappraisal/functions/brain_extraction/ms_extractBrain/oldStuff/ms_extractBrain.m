function [ output_args ] = ms_extractBrain( P, BrSize )
%MS_EXTRACTBRAIN usage: ms_extractBrain( P, BrSize )
%   This function extracts the brain of rodent MR data; main idea is to use
%   a pusle-coupled neural network (PCNN) and consists of several steps:
%   1. remove noise by ms_DenoiseMR
%   2. make an initial brain extraction 
%   3. de-bias the original image using the information from the first
%   extraction
%   4. do a final brain extraction of the de-biased image
% for PCNN: https://www.a-star.edu.sg/sbic/RESOURCES/Software.aspx
if nargin <1
    P=spm_select;
end

if nargin <2
    if ~isempty(strfind(P,'ZI_M')) % that should work; maybe better to calculate the whole volume size
        BrSize=[350,550]*1000; % brain size range for mouse (mm3). If you use 10x data, this should be 10x too (for each dimension!)
    else
        BrSize=[1200,3000]*1000; % brain size range for RAT (mm3)
    end
end
% set some paths if needed
if isempty(which('PCNN3D')); addpath(genpath([fileparts(which('ms_extractBrain')) filesep 'PCNN3D_matlab'])); end
if isempty(which('ms_DenoiseMR')); addpath(genpath([fileparts(which('ms_extractBrain')) filesep 'ms_DenoiseMR'])); end
if isempty(which('spm_bias_estimate')); addpath(genpath([fileparts(which('ms_extractBrain')) filesep 'spm_stuff'])); end
% if isempty(which('load_untouch_nii')); addpath('/data/matlab/NIFTI/'); end
if ~isempty(which('imresize3')); flag3d =1; else; flag3d=0; end
% we need spm8
% if isempty(strfind(which('spm'),'spm8')); spm8p; end

[d,name,ext]=fileparts(P);

V=spm_vol(P);
Mtx=spm_read_vols(V); 
voxdim=spm_imatrix(V.mat); voxdim=abs(voxdim(7:9)); voxdim_orig=voxdim;
% [nii] = load_untouch_nii(P);
% voxdim=nii.hdr.dime.pixdim(2:4); 
%% check if BrSize is set correctly
if BrSize(2)>=length(find(Mtx))*prod(voxdim)
    BrSize(2)=floor(length(find(Mtx))*prod(voxdim));
    fprintf('upper Limit of BrainSize is bigger than the provided image!\n Setting BrainSize to %.2f\n', BrSize(2)/1000)
end
%% calculate the noise and remove it; we won't use it for the last result!
% [ noise ] = ms_DenoiseMR( P ); Mtx=Mtx-noise; % questionable if we need it here
%% use a PCNN approach

% to make it a bit quicker; works.. but the imresize3 function would be'
% better -> but only avaiable in R2017a!!
Mtx_orig=Mtx;
% tform = affine3d([0.5 0 0 0; 0 0.5 0 0; 0 0 0.5 0; 0 0 0 1]);
% Mtx = imwarp(Mtx,tform);
% % if flag3d; Mtx=imresize3(Mtx,0.6); else; Mtx=imresize(Mtx,0.6); end % imresize3 was introduced R2017a
% voxdim=voxdim_orig.*(size(Mtx_orig)./size(Mtx));

% interestingly.. that makes it quicker
Mtx=Mtx./max(max(max(Mtx)));
Mtx = reshape(imadjust(Mtx(:)),size(Mtx));

StrucRadius=5; % use =3 for low resolution; 3 is also quicker, so take it first
% run PCNN
[I_border, G_I, optG] = PCNN3D(Mtx, StrucRadius, voxdim, BrSize, 100); % BrSize and MaxIter are optional
close(gcf); % PCNN creates a figure.. simply close it immediately
maskBrain=zeros(size(Mtx));
for n=1:size(Mtx,3)
    maskBrain(:,:,n)=I_border{optG}{n};
end
fprintf('First brain volume guess is %.2f mm^3\n', length(find(maskBrain))*prod(voxdim)/1000)
% save a tmp file
Vtmp=V; Vtmp.fname = [d filesep name '_braintmp.nii'];
% if flag3d; maskBrain=imresize3(maskBrain,[size(Mtx_orig,1) size(Mtx_orig,2) size(Mtx_orig,3)]); else; maskBrain=imresize(maskBrain,[size(Mtx_orig,1) size(Mtx_orig,2)]); end 
% s=size(Mtx_orig)./size(Mtx)*0.9999; tform = affine3d([s(1) 0 0 0; 0 s(2) 0 0; 0 0 s(3) 0; 0 0 0 1]);
% maskBrain = imwarp(maskBrain,tform);
% maskBrain(maskBrain<0.8)=0;  maskBrain(maskBrain>0)=1;
spm_write_vol(Vtmp, smooth3(Mtx_orig.*maskBrain)); % it can happen that you have some artifacts in the brain which are causing spikes in its histogram -> bias correction doesn't work so well then


%% estimate a bias correction on the first brain extraction 
spm('defaults','fmri');
spm_jobman('initcfg');

flags.nbins=1024; flags.reg=0.001; flags.cutoff=35;
T=spm_bias_estimate(Vtmp ,flags);
% Vbc = V; Vbc.fname = [d filesep 'bc_' name ext]; copyfile(V.fname, Vbc.fname);
Vbc = spm_bias_apply(V,T); % apply it on the original image
Vbc.fname = [d filesep 'bc_' name ext];
spm_write_vol(Vbc, Vbc.dat)
%% if we need a stronger bias field
% [ F ] = ms_getBiasField([d filesep 'bias_' name '_braintmp.mat']);
% F=F.^3;
% Mtx=spm_read_vols(Vbc);
% Mtx=Mtx.*F;
% spm_write_vol(Vbc, Mtx)
%% run PCNN again
voxdim=voxdim_orig; 
Mtx=spm_read_vols(Vbc); Mtx_orig=Mtx;
[ noise ] = ms_DenoiseMR( P ); Mtx=Mtx-noise; Mtx=Mtx./max(max(max(Mtx))); Mtx = reshape(imadjust(Mtx(:)),size(Mtx));
% StrucRadius=5;
[I_border, G_I, optG] = PCNN3D(Mtx, StrucRadius, voxdim, BrSize);
close(gcf); % PCNN creates a figure.. simply close it immediately
maskBrain=zeros(size(Mtx));
for n=1:size(Mtx,3)
    maskBrain(:,:,n)=I_border{optG}{n};
end
fprintf('Final brain volume guess is %.2f mm^3\n', length(find(maskBrain))*prod(voxdim)/1000)
VbrainBC = Vbc;
VbrainBC.fname = [d filesep 'bc_' name '_brain' ext];
spm_write_vol(VbrainBC, Mtx_orig.*maskBrain);
%% cleanup
% delete(Vtmp.fname)
%% save the masks
BC=Vbc.fname;
save([d filesep 'BrainMasks_' name '.mat'], 'I_border', 'G_I', 'optG','BC');

%% old Stuff

%% do bias correction
% [Pout, biasField]=ms_do_bias(Pbrain); %P=Pout;

%% apply the field to the original image
% 
% 
% %% run bet
% f = 0.90; % default 0.5; [0,1]
% g = 0; % default 0; [-1,1]; vertical gradient in fractional intensity threshold (-1->1); default=0; positive values give larger brain outline at bottom, smaller at top  
% r = 80; % -r <r> head radius (mm not voxels); initial surface sphere is set to half of this 
% c = [50 70 22];
% [d,name,ext]=fileparts(P);
% % ppt_resave(infile,tempfile)
% ppt_transform(P,[0 0 0 0 0 0 1 0.5 1]);
% fslBET=[ name '_brain.nii'];
% command = ['bet ' P ' ' name '_brain.nii -f ' num2str(f) ' -g ' num2str(g) ' -r ' num2str(r) ' -c ' num2str(c(1)) ' ' num2str(c(2)) ' ' num2str(c(3)) ' -R'];
% system(command)
% gunzip([fslBET '.gz']); delete([fslBET '.gz'])
% ppt_transform(fslBET,[0 0 0 0 0 0 1 2 1]);
% ppt_transform(P,[0 0 0 0 0 0 1 2 1]);
% spm_check_registration(char(P,  fslBET))
% %%
% Pout=wwf_do_bias('tmp.nii');
% 
% sum(Mtx(:)>0)

end

