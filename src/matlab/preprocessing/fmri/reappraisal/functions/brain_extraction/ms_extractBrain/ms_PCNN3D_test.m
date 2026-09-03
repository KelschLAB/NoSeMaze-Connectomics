function [ Pout, finalBrainSize ] = ms_PCNN3D_test(P, BrSize )
%MS_PCNN3D Summary of this function goes here
%   Detailed explanation goes here

verb = 0; % verbose mode
ToSkip = 0; % iterations to skip the actual brain mask calculation; but PCNN runs! NOT recommended!
showResult = 1; % final check_reg and iteration figure

if isempty(which('findit')); addpath(genpath([fileparts(which('ms_PCNN3D')) filesep 'PCNN3D_matlab'])); end
if isempty(which('ms_spm_bias_estimate')); addpath(genpath([fileparts(which('ms_extractBrain')) filesep 'spm_stuff'])); end

if nargin <1
    P=spm_select;
end

V=spm_vol([P ',1']); %V=V(1);
Mtx=spm_read_vols(V); 
voxdim=spm_imatrix(V.mat); voxdim=abs(voxdim(7:9));
% tmp=V.mat*[1 1 1 0]'; voxdim=abs(tmp(1:3)); % is this "more" correct?
[d,name,ext]=fileparts(P);
totVol=numel(Mtx)*prod(voxdim)/1000;

if nargin <2
    if ~isempty(strfind(P,'ZI_M')) % that should work; maybe better to calculate the whole volume size
        BrSize=[350,650]*1000; % brain size range for mouse (mm3). If you use 10x data, this should be 10x too (for each dimension!)
%         BrSize=[250,450]*1000; % for epis
    else
        BrSize=[1200,3000]*1000; % brain size range for RAT (mm3)
    end
end

if nargin <3
    if prod(voxdim)<10; flag.r=3; flag.p=5; else; flag.r=2; flag.p=2; end % r is for PCNN; p for morphological smooting; for anatomical 3/5 seems okay; for EPIs it's more 2/2-3
end
p=flag.p;
r=flag.r;

[ Vtmp ] = ms_predictBrain( P );
%% make bias correction
flags.nbins=128; flags.reg=0.0001; flags.cutoff=55;
T=ms_spm_bias_estimate(Vtmp ,flags);
% Vbc = V; Vbc.fname = [d filesep 'bc_' name ext]; copyfile(V.fname, Vbc.fname);
Vbc = spm_bias_apply(V,T); % apply it on the original image
Vbc.fname = [d filesep 'bc_' name ext];
spm_write_vol(Vbc, Vbc.dat);
%% get slices we can cut
predMtx=spm_read_vols(Vtmp); SlToRem=false(1,size(predMtx,3)); for ix=1:size(predMtx,3); if ~any(predMtx(:,:,ix)); SlToRem(ix)=true; end; end
loc=find(~SlToRem); if loc(1)>2 && loc(end)<size(Mtx,3)-5; SlToRem(loc(1)-2:loc(end)+5)=false; end
%% preprocess the image
[S, Vproc] = ms_preprocImage(Mtx, Vbc, voxdim);
% S=spm_read_vols(Vbc); S = reshape(imadjust(S(:)./max(S(:))),size(S));
% Vproc = V; Vproc.dt(1)=16;
% [d,name,ext]=fileparts(V.fname);
% Vproc.fname = [d filesep name '_procInp' ext]; 
% spm_write_vol(Vproc, S);
S_orig=S;
S(:,:,SlToRem)=[];
%% check if BrSize is set correctly
if BrSize(2)>=length(find(Mtx))*prod(voxdim)
    BrSize(2)=floor(length(find(Mtx))*prod(voxdim));
    fprintf('upper Limit of BrainSize is bigger than the provided image!\n Setting BrainSize to %.2f\n', BrSize(2)/1000)
end

%% setup; in the paper they mention r=3 and p=4; but it seems r=p (more or less confirmed)
% if prod(voxdim)<10; r=3; p=5; else; r=2; p=2; end % r is for PCNN; p for morphological smooting; for anatomical 3/5 seems okay; for EPIs it's more 2/3

