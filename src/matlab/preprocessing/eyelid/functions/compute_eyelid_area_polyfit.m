
function result = compute_eyelid_area_polyfit(landmarks,cfg)
% COMPUTE_EYELID_AREA_POLYFIT Final eye-opening-area estimator.
%
% This is the only eyelid geometry estimator in the active pipeline.
%
% For each frame:
%   - use 8 DLC eyelid landmarks;
%   - rotate the eye so the W-E corner axis is horizontal;
%   - fit a degree-2 polynomial through five upper-lid points;
%   - fit a degree-2 polynomial through five lower-lid points;
%   - evaluate both fits on a 0.1-pixel grid;
%   - back-rotate the fitted contours;
%   - integrate the vertical area between them with trapz.
%
% This corresponds to the historical `lid_dia_v2.d_mean` branch that the
% user confirmed was used for the final manuscript analysis.

X = landmarks.x;
Y = landmarks.y;

nFrames = size(X,1);

%% Estimate one session-level rotation angle before interpolation.
validCorners = ...
    isfinite(X(:,cfg.eastIndex)) & ...
    isfinite(Y(:,cfg.eastIndex)) & ...
    isfinite(X(:,cfg.westIndex)) & ...
    isfinite(Y(:,cfg.westIndex));

firstValid = find(validCorners,1,'first');

assert(~isempty(firstValid), ...
    'No frame has valid east/west eyelid corners.');

xW = X(firstValid,cfg.westIndex);
yW = Y(firstValid,cfg.westIndex);
xE = X(firstValid,cfg.eastIndex);
yE = Y(firstValid,cfg.eastIndex);

% Historical image-coordinate convention.
slope = ((-yE)-(-yW))/(xE-xW);
theta = round(atand(slope));

%% Historical coordinate spike/NaN correction.
coords = nan(nFrames,16);
coords(:,1:2:end) = X;
coords(:,2:2:end) = Y;

M = nan(1,nFrames,16);
M(1,:,:) = coords;

[Mcorrected,removedCoordinateSpikes] = ...
    remove_spikes_and_interpolate( ...
        M, ...
        cfg.coordinateSpikeStdThreshold, ...
        cfg.coordinateMaxGap, ...
        nan);

coords = squeeze(Mcorrected);

X = coords(:,1:2:end);
Y = coords(:,2:2:end);

%% Polynomial eye-opening area.
area = nan(nFrames,1);

R = [ ...
    cosd(theta) -sind(theta)
    sind(theta)  cosd(theta) ...
];

Rback = [ ...
    cosd(-theta) -sind(-theta)
    sind(-theta)  cosd(-theta) ...
];

for frame = 1:nFrames

    xy = [X(frame,:)' Y(frame,:)'];

    % The final fit requires all eight eyelid landmarks after correction.
    if any(~isfinite(xy),'all')
        continue
    end

    % Historical translations retained for exact numerical provenance.
    xy(:,1) = xy(:,1)+650;
    xy(:,2) = xy(:,2)+300;

    rotated = xy*R';

    upper = cfg.upperLidIndices;
    lower = cfg.lowerLidIndices;

    xStart = rotated(cfg.westIndex,1);
    xEnd = rotated(cfg.eastIndex,1);

    if xEnd<=xStart
        continue
    end

    xGrid = (xStart:cfg.fitStepPixels:xEnd)';

    try
        pUpper = polyfit( ...
            rotated(upper,1), ...
            rotated(upper,2), ...
            cfg.polynomialDegree);

        pLower = polyfit( ...
            rotated(lower,1), ...
            rotated(lower,2), ...
            cfg.polynomialDegree);

        yUpper = polyval(pUpper,xGrid);
        yLower = polyval(pLower,xGrid);

        upperBack = [xGrid yUpper]*Rback';
        lowerBack = [xGrid yLower]*Rback';

        % Preserve the historical final area calculation exactly: the
        % integration coordinate is the rotated xGrid, while the vertical
        % difference is taken after back-rotation.
        area(frame) = trapz( ...
            xGrid, ...
            lowerBack(:,2)-upperBack(:,2));

    catch
        area(frame) = NaN;
    end
end

result = struct();
result.area = area;
result.rotation_angle_deg = theta;
result.removed_coordinate_spikes = removedCoordinateSpikes;
result.valid_frame = isfinite(area);

end
