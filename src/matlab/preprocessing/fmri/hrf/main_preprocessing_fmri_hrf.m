
%% main_preprocessing_fmri_hrf.m
%
% HRF-cohort fMRI preprocessing master.
%
% This is the cleaned/public counterpart of:
%
%
% It preserves the historical processing order while replacing absolute
% project paths with repository/configuration paths and explicit stage
% switches.
%
% Final HRF-analysis branch:
%
%   raw Bruker MRI
%       ↓
%   remove first 25 volumes
%       ↓
%   field-map correction + realignment/unwarping
%       ↓
%   slice timing
%       ↓
%   anatomical processing / template alignment
%       ↓
%   DARTEL normalization + reslicing
%       ↓
%   s5 smoothing
%       ↓
%   brain masking
%       ↓
%   msk_s5_rwrst_a1_u_del25_*_c2t.nii
%
% The raw MRI data are not distributed.

clearvars;
close all;
clc;

%% Locate repository

scriptFile = mfilename('fullpath');
if isempty(scriptFile)
    error('Run the complete saved script rather than selected lines.');
end

scriptDir = fileparts(scriptFile);             % .../fmri/hrf
fmriDir = fileparts(scriptDir);                % .../fmri
preprocessingRoot = fileparts(fmriDir);        % .../preprocessing

helpersDir = fullfile(preprocessingRoot,'helpers');
functionsDir = fullfile(scriptDir,'functions');
toolboxesDir = fullfile(preprocessingRoot,'toolboxes');
sharedReappraisalFunctions = fullfile(fmriDir,'reappraisal','functions');

assert(isfolder(helpersDir),'Missing preprocessing helpers:\n%s',helpersDir);
addpath(helpersDir);

repoRoot = find_repo_root(scriptFile);

% Shared preprocessing implementations used by all three fMRI cohorts.
if isfolder(sharedReappraisalFunctions)
    addpath(genpath(sharedReappraisalFunctions));
end

% HRF-specific functions are added afterwards so they take precedence over
% similarly named historical/shared variants.
if isfolder(functionsDir)
    addpath(genpath(functionsDir));
end

% Add only preprocessing-relevant repository toolboxes.
spm12AnimalDir = fullfile(toolboxesDir,'spm12_animal');
waveletDir = fullfile(toolboxesDir,'wavelet_despiking');

if isfolder(spm12AnimalDir); addpath(genpath(spm12AnimalDir)); end
if isfolder(waveletDir); addpath(genpath(waveletDir)); end

cfg = fmri_hrf_config(repoRoot);

for d = {cfg.workRoot,cfg.convertedDir,cfg.fileListDir, ...
        cfg.dartelDir,cfg.motionDir,cfg.processedRoot}
    if ~isfolder(d{1}); mkdir(d{1}); end
end

%% Stage selection

runStage.convert = false;
runStage.buildFileList = false;
runStage.correctFieldmapPosition = false;
runStage.removeDummies = false;
runStage.prepareAndApplyFieldmap = false;
runStage.realignUnwarp = false;
runStage.sliceTime = false;
runStage.anatomicalPreprocessing = false;
runStage.templateAlignment = false;
runStage.dartel = false;
runStage.resliceToOriginalVoxel = false;
runStage.smoothPrimary = false;
runStage.maskPrimary = false;
runStage.optionalWaveletDespike = false;

%% Status

if isempty(cfg.rawMriRoot) || ~isfolder(cfg.rawMriRoot)
    fprintf([ ...
        '\nHRF raw MRI root is not configured.\n' ...
        'Set:\n' ...
        '  NOSEMAZE_HRF_FMRI_RAW_ROOT\n\n' ...
        'This is expected for the public repository because the raw HRF ' ...
        'MRI acquisitions are not distributed.\n\n' ...
    ]);
end

fprintf('HRF acquisition: TR %.3f s, %d slices, %d volumes.\n', ...
    cfg.TR,cfg.nSlices,cfg.nVolumes);

