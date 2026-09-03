
function [tc,roidata] = extract_roi_timecourse(maskFile,dataFile,outputFile)
% EXTRACT_ROI_TIMECOURSE Mean BOLD time course within a binary ROI mask.
%
% Cleaned version of the supplied historical wwf_roi_tcours function.
% The mask is resampled to the first functional volume using nearest-neighbor
% interpolation, matching the historical spm_imcalc approach.

assert(isfile(maskFile),'ROI mask not found:\n%s',maskFile);
assert(isfile(dataFile),'Functional 4-D NIfTI not found:\n%s',dataFile);

Vdata = spm_vol(dataFile);
Vmask = spm_vol(maskFile);

[dataDir,dataName,~] = fileparts(dataFile);
[~,maskName,~] = fileparts(maskFile);

resampledMask = fullfile( ...
    dataDir, ...
    sprintf('%s_%s_mask_resampled.nii',dataName,maskName));

Vout = Vdata(1);
Vout.fname = resampledMask;
Vout.dt = [spm_type('uint8') 0];

Vi = [Vdata(1) Vmask];

VmaskFunc = spm_imcalc(Vi,Vout,'i2',{0,0,0});

func = spm_read_vols(Vdata);
funcSize = size(func);

if numel(funcSize)<4
    funcSize(4) = 1;
end

func2d = reshape(func,prod(funcSize(1:3)),funcSize(4));

mask = spm_read_vols(VmaskFunc);
mask(isnan(mask)) = 0;

idx = find(mask~=0);

roi = func2d(idx,:);
badVoxel = any(isnan(roi),2);

roi = roi(~badVoxel,:);

[x,y,z] = ind2sub(size(mask),idx);
pos = [x y z];
pos = pos(~badVoxel,:);

posHom = [pos ones(size(pos,1),1)];
posMm = (VmaskFunc.mat * posHom')';
posMm = posMm(:,1:3);

tc = mean(roi,1);

roidata = struct();
roidata.pos = pos;
roidata.pos_mm = posMm;
roidata.tc = roi;

if nargin >= 3 && ~isempty(outputFile)
    outDir = fileparts(outputFile);
    if ~isempty(outDir) && ~isfolder(outDir)
        mkdir(outDir);
    end
    save(outputFile,'roidata','tc');
end

end
