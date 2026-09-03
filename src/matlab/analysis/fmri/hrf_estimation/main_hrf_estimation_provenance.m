%% main_hrf_estimation_provenance.m
% Validate and document the final study-specific HRF endpoint.

clearvars;
clc;

scriptFile = mfilename('fullpath');
thisDir = fileparts(scriptFile);

repoRoot = thisDir;
while ~isfile(fullfile(repoRoot,'NoSeMaze-Connectomics.Rproj')) && ...
        ~isfolder(fullfile(repoRoot,'.git'))
    parent = fileparts(repoRoot);
    if strcmp(parent,repoRoot)
        break;
    end
    repoRoot = parent;
end

cfg = hrf_estimation_config(repoRoot);

assert(isfile(cfg.final.functionFile), ...
    'Final mouse HRF function is missing:\n%s',cfg.final.functionFile);

fprintf('Study-specific mouse HRF provenance\n');
fprintf('  HRF cohort      : n = %d\n',cfg.nSessions);
fprintf('  acquisition TR  : %.3f s\n',cfg.acquisition.TR);
fprintf('  trials          : %d\n',cfg.paradigm.nTrials);
fprintf('  durations       : %.1f / %.1f / %.1f s\n', ...
    cfg.paradigm.durationsSec);
fprintf('  individual mask : top %.0f%% odor-responsive voxels\n', ...
    cfg.step1.maxVoxelFraction*100);
fprintf('  final model     : %s\n',cfg.final.label);

fprintf('\nFinal SPM-HRF parameters:\n');
disp(cfg.final.parameters);

fprintf('Final implementation:\n%s\n',cfg.final.functionFile);

if isfile(cfg.final.sourceDataMouse)
    fprintf('Mouse HRF source data:\n%s\n',cfg.final.sourceDataMouse);
end

if isfile(cfg.final.sourceDataHuman)
    fprintf('Human HRF comparison source data:\n%s\n', ...
        cfg.final.sourceDataHuman);
end