%% 1. ParaVision conversion
%
% Historical code used do_pvconv_jr. This stage remains optional because
% converted NIfTIs may already exist in a private historical tree.

if runStage.convert

    require_function('do_pvconv_jr');

    assert(~isempty(cfg.rawMriRoot) && isfolder(cfg.rawMriRoot), ...
        'NOSEMAZE_HRF_FMRI_RAW_ROOT is not configured.');

    assert(isfile(cfg.scanList), ...
        'HRF scan list not found:\n%s',cfg.scanList);

    T = readtable(cfg.scanList,'VariableNamingRule','preserve');
    subjectIDs = unique(string(T{:,1}),'stable');

    for i = 1:numel(subjectIDs)

        subjectID = char(subjectIDs(i));
        outDir = fullfile(cfg.convertedDir,subjectID);

        if ~isfolder(outDir); mkdir(outDir); end

        do_pvconv_jr( ...
            [cfg.rawMriRoot filesep], ...
            outDir, ...
            subjectID ...
        );
    end
end

%% 2. Build EPI/anatomical/field-map file list

if runStage.buildFileList
    build_hrf_filelist(cfg);
end

if ~isfile(cfg.fileList)
    fprintf([ ...
        '\nHRF file list not present yet:\n%s\n' ...
        'Enable buildFileList after converted NIfTIs and the scan list ' ...
        'are available.\n\n' ...
    ],cfg.fileList);
else
    F = load(cfg.fileList,'Pfunc','Pfunc_subjName','P3d','Pdmap');
end

%% The remaining stages require the historical file list.

needsFileList = any([ ...
    runStage.correctFieldmapPosition, ...
    runStage.removeDummies, ...
    runStage.prepareAndApplyFieldmap, ...
    runStage.realignUnwarp, ...
    runStage.sliceTime, ...
    runStage.anatomicalPreprocessing, ...
    runStage.templateAlignment, ...
    runStage.dartel, ...
    runStage.resliceToOriginalVoxel, ...
    runStage.smoothPrimary, ...
    runStage.maskPrimary, ...
    runStage.optionalWaveletDespike ...
]);

if needsFileList && ~exist('F','var')
    error('Enabled preprocessing stages require cfg.fileList.');
end

%% 3. Correct field-map position

if runStage.correctFieldmapPosition

    require_function('wwf_correct_fm_pos');

    for i = 1:numel(F.Pdmap)
        wwf_correct_fm_pos(F.Pdmap{i});
    end
end

%% 4. Remove first 25 EPI volumes

if runStage.removeDummies

    require_function('wwf_del_vol');

    for i = 1:numel(F.Pfunc)

        [fdir,fname,~] = fileparts(F.Pfunc{i});

        P = spm_select( ...
            'ExtFPList',fdir, ...
            ['^' regexptranslate('escape',fname) '\.nii$'], ...
            1 ...
        );

        assert(~isempty(P),'Original EPI not found for %s.',fname);

        wwf_del_vol(P,cfg.nDummies);
    end
end

%% 5. Prepare and apply field map

if runStage.prepareAndApplyFieldmap

    require_function('wwf_FieldMap_miceCF_jr');
    require_function('fieldmap_fill_dilate_jr');
    require_function('wwf_appl_fieldmapCF');

    for i = 1:numel(F.Pdmap)

        wwf_FieldMap_miceCF_jr(F.Pdmap{i});

        Pfm = spm_select( ...
            'FPList',F.Pdmap{i}, ...
            '^fpm_ZI.*_acq0_reorient_cf_spm2\.img$' ...
        );

        assert(~isempty(Pfm),'Prepared field map not found for session %d.',i);

        fieldmap_fill_dilate_jr(Pfm);

        [fdir,fname,~] = fileparts(F.Pfunc{i});

        PfuncFirst = spm_select( ...
            'ExtFPList',fdir, ...
            ['^del25_' regexptranslate('escape',fname) '\.nii$'], ...
            1 ...
        );

        wwf_appl_fieldmapCF(F.Pdmap{i},PfuncFirst,F.P3d{i});
    end
