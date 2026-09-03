function [regionsInROI]=determineAtlasRegionsInROI_jr(regionFile,atlas_niftiFile,atlas_txtFile,thresh_plot)
% Jonathan Reinwald

% Info:
% function to determine the altas regions within one region of interest
% (e.g. from seed-based connectivity or BOLD results)

% Input:
% - regionFile = region of interest as a nifti
% - atlas_niftiFile = atlas nifti file
% - atlas_txtFile = atlas regions as a text file (number, region name)

% Output:


% load img.nii of region of interest 
V=spm_vol(regionFile);
img=spm_read_vols(V);

% load img.nii of region of interest 
V_atlas=spm_vol(atlas_niftiFile);
if V_atlas.dim~=V.dim
    Pinput=[cellstr(regionFile);cellstr(atlas_niftiFile)];
    do_reslice_dim(Pinput,0,V.dim);
    [fdir,fname,fext]=fileparts(V_atlas.fname);
    newAtlas_niftiFile = fullfile(fdir,['r' num2str(V.dim) fname fext]);
    V_atlas=spm_vol(newAtlas_niftiFile);
end
img_atlas=spm_read_vols(V_atlas);

% create myImg as a multiplication of the mask of the ROI-file and the atlas
myImg=img_atlas.*(img>0);

% get the indices of the atlas regions
[atlasInRoi_idx,~,atlasInRoi_ic] = unique(myImg(myImg>0));
a_counts = accumarray(atlasInRoi_ic,1);
value_counts = [atlasInRoi_idx, a_counts];

% get the indices of the atlas regions
[atlasInAtlas_idx,~,atlasInAtlas_ic] = unique(img_atlas(img_atlas>0));
a_counts_atlas = accumarray(atlasInAtlas_ic,1);
value_counts_atlas = [atlasInAtlas_idx, a_counts_atlas];

fileID = fopen(atlas_txtFile,'rt');
D = textscan(fileID, '%s %n', 'Delimiter','\t', 'HeaderLines',0);
region_names = D{1};
region_ID = D{2};

for i=1:size(value_counts,1)
    regionsInROI{i,1}=region_names((region_ID == value_counts(i,1)));
    regionsInROI{i,2}=value_counts(i,2);
    regionsInROI{i,3}=value_counts(i,2)./value_counts_atlas(value_counts_atlas(:,1)==value_counts(i,1),2);
end

figure; pie([regionsInROI{[regionsInROI{:,2}]>=thresh_plot,2}]',string([regionsInROI([regionsInROI{:,2}]>=thresh_plot,1)]))
1==1;

