function [ts, post_q] = generate_ts

% basic setting for paradigm
run_num = 3;
trial_num = repmat(3, run_num, 1); %21
%{'QUIN'}; {'REST'};
S1{1} = [{'REST'}, {'QUIN'}, {'CAPS'}];
S1{2} = [{'LV0'}];
S1{3} = [{'0003'}; repmat({'0003'}, 1, 1); {'0003'}]; %13 53 23, 19
S1{4} = [{'overall_avoidance'}];
S1{5} = [{'0'}];
S1{6} = [{'0'}];
rate_to_stim = 7;

% run randomization
%S1{1} = S1{1}(randperm(run_num)); % in this variable, we have to specify index in resizing section.



for i = 1:run_num
    
    % resizing
    T1{1} = repmat(S1{1}(i), ceil(trial_num(i)/numel(S1{1}(i))), 1); % like this.
    T1{2} = repmat(S1{2}, ceil(trial_num(i)/numel(S1{2})), 1);
    T1{3} = repmat(S1{3}, ceil(trial_num(i)/numel(S1{3})), 1);
    T1{4} = repmat(S1{4}, ceil(trial_num(i)/numel(S1{4})), 1);
    T1{5} = repmat(S1{5}, ceil(trial_num(i)/numel(S1{5})), 1);
    T1{6} = repmat(S1{6}, ceil(trial_num(i)/numel(S1{6})), 1);
    
    % trial randomization
    T1{6} = T1{6}(randperm(trial_num(i)));
    
    for j = 1:trial_num(i)
        
        ts{i}{j}(1) = T1{1}(j);
        ts{i}{j}(2) = T1{2}(j);
        ts{i}{j}(3) = T1{3}(j);
        ts{i}{j}(4) = {T1{4}(j)};
        ts{i}{j}(5) = T1{5}(j);
        ts{i}{j}(6) = T1{6}(j);
        ts{i}{j}(7) = {num2str(rate_to_stim - str2num(T1{6}{j}))};
        
    end
end


for i = 1:numel(S1{1})
    post_q{i} = {'overall_relaxed', ...
        'overall_attention',...
        'overall_boredness', ...
        'overall_alertness', ...
        'overall_resting_positive', ...
        'overall_resting_negative', ...
        'overall_resting_myself', ...
        'overall_resting_others', ...
        'overall_resting_imagery', ...
        'overall_resting_present', ...
        'overall_resting_past', ...
        'overall_resting_future'};
    if strcmp(S1{1}{i}, 'CAPS')
        post_q{i} = [post_q{i}, ...
            {'overall_resting_capsai_int', ...
            'overall_resting_capsai_unp'}];
    elseif strcmp(S1{1}{i}, 'QUIN')
        post_q{i} = [post_q{i}, ...
            {'overall_resting_bitter_int', ...
            'overall_resting_bitter_unp'}];
    elseif strcmp(S1{1}{i}, 'REST')
    end
end