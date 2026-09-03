function [DS_info,DS_info_chasing] = compute_hierarchy_window( ...
    full_hierarchy,includeDays,excludeIDs)
% COMPUTE_HIERARCHY_WINDOW Sum daily matrices and compute David's scores.

arguments
    full_hierarchy (1,:) struct
    includeDays (1,:) double
    excludeIDs cell = {}
end

canonicalIDs = cellstr(string(full_hierarchy(1).ID(:)));
includeAnimal = ~ismember(string(canonicalIDs),string(excludeIDs));
includedIDs = canonicalIDs(includeAnimal);

nIncluded = sum(includeAnimal);
fullMatch = zeros(nIncluded,nIncluded);

hasChasing = all(arrayfun(@(x)isfield(x,'match_matrix_chasing'), ...
    full_hierarchy(includeDays)));

if hasChasing
    fullChasing = zeros(nIncluded,nIncluded);
end

for dayIndex = includeDays
    fullMatch = fullMatch + ...
        full_hierarchy(dayIndex).match_matrix(includeAnimal,includeAnimal);

    if hasChasing
        fullChasing = fullChasing + ...
            full_hierarchy(dayIndex).match_matrix_chasing(includeAnimal,includeAnimal);
    end
end

DS_info = compute_DS_from_match_matrix(fullMatch);
DS_info.ID = includedIDs;
[~,idx] = sort(DS_info.DS,'descend');
[~,DS_info.rank] = sort(idx);
DS_info.sortedID = DS_info.ID(DS_info.DS_sortedIndex);

if hasChasing
    DS_info_chasing = compute_DS_from_match_matrix(fullChasing);
    DS_info_chasing.ID = includedIDs;
    [~,idx] = sort(DS_info_chasing.DS,'descend');
    [~,DS_info_chasing.rank] = sort(idx);
    DS_info_chasing.sortedID = ...
        DS_info_chasing.ID(DS_info_chasing.DS_sortedIndex);
else
    DS_info_chasing = struct();
end
end
