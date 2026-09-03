
function merge_residuals_jr(outputdir)
% Jonathan Reinwald 06/2021 based on script by Laurens Winkelmeier

cd(outputdir);
firstleveldir=spm_select(1,'dir', ...
    'Select directory including firstlevel_residuals directory!');

dirlist = dir(firstleveldir);
dirlist = dirlist(contains({dirlist.name},'ZI_M'));
numbersess = numel(dirlist);

spm fmri

for sess = 1:numbersess

    sessiondir = [firstleveldir filesep dirlist(sess).name];
    P = spm_select('ExtFPlistrec',sessiondir,'ResI_*');

    try
        clear matlabbatch
        matlabbatch{1}.spm.util.cat.vols = cellstr(P);
        matlabbatch{1}.spm.util.cat.name = ...
            ['4D_residuals_' dirlist(sess).name '.nii'];
        matlabbatch{1}.spm.util.cat.dtype = 0;
        spm_jobman('run',matlabbatch);

        cd(sessiondir);
        delete('ResI_*')
    catch
    end
end
end
