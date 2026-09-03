function do_smooth_lw(Pcur,fwhm)
% DO_SMOOTH_LW Apply isotropic SPM smoothing to a 4-D NIfTI series.
%
% Examples:
%   do_smooth_lw(Pcur,0.6)  -> prefix s6_
%   do_smooth_lw(Pcur,0.5)  -> prefix s5_
%   do_smooth_lw(Pcur,0.4)  -> prefix s4_
%
% The historical project naming convention encodes FWHM in tenths of a
% millimetre in the output prefix.

if nargin < 2
    error('Usage: do_smooth_lw(Pcur,fwhm)');
end

if ~isnumeric(fwhm) || isempty(fwhm) || any(~isfinite(fwhm(:)))
    error('fwhm must contain finite numeric values.');
end

if isscalar(fwhm)
    fwhm = repmat(double(fwhm),1,3);
else
    fwhm = double(fwhm(:)');
end

if numel(fwhm) ~= 3
    error('fwhm must be a scalar or a three-element vector.');
end

if max(abs(fwhm - fwhm(1))) > 1e-12
    error([ ...
        'The NoSeMaze preprocessing naming convention expects isotropic ' ...
        'smoothing. Received [%g %g %g] mm.' ...
    ],fwhm(1),fwhm(2),fwhm(3));
end

[fdir,fname,~] = fileparts(Pcur);
Pcurn = spm_select('ExtFPlist',fdir,['^' regexptranslate('escape',fname) '\.nii$'],1:5000);

if isempty(Pcurn)
    error('No NIfTI volumes found for smoothing input:\n%s',Pcur);
end

job_smooth;

matlabbatch{1}.spm.spatial.smooth.data = cellstr(Pcurn);
matlabbatch{1}.spm.spatial.smooth.fwhm = fwhm;
matlabbatch{1}.spm.spatial.smooth.prefix = sprintf('s%d_',round(fwhm(1)*10));

spm_jobman('run',matlabbatch);
end
