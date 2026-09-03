function protocolFile = find_control_protocol_file(cfg, subjectID, scannerID)
% FIND_CONTROL_PROTOCOL_FILE Locate the processed protocol using scanlist IDs.
%
% Historical folders used <scannerID>_<YYMMDD>. Using the supplied scanlist
% avoids old filename-specific exceptions (including the 230906C/3205 case).

subjectID = char(subjectID);
dateToken = erase(subjectID, 'ZI_M');
dateToken = dateToken(1:6);

stem = sprintf('%d_%s', scannerID, dateToken);

matches = dir(fullfile(cfg.protocolDir, '**', [stem '*']));
matches = matches(~[matches.isdir]);

if isempty(matches)
    protocolFile = '';
    return;
end

if numel(matches) > 1
    paths = strings(numel(matches),1);
    for i = 1:numel(matches)
        paths(i) = string(fullfile(matches(i).folder, matches(i).name));
    end
    error('Multiple protocol files found for %s:\n%s', ...
        subjectID, strjoin(paths,newline));
end

protocolFile = fullfile(matches(1).folder, matches(1).name);
end