end

%% 6. Realignment and unwarping

if runStage.realignUnwarp

    require_function('do_unwarp_jr');

    for i = 1:numel(F.Pfunc)

        [fdir,fname,~] = fileparts(F.Pfunc{i});

        PfuncFirst = spm_select( ...
            'ExtFPList',fdir, ...
            ['^del25_' regexptranslate('escape',fname) '\.nii$'], ...
            1 ...
        );

        do_unwarp_jr(F.Pdmap{i},PfuncFirst);
    end
end

%% 7. Slice-time correction

if runStage.sliceTime

    require_function('do_slice_time_hrf_jr');

    for i = 1:numel(F.Pfunc)

        [fdir,fname,~] = fileparts(F.Pfunc{i});

        P = spm_select( ...
            'ExtFPList',fdir, ...
            ['^u_del25.*' regexptranslate('escape',fname) '\.nii$'], ...
            1 ...
        );

        do_slice_time_hrf_jr(P);
    end
end

%% 8. Anatomical bias correction + brain extraction

if runStage.anatomicalPreprocessing

    require_function('wwf_do_bias_jr');
    require_function('ms_do_brainExtraction');

    for i = 1:numel(F.P3d)

        [fdir,fname,~] = fileparts(F.P3d{i});

        Porig = spm_select('FPList',fdir, ...
            ['^' regexptranslate('escape',fname) '\.nii$']);

        wwf_do_bias_jr(Porig,Porig);

        Pbias = spm_select('FPList',fdir, ...
            ['^bc_' regexptranslate('escape',fname) '\.nii$']);

        ms_do_brainExtraction(Pbias,[350 600]*1000);
    end
end

%% 9. Shift/coregister anatomy + EPI to common template

if runStage.templateAlignment

    require_function('do_shift_auto_brain_jr_lw');
    require_function('do_coreg_all2temp_pain_lw');
    require_function('wwf_do_bias_jr');
    require_function('jr_do_segmentation');

    assert(isfile(cfg.template),'Template not found:\n%s',cfg.template);

    for i = 1:numel(F.Pfunc)

        [funcDir,funcName,~] = fileparts(F.Pfunc{i});
        [anDir,anName,~] = fileparts(F.P3d{i});

        Pfunc = spm_select('FPList',funcDir, ...
            ['^a1_u_del25_' regexptranslate('escape',funcName) '\.nii$']);

        P3d = spm_select('FPList',anDir, ...
            ['^' regexptranslate('escape',anName) '\.nii$']);

        do_shift_auto_brain_jr_lw(P3d,Pfunc,cfg.template);

        PfuncShifted = spm_select('ExtFPList',funcDir, ...
            ['^st_a1_u_del25_' regexptranslate('escape',funcName) '\.nii$'],1);

        P3dBrainShifted = spm_select('FPList',anDir, ...
            ['^st_' regexptranslate('escape',anName) '_brain\.nii$']);

        P3dWholeShifted = spm_select('FPList',anDir, ...
            ['^st_' regexptranslate('escape',anName) '\.nii$']);

        do_coreg_all2temp_pain_lw( ...
            P3dBrainShifted,P3dWholeShifted,PfuncShifted,cfg.template);

        P3dCoregWhole = spm_select('FPList',anDir, ...
            ['^st_' regexptranslate('escape',anName) '_c2t\.nii$']);

        P3dCoregBrain = spm_select('FPList',anDir, ...
            ['^st_' regexptranslate('escape',anName) '_brain_c2t\.nii$']);

        wwf_do_bias_jr(P3dCoregBrain,P3dCoregWhole);

        PbiasCoreg = spm_select('FPList',anDir, ...
            ['^bc_st_' regexptranslate('escape',anName) '_c2t\.nii$']);

        jr_do_segmentation(PbiasCoreg,cfg.tpm);
    end
