function res=nii2ana(P)

if nargin == 0
    P=spm_select(inf,'image','Select input files');
end
nfiles=size(P,1)
for n=1:nfiles
    Pn=deblank(P(n,:));
    V1=spm_vol(Pn);
    [pthstr inname ext]=fileparts(Pn);
    outname=[inname '_spm2'];
    V2=V1;
    V2.fname=[pthstr filesep outname '.img'];
    disp(['Saving to ' pthstr filesep outname '.img']);
    matname=[pthstr filesep outname '.mat'];
    spm_write_vol(V2,spm_read_vols(V1));
    M=V1.mat;
    save(matname,'M','-V6');
end