%% Save randmoized run order. Each version contains 24 pairs.

runs = {'REST', 'CAPS', 'ODOR', 'QUIN'};
runs = runs(perms(1:4));
runs = runs(randperm(size(runs, 1)), :);
subjmarker = 1;
runmarker = 1;
save('CAPS2_randomized_run_data_v3.mat', 'runs', 'subjmarker', 'runmarker');
