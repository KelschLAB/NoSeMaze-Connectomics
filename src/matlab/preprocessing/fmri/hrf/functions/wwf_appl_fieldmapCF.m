
function matlabbatch = wwf_appl_fieldmapCF(Pfmdir,Pfunci,P3di)
% WWF_APPL_FIELDMAPCF Create/apply the HRF voxel-displacement map.
%
% Preserves the historical HRF settings:
%   - corrected full field map (*_cf_spm2.img)
%   - corrected p2 magnitude image
%   - total EPI readout time =
%       PVM_EpiEchoSpacing * PVM_EpiNEchoes
%   - blip direction = -1

if nargin < 1 || isempty(Pfmdir)
    error('Field-map directory is required.');
end

if nargin < 2 || isempty(Pfunci)
    error('Functional EPI image is required.');
end

Pfmdir = char(Pfmdir);
Pfunci = char(Pfunci);

assert(isfolder(Pfmdir),'Field-map directory missing:\n%s',Pfmdir);

PB0map = spm_select( ...
    'ExtFPList',Pfmdir, ...
    '^full_fpm_.*_cf_spm2\.img$',1);

assert(~isempty(PB0map), ...
    'Prepared full field map not found in:\n%s',Pfmdir);

Pmagmap = spm_select( ...
    'ExtFPList',fullfile(Pfmdir,'p2'), ...
    '^ZI.*_acq0_reorient_cf\.nii$',1);

assert(~isempty(Pmagmap), ...
    'Corrected magnitude image not found below:\n%s',fullfile(Pfmdir,'p2'));

funcFile = regexprep(strtrim(Pfunci),',\d+$','');
[fdir,~,~] = fileparts(funcFile);

hdrfile = spm_select('FPList',fdir,'.*\.brkhdr$');
assert(size(hdrfile,1)==1, ...
    'Expected one EPI Bruker header in %s; found %d.', ...
    fdir,size(hdrfile,1));

hdr = readBrukerParamFile(strtrim(hdrfile));

assert(isfield(hdr,'PVM_EpiEchoSpacing') && ...
       isfield(hdr,'PVM_EpiNEchoes'), ...
    'EPI echo-spacing information missing from %s.',strtrim(hdrfile));

EpiTime = hdr.PVM_EpiEchoSpacing * hdr.PVM_EpiNEchoes;

% Load the historical SPM field-map defaults that are already distributed
% with the shared preprocessing functions, then overwrite all session-
% specific fields exactly as in the supplied HRF helper.
clear matlabbatch
job_create_vdm

matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj. ...
    precalcfieldmap{1} = PB0map;

matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj. ...
    magfieldmap{1} = Pmagmap;

matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj. ...
    session.epi{1} = Pfunci;

matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj. ...
    defaults.defaultsval.tert = EpiTime;

matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj. ...
    defaults.defaultsval.blipdir = -1;

if nargin >= 3 && ~isempty(P3di)
    matlabbatch{1}.spm.tools.fieldmap.precalcfieldmap.subj. ...
        anat{1} = char(P3di);
end

spm_jobman('run',matlabbatch);

end
