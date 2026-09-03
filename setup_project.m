function repoRoot = setup_project()
%SETUP_PROJECT Minimal repository bootstrap for NoSeMaze-Connectomics.
%
% Usage:
%   repoRoot = setup_project();
%
% This helper intentionally does NOT call:
%
%   addpath(genpath(fullfile(repoRoot,'src','matlab')))
%
% because the repository contains analysis-specific toolboxes and
% implementations with potentially overlapping function names.
%
% Figure scripts are designed to determine the repository root from their
% own saved locations. For upstream preprocessing/analysis, run the relevant
% module-specific main_* entry point documented in:
%
%   src/matlab/README.md

    scriptFile = mfilename('fullpath');

    if isempty(scriptFile)
        error( ...
            ['Could not determine setup_project.m location. ' ...
             'Run the saved file from the repository root.'] ...
        );
    end

    repoRoot = fileparts(scriptFile);

    requiredDirs = {
        fullfile(repoRoot,'data')
        fullfile(repoRoot,'figures')
        fullfile(repoRoot,'results')
        fullfile(repoRoot,'src')
    };

    missingDirs = requiredDirs(~cellfun(@isfolder,requiredDirs));

    if ~isempty(missingDirs)
        error( ...
            'Repository directories are missing:\n%s', ...
            strjoin(missingDirs,newline) ...
        );
    end

    % Standard result roots are safe to create.
    resultDirs = {
        fullfile(repoRoot,'results','main')
        fullfile(repoRoot,'results','supplement')
    };

    for i = 1:numel(resultDirs)
        if ~isfolder(resultDirs{i})
            mkdir(resultDirs{i});
        end
    end

    fprintf('\nNoSeMaze-Connectomics repository detected:\n%s\n\n',repoRoot);
    fprintf('Figure navigation: FIGURE_MAP.md\n');
    fprintf('MATLAB workflow:   src/matlab/README.md\n');
    fprintf(['No global MATLAB path was added. Run the relevant figure ' ...
             'or module-specific main_* script.\n\n']);
end
