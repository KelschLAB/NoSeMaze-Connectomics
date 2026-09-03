
function protocolFile = find_hrf_protocol_file( ...
    processedProtocolDir,subjectName,epiFile)
% FIND_HRF_PROTOCOL_FILE Match a processed protocol to an HRF EPI session.

[~,epiName,~] = fileparts(epiFile);

subjectName = char(subjectName);
assert(numel(subjectName)>=2,'Unexpected HRF subject name: %s',subjectName);

animalDir = fullfile( ...
    processedProtocolDir, ...
    ['animal_' subjectName(2:end)]);

assert(isfolder(animalDir), ...
    'Processed HRF protocol directory not found:\n%s',animalDir);

D = dir(fullfile(animalDir,'*.mat'));

% Historical matching used characters 5:10 of the EPI filename.
assert(numel(epiName)>=10,'Unexpected HRF EPI filename: %s',epiName);
dateToken = epiName(5:10);

keep = contains({D.name},dateToken);
D = D(keep);

assert(numel(D)==1, ...
    'Expected one HRF protocol match for %s; found %d.', ...
    epiName,numel(D));

protocolFile = fullfile(D.folder,D.name);

end
