function data = CAPS2_main(trial_sequence, varargin)
% This function is for controlling the LabView program to deliver pressure
% pain and collecting ratings (continuous or one-time ratings)
%
% Usage:
% -------------------------------------------------------------------------
% data = CAPS2_main(trial_sequence, varargin)
%
% Inputs:
% -------------------------------------------------------------------------
% trial_sequence trial_sequence should provide information of intensity,
%                duration, repetition of simulation, rating and scale type
%                you want to use, and cue/iti duration.
%
% The generic form of trial sequence:
% trial_sequence{run_number}{trial_number} = ...
%          {intensity(four digits:string), duration(four digits:string),
%           repetition_number, rating_scale_type, cue_duration,
%           post-stim jitter, inter_stim_interval (from the rating to the
%           next trial), cue_message, during_stim_message};
% For details, see example below.
%
% Optional input:
% -------------------------------------------------------------------------
% 'scriptdir'           Specify the script directory
% 'explain_scale'       If you want to show rating scale before starting
%                       the experiment, you can use this option.
%                       (e.g., 'explain_scale', {'overall_avoidance',
%                       'overall_int'})
% 'test'                Running a testmode with partial-screen
% 'fmri'                Display some instructions for a fmri experiment
% 'post_st_rating_dur'  If you are collecting continuous rating, using this
%                       option, you can specify the duration for the
%                       post-stimulus rating. The default is 5 seconds.
%                       (e.g., 'post_st_rating_dur', duration_in_seconds)
% 'biopac'              If you want to use biopac, use this option.
% 'postrun_questions'   If you want to display postrun questionnaire, use
%                       this option.
% 'controller'          Specify the controller. Options can 'joy', 'mouse'.
%
% Outputs:
% -------------------------------------------------------------------------
% data.
%
%
%
%
% Example:
% -------------------------------------------------------------------------
% trial_sequence{1}{1} = {'PP', 'LV1', '0010', {'overall_avoidance'}, '0', '3', '7'};
%     ----------------------------
%     {1}{1}: first run, first trial
%     'PP'  : pressure pain
%         -- other options --
%         'TP': thermal pain
%         'PP': thermal pain
%         'AU': aversive sounds
%         'VI': aversive visual
%         ** you can add more stimuli options...
%     'LV1'-'LV4' : intensity levels
%     '0010': duration in seconds (10 seconds)
%     {'overall_avoidance'}: overall avoidance rating (after stimulation ends)
%         -- other options --
%         'no'              : no ratings
%         'cont_int'        : continuous intensity rating
%         'cont_avoidance'  : continuous rating
%         'overall_int'     : overall intensity rating
%         'overall_unpleasant' : overall intensity rating
%         'overall_avoidance'  : overall avoidance rating
%         ** to add more combinations, see "parse_trial_sequence.m" and "draw_scale.m" **
%     '0': cue duration 0 seconds: no cue
%     '3': interval between stimulation and ratings: 3 seconds
%     '7': inter_stim_interval: This defines the interval from the time the rating starts
%          to the next trial starts. Actual ITI will be this number minus RT.
%     ** optional: Using 8th cell array, you can specify cue text
%                  Using 9th cell array, you can specify text during stimulation
%
% trial_sequence{1}{2} = {'AU', 'LV2', '0010', {'overall_int'}, '0', '3', '7', 'How much pressure?'};
%     'How much pressure?' - will be appeared as cue. If the 8th cell is not
%                            specified, it will display a fixation cross.
%
% trial_sequence{1}{3} = {'TP', 'LV4', '0010', {'overall_pleasant'}, '0', '3', '7'};
%
% data = mpa1_main(trial_sequence, 'explain_scale', exp_instructions, 'fmri', 'biopac')
%
% -------------------------------------------------------------------------
% Copyright (C) 1/10/2015, Wani Woo
%
% Programmer's note:
% 10/19/2015, Wani Woo -- modified the original code for MPA1
% 27/06/2017, J.J. Lee -- overall trimming of the code.
% 01/07/2017, J.J. Lee -- reconstruction of the code.


%% SETUP: global
global window_rect W H theWindow; % window property
global white red orange bgcolor; % color
global font fontsize
global Exp_key Par_key Scan_key
global t r; % pressure device udp channel
global rating_types % dictionary for all rating types and matched prompts

%% SETUP: varargin
scriptdir = pwd;
doexplain_scale = false;
testmode = false;
screen_mode = 'small';
set_input = false;
dofmri = false;
post_stimulus_t = 5; % post-stimulus continuous rating seconds
USE_BIOPAC = false;
postrun_questions = [];
controller = 'mouse';
control_speed = 0;


