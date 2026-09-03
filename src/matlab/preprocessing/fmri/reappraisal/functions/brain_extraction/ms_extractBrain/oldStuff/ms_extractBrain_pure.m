function [ output_args ] = ms_extractBrain_pure( P, BrSize )
%MS_EXTRACTBRAIN usage: ms_extractBrain_pure( P, BrSize )
%   This function extracts the brain of rodent MR data; main idea is to use
%   a pusle-coupled neural network (PCNN)
% for PCNN: https://www.a-star.edu.sg/sbic/RESOURCES/Software.aspx
if nargin <1
    P=spm_select;
end

if nargin <2
    if ~isempty(strfind(P,'ZI_M')) % that should work; maybe better to calculate the whole volume size
        BrSize=[350,540]*1000; % brain size range for mouse (mm3). If you use 10x data, this should be 10x too (for each dimension!)
    else
        BrSize=[1200,3000]*1000; % brain size range for RAT (mm3)
    end
end
% set some paths if needed
if isempty(which('PCNN3D')); addpath(genpath([fileparts(which('ms_extractBrain')) filesep 'PCNN3D_matlab'])); end

[d,name,ext]=fileparts(P);

V=spm_vol(P); V=V(1);
Mtx=spm_read_vols(V); 
voxdim=spm_imatrix(V.mat); voxdim=abs(voxdim(7:9));

%% check if BrSize is set correctly
if BrSize(2)>=length(find(Mtx))*prod(voxdim)
    BrSize(2)=floor(length(find(Mtx))*prod(voxdim));
    fprintf('upper Limit of BrainSize is bigger than the provided image!\n Seeting BrainSize to %.2f\n', BrSize(2)/1000)
end
% interestingly.. that makes it quicker
S=Mtx./max(max(max(Mtx)));
S = reshape(imadjust(S(:)),size(S));
%% use a PCNN approach
StrucRadius=3; % use =3 for low resolution
% run PCNN
[I_border, G_I, optG] = PCNN3D(S, StrucRadius, voxdim, BrSize, 200); % BrSize and MaxIter are optional
% close(gcf); % PCNN creates a figure.. simply close it immediately
maskBrain=zeros(size(Mtx));
for n=1:size(Mtx,3)
    maskBrain(:,:,n)=I_border{optG}{n};
end
fprintf('Brain volume guess is %.2f mm^3\n', length(find(maskBrain))*prod(voxdim)/1000)
% save file
Vtmp=V; Vtmp.fname = [d filesep name '_brain.nii'];
spm_write_vol(Vtmp, Mtx.*maskBrain); 
%% save the masks
BC=V.fname;
save([d filesep 'BrainMasks_' name '.mat'], 'I_border', 'G_I', 'optG','BC');

end

