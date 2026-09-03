function validate_full_hierarchy(newHierarchy,referenceFile)
% VALIDATE_FULL_HIERARCHY Compare recomputed day-wise match matrices.

reference = load(referenceFile,'full_hierarchy');
oldHierarchy = reference.full_hierarchy;

if numel(newHierarchy)~=numel(oldHierarchy)
    error('Day count differs: new %d vs old %d.', ...
        numel(newHierarchy),numel(oldHierarchy));
end

for dayIndex = 1:numel(newHierarchy)

    newMatrix = newHierarchy(dayIndex).match_matrix;
    oldMatrix = oldHierarchy(dayIndex).match_matrix;

    if ~isequal(size(newMatrix),size(oldMatrix)) || ~isequaln(newMatrix,oldMatrix)
        error('Match matrix differs on day %d.',dayIndex);
    end
end

fprintf('Validation successful: all day-wise match matrices match %s\n',referenceFile);
end
