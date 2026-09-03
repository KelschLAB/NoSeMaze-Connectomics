
function x0 = build_hrf_start_grid(cfg)
% BUILD_HRF_START_GRID Reproduce the historical HRF multi-start grid.

counter = 1;
x0 = [];

for p1 = cfg.start.responseDelay
    for p2 = cfg.start.undershootDelay
        for p3 = cfg.start.dispersion
            for p4 = cfg.start.responseUndershootRatio

                if cfg.optimizeOnsetParameter
                    for p5 = cfg.start.onset
                        x0(counter,:) = [p1 p2 p3 p4 p5]; %#ok<AGROW>
                        counter = counter + 1;
                    end
                else
                    x0(counter,:) = [p1 p2 p3 p4]; %#ok<AGROW>
                    counter = counter + 1;
                end
            end
        end
    end
end

end