% M = scaledgauss(r, voxdim./min(voxdim), 0.5);
M = ms_3Dgaussian(r, voxdim./min(voxdim), 0.5); % more or less the same as scaledgauss
% se = strel('sphere',p); % that is for erode and dilate
% TR = makehgtform('scale',voxdim./min(voxdim));
% NH = imwarp(se.Neighborhood, affine3d(inv(TR)));
NH = ms_3Dsphere(p, voxdim./min(voxdim));
% NH = ms_3Dsphere(p, voxdim); % better than the normalized version? not always
se = strel('arbitrary', NH); % adapt it to the actual voxel dimensions
tic
N=60; % doesn't look like we need more than 60 iterations
Y=zeros(size(S)); F = Y; L = F;  T = Y + 1; %U = F;
A = logical(Y); BW=false([N, size(S,1), size(S,2), size(S,3)]);
t =1; brainSize=0;
% for t = 1:N
while brainSize<BrSize(2)/1000
    [F,L,T,Y] = calcPCNN_mex(F,L,T,Y,M,S);
    A = A | logical(Y);
    if t>ToSkip % to save time we could skip the first iterations
        [BW(t+1,:,:,:)] = calcBrainMask(A,se); % this takes the most time ~1-2s for high res images
        vox(t+1)=length(find(BW(t+1,:,:,:)))*prod(voxdim)/1000; brainSize=vox(t+1);
        fprintf('#%.0f: BrainSize: %.2f mm^3 (%.2f of total Volume)\n',t, vox(t+1), vox(t+1)/totVol)
        if verb; plotSomething(squeeze(BW(t+1,:,:,:)), A, Y, T,F,L,vox,t,Mtx); end
        %         if vox(t+1)>BrSize(2)/1000; break; end
        %         if t>3 && vox(t)>0; if vox(t)==vox(t-2); vox(end)=BrSize(2)/1000*1.1; break; end; end
        if t>30 && vox(t)>0
            if vox(t)<=vox(t-10)*1.01
                vox(end)=BrSize(2)/1000*1.1; warndlg(sprintf('I was trapped and stopped the iteration!\n%s',name)); break;
            end
        end
    end
    t=t+1;
end
toc

% add the removed slices again
tmp=BW; BW=false([size(tmp,1), size(Mtx)]); BW(:,:,:,~SlToRem)=tmp;
S=S_orig;
optIteration = findOptIter(vox, BrSize, BW, S, showResult, name);
mask=squeeze(BW(optIteration,:,:,:)); %mask(~mask)=NaN;
finalBrainSize = vox(optIteration);

%% write a brain and mask
Vbrain = V;
Vbrain.fname = [d filesep 'bc_' name '_brain' ext]; Pout=Vbrain.fname;
% spm_write_vol(Vbrain, Mtx.*mask);
spm_write_vol(Vbrain, spm_read_vols(Vbc).*mask);
Vmask = V;
Vmask.fname = [d filesep name '_brainmask' ext]; 
spm_write_vol(Vmask, mask);
if showResult
    spm_check_registration(char([V.fname ',1'],Vtmp.fname,Vproc.fname,Vbrain.fname, Vmask.fname))
end

%% save the masks
BW(t+2:end,:,:,:)=[];
BC=V.fname; I_border = BW; G_I = vox; optG = optIteration; % renaming to be in line with the gui 
save([d filesep 'BrainMasks_' name '.mat'], 'I_border', 'G_I', 'optG','BC');

end

% function [Fn,Ln,Tn,Yn] = calcPCNN(F,L,T,Y,M,S)
% K = convn(Y,M,'same');
% Fn = exp(-log(2)/0.3).*F + 0.01*K + S;
% Ln = exp(-log(2)/1).*L + 0.2.*K;
% Un = Fn.*(1+0.2*Ln);
% Tn = exp(-log(2)/10).*T + 20.*Y;
% Yn = double(Un>Tn);
% end

function plotSomething(BW, A, Y, T,F,L,vox,t,IM)
figure(22);
sl=floor(size(A,3)/2)+4;
subplot(2,4,1); imagesc(squeeze(BW(:,:,sl))); title(['Mask, n=' num2str(t)]);
subplot(2,4,2); imagesc(squeeze(A(:,:,sl))); title(['A']);
subplot(2,4,3); imagesc(squeeze(Y(:,:,sl))); title(['Y']);
subplot(2,4,4); imagesc(squeeze(T(:,:,sl))); title(['T']);
subplot(2,4,5); imagesc(double(squeeze(IM(:,:,sl)))); title(['Image']);
subplot(2,4,6); plot(vox); title(['voxel']);
subplot(2,4,7); imagesc(squeeze(F(:,:,sl))); title(['F']);
subplot(2,4,8); imagesc(squeeze(L(:,:,sl))); title(['L']);
pause(0.1)
end

