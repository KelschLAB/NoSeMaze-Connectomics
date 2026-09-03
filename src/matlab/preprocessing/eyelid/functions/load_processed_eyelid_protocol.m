function P = load_processed_eyelid_protocol(protocolFile)
% LOAD_PROCESSED_EYELID_PROTOCOL Load semantic synchronized protocol file.

assert(isfile(protocolFile),'Processed eyelid protocol not found:\n%s',protocolFile);
P = load(protocolFile);

assert(isfield(P,'events') && isfield(P,'sync'), ...
    'Expected events and sync in processed eyelid protocol: %s',protocolFile);
assert(isfield(P.sync,'video_led_off'), ...
    'Expected sync.video_led_off in: %s',protocolFile);
end
