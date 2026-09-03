function pairs = pair_eyelid_protocol_rhd(protocolList,rhdList)
% PAIR_EYELID_PROTOCOL_RHD Pair each protocol with all RHD segments.

pairs = repmat(struct('key','','protocolFile','','rhdFiles',{{}}), ...
    numel(protocolList),1);

rhdLower = lower(string(rhdList));

for i = 1:numel(protocolList)
    key = session_key_from_filename(protocolList{i});
    hit = contains(rhdLower,lower(key));

    assert(any(hit), ...
        'No RHD file found for protocol session %s.',key);

    pairs(i).key = key;
    pairs(i).protocolFile = protocolList{i};
    pairs(i).rhdFiles = sort(rhdList(hit));
end
end
