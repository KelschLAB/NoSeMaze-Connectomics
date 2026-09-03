function protocolFile = find_subject_protocol_file(protocolDir, animalNumber)
% FIND_SUBJECT_PROTOCOL_FILE Find unique MAT file containing events.

animalDir = fullfile( ...
    protocolDir, ...
    sprintf('animal_%02d', animalNumber) ...
);

if ~isfolder(animalDir)
    error('Protocol folder not found:\n%s', animalDir);
end

files = dir(fullfile(animalDir, '**', '*.mat'));

matches = false(numel(files), 1);

for fileIndex = 1:numel(files)

    filePath = fullfile(files(fileIndex).folder, files(fileIndex).name);

    vars = whos('-file', filePath);

    matches(fileIndex) = ...
        any(strcmp({vars.name}, 'events'));
end

files = files(matches);

if numel(files) ~= 1
    error( ...
        'Expected one protocol MAT containing events for animal %02d; found %d.', ...
        animalNumber, ...
        numel(files) ...
    );
end

protocolFile = fullfile(files(1).folder, files(1).name);

end
