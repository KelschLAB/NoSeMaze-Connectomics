
# Eyelid-session RHD/protocol preprocessing

This module synchronizes the behavioral protocol, air-puff TTLs, odor TTLs,
and the video synchronization light.

It reuses the common Intan conversion machinery from the other task-timing
pipelines but uses the historically verified eyelid-session channel map:

```text
digital channel 1  air puff
digital channel 2  odor/final valve
digital channel 7  video synchronization light
```

The cleaned output uses semantic fields:

```text
events(t).odor_on
events(t).odor_off
events(t).odor_duration

events(t).has_air_puff
events(t).air_puff_on
events(t).air_puff_off

sync.video_led_start_on
sync.video_led_start_off
sync.video_led_end_on
sync.video_led_end_off
sync.video_led_off
```

The old generic "laser" terminology is not used.

## External Intan reader

Raw `.rhd` conversion requires the historical `BundleSession`, `LengthRhd`, and `IntanImport` functions. These are treated as an external reader dependency and are not reimplemented in the public repository.