function [BW] = calcBrainMask(A, se)
BW = false(size(A));
A = imerode(A,se);
% A=imfill(A,'holes');
% A=imfill(A,26,'holes');
CC = bwconncomp(A,26); % 6 or 26? it doesn't make a big difference but it seems in the paper they use 26
numPixels = cellfun(@numel,CC.PixelIdxList);
[biggest,idx] = max(numPixels);
if ~isempty(idx)
    BW(CC.PixelIdxList{idx}) = true; 
    BW=imdilate(BW,se); 
%     BW=imfill(BW,26,'holes'); % this takes long and does not fill all the holes
    for ix=1:size(BW,3); BW(:,:,ix)=imfill(BW(:,:,ix),'holes'); end % that is quicker, not really "correct"; but it works okay
%     for ix=1:size(BW,2); BW(:,ix,:)=imfill(BW(:,ix,:),'holes'); end % that is quicker, not really "correct"; but it works okay
end
end

function optIteration = findOptIter(vox, BrSize, BW, S, showResult, name)
% dv=diff(diff(vox(vox>BrSize(1)/1000))); dv=dv(1:end-1);
% optIteration=round((find(dv==max(dv))+find(dv==min(dv)))/2 + find(vox>BrSize(1)/1000,1)) - 1; % that should represent the paper approach
% fprintf('The paper would prob. say %.2f\n', optIteration)
% optIteration=find(cumsum(dv)>0,1)+ find(vox>BrSize(1)/1000,1)-1;
% optIteration=find(stdfilt(vox(vox>BrSize(1)/1000))>mean(stdfilt(vox(vox>BrSize(1)/1000))),1)+ find(vox>BrSize(1)/1000,1)-1;
% assume the best iteration in the last third
% voxnorm=vox./max(vox);
% c=round(length(vox)*2/3);
% stdvox=stdfilt(voxnorm(c:end)); optIteration= find(stdvox>mean(stdvox(1:floor(length(stdvox)/2)))*1.5,1) + c -2; % that works pretty well
% can we use the gradient field to get rid of these little blobs? they
% often disappear some iterations before: works sometimes..
mask=squeeze(BW(end,:,:,:));
[Gmag] = (imgradient3(S.*mask)); Gmag=Gmag./max(Gmag(:)); se = strel('sphere',1);
for ix=0:10
    mask=squeeze(BW(end-ix,:,:,:)); Bou =  mask - imerode(mask,se); % get the boundary of the mask
    tmp=Gmag(logical(Bou)); %tmp=S(logical(Bou));
    OL(ix+1)=mean(tmp(tmp>0));%/voxnorm(optIteration-ix); % the highest overlap value should do the trick
end
[~,idx]=sort(OL,'descend'); optIteration=length(vox)-idx(1)-1;
fprintf('Gradient operation says %.0f or maybe %.0f\n', optIteration,length(vox)-idx(2)-1)
% paper approach
[paper]=findit(vox*1000,BrSize); % that is the paper approach
fprintf('The orig. paper says %.0f [%.0f %.0f]\n', paper(2), paper(1),paper(3)); 

% another approach: find the plateau
voxsmall=vox(vox>BrSize(1)/1000);
stdvox=stdfilt(diff(voxsmall)./voxsmall(2:end)); pl=find(stdvox<min(stdvox)*6); pl=pl+(length(vox)-length(voxsmall)); % I don't like this "6".. but don't know how to make it better
if ~isempty(pl)
    optIteration=pl(1)+round((pl(end)-pl(1))/2);
else
    fprintf('Own approach failed! Using the paper approach.\n');
    optIteration=paper(2); pl =[paper(1) paper(3)];
end
fprintf('I guess the best Iteration is number %.0f; Brain Volume: %.2f\n', optIteration, vox(optIteration))
if showResult
    figure(10); plot(vox); hold on; plot(optIteration, vox(optIteration), 'ro'); line([pl(1) pl(1)], [0 BrSize(2)/1000], 'Color', 'g'); line([pl(end) pl(end)], [0 BrSize(2)/1000], 'Color', 'g'); title(name, 'Interpreter', 'none'); hold off;
end
% save('vox.mat', 'vox')
end
