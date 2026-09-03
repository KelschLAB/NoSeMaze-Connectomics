%% master_create_mask_of_DARTELtemplate(P_template)
% 
function master_create_mask_of_DARTELtemplate(P_template)

V1=spm_vol([P_template ',1']);
V2=spm_vol([P_template ',2']);
Vi=[V1 V2];
Vo=V1;
[fdir,fname,ext]=fileparts(V1.fname);
Vo.fname=[fdir filesep 'mask_template_6.nii'];
Vmask=spm_imcalc(Vi,Vo,['(i1+i2)>0.15'],{0, 0, 0});

mask=spm_read_vols(Vmask);
params.ErodeNum=5;
mask_new=zeros(size(mask,1)+params.ErodeNum*2+2,size(mask,2)+params.ErodeNum*2+2,size(mask,3)+params.ErodeNum*2+2);
mask_new(params.ErodeNum+2:size(mask_new,1)-params.ErodeNum-1,params.ErodeNum+2:size(mask_new,2)-params.ErodeNum-1,params.ErodeNum+2:size(mask_new,3)-params.ErodeNum-1)=mask;
mask_new=wwf_polish_mask(mask_new,params);
mask=mask_new(params.ErodeNum+2:size(mask_new,1)-params.ErodeNum-1,params.ErodeNum+2:size(mask_new,2)-params.ErodeNum-1,params.ErodeNum+2:size(mask_new,3)-params.ErodeNum-1);
Vout=Vmask;
[fdir,fname,ext]=fileparts(Vout.fname);
Vout.fname=[fdir filesep 'mask_template_6_polished.nii'];
spm_write_vol(Vout,single(mask));
