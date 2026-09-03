
function res=wwf_FieldMap_rat(Pdir)
start=pwd;
if nargin < 1
    Pdir=spm_select(inf,'dir','Field-Map Ordner waehlen');
end

for i=1:size(Pdir,1)
    Pcur=deblank(Pdir(i,:));
    fieldmap=spm_select('FPlist',Pcur,'^Z.*acq0_reorient_cf.nii$');
    [path,name,ext]=fileparts(fieldmap);
    newfieldmap=fullfile(path,['fpm_' name ext]);
    ppt_resave(deblank(fieldmap),deblank(newfieldmap));
    brkhdr=spm_select('FPlist',Pdir,'^Z.*.brkhdr');
    hdr=readBrukerParamFile(brkhdr);
    val=hdr.RECO_map_slope(1);
    V=spm_vol(newfieldmap);
    imtx=spm_read_vols(V);
    spm_write_vol(V,imtx/val);
    nii2ana(newfieldmap)
end
cd(start)
res=1;
end
