function do_secondlevel_jr(outputDir_secondlevel,contrast_info,firstlevelDir,explicit_mask)
% DO_SECONDLEVEL_JR General one-sample second-level SPM analysis.
%
% Required batch template:
%   job_secondlevel_jr.m
%
% The historical scientific logic is retained. Contrast files are now
% resolved from each subject's SPM.mat by contrast name, avoiding fragile
% con_000X / ess_000X string construction.

if isempty(which('job_secondlevel_jr'))
    error('Missing job_secondlevel_jr.m');
end

if ~isfolder(outputDir_secondlevel)
    mkdir(outputDir_secondlevel);
end

for ix = 1:length(contrast_info.names)

    clear matlabbatch
    job_secondlevel_jr

    contrastName = contrast_info.names{ix};
    outputdir = fullfile( ...
        outputDir_secondlevel, ...
        matlab.lang.makeValidName(contrastName) ...
    );

    if ~isfolder(outputdir)
        mkdir(outputdir);
    end

    matlabbatch{1}.spm.stats.factorial_design.dir = {outputdir};

    myInput = collect_firstlevel_contrasts( ...
        firstlevelDir, ...
        contrastName, ...
        contrast_info.test{ix} ...
    );

    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = myInput(:);
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {explicit_mask};
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;

    spm_jobman('run',matlabbatch);
end

end
