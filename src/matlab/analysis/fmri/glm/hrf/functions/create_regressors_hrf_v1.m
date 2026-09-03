
function regressors = create_regressors_hrf_v1(events,odorDelaySec)
% CREATE_REGRESSORS_HRF_V1 Three odor-duration regressors used for mask GLM.
%
% Historical v1:
%   Odor_500ms   duration 0.5 s
%   Odor_1000ms  duration 1.0 s
%   Odor_2400ms  duration 2.4 s
%
% Onsets are shifted by the mini-PID odor delay.

if nargin < 2
    odorDelaySec = 0.7;
end

dur = [events.fv_dur_del25];

sel500 = dur > 0.45 & dur < 0.55;
sel1000 = dur > 0.95 & dur < 1.05;
sel2400 = dur > 2.35 & dur < 2.55;

regressors(1).name = 'Odor_500ms';
regressors(1).onset = [events(sel500).fv_on_del25] + odorDelaySec;
regressors(1).duration = 0.5;
regressors(1).pm = [];

regressors(2).name = 'Odor_1000ms';
regressors(2).onset = [events(sel1000).fv_on_del25] + odorDelaySec;
regressors(2).duration = 1.0;
regressors(2).pm = [];

regressors(3).name = 'Odor_2400ms';
regressors(3).onset = [events(sel2400).fv_on_del25] + odorDelaySec;
regressors(3).duration = 2.4;
regressors(3).pm = [];

end
