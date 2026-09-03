function geom = infer_eyelid_geometry(dlc)
% INFER_EYELID_GEOMETRY Identify two corners and 3 upper/3 lower points.
%
% Geometry is inferred from the median valid frame so numeric landmark names
% are also supported.

valid = dlc.validFrame;
assert(any(valid),'No frame has all eight valid eyelid landmarks.');

x = median(dlc.x(valid,:),1,'omitnan');
y = median(dlc.y(valid,:),1,'omitnan');

[~,leftCorner] = min(x);
[~,rightCorner] = max(x);
assert(leftCorner~=rightCorner,'Could not identify two distinct eye corners.');

remaining = setdiff(1:8,[leftCorner rightCorner],'stable');

x1 = x(leftCorner); y1 = y(leftCorner);
x2 = x(rightCorner); y2 = y(rightCorner);

% Compare each point with the straight line joining both eye corners.
yLine = y1 + (x(remaining)-x1) .* (y2-y1) ./ (x2-x1);
deltaY = y(remaining)-yLine;

upper = remaining(deltaY<0); % image y increases downward
lower = remaining(deltaY>0);

assert(numel(upper)==3 && numel(lower)==3, ...
    ['Geometry inference did not produce 3 upper and 3 lower landmarks. ' ...
     'Check landmark placement/bodypart selection.']);

[~,ord] = sort(x(upper)); upper = upper(ord);
[~,ord] = sort(x(lower)); lower = lower(ord);

geom = struct();
geom.leftCorner = leftCorner;
geom.rightCorner = rightCorner;
geom.upper = upper;
geom.lower = lower;
geom.upperWithCorners = [leftCorner upper rightCorner];
geom.lowerWithCorners = [leftCorner lower rightCorner];
end
