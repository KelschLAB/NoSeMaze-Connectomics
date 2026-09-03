
function [array,interpolated,events] = interpolate_short_nan_runs(array,maxNans)
% INTERPOLATE_SHORT_NAN_RUNS Linearly interpolate short internal NaN runs.
%
% Adapted from the supplied InterpolateNaN function. Leading/trailing NaNs
% without two finite anchors are not extrapolated.

interpolated = nan(size(array));
events = 0;

inGap = false;
reset = 0;
startIndex = 0;
startValue = 0;

for b = 1:numel(array)

    if reset == maxNans
        inGap = false;
        reset = 0;
        startIndex = 0;
        startValue = 0;
    end

    if ~isnan(array(b)) && ~inGap

        startIndex = b;
        startValue = array(b);

    elseif isnan(array(b)) && ~inGap

        inGap = true;
        reset = 0;

    elseif isnan(array(b)) && inGap

        reset = reset+1;

    elseif ~isnan(array(b)) && inGap

        if startIndex == 0
            reset = maxNans;
            continue
        end

        endIndex = b;
        endValue = array(b);

        add = linspace( ...
            startValue,endValue,numel(startIndex:endIndex));

        interpolated(startIndex:endIndex) = add;

        if endIndex-startIndex>1
            array(startIndex+1:endIndex-1) = add(2:end-1);
        end

        events = events+1;
        reset = maxNans;
    end
end

end
