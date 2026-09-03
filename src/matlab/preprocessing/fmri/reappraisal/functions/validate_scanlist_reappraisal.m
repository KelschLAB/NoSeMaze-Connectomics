function scanInfo = validate_scanlist_reappraisal(scanListFile)
% VALIDATE_SCANLIST_REAPPRAISAL Validate the reappraisal MRI acquisition list.
%
% The original scan list contains acquisition rows beyond the six scan
% types required by the preprocessing workflow. These additional localizer,
% test, and adjustment rows are retained for provenance but ignored by the
% core preprocessing.
%
% Required scan types per subject:
%   EPI_RS
%   EPI_reappraisal
%   Fieldmap_1
%   Fieldmap_2
%   Fieldmap_3
%   TurboRARE3D
%
% OUTPUT
%   scanInfo.table
%       original complete scan table
%
%   scanInfo.coreTable
%       rows belonging to the six core scan types
%
%   scanInfo.subjects
%       stable list of subject IDs
%
%   scanInfo.coreManifest
%       one row per subject, with Expno for each core scan type

arguments
    scanListFile (1,:) char
end

if ~isfile(scanListFile)
    error('Scan list not found:\n%s',scanListFile);
end

scanTable = readtable( ...
    scanListFile, ...
    'VariableNamingRule', ...
    'preserve' ...
);

requiredColumns = {
    'Subject Comment'
    'Subject ID'
    'Subject Name'
    'Study'
    'Examination'
    'Expno'
    'Image Comment'
};

missingColumns = setdiff( ...
    requiredColumns, ...
    scanTable.Properties.VariableNames ...
);

if ~isempty(missingColumns)
    error( ...
        'Scan list is missing required column(s): %s', ...
        strjoin(missingColumns, ', ') ...
    );
end

coreScanTypes = {
    'EPI_RS'
    'EPI_reappraisal'
    'Fieldmap_1'
    'Fieldmap_2'
    'Fieldmap_3'
    'TurboRARE3D'
};

subjectIDs = unique( ...
    string(scanTable.('Subject ID')), ...
    'stable' ...
);

subjectIDs = subjectIDs(strlength(subjectIDs) > 0);

coreRows = ismember( ...
    string(scanTable.Examination), ...
    string(coreScanTypes) ...
);

coreTable = scanTable(coreRows, :);

manifest = table();

for subjectIndex = 1:numel(subjectIDs)

    subjectID = subjectIDs(subjectIndex);

    subjectRows = ...
        string(coreTable.('Subject ID')) == subjectID;

    current = coreTable(subjectRows, :);

    if isempty(current)
        error('No core scans found for %s.',subjectID);
    end

    subjectNameValues = unique(current.('Subject Name'));

    if numel(subjectNameValues) ~= 1
        error('Subject Name is inconsistent for %s.',subjectID);
    end

    newRow = table( ...
        subjectID, ...
        subjectNameValues(1), ...
        'VariableNames', ...
        {'Subject_ID','Subject_Name'} ...
    );

    for scanIndex = 1:numel(coreScanTypes)

        scanType = coreScanTypes{scanIndex};

        matchingRows = strcmp( ...
            string(current.Examination), ...
            scanType ...
        );

        if sum(matchingRows) ~= 1
            error( ...
                '%s has %d rows for %s; expected exactly one.', ...
                subjectID, ...
                sum(matchingRows), ...
                scanType ...
            );
        end

        variableName = matlab.lang.makeValidName(scanType);

        newRow.(variableName) = ...
            current.Expno(matchingRows);
    end

    manifest = [manifest; newRow]; %#ok<AGROW>
end

% Ensure no core scan type is missing from any subject.
expectedCoreRows = ...
    numel(subjectIDs) * numel(coreScanTypes);

if height(coreTable) ~= expectedCoreRows
    error( ...
        ['Unexpected number of core scan rows: %d. ' ...
         'Expected %d (%d subjects x %d scan types).'], ...
        height(coreTable), ...
        expectedCoreRows, ...
        numel(subjectIDs), ...
        numel(coreScanTypes) ...
    );
end

scanInfo = struct();

scanInfo.table = scanTable;
scanInfo.coreTable = coreTable;
scanInfo.subjects = cellstr(subjectIDs);
scanInfo.coreScanTypes = coreScanTypes;
scanInfo.coreManifest = manifest;

fprintf( ...
    ['Validated reappraisal scan list: %d subjects; ' ...
     'exactly one of each of %d core scan types per subject.\n'], ...
    numel(subjectIDs), ...
    numel(coreScanTypes) ...
);
end
