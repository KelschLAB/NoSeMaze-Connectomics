# Historical provenance

The original working scripts used filenames and folder labels that referred
to other modalities. They paired `*protocol.mat` files with all matching RHD
segments and then called a project-specific protocol-processing function.

The active replacement in the parent directory preserves that scientific
role while using eyelid-specific naming and semantic event fields.

The exact historical video-trigger channel assignment was not visible in the
supplied excerpt. The cleaned implementation therefore identifies the
one-second video-sync TTL from the digital recordings and allows an explicit
channel override.
