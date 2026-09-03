
function res=wwf_correct_fm_pos(Pdmap)
if exist(Pdmap) ~= 7
    fprintf('Input not directory \n')
    return;
end
Phdr=spm_select('FPList',Pdmap,'.*.brkhdr');
hdr=readBrukerParamFile(Phdr);
shiftlr=hdr.PVM_SPackArrSliceOffset;
Pimglist=spm_select('FPListRec',Pdmap,'.*reorient.nii');

for ix=1:size(Pimglist,1)
    [fdir,fname,~]=fileparts(strtrim(Pimglist(ix,:)));
    Pf_simp=spm_select('FPlist',fdir,['^' fname '.nii']);
    [fdir,fname,ext]=fileparts(Pf_simp);
    Pmcor=[fdir filesep fname '_cf.nii'];
    ppt_resave(Pf_simp,Pmcor);
    M=spm_get_space(Pmcor);
    spm_get_space(Pmcor,spm_matrix([shiftlr*10 0 0])*M);
end
res=1;
end
