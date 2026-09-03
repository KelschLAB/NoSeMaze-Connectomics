function [ Vout ] = ms_predictBrain( P )
%MS_PREDICTBRAIN Summary of this function goes here
%   Detailed explanation goes here
if nargin<1
P=spm_select;
end
[d,name,ext]=fileparts(P);

V=spm_vol(P); V=V(1);
Mtx=spm_read_vols(V); Mtx_orig=Mtx;

load([fileparts(which('ms_predictBrain')) filesep 'Mdl32.mat']);
eval(flag.process);
% Mtx=reshape(histeq(Mtx(:)./max(Mtx(:))),size(Mtx)); Mtx=Mtx*3000;

% load([fileparts(which('ms_predictBrain')) filesep 'Mdl.mat']);
% Mtx = imresize3(Mtx, [32 32 16], 'nearest');


Mtx = imresize3(Mtx, flag.imgsize, 'nearest');

%% predict whole image
% set other parameters if you want
% Mdl.NumNeighbors=6; Mdl.Distance='minkowski';
tic
[x,y,z]=ind2sub(size(Mtx),1:length(Mtx(:)));
tmp=[x',y',z',Mtx(:)];
estBrain=reshape(strcmp(predict(Mdl, tmp),'brain'), size(Mtx));
toc
%%
BW=zeros(size(estBrain));
se = strel('sphere',1);
estBrain=imerode(estBrain,se);
estBrain=imfill(estBrain,'holes');
CC = bwconncomp(estBrain,6); % 6 or 26? 
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
BW(CC.PixelIdxList{idx}) = 1; 
figure, imagesc(BW(:,:,floor(size(Mtx,3)/2)))
%% cubic interpolation.. so lala
% BW=imresize3((BW), [size(Mtx_orig)]); BW(BW>0.2)=1;
%% dilate and "smooth"; works fine; to be sure maybe set the strel to 2
BW=imdilate(BW,strel('sphere',1));
BW=imresize3((BW), [size(Mtx_orig)], 'nearest'); 
BW=imgaussfilt3(BW,2); BW(BW>0.2)=1;


Vout=V; Vout.fname=[d filesep name '_estBrain' ext]; %Vout.dt(1)=16;
spm_write_vol(Vout, Mtx_orig.*BW);

spm_check_registration(V,Vout)
end

