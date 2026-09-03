function addExtractBrain
% ADDEXTRACTBRAIN Add the packaged rodent brain-extraction dependency.

fieldmapDir = fileparts(mfilename('fullpath'));
functionsDir = fileparts(fieldmapDir);
brainExtractionDir = fullfile( ...
    functionsDir,'brain_extraction','ms_extractBrain' ...
);

if ~isfolder(brainExtractionDir)
    error('Brain-extraction directory not found:\n%s',brainExtractionDir);
end

addpath(genpath(brainExtractionDir));
end
