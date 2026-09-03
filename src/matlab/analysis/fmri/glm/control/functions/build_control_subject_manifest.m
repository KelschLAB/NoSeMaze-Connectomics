function manifest = build_control_subject_manifest(cfg)
% BUILD_CONTROL_SUBJECT_MANIFEST Build portable subject/scanner mapping.

T = readtable(cfg.scanlist, 'VariableNamingRule', 'preserve');

required = {'Subject','ID','Examn','Study'};
assert(all(ismember(required, T.Properties.VariableNames)), ...
    'Unexpected control scanlist columns.');

[subjectIDs, ia] = unique(string(T.Subject), 'stable');
scannerIDs = T.ID(ia);

manifest = table(subjectIDs, scannerIDs, ...
    'VariableNames', {'Subject_ID','Scanner_ID'});

assert(height(manifest) == 24, ...
    'Expected 24 control animals, found %d.', height(manifest));

end