end

%% 10. DARTEL import/template/normalization

if runStage.dartel

    require_function('jr_do_DARTEL_inital_import');
    require_function('jr_do_DARTEL_create_templates');
    require_function('spm_dartel_norm_fun_mice_jr');
    require_function('do_reslice');

    Pcur = cell(numel(F.P3d),1);

    for i = 1:numel(F.P3d)

        [anDir,anName,~] = fileparts(F.P3d{i});

        Pcur{i} = spm_select('FPList',anDir, ...
            ['^bc_st_' regexptranslate('escape',anName) ...
             '_c2t_seg_sn\.mat$']);
    end

    jr_do_DARTEL_inital_import( ...
        Pcur,cfg.dartelDir,cfg.dartelImportVoxelSPM);

    Pcur1 = spm_select('ExtFPList',cfg.dartelDir, ...
        '^rc1bc_st_.*_c2t\.nii$',1);
    Pcur2 = spm_select('ExtFPList',cfg.dartelDir, ...
        '^rc2bc_st_.*_c2t\.nii$',1);

    jr_do_DARTEL_create_templates(Pcur1,Pcur2);

    % Normalize anatomy and EPI using the historical study-specific DARTEL
    % template/flow fields.
    for i = 1:numel(F.P3d)

        [anDir,anName,~] = fileparts(F.P3d{i});
        [funcDir,funcName,~] = fileparts(F.Pfunc{i});

        job = struct();

        job.template = {fullfile(cfg.dartelDir,'Template_6.nii')};

        job.data.subj.flowfield = {spm_select( ...
            'FPList',cfg.dartelDir, ...
            ['^u_rc1bc_st_' regexptranslate('escape',anName) ...
             '_c2t_Template\.nii$'])};

        job.data.subj.images = {
            spm_select('FPList',anDir, ...
                ['^c1bc_st_' regexptranslate('escape',anName) '_c2t\.nii$'])
            spm_select('FPList',anDir, ...
                ['^c2bc_st_' regexptranslate('escape',anName) '_c2t\.nii$'])
            spm_select('FPList',anDir, ...
                ['^c3bc_st_' regexptranslate('escape',anName) '_c2t\.nii$'])
        };

        job.vox = [NaN NaN NaN];
        job.bb = [NaN NaN NaN; NaN NaN NaN];
        job.fwhm = [0 0 0];

        for preserve = [0 1]
            job.preserve = preserve;
            spm_dartel_norm_fun_mice_jr(job);
        end

        clear job

        job.template = {fullfile(cfg.dartelDir,'Template_6.nii')};
        job.data.subj.flowfield = {spm_select( ...
            'FPList',cfg.dartelDir, ...
            ['^u_rc1bc_st_' regexptranslate('escape',anName) ...
             '_c2t_Template\.nii$'])};

        PfuncNormInput = spm_select('FPList',funcDir, ...
            ['^rst_a1_u_del25_' regexptranslate('escape',funcName) ...
             '_c2t\.nii$']);

        job.data.subj.images = cellstr(PfuncNormInput);
        job.vox = [NaN NaN NaN];
        job.bb = [NaN NaN NaN; NaN NaN NaN];
        job.fwhm = [0 0 0];
        job.preserve = 0;

        spm_dartel_norm_fun_mice_jr(job);
    end
end

%% 11. Reslice normalized EPI to original ultrafast acquisition grid
%
% The historical master used a single reference volume from one HRF session.
% For portability, the reference is configured externally rather than
% hard-coded into the public script.

