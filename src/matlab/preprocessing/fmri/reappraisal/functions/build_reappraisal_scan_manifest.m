function manifest = build_reappraisal_scan_manifest( ...
    scanListFile, ...
    outputDir ...
)
% BUILD_REAPPRAISAL_SCAN_MANIFEST Create a clean subject-by-scan manifest.
%
% This function reduces the complete historical scan list to the six
% acquisitions used by the fMRI preprocessing. It does not locate the
% actual MRI files; it records the acquisition number (Expno) associated
% with each required scan type.
%
% The complete original CSV should remain in data/reference/ for
% provenance. The generated manifest is an interim preprocessing product.

arguments
    scanListFile (1,:) char
    outputDir (1,:) char
end

if ~isfolder(outputDir)
    mkdir(outputDir);
end

scanInfo = validate_scanlist_reappraisal(scanListFile);

manifest = scanInfo.coreManifest;

csvOutput = fullfile( ...
    outputDir, ...
    'scan_manifest_reappraisal.csv' ...
);

matOutput = fullfile( ...
    outputDir, ...
    'scan_manifest_reappraisal.mat' ...
);

writetable(manifest, csvOutput);

save( ...
    matOutput, ...
    'manifest', ...
    'scanInfo' ...
);

fprintf('Saved scan manifest:\n%s\n',csvOutput);
fprintf('Saved scan manifest MAT:\n%s\n',matOutput);
end
