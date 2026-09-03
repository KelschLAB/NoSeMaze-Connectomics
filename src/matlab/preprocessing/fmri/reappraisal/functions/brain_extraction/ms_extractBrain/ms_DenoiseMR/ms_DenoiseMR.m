function [ noise ] = ms_DenoiseMR( P )
%MS_DENOISEMR Summary of this function goes here
%   Detailed explanation goes here

if nargin <1
    P=spm_select;
end

if isempty(which('RicianSTD'))
    addpath(genpath(fileparts(which('ms_DenoiseMR'))))
end

verbose=0;
if ischar(P)
    VI=spm_vol(P);
    ima=spm_read_vols(VI);
    writeImage=1;
else
    ima=P;
    writeImage=0;
end
ima_orig=ima;
s=size(ima);

% fixed range
map = isnan(ima(:));
ima(map) = 0;
map = isinf(ima(:));
ima(map) = 0;
mini = min(ima(:));
ima = ima - mini;
maxi=max(ima(:));
ima=ima*256/maxi;

rician=1;
beta =1;
[hfinal, ho, SNRo, hbg, SNRbg] = MRINoiseEstimation(ima, rician, verbose);

MRIdenoised = MRIDenoisingPRINLM(ima, hfinal, beta, rician, verbose);

map = find(MRIdenoised<0);
MRIdenoised(map)=0;

% Original intensity range
MRIdenoised= MRIdenoised*maxi/256;
MRIdenoised =MRIdenoised + mini;

suffixfile='_denoised';
VO = VI; % copy input info for output image
[pathstr, name_s, ext]=fileparts(P);
nout=[name_s suffixfile ext];
outfilename =fullfile(pathstr, nout);
VO.fname = outfilename;
VO.dim=s;
spm_write_vol(VO,MRIdenoised(:,:,:));

% a noise image
noise = ima_orig - MRIdenoised;

end

