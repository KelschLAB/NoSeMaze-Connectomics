
function [M,removed] = remove_spikes_and_interpolate( ...
    M,stdThreshold,maxGap,absoluteThreshold)
% REMOVE_SPIKES_AND_INTERPOLATE Historical eyelid spike correction.
%
% Adapted from RemovePikes_NaN_jr. M is expected as:
%   1 x time x series
%
% The algorithm identifies opposing large first differences, converts the
% enclosed short interval to NaN, then linearly interpolates short NaN runs.

if nargin < 4
    absoluteThreshold = nan;
end

copy = M;
mask = ones(size(M));
mask(isnan(M)) = NaN;

delta = M(1,2:end,:) - M(1,1:end-1,:);

STD = std(delta,0,"all","omitnan");
AVG = mean(delta,"all","omitnan");

OL = zeros(size(delta));

if isnan(absoluteThreshold)
    OL(delta < AVG-stdThreshold*STD) = -1;
    OL(delta > AVG+stdThreshold*STD) = 2;
else
    OL(delta < -absoluteThreshold) = -1;
    OL(delta > absoluteThreshold) = 2;
end

removed = 0;

for tr = 1:size(OL,3)

    win = 0;
    cou = 0;
    beginIndex = 0;
    endIndex = 0;

    for b = 1:size(OL,2)

        if cou == maxGap
            win = 0;
            cou = 0;
            beginIndex = 0;
            endIndex = 0;
            continue
        end

        if OL(1,b,tr)==0

            if win~=0
                cou = cou+1;
            end

        elseif OL(1,b,tr)==2

            if win==0
                beginIndex = b+1;
                win = 2;
            elseif win==-1
                endIndex = b;
                win = 1;
            elseif win==2
                cou = 0;
            end

        elseif OL(1,b,tr)==-1

            if win==0
                beginIndex = b+1;
                win = -1;
            elseif win==2
                endIndex = b;
                win = 1;
            elseif win==-1
                cou = 0;
            end
        end

        if win==1
            mask(1,beginIndex:endIndex,tr) = NaN;
            OL(1,beginIndex-1:endIndex-1,tr) = 0;
            removed = removed+1;

            win = 0;
            cou = 0;
            beginIndex = 0;
            endIndex = 0;
        end
    end
end

copy = copy.*mask;

% Second pass: treat existing NaNs and remaining large jumps as gaps.
delta = copy(1,2:end,:) - copy(1,1:end-1,:);
OL = zeros(size(delta));
OL(delta < AVG-stdThreshold*STD) = -1;
OL(delta > AVG+stdThreshold*STD) = -1;
OL(isnan(delta)) = 2;

for tr = 1:size(OL,3)

    win = 0;
    cou = 0;
    beginIndex = 0;
    endIndex = 0;

    for b = 1:size(OL,2)

        if cou == maxGap
            win = 0;
            cou = 0;
            beginIndex = 0;
            endIndex = 0;
            continue
        end

        if OL(1,b,tr)==0

            if win~=0
                cou = cou+1;
            end

        elseif OL(1,b,tr)==2

            if win==0
                beginIndex = b+1;
                win = 2;
            elseif win==-1
                endIndex = b;
                win = 1;
            elseif win==2
                cou = 0;
            end

        elseif OL(1,b,tr)==-1

            if win==0
                beginIndex = b+1;
                win = -1;
            elseif win==2
                endIndex = b;
                win = 1;
            elseif win==-1
                cou = 0;
            end
        end

        if win==1
            mask(1,beginIndex:endIndex,tr) = NaN;
            OL(1,beginIndex-1:endIndex-1,tr) = 0;
            removed = removed+1;

            win = 0;
            cou = 0;
            beginIndex = 0;
            endIndex = 0;
        end
    end
end

copy = M.*mask;

for tr = 1:size(copy,3)
    copy(1,:,tr) = interpolate_short_nan_runs( ...
        copy(1,:,tr),maxGap+1);
end

M = copy;

end
