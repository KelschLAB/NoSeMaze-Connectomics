function intensity_normalization(P);

Vi=spm_vol(P);
immtx_allfr=NaN([Vi(1).dim,length(Vi)]);

for iy=1:length(Vi)
    immtx=spm_read_vols(Vi(iy));
    immtx(immtx==0)=NaN;
    immtx_allfr(:,:,:,iy)=immtx;
end
n=numel(immtx_allfr);
i_allfr_resh=reshape(immtx_allfr,[n,1]);
med=nanmedian(i_allfr_resh);
immtx_allfr_med1000=immtx_allfr-med+100000;
%% test
testmed=nanmedian(reshape(immtx_allfr_med1000,[n,1]));
if testmed~=100000
    error('median not 1000!')
end
%%
Vo=Vi;
[fdir, fname, ext]=fileparts(P);

for iy=1:length(Vi)
    Vo(iy).fname=[fdir filesep 'med100000_' fname '.nii'];% NB: ",1" is not necessary
    spm_write_vol(Vo(iy),squeeze(immtx_allfr_med1000(:,:,:,iy)))
end