if runStage.resliceToOriginalVoxel

    require_function('do_reslice');

    referenceFile = getenv('NOSEMAZE_HRF_REFERENCE_EPI');

    assert(~isempty(referenceFile) && isfile(strtok(referenceFile,',')), ...
        ['Set NOSEMAZE_HRF_REFERENCE_EPI to the historical reference ' ...
         'NIfTI used for reslicing.']);

    for i = 1:numel(F.Pfunc)

        [funcDir,funcName,~] = fileparts(F.Pfunc{i});

        Pcur = spm_select('ExtFPList',funcDir, ...
            ['^wrst_a1_u_del25_' regexptranslate('escape',funcName) ...
             '_c2t\.nii$'],1:cfg.nVolumes-cfg.nDummies);

        Pinput = [cellstr(referenceFile);cellstr(Pcur)];

        do_reslice(Pinput,4);
    end
end

%% 12. Primary s5 smoothing

if runStage.smoothPrimary

    require_function('do_smooth_lw');

    for i = 1:numel(F.Pfunc)

        [funcDir,funcName,~] = fileparts(F.Pfunc{i});

        Pcur = spm_select('ExtFPList',funcDir, ...
            ['^rwrst_a1_u_del25_' regexptranslate('escape',funcName) ...
             '_c2t\.nii$'],1);

        do_smooth_lw(Pcur,cfg.primaryEpi.smoothingSPM);
    end
end

%% 13. Mask primary HRF-analysis EPI
%
% Output:
%   msk_s5_rwrst_a1_u_del25_<session>_c2t.nii

if runStage.maskPrimary

    maskFile = getenv('NOSEMAZE_HRF_DARTEL_MASK');

    assert(~isempty(maskFile) && isfile(maskFile), ...
        'Set NOSEMAZE_HRF_DARTEL_MASK to the historical resliced mask.');

    Vmask = spm_vol(maskFile);
    mask = spm_read_vols(Vmask);
    mask(isnan(mask)) = 0;

    for i = 1:numel(F.Pfunc)

        [funcDir,funcName,~] = fileparts(F.Pfunc{i});

        P = spm_select('ExtFPList',funcDir, ...
            ['^s5_rwrst_a1_u_del25_' regexptranslate('escape',funcName) ...
             '_c2t\.nii$'],1:cfg.nVolumes-cfg.nDummies);

        V = spm_vol(P);
        img = spm_read_vols(V);

        Vout = V;
        outputFile = fullfile(funcDir, ...
            [cfg.primaryEpi.prefix funcName cfg.primaryEpi.suffix '.nii']);

        for j = 1:numel(Vout)
            Vout(j).fname = outputFile;
            spm_write_vol(Vout(j),squeeze(img(:,:,:,j)).*mask);
        end
    end
end

%% 14. Optional historical wavelet-despiking branch
%
% The supplied HRF time-course analysis used the s5 masked branch above.
% Wavelet despiking is retained as an explicitly optional historical branch
% rather than silently defining it as the primary HRF-estimation input.

if runStage.optionalWaveletDespike

    require_function('WaveletDespike');

    for i = 1:numel(F.Pfunc)

        [funcDir,funcName,~] = fileparts(F.Pfunc{i});
        inputFile = fullfile(funcDir, ...
            [cfg.primaryEpi.prefix funcName cfg.primaryEpi.suffix '.nii']);

        assert(isfile(inputFile),'Primary HRF EPI missing:\n%s',inputFile);

        waveDir = fullfile(funcDir,'wavelet');
        if ~isfolder(waveDir); mkdir(waveDir); end

        [~,base,~] = fileparts(inputFile);

        WaveletDespike( ...
            inputFile, ...
            fullfile(waveDir,['wave_' num2str(cfg.waveletThreshold) ...
                'cons_' base]), ...
            'threshold',cfg.waveletThreshold, ...
            'chsearch',cfg.waveletSearch, ...
            'verbose',1, ...
            'LimitRAM',80 ...
        );
    end
end

fprintf('\nHRF fMRI preprocessing pipeline initialized/completed.\n');

function require_function(name)
if isempty(which(name))
    error('Required preprocessing function not found: %s.m',name);
end
end
