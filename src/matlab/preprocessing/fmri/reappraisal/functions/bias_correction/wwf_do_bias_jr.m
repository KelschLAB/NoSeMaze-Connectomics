function Pout=wwf_do_bias_jr(P,P3d_orig,flags);

if nargin < 3
    flags.nbins=1024; % predefined by Natalia/Wolfgang
    flags.reg=0.01; % predefined by Natalia/Wolfgang
    flags.cutoff=35; % predefined by Natalia/Wolfgang
end


[fpath, fname, ext]=fileparts(P);
Psimp=[fpath filesep fname '.nii']
Pfirst=[fpath filesep fname '.nii,1'];
Ptmp='temp.nii';
V1=spm_vol(Pfirst);
Vo1=V1;
mtx1=spm_read_vols(V1);
%mtx1(mtx1>2000)=2000;
Vo1.fname=Ptmp;
spm_write_vol(Vo1,mtx1);
%T=spm_bias_estimate([fpath filesep fname '.nii,1'] ,flags);
T=spm_bias_estimate(Ptmp ,flags);
Vall=spm_vol(Psimp);
Vorig=spm_vol(P3d_orig);
%Vnew=Vall;
for nv=1:length(Vall)
    Vnew(nv)=spm_bias_apply(Vall(nv),T);
    [fpath, fname, ext]=fileparts(Psimp);
    outname=[fpath filesep 'bc_' fname '.nii'];
    Vnew(nv).fname=outname;
    spm_write_vol(Vnew(nv),Vnew(nv).dat);
    
    VorigNew(nv)=spm_bias_apply(Vorig(nv),T);
    [fpath, fname, ext]=fileparts(P3d_orig);
    outname=[fpath filesep 'bc_' fname '.nii'];
    VorigNew(nv).fname=outname;
    spm_write_vol(VorigNew(nv),VorigNew(nv).dat);
end
Pout=Vnew(1).fname