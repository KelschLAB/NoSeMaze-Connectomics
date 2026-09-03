function area = compute_eye_opening_area(dlc,geom,cfg)
% COMPUTE_EYE_OPENING_AREA Area between polynomial upper/lower eyelid fits.

nFrames = size(dlc.x,1);
area = nan(nFrames,1);

for f = 1:nFrames
    if ~dlc.validFrame(f)
        continue;
    end

    iu = geom.upperWithCorners;
    il = geom.lowerWithCorners;

    xU = dlc.x(f,iu); yU = dlc.y(f,iu);
    xL = dlc.x(f,il); yL = dlc.y(f,il);

    left = max(min(xU),min(xL));
    right = min(max(xU),max(xL));
    if ~(isfinite(left) && isfinite(right) && right>left)
        continue;
    end

    center = (left+right)/2;
    scale = (right-left)/2;
    if scale<=0; continue; end

    zU = (xU-center)./scale;
    zL = (xL-center)./scale;

    degree = min([cfg.polyDegree numel(xU)-1 numel(xL)-1]);
    pU = polyfit(zU,yU,degree);
    pL = polyfit(zL,yL,degree);

    xGrid = linspace(left,right,cfg.fitGridPoints);
    zGrid = (xGrid-center)./scale;
    yUpper = polyval(pU,zGrid);
    yLower = polyval(pL,zGrid);

    opening = yLower-yUpper;

    % If geometric upper/lower assignment is reversed for a rotated camera,
    % correct the sign globally within this frame.
    if median(opening,'omitnan') < 0
        opening = -opening;
    end

    % Polynomial crossings indicate a poor fit; do not allow negative area.
    opening(opening<0) = 0;
    area(f) = trapz(xGrid,opening);
end

end
