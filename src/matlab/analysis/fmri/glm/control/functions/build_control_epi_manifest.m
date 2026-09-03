function manifest = build_control_epi_manifest(cfg)

subjects = build_control_subject_manifest(cfg);

EPI_File = strings(height(subjects),1);

for i = 1:height(subjects)
    EPI_File(i) = string(find_control_epi( ...
        cfg, char(subjects.Subject_ID(i))));
end

manifest = [subjects table(EPI_File)];
manifest.Has_EPI = strlength(manifest.EPI_File) > 0;

end
