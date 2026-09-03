function do_secondlevel_GLM_to_NoSeMaze_jr( ...
    outputDir_secondlevel, contrast_info, firstlevelDir, explicit_mask, ExplVar)
% DO_SECONDLEVEL_GLM_TO_NOSEMAZE_JR
% Run a second-level SPM regression for one explanatory variable.
%
% Required batch template:
%   job_secondlevel_GLM_to_NoSeMaze_jr.m
%
% This cleaned version preserves the historical SPM settings while making
% subject/covariate alignment explicit. Contrast images are identified from
% each subject's SPM.mat by contrast name, not by recursive file ordering.

if numel(ExplVar) ~= 1
    error('ExplVar must contain exactly one explanatory variable.');
end

requiredFields = {'name','values','AnimalNumb'};
for fieldIndex = 1:numel(requiredFields)
    if ~isfield(ExplVar, requiredFields{fieldIndex})
        error('ExplVar is missing field "%s".', requiredFields{fieldIndex});
    end
end

if numel(ExplVar.values) ~= numel(ExplVar.AnimalNumb)
    error('ExplVar.values and ExplVar.AnimalNumb must have the same length.');
end

if isempty(which('job_secondlevel_GLM_to_NoSeMaze_jr'))
    error([ ...
        'Missing job_secondlevel_GLM_to_NoSeMaze_jr.m. ' ...
        'Copy the historical batch-template script into this functions folder.' ...
    ]);
end

if ~isfolder(outputDir_secondlevel)
    mkdir(outputDir_secondlevel);
end

for contrastIndex = 1:numel(contrast_info.names)

    contrastName = contrast_info.names{contrastIndex};
    contrastType = contrast_info.test{contrastIndex};

    clear matlabbatch
    job_secondlevel_GLM_to_NoSeMaze_jr

    if ~exist('matlabbatch','var')
        error('job_secondlevel_GLM_to_NoSeMaze_jr.m did not create matlabbatch.');
    end

    safeContrastName = matlab.lang.makeValidName(contrastName);
    outputDir = fullfile(outputDir_secondlevel, safeContrastName);

    if isfolder(outputDir)
        fprintf('Skipping existing output: %s\n', outputDir);
        continue;
    end

    mkdir(outputDir);
    matlabbatch{1}.spm.stats.factorial_design.dir = {outputDir};

    % Collect first-level images and subject numbers in exactly the same order.
    [inputFiles, subjectNumbers] = collect_firstlevel_contrasts( ...
        firstlevelDir, ...
        contrastName, ...
        contrastType ...
    );

    matlabbatch{1}.spm.stats.factorial_design.des.t1.scans = inputFiles(:);

    % Explicit mask
    matlabbatch{1}.spm.stats.factorial_design.masking.em = {explicit_mask};
    matlabbatch{1}.spm.stats.factorial_design.masking.im = 0;

    % Align explanatory values to actual included first-level subjects.
    animalNumbers = ExplVar.AnimalNumb(:);
    values = ExplVar.values(:);
    alignedValues = nan(numel(subjectNumbers),1);

    for subjectIndex = 1:numel(subjectNumbers)

        matchIndex = find(animalNumbers == subjectNumbers(subjectIndex));

        if isempty(matchIndex)
            error( ...
                'No %s value found for animal ZI_M%02d.', ...
                ExplVar.name, ...
                subjectNumbers(subjectIndex) ...
            );
        end

        if numel(matchIndex) > 1
            error( ...
                'Multiple %s values found for animal ZI_M%02d.', ...
                ExplVar.name, ...
                subjectNumbers(subjectIndex) ...
            );
        end

        alignedValues(subjectIndex) = values(matchIndex);
    end

    if any(~isfinite(alignedValues))
        error('Aligned values for %s contain NaN/Inf.', ExplVar.name);
    end

    % Save exact second-level input ordering for provenance.
    inputManifest = table( ...
        subjectNumbers(:), ...
        alignedValues(:), ...
        string(inputFiles(:)), ...
        'VariableNames', ...
        {'AnimalNumber', ExplVar.name, 'ContrastFile'} ...
    );

    writetable( ...
        inputManifest, ...
        fullfile(outputDir, 'secondlevel_input_manifest.csv') ...
    );

    % Historical covariate settings.
    matlabbatch{1}.spm.stats.factorial_design.cov.c = alignedValues;
    matlabbatch{1}.spm.stats.factorial_design.cov.cname = ExplVar.name;
    matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1;
    matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 1;
    matlabbatch{1}.spm.stats.factorial_design.multi_cov = ...
        struct('files', {}, 'iCFI', {}, 'iCC', {});

    % Historical second-level design: intercept + one covariate.
    matlabbatch{3}.spm.stats.con.spmmat = cfg_dep( ...
        'Model estimation: SPM.mat File', ...
        substruct('.','val','{}',{2},'.','val','{}',{1},'.','val','{}',{1}), ...
        substruct('.','spmmat') ...
    );

    matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'mean+';
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.weights = [1 0];
    matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'mean-';
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.weights = [-1 0];
    matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.consess{3}.tcon.name = [ExplVar.name '+'];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.weights = [0 1];
    matlabbatch{3}.spm.stats.con.consess{3}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.consess{4}.tcon.name = [ExplVar.name '-'];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.weights = [0 -1];
    matlabbatch{3}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

    matlabbatch{3}.spm.stats.con.delete = 0;

    spm_jobman('run', matlabbatch);
end

end
