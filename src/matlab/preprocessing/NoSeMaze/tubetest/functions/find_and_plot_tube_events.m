function find_and_plot_tube_events(logDir,outputDir,overwriteExisting)
% FIND_AND_PLOT_TUBE_EVENTS Extract daily competition events and QC plots.

arguments
    logDir (1,:) char
    outputDir (1,:) char
    overwriteExisting (1,1) logical = false
end

if ~isfolder(logDir)
    error('LOG directory not found:\n%s',logDir);
end
if ~isfolder(outputDir)
    mkdir(outputDir);
end

logFiles = dir(fullfile(logDir,'LOG_*.mat'));
if isempty(logFiles)
    error('No LOG_*.mat files found in:\n%s',logDir);
end

[~,order] = sort(string({logFiles.name}));
logFiles = logFiles(order);

for fileIndex = 1:numel(logFiles)

    inputFile = fullfile(logFiles(fileIndex).folder,logFiles(fileIndex).name);
    loaded = load(inputFile,'Data');

    if ~isfield(loaded,'Data') || isempty(loaded.Data)
        fprintf('Skipping empty LOG: %s\n',inputFile);
        continue;
    end

    [~,logName] = fileparts(inputFile);
    currentOutputDir = fullfile(outputDir,logName);
    dataOutputFile = fullfile(currentOutputDir,'Data.mat');

    if isfile(dataOutputFile) && ~overwriteExisting
        fprintf('Keeping existing: %s\n',dataOutputFile);
        continue;
    end

    if ~isfolder(currentOutputDir)
        mkdir(currentOutputDir);
    end

    fprintf('Extracting competitions: %s\n',logFiles(fileIndex).name);

    hierarchy_data = extract_tube_tests_from_LOG_clean(inputFile);
    hierarchy_data.save_dir = currentOutputDir;

    plot_tube_test_events(hierarchy_data);

    save(dataOutputFile,'hierarchy_data','-v7.3');
end
end
