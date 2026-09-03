function full_hierarchy = combine_curated_data_NoSeMaze_1(eventPlotDir)
% COMBINE_CURATED_DATA_NOSEMAZE_1 Cohort wrapper.

trueIDs = sort({
    '0007CA3A35'
    '0007CB357C'
    '0007CB239E'
    '0007CA38FF'
    '0007CB330D'
    '0007CB08A5'
    '0007CB4123'
    '0007CB0D91'
    '0007CB1EC1'
    '0007CB6EA3'
    '0007CB0ABC'
    '0007CB42F2'
    '0007CB0F95'
    '0007CB090F'
});

full_hierarchy = combine_curated_tube_days(eventPlotDir,trueIDs);
end