for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
            case {'scriptdir'}
                scriptdir = varargin{i+1};
            case {'explain_scale'}
                doexplain_scale = true;
                exp_scale = varargin{i+1};
            case {'test'}
                testmode = true;
            case {'screenmode'}
                screen_mode = varargin{i+1};
            case {'setinput'}
                set_input = true;
            case {'fmri'}
                dofmri = true;
            case {'post_st_rating_dur', 'post_st_rating'}
                post_stimulus_t = varargin{i+1};
            case {'biopac'}
                USE_BIOPAC = true;
                channel_n = 3;
                biopac_channel = 0;
                ljHandle = BIOPAC_setup(channel_n);
            case {'postrun_questions'}
                postrun_questions = varargin{i+1};
            case {'controller'}
                controller = varargin{i+1};
            case {'controlspeed'}
                control_speed = varargin{i+1};
        end
    end
end

cd(scriptdir); addpath(genpath(scriptdir));
savedir = 'Data';


%% SETUP: DATA and Subject INFO
[fname, SID, start_line, data] = subjectinfo_check(savedir); % subject information check, start line reading
% add some information
data.version = 'CAPS2_v1_07-01-2017_Cocoanlab';
data.subject = SID;
data.datafile = fname;
data.starttime = datestr(clock, 0); % date-time
data.starttime_getsecs = GetSecs; % in the same format of timestamps for each trial
save(data.datafile, 'trial_sequence', 'data') % initial save of trial sequence

%% SETUP: Experiment
[run_num, trial_num, run_start, trial_start] = parse_trial_sequence(trial_sequence, start_line);
call_ratingtypes; % call rating types dictionary
lvs = {'LV1', 'LV2', 'LV3', 'LV4'};

%% SETUP: STIMULI -- modify this for each study
% PP_int = pressure_pain_setup; % pain of each intensity
% players = auditory_setup; % sound of each aversiveness
% if isempty(postrun_questions)
%     for i = 1:run_num, postrun_questions{i} = []; end
% end


%% SETUP: Screen parameter
setup_screen(testmode, screen_mode); % setup screen parameter

%% SETUP: Input setting
setup_input(set_input);

%% MAIN EXPERIMENT
%% EXPLAIN SCALES
if doexplain_scale
    data = get_ratings(exp_scale, 'explain', controller, control_speed, 1, 1, Inf, data);
end

