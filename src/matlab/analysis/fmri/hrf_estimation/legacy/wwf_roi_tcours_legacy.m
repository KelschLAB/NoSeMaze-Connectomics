
function [tc,roidata]=wwf_roi_tcours(Pmsk,Pdata)

if nargin<1
    Pmsk=spm_select(1,'any','Select Mask',[],pwd,'.*..nii');
end

if nargin<2
    Pdata=spm_select(1,'image','Select Image');
end

[fpath,fname,~]=fileparts(Pdata);
V2=spm_vol(Pmsk);
Vcur=spm_vol([fpath filesep fname '.nii']);
V1=Vcur(1);
Vi=[V1 V2];
Vo=V1;
Vo.fname=[fpath filesep fname '_mask.nii'];
Vmask_func=spm_imcalc(Vi,Vo,'i2',{0,0,0});

nimg=size(Vcur,1); %#ok<NASGU>
mtx_func=spm_read_vols(Vcur);
funcsize=size(mtx_func);
mtx_func=reshape(mtx_func,prod(funcsize(1:3)),funcsize(4));

mtx_mask=spm_read_vols(Vmask_func);
mtx_mask(isnan(mtx_mask))=0;

indx=find(mtx_mask);
roidat=mtx_func(indx,:);
nanIndex=any(isnan(roidat),2);

[x,y,z]=ind2sub(size(mtx_mask),indx);
pos=[x y z];
pos_mtx=[pos ones(size(pos,1),1)];
pos_mm=Vmask_func.mat*pos_mtx';
pos_mm=pos_mm(1:3,:);

meantime=squeeze(mean(roidat(~nanIndex,:)));

roidata.pos=pos(~nanIndex,:);
roidata.pos_mm=pos_mm;
roidata.tc=roidat(~nanIndex,:);

[~,mskname]=fileparts(Pmsk);

save([fpath filesep fname '_' mskname '_roidata.mat'],'roidata');

tc=meantime;
end
