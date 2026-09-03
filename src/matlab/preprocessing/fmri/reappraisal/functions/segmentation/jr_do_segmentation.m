function jr_do_segmentation(P3d,templates)
% 
% Input: 
% P3d should be a (to template) coregistered 3D

if nargin < 1
    P3d=spm_select(1, 'image', '3D-Data (non brain extracted)');
end

job_segment
matlabbatch{1}.spm.spatial.preproc.data = cellstr(P3d);
matlabbatch{1}.spm.spatial.preproc.output.GM = [0 0 1];
matlabbatch{1}.spm.spatial.preproc.output.WM = [0 0 1];
matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 0 1];
matlabbatch{1}.spm.spatial.preproc.opts.tpm = templates
% {
%                                                };
matlabbatch{1}.spm.spatial.preproc.opts.regtype = 'subj';

spm_jobman('run',matlabbatch);
1==1;