%% START : RUN
for run_i = run_start:run_num
    
    %% START : TRIAL
    for tr_i = trial_start(run_i):trial_num(run_i)
        
        %% Parse stimulation data
        [S, data] = parse_trial(trial_sequence, run_i, tr_i, data);
        S.ratetime_cont = str2double(S.dur) + post_stimulus_t; % collect data for duration + post stimulus time
        S.ratetime_overall = 7;
        S.ratetime_post = 7;
        
        %% Check for ready
        if run_i == 1 && tr_i == 1
            while true
                [~,~,keyCode_E] = KbCheck(Exp_key);
                if keyCode_E(KbName('space'))
                    break
                elseif keyCode_E(KbName('q'))
                    abort_experiment('manual');
                    break
                end
                
                display_message('start', run_i);
            end
        end
        
        %% Synced RUN, with disdaq for 10 sec and preparing for BIOPAC
        if tr_i == 1 % first trial
            
            % if this is for fMRI experiment, it will start with s,
            % but if behavioral, it will start with "r" key.
            if dofmri
                while true
                    [~,~,keyCode_S] = KbCheck(Scan_key);
                    [~,~,keyCode_E] = KbCheck(Exp_key);
                    if keyCode_S(KbName('s'))
                        break
                    elseif keyCode_E(KbName('q'))
                        abort_experiment('manual');
                        break
                    end
                    
                    display_message('run_fmri', run_i);
                end
            elseif ~dofmri
                while true
                    [~,~,keyCode_P] = KbCheck(Par_key);
                    [~,~,keyCode_E] = KbCheck(Exp_key);
                    if keyCode_P(KbName('r'))
                        break
                    elseif keyCode_E(KbName('q'))
                        abort_experiment('manual');
                        break
                    end
                    display_message('run_behavior', run_i);
                end
            end
            
            
            if dofmri
                % gap between s key push and the first stimuli (disdaqs: 10 seconds)
                % 4 seconds: "Starting..."
                display_message('scanstart', run_i);
                WaitSecs(4); % ADJUST THIS
                
                % 4 seconds: Blank
                Screen(theWindow,'FillRect',bgcolor, window_rect);
                Screen('Flip', theWindow);
                data.dat{run_i}{tr_i}.runscan_starttime = GetSecs;
                WaitSecs(4); % ADJUST THIS
            end
            
            % 2 seconds: BIOPAC
            if USE_BIOPAC
                BIOPAC_trigger(ljHandle, biopac_channel, 'on');
            end
            
            Screen(theWindow,'FillRect',bgcolor, window_rect);
            Screen('Flip', theWindow);
            WaitSecs(2); % ADJUST THIS
            
            if USE_BIOPAC
                BIOPAC_trigger(ljHandle, biopac_channel, 'off');
            end
            
        end
        
        %% CUE FIXATION
        data.dat{run_i}{tr_i}.cue_timestamp = GetSecs;
        
        if S.cue_t > 0 % if S.cue_t == 0, this is not running.
            DrawFormattedText(theWindow, S.cuetext, 'center', 'center', white, [], [], [], 2);
            Screen('Flip', theWindow);
            WaitSecs(S.cue_t-.5);
            
            % 0.5 sec with blank
            Screen(theWindow,'FillRect',bgcolor, window_rect);
            Screen('Flip', theWindow);
            WaitSecs(.5);
        end
        
        %% STIMULATION. If continuous, rating is done.
        data.dat{run_i}{tr_i}.stim_timestamp = GetSecs;
        
        DrawFormattedText(theWindow, S.stimtext, 'center', 'center', white, [], [], [], 2);
        Screen('Flip', theWindow);
        
        if strcmp(S.type, 'PP') % pressure pain
            eval(['fwrite(t, ''1,' PP_int{strcmp(lvs, S.int)} ',t'');']);
        elseif strcmp(S.type, 'AU') % aversive auditory
            play(players{strcmp(lvs, S.int)});
        end
        
        if ~isempty(S.cont_scale) % continuous rating
            data = get_ratings(S.cont_scale, 'continuous', controller, control_speed, run_i, tr_i, S.ratetime_cont, data);
        else % not continuous rating
            WaitSecs(S.dur);
            if strcmp(S.type, 'PP')
                eval(['fwrite(t, ''1,' PP_int{strcmp(lvs, S.int)} ',s'');']);
            end
        end
        
        data.dat{run_i}{tr_i}.total_dur_recorded = GetSecs - data.dat{run_i}{tr_i}.stim_timestamp;
        
        %% POST-STIM JITTER
        Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen
        Screen('Flip', theWindow);
        WaitSecs(S.post_stim_jitter);
        
        %% OVERALL RATING
        if ~isempty(S.overall_scale)
            data = get_ratings(S.overall_scale, 'overall', controller, control_speed, run_i, tr_i, S.ratetime_overall, data);
        end
        
        %% INTER-TRIAL INTERVAL
        Screen('FillRect', theWindow, bgcolor, window_rect); % basically, clear the screen
        Screen('Flip', theWindow);
        if ~isempty(S.overall_scale)
            data.dat{run_i}{tr_i}.iti = data.dat{run_i}{tr_i}.isi - data.dat{run_i}{tr_i}.overall_total_RT;
        else
            data.dat{run_i}{tr_i}.iti = data.dat{run_i}{tr_i}.isi;
        end
        
        if data.dat{run_i}{tr_i}.iti <= 0
            data.dat{run_i}{tr_i}.iti = 0.01;
        end
        WaitSecs(data.dat{run_i}{tr_i}.iti);
        
        %% POSTRUN QUESTIONNAIRES
        if tr_i == trial_num(run_i) && ~isempty(postrun_questions{run_i})
            data = get_ratings(postrun_questions{run_i}, 'postrun', controller, control_speed, run_i, tr_i, S.ratetime_post, data);
        end
        save(data.datafile, '-append', 'data') % By this, if postrun questionnaire, the last trial will be saved after questionniare.
        
    end % trial ends
    
    %% END-RUN MESSAGE
    while true % Space
        [~,~,keyCode_E] = KbCheck(Exp_key);
        if keyCode_E(KbName('space'))
            break
        elseif keyCode_E(KbName('q'))
            abort_experiment('manual');
            break
        end
        
        if run_i < run_num
            display_message('endrun', run_i)
        else
            display_message('endall', run_i)
        end
        
    end
    
end % run ends

Screen('CloseAll');
disp('Done');
save(data.datafile, '-append', 'data');

if exist('t', 'var') && ~isempty(t); fclose(t); end
if exist('r', 'var') && ~isempty(r); fclose(r); end

