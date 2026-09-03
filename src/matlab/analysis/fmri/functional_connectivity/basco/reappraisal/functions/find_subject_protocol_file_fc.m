function protocolFile = find_subject_protocol_file_fc(protocolDir, subjectID, animalNumber)
% FIND_SUBJECT_PROTOCOL_FILE_FC Find one processed event-timing MAT file.

protocolFile = '';

if ~isfolder(protocolDir)
    return;
end

files = dir(fullfile(protocolDir, '**', '*.mat'));
files = files(~[files.isdir]);

if isempty(files)
    return;
end

subjectIDlower = lower(subjectID);

animalTokens = {
    sprintf('animal_%02d', animalNumber)
    sprintf('animal_%d', animalNumber)
    lower(subjectID)
};

scores = zeros(numel(files), 1);

for i = 1:numel(files)

    fullName = lower(fullfile(files(i).folder, files(i).name));

    if contains(fullName, subjectIDlower)
        scores(i) = scores(i) + 20;
    end

    for t = 1:numel(animalTokens)
        if contains(fullName, lower(animalTokens{t}))
            scores(i) = scores(i) + 10;
        end
    end

    if contains(lower(files(i).name), 'protocol')
        scores(i) = scores(i) + 3;
    end

    if contains(lower(files(i).name), 'new')
        scores(i) = scores(i) + 2;
    end
end

maxScore = max(scores);

if maxScore == 0
    return;
end

best = files(scores == maxScore);

if numel(best) > 1
    candidates = strings(numel(best), 1);

    for i = 1:numel(best)
        candidates(i) = string(fullfile(best(i).folder, best(i).name));
    end

    error( ...
        ['More than one equally plausible processed protocol file was found ' ...
         'for %s:\n%s'], ...
        subjectID, ...
        strjoin(candidates, newline) ...
    );
end

protocolFile = fullfile(best(1).folder, best(1).name);

end
