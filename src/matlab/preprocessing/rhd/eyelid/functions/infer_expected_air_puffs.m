function n = infer_expected_air_puffs(trialmatrix)
% INFER_EXPECTED_AIR_PUFFS Infer expected puff count from protocol fields.

n = NaN;
if isempty(trialmatrix)
    return;
end

fields = string(fieldnames(trialmatrix));
candidates = ["air_lat","airLat","puff","puff_or_not","air_puff"];

for c = candidates
    if any(fields==c)
        v = [trialmatrix.(char(c))];
        if islogical(v)
            n = sum(v);
        else
            n = sum(isfinite(v) & v~=0);
        end
        return;
    end
end
end
