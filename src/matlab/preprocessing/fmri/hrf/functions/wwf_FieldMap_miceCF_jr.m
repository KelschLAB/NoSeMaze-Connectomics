
function outputFiles = wwf_FieldMap_miceCF_jr(Pdir)
% WWF_FIELDMAP_MICECF_JR Prepare corrected HRF field maps for SPM.
%
% Adapted from the supplied historical wwf_FieldMap_rat implementation.
% It:
%   1. selects the corrected acq0 field map (*_cf.nii);
%   2. resaves it with the fpm_ prefix;
%   3. divides by the Bruker RECO_map_slope;
%   4. writes the SPM2 Analyze representation used by the historical
%      downstream field-map code.

if nargin < 1 || isempty(Pdir)
    error('A field-map directory must be supplied.');
end

if ischar(Pdir)
    if isrow(Pdir)
        dirs = {Pdir};
    else
        dirs = cellstr(Pdir);
    end
elseif isstring(Pdir)
    dirs = cellstr(Pdir);
elseif iscell(Pdir)
    dirs = Pdir;
else
    error('Unsupported Pdir input type.');
end

outputFiles = cell(numel(dirs),1);

for i = 1:numel(dirs)

    Pcur = strtrim(dirs{i});
    assert(isfolder(Pcur),'Field-map directory missing:\n%s',Pcur);

    fieldmap = spm_select( ...
        'FPList',Pcur, ...
        '^Z.*acq0_reorient_cf\.nii$' ...
    );

    assert(size(fieldmap,1)==1, ...
        'Expected one corrected acq0 field map in %s; found %d.', ...
        Pcur,size(fieldmap,1));

    fieldmap = strtrim(fieldmap);

    [fdir,name,ext] = fileparts(fieldmap);
    newFieldmap = fullfile(fdir,['fpm_' name ext]);

    if isfile(newFieldmap)
        delete(newFieldmap);
    end

    ppt_resave(fieldmap,newFieldmap);

    brkhdr = spm_select('FPList',Pcur,'^Z.*\.brkhdr$');
    assert(size(brkhdr,1)==1, ...
        'Expected one Bruker header in %s; found %d.', ...
        Pcur,size(brkhdr,1));

    hdr = readBrukerParamFile(strtrim(brkhdr));

    assert(isfield(hdr,'RECO_map_slope'), ...
        'RECO_map_slope missing from %s.',strtrim(brkhdr));

    slope = hdr.RECO_map_slope(1);
    assert(isfinite(slope) && slope~=0, ...
        'Invalid RECO_map_slope in %s.',strtrim(brkhdr));

    V = spm_vol(newFieldmap);
    img = spm_read_vols(V);
    spm_write_vol(V,img./slope);

    % Creates fpm_*_spm2.img/.hdr/.mat, matching the historical workflow.
    nii2ana(newFieldmap);

    outputFiles{i} = newFieldmap;
end

end
