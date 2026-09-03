function res=wwf_polish_mask2(imtx,params)

if nargin <2
    params.ErodeNum=6;
    params.DilateNum=6;
end

nx=2;
ny=4;
if max(params.ErodeNum,params.DilateNum) >8
    nx=5;ny=5;
end

ix=find(imtx);
[x y z]=ind2sub(size(imtx),ix);
zm=floor(mean(z));
res=double(imtx);

fprintf('\nEroding: ');
for n=1:params.ErodeNum
    fprintf('%d ',n);
    res=spm_erode(res);
    figure(11);subplot(nx,ny,n);imagesc(squeeze(res(:,:,zm)));axis off;
end
fprintf('\n');

fprintf('Dilating: ');
try
    figure(9);imagesc(squeeze(imtx(:,:,zm)));
catch
    keyboard
end
for n=1:params.DilateNum
    fprintf('%d,',n);
    res=spm_dilate(res);
    try
        figure(10);subplot(nx,ny,n);imagesc(squeeze(res(:,:,zm)));axis off;
    catch
        keyboard;
    end
end
