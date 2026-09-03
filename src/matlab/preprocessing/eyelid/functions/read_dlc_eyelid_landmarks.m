
function landmarks = read_dlc_eyelid_landmarks(csvFile,cfg)
% READ_DLC_EYELID_LANDMARKS Read only the eight eyelid landmarks from DLC.
%
% Expected DLC CSV header rows:
%   row 1: scorer
%   row 2: bodyparts
%   row 3: coords (x/y/likelihood)

assert(isfile(csvFile),'DLC CSV not found:\n%s',csvFile);

C = readcell(csvFile,'Delimiter',',');

assert(size(C,1)>=4, ...
    'Unexpected DeepLabCut CSV structure: %s',csvFile);

bodyparts = strtrim(string(C(2,2:end)));
coords = lower(strtrim(string(C(3,2:end))));

nFrames = size(C,1)-3;
nPoints = numel(cfg.bodyparts);

X = nan(nFrames,nPoints);
Y = nan(nFrames,nPoints);
L = nan(nFrames,nPoints);

for p = 1:nPoints

    part = cfg.bodyparts(p);
    cols = find(bodyparts==part);

    assert(numel(cols)==3, ...
        'Expected x/y/likelihood columns for %s.',part);

    xcol = cols(coords(cols)=="x");
    ycol = cols(coords(cols)=="y");
    lcol = cols(coords(cols)=="likelihood");

    assert(numel(xcol)==1 && numel(ycol)==1 && numel(lcol)==1, ...
        'Malformed DLC columns for %s.',part);

    X(:,p) = str2double(string(C(4:end,xcol+1)));
    Y(:,p) = str2double(string(C(4:end,ycol+1)));
    L(:,p) = str2double(string(C(4:end,lcol+1)));
end

low = L < cfg.likelihoodThreshold;

X(low) = NaN;
Y(low) = NaN;

landmarks = struct();
landmarks.bodyparts = cfg.bodyparts;
landmarks.x = X;
landmarks.y = Y;
landmarks.likelihood = L;

end
