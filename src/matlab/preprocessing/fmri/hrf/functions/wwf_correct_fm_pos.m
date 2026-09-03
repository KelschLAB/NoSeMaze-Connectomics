
function wwf_correct_fm_pos(Pdmap)
% WWF_CORRECT_FM_POS Correct historical left/right field-map displacement.
%
% Input
%   Pdmap  converted field-map directory
%
% Output
%   Every *reorient.nii image in the directory tree is copied to
%   *_cf.nii and its affine is shifted according to
%   PVM_SPackArrSliceOffset.
%
% Historical mouse/SPM coordinates were scaled by a factor of 10; this
% factor is intentionally preserved.

if nargin < 1 || isempty(Pdmap)
    error('A field-map directory must be supplied.');
end

Pdmap = char(Pdmap);

assert(isfolder(Pdmap), ...
    'Field-map input is not a directory:\n%s',Pdmap);

Phdr = spm_select('FPList',Pdmap,'.*\.brkhdr$');
assert(size(Phdr,1)==1, ...
    'Expected one Bruker header in %s; found %d.',Pdmap,size(Phdr,1));

hdr = readBrukerParamFile(strtrim(Phdr));

assert(isfield(hdr,'PVM_SPackArrSliceOffset'), ...
    'PVM_SPackArrSliceOffset missing from %s.',strtrim(Phdr));

shiftLR = hdr.PVM_SPackArrSliceOffset;

PimgList = spm_select('FPListRec',Pdmap,'.*reorient\.nii$');

assert(~isempty(PimgList), ...
    'No *reorient.nii images found below:\n%s',Pdmap);

for i = 1:size(PimgList,1)

    sourceFile = strtrim(PimgList(i,:));
    [fdir,fname,ext] = fileparts(sourceFile);

    % Do not recursively correct files already carrying the correction
    % suffix.
    if endsWith(fname,'_cf')
        continue;
    end

    correctedFile = fullfile(fdir,[fname '_cf' ext]);

    ppt_resave(sourceFile,correctedFile);

    M = spm_get_space(correctedFile);
    spm_get_space( ...
        correctedFile, ...
        spm_matrix([shiftLR*10 0 0]) * M ...
    );
end

end
