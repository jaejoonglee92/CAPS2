

% ts{1}{1} = {'PP', 'LV1', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{2} = {'PP', 'LV2', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{3} = {'PP', 'LV3', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{4} = {'PP', 'LV4', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{5} = {'AU', 'LV1', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{6} = {'AU', 'LV2', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{7} = {'AU', 'LV3', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{8} = {'AU', 'LV4', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{9} = {'PP', 'LV1', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{10} = {'PP', 'LV2', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{11} = {'PP', 'LV3', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{12} = {'PP', 'LV4', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{13} = {'AU', 'LV1', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{14} = {'AU', 'LV2', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{15} = {'AU', 'LV3', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};
% ts{1}{16} = {'AU', 'LV4', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7'};

% 4 levels, 2 types, 3 jitter randomly permutate: 4 of these
% 4 runs, 16 trials = 64 trials

% 5th run

% ts{5}{1} = {'PP', 'LV3', '0010', 'overall_avoidance', 'avoidance_linear', '2', '3', '7', 'Focus on "feeling" how bad this is'};
% ts{5}{2} = {'PP', 'LV4', '0010', 'overall_avoidance', 'avoidance_linear', '2', '3', '7', 'Focus on "feeling" how bad this is'};
% ts{5}{3} = {'PP', 'LV3', '0010', 'overall_intensity', 'linear', '2', '3', '7', 'Focus on "measuring" the pressure level'};
% ts{5}{4} = {'PP', 'LV4', '0010', 'overall_intensity', 'linear', '2', '3', '7', 'Focus on "measuring" the pressure level'};
% ts{5}{5} = {'PP', 'LV3', '0010', 'no', 'no', '0', '3', '7', 'No reporting is required'};
% ts{5}{6} = {'PP', 'LV4', '0010', 'no', 'no', '0', '3', '7', 'No reporting is required'};
% ts{5}{7} = {'PP', 'LV3', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7', 'Focus on "feeling" how bad this is'};
% ts{5}{8} = {'PP', 'LV4', '0010', 'overall_avoidance', 'avoidance_linear', '0', '3', '7', 'Focus on "feeling" how bad this is'};
% ts{5}{9} = {'PP', 'LV3', '0010', 'overall_intensity', 'linear', '0', '3', '7', 'Focus on "measuring" the pressure level'};
% ts{5}{10} = {'PP', 'LV4', '0010', 'overall_intensity', 'linear', '0', '3', '7', 'Focus on "measuring" the pressure level'};
% ts{5}{11} = {'PP', 'LV3', '0010', 'no', 'no', '0', '3', '7', 'No reporting is required'};
% ts{5}{12} = {'PP', 'LV4', '0010', 'no', 'no', '0', '3', '7', 'No reporting is required'};

% 2 levels, 3 conditions, 3 jitter set (3/7, 5/5, 7/3), 3 cue time (2, 3.5, 5), randomly permutated
% 4 runs, 12 trials = 48 trials

% Building the design matrix