function [S, data] = parse_trial(trial_sequence, run_i, tr_i, data)
%[S, data] = parse_trial(trial_sequence, run_i, tr_i, data)
%This function can parse trial, and its output is S and data.
%S is composed of type, int, dur, cont_scale, overall_scale, cue_t,
%poststim_jitter, isi, cuetext, stimtext.
%These information are recorded in data.

S.type = trial_sequence{run_i}{tr_i}{1}; % 'PP', 'TP', 'AU', 'VI'
S.int = trial_sequence{run_i}{tr_i}{2};  % 'LV1', 'LV2'...
S.dur = str2double(trial_sequence{run_i}{tr_i}{3});  % '0010'...
S.cont_scale = trial_sequence{run_i}{tr_i}{4}(strncmp(trial_sequence{run_i}{run_i}{4}, 'cont_', length('cont_')));
S.overall_scale = trial_sequence{run_i}{tr_i}{4}(strncmp(trial_sequence{run_i}{tr_i}{4}, 'overall_', length('overall_')));
S.cue_t = str2double(trial_sequence{run_i}{tr_i}{5});
S.post_stim_jitter = str2double(trial_sequence{run_i}{tr_i}{6});
S.isi = str2double(trial_sequence{run_i}{tr_i}{7});
if numel(trial_sequence{run_i}{tr_i}) > 7 % if there were some pictures of texts for cue
    S.cuetext = trial_sequence{run_i}{tr_i}{8};
else
    S.cuetext = '+';
end
if numel(trial_sequence{run_i}{tr_i}) > 8 % if there were some pictures of texts for stimulation
    S.stimtext = trial_sequence{run_i}{tr_i}{9};
else
    S.stimtext = '+';
end

data.dat{run_i}{tr_i}.type = S.type;
data.dat{run_i}{tr_i}.intensity = S.int;
data.dat{run_i}{tr_i}.duration = S.dur;
data.dat{run_i}{tr_i}.cont_scale = S.cont_scale;
data.dat{run_i}{tr_i}.overall_scale = S.overall_scale;
data.dat{run_i}{tr_i}.cue_duration = S.cue_t;
data.dat{run_i}{tr_i}.post_stim_jitter = S.post_stim_jitter;
data.dat{run_i}{tr_i}.isi = S.isi;
data.dat{run_i}{tr_i}.cuetext = S.cuetext;
data.dat{run_i}{tr_i}.stimtext = S.stimtext;
