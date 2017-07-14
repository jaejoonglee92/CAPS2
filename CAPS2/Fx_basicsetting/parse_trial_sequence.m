function [run_num, trial_num, run_start, trial_start] = parse_trial_sequence(trial_sequence, start_line)
%[run_num, trial_num, run_start, trial_start] = parse_trial_sequence(trial_sequence, start_line)
%This function can parse trial sequence, and get information of the paradigm.
%run_num : total run number.
%trial_num : total trial number.
%run_start : the run of start point.
%trial_start : the trial of start point.


run_num = numel(trial_sequence);
idx = zeros(run_num+1,1); % index to calculate trial_start
trial_num = zeros(run_num,1);
trial_start = ones(run_num,1);

for i = 1:run_num
    trial_num(i,1) = numel(trial_sequence{i});
    idx(i+1) = idx(i) + trial_num(i);
    
    if idx(i) < start_line && idx(i+1) >= start_line
        run_start = i;
        trial_start(i,1) = start_line - idx(i);
    end
    
end

end