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

%% SETUP : global

global W H lb1 rb1 lb2 rb2 scale_W space korean alpnum special theWindow; % window property
global white orange bgcolor; % color
global t r; % pressure device udp channel


%% SETUP: varargin
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
USE_MASTER9 = false;


for i = 1:length(varargin)
    if ischar(varargin{i})
        switch varargin{i}
            % functional commands
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
                channel_n = 1;
                biopac_channel = 0;
                ljHandle = BIOPAC_setup(channel_n);
            case {'postrun_questions'}
                postrun_questions = varargin{i+1};
            case {'controller'}
                controller = varargin{i+1};
            case {'controlspeed'}
                control_speed = varargin{i+1};
            case {'master-9'}
                USE_MASTER9 = true;
        end
    end
end


%% SETUP: DATA and Subject INFO

% Basic parameter setting
savedir = 'Data';
start_line = 1;

% Get subject ID
data.subject = input('\nSubject ID? ','s');
data.datafile = fullfile(savedir, ['s' data.subject '.mat']);
    
% Check if the data file exists
if ~exist(savedir, 'dir')
    mkdir(savedir);
else
    if exist(data.datafile, 'file')
        checkdat = input(['The Subject ' data.subject ' data file exists. Press a button for the following options.\n', ...
            '1:Save new file, 2:Save the data from where we left off, Ctrl+C:Abort? ']);
        
        if checkdat == 2 % if file exists, get the start line
            load(data.datafile);
            datafields = fields(data);
            for fields_i = 1:numel(datafields)
                if strcmp(datafields{fields_i}, 'dat') % find whether the dat substructure is exist.
                    for line_i = 1:numel(data.dat)
                        start_line = start_line + numel(data.dat{line_i});
                    end
                end
            end
        end
        
    end
    
end

% add some information
data.version = 'CAPS2_v1_07-01-2017_Cocoanlab';
data.starttime = datestr(clock, 0); % date-time
data.starttime_getsecs = GetSecs; % in the same format of timestamps for each trial
save(data.datafile, 'trial_sequence', 'data') % initial save of trial sequence

%% SETUP: Parsing data

run_num = numel(trial_sequence);
idx = zeros(run_num+1,1); % index to calculate trial_start
trial_num = zeros(run_num,1);
trial_start = ones(run_num,1);

for run_i = 1:run_num
    trial_num(run_i) = numel(trial_sequence{run_i});
    idx(run_i+1) = idx(run_i) + trial_num(run_i);
    
    if idx(run_i) < start_line && idx(run_i+1) >= start_line
        run_start = run_i;
        trial_start(run_i) = start_line - idx(run_i);
    end
    
end

%% SETUP : Prompts
rating_types = call_ratingtypes;

%% SETUP: STIMULI -- modify this for each study

lvs = {'LV1', 'LV2', 'LV3', 'LV4'};

PP_int = pressure_pain_setup; % pain of each intensity
% players = auditory_setup; % sound of each aversiveness
% if isempty(postrun_questions)
%     for i = 1:run_num, postrun_questions{i} = []; end
% end

%% SETUP: Master-9

if USE_MASTER9
    cmOff = 0;
    cmFree = 1;
    cmTrain = 2;
    cmTrig = 3;
    cmDC = 4;
    cmGate = 5;
    cmTwin=6;
    csMonopolar=0;
    csBipolar=1;
    csRamp=2;
    
    Master9 = actxserver('AmpiLib.Master9'); %Create COM Automation server
    
    if ~(Master9.Connect)
        h=errordlg('Can''t connect to Master9!','Error');
        uiwait(h);
        delete(Master9); %Close COM
        return;
    end
    
    Master9.ChangeParadigm(1);            %switch to paradigm #1
    Master9.ClearParadigm;                %clear present paradigm
    
    Master9.ChangeChannelMode(1, cmTrig);
    
    Master9.SetChannelDuration(1, 10);
    Master9.SetChannelDelay(1, 0);
    
    Master9.ChangeChannelMode(2, cmTrig);
    
    Master9.SetChannelDuration(2, 10);
    Master9.SetChannelDelay(2, 0);
end

%% SETUP: Screen parameter

screens = Screen('Screens');
if ~testmode
    window_num = screens(end); % the last window
    HideCursor;
elseif testmode
    window_num = 0;
    ShowCursor;
end

Screen('Preference', 'SkipSyncTests', 1);

window_info = Screen('Resolution', window_num);
switch screen_mode
    case 'full'
        window_rect = [0 0 window_info.width window_info.height]; % full screen
    case 'semifull'
        window_rect = [0 0 window_info.width-100 window_info.height-100]; % a little bit distance
    case 'middle'
        window_rect = [0 0 window_info.width/2 window_info.height/2]; 
    case 'small'
        window_rect = [0 0 400 300]; % in the test mode, use a little smaller screen
end

% size
W = window_rect(3); % width
H = window_rect(4); % height

lb1 = W/4; % rating scale left bounds 1/4
rb1 = (3*W)/4; % rating scale right bounds 3/4

lb2 = W/3; % new bound for or not
rb2 = (W*2)/3; 

scale_W = (rb1-lb1).*0.1; % Height of the scale (10% of the width)

% font
fontsize = 33;
%font = 'Helvetica';
%font = 'NanumBarunGothic'; 
Screen('Preference', 'TextEncodingLocale', 'ko_KR.UTF-8');

% color
bgcolor = 100;
white = 255;
red = [158 1 66];
orange = [255 164 0];

% open window
theWindow = Screen('OpenWindow', window_num, bgcolor, window_rect); % start the screen
%Screen('TextFont', theWindow, font);
Screen('TextSize', theWindow, fontsize);

% get font parameter
anchor_lms = [0.014 0.061 0.172 0.354 0.533].*(rb1-lb1)+lb1;

[~, ~, wordrect0, ~] = DrawFormattedText(theWindow, double(' '), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect1, ~] = DrawFormattedText(theWindow, double('��'), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect2, ~] = DrawFormattedText(theWindow, double('p'), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect3, ~] = DrawFormattedText(theWindow, double('^'), lb1-30, H/2+scale_W+40, bgcolor);
[space.x space.y korean.x korean.y alpnum.x alpnum.y special.x special.y] = deal(wordrect0(3)-wordrect0(1), wordrect0(4)-wordrect0(2), ...
    wordrect1(3)-wordrect1(1), wordrect1(4)-wordrect1(2), wordrect2(3)-wordrect2(1), wordrect2(4)-wordrect2(2), ...
    wordrect3(3)-wordrect3(1), wordrect3(4)-wordrect3(2));

%% SETUP: Input setting (for Mac and test)

if set_input && ismac 
    devices = PsychHID('Devices');  
    devices_keyboard = [];
    for i = 1:numel(devices)
        if strcmp(devices(i).usageName, 'Keyboard')
            devices_keyboard = [devices_keyboard, devices(i)];
        end
    end
    Exp_key = devices_keyboard(2).index; % JJ's mac setting. MODIFY.
    Par_key = devices_keyboard(2).index;
    Scan_key = devices_keyboard(2).index;
else
    Exp_key = [];
    Par_key = [];
    Scan_key = [];
end

%% MAIN EXPERIMENT
%% EXPLAIN SCALES
if doexplain_scale
    
    % Going through each scale
    for scale_i = 1:numel(exp_scale)
        
        % First introduction
        if scale_i == 1
            while true % Space
                DrawFormattedText(theWindow, rating_types.prompts_ex{1}, 'center', 100, white, [], [], [], 2);
                Screen('Flip', theWindow);
                
                [~,~,button] = GetMouse(theWindow);
                [~,~,keyCode_E] = KbCheck(Exp_key);
                
                if button(1) || keyCode_E(KbName('space'))
                    break
                elseif keyCode_E(KbName('q'))
                    abort_experiment('manual');
                    break
                end
                
            end
        end
        
        
        % Parse scales and basic setting
        scale = exp_scale{scale_i};
        
        [lb, rb, start_center] = draw_scale(scale); % Get information about scale.
        Screen(theWindow, 'FillRect', bgcolor, window_rect); % Just getting information, and do not show the scale.
        
        start_t = GetSecs;
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        Screen('Flip', theWindow);
        
        rec_i = 0;
        ratetype = strcmp(rating_types.alltypes, scale);
        joy_button(1) = 0;
        button(1) = 0;
        
        % Explain scale with visualization
        while true % Space
            [lb, rb, start_center] = draw_scale(scale); % draw scale
            DrawFormattedText(theWindow, rating_types.prompts_ex{2}, 'center', 100, orange, [], [], [], 1);
            DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 300, white, [], [], [], 1);
            Screen('Flip', theWindow);
            
            [~,~,button] = GetMouse(theWindow);
            [~,~,keyCode_E] = KbCheck(Exp_key);
            
            if button(1) || keyCode_E(KbName('space'))
                break
            elseif keyCode_E(KbName('q'))
                abort_experiment('manual');
                break
            end
            
        end
        
        % Initial position
        if strcmp(controller, 'joy')
            [joy_pos, joy_button] = mat_joy(0);
            start_joy_pos = joy_pos(1); % getting initial poisition
        elseif strcmp(controller, 'mouse')
            if start_center
                SetMouse((rb+lb)/2,H/2); % set mouse at the center
            else
                SetMouse(lb,H/2); % set mouse at the left
            end
        end
        
        % Get ratings
        while true % Button
            rec_i = rec_i+1;
            
            if strcmp(controller, 'joy')
                [joy_pos, joy_button] = mat_joy(0);
                %             if abs(start_joy_pos) > .1 % if start point is too deviated
                %                 start_joy_pos = joy_pos(1);
                %             end
                if start_center
                    x = (joy_pos(1)-start_joy_pos) ./ controlspeed .* (rb-lb) + (rb+lb)/2; % both direction
                else
                    x = (joy_pos(1)-start_joy_pos) ./ controlspeed .* (rb-lb) + lb; % only right direction
                end
            elseif strcmp(controller, 'mouse')
                [x,~,button] = GetMouse(theWindow);
            end
            
            if x < lb; x = lb; elseif x > rb; x = rb; end
            
            if joy_button(1) || button(1); break; end
            
            DrawFormattedText(theWindow, rating_types.prompts_ex{3}, 'center', 100, orange, [], [], [], 2);
            DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 300, white, [], [], [], 2);
            
            [lb, rb, start_center] = draw_scale(scale);
            Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
            Screen('Flip', theWindow);
            
            cur_t = GetSecs;
            
            if cur_t-start_t >= Inf-0.5
                break
            end
            
        end
        
        % Freeze the screen 0.5 second with red line if overall type
        freeze_t = GetSecs;
        while true
            [lb, rb, start_center] = draw_scale(scale);
            DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 300, white, [], [], [], 2);
            Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
            Screen('Flip', theWindow);
            freeze_cur_t = GetSecs;
            if freeze_cur_t - freeze_t > 0.5
                break
            end
        end
        
        % (EXPLAIN or POSTRUN) Move to next
        while true % Space
            if strncmp(scale, 'cont_', numel('cont_'))
                if scale_i < numel(exp_scale)
                    DrawFormattedText(theWindow, [rating_types.prompts_ex{4} '\n\n' ...
                        rating_types.prompts_ex{6}], 'center', 100, orange, [], [], [], 2);
                else
                    DrawFormattedText(theWindow, [rating_types.prompts_ex{5} '\n\n' ...
                        rating_types.prompts_ex{6}], 'center', 100, orange, [], [], [], 2);
                end
            elseif strncmp(scale, 'overall_', numel('overall_'))
                if scale_i < numel(exp_scale)
                    DrawFormattedText(theWindow, rating_types.prompts_ex{4}, 'center', 100, orange, [], [], [], 1);
                else
                    DrawFormattedText(theWindow, rating_types.prompts_ex{5}, 'center', 100, orange, [], [], [], 1);
                end
            end
            Screen('Flip', theWindow);
            
            [~,~,button] = GetMouse(theWindow);
            [~,~,keyCode_E] = KbCheck(Exp_key);
            
            if button(1) || keyCode_E(KbName('space'))
                break
            elseif keyCode_E(KbName('q'))
                abort_experiment('manual');
                break
            end
            
        end
        
    end
    
    
end

%% START : RUN
for run_i = run_start:run_num
    
    %% START : TRIAL
    for tr_i = trial_start(run_i):trial_num(run_i)
        
        %% Parse stimulation data
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
            S.cuetext = ' ';
        end
        if numel(trial_sequence{run_i}{tr_i}) > 8 % if there were some pictures of texts for stimulation
            S.stimtext = trial_sequence{run_i}{tr_i}{9};
        else
            S.stimtext = ' ';
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
                
                Screen(theWindow,'FillRect',bgcolor, window_rect);
                msgtxt = '�����ڴ� ��� ������ �Ϸ�Ǿ���� Ȯ���Ͻñ� �ٶ�ϴ�.(BIOPAC, PPD, ���...)\n�غ� �Ϸ�Ǹ� �����ڴ� SPACE Ű�� �����ֽñ� �ٶ�ϴ�.';
                msgtxt = double(msgtxt); % korean to double
                DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
                Screen('Flip', theWindow);
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
                    
                    Screen(theWindow,'FillRect',bgcolor, window_rect);
                    msgtxt = '���ڰ� ��� �غ� �Ϸ�Ǹ� ��ĵ�� �����մϴ�. (S Ű)';
                    msgtxt = double(msgtxt); % korean to double
                    DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
                    Screen('Flip', theWindow);
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
                    Screen(theWindow,'FillRect',bgcolor, window_rect);
                    msgtxt = '���ڴ� ��� �غ� �Ϸ�Ǹ� R Ű�� �����ֽñ� �ٶ�ϴ�.';
                    msgtxt = double(msgtxt); % korean to double
                    DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
                    Screen('Flip', theWindow);
                end
            end
            
            
            if dofmri
                Screen(theWindow,'FillRect',bgcolor, window_rect);
                msgtxt = '�����ϴ� ��...';
                msgtxt = double(msgtxt); % korean to double
                DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
                Screen('Flip', theWindow);
                
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
            Screen(theWindow, 'FillRect', bgcolor, window_rect);
            Screen('Flip', theWindow);
            WaitSecs(.5);
        end
        
        %% STIMULATION. If continuous, rating is done.
        data.dat{run_i}{tr_i}.stim_timestamp = GetSecs;
        
        DrawFormattedText(theWindow, S.stimtext, 'center', 'center', white, [], [], [], 2);
        Screen('Flip', theWindow);
        
        if strcmp(S.type, 'PP') % pressure pain
            eval(['fwrite(t, ''1,' PP_int{strcmp(lvs, S.int)} ',t'');']);
            eval(['fwrite(t, ''1,' PP_int{strcmp(lvs, S.int)} ',s'');']);
        elseif strcmp(S.type, 'AU') % aversive auditory
            play(players{strcmp(lvs, S.int)});
        elseif strcmp(S.type, 'ODOR') % aversive odor
            eval(['fwrite(t, ''1,' PP_int{strcmp(lvs, S.int)} ',t'');']);
            if tr_i == 1
                odordur = 90; % 90 sec
                totaldur = 20*60; % 20 min
                Master9.SetChannelDuration(1, odordur);
                Master9.SetChannelDelay(1, 0);
                Master9.Trigger(1);
                Master9.SetChannelDuration(2, totaldur - odordur);
                Master9.SetChannelDelay(2, odordur);
                Master9.Trigger(2);
            end
        end
        
        if ~isempty(S.cont_scale) % continuous rating
            
            % Basic setting
            all_start_t = GetSecs;
            data.dat{run_i}{tr_i}.continuous_rating_timestamp = all_start_t;
            
            % Parse scales and basic setting
            scale = S.cont_scale;
            
            [lb, rb, start_center] = draw_scale(scale); % Get information about scale.
            Screen(theWindow,'FillRect',bgcolor, window_rect); % Just getting information, and do not show the scale.
            
            start_t = GetSecs;
            eval(['data.dat{run_i}{tr_i}.' scale '_timestamp = start_t;']);
            Screen(theWindow,'FillRect',bgcolor, window_rect);
            Screen('Flip', theWindow);
            
            rec_i = 0;
            ratetype = strcmp(rating_types.alltypes, scale);
            joy_button(1) = 0;
            button(1) = 0;
            
            
            % Initial position
            if strcmp(controller, 'joy')
                [joy_pos, joy_button] = mat_joy(0);
                start_joy_pos = joy_pos(1); % getting initial poisition
            elseif strcmp(controller, 'mouse')
                if start_center
                    SetMouse((rb+lb)/2,H/2); % set mouse at the center
                else
                    SetMouse(lb,H/2); % set mouse at the left
                end
            end
            
            % Get ratings
            while true % Button
                rec_i = rec_i+1;
                
                if strcmp(controller, 'joy')
                    [joy_pos, joy_button] = mat_joy(0);
                    %             if abs(start_joy_pos) > .1 % if start point is too deviated
                    %                 start_joy_pos = joy_pos(1);
                    %             end
                    if start_center
                        x = (joy_pos(1)-start_joy_pos) ./ controlspeed .* (rb-lb) + (rb+lb)/2; % both direction
                    else
                        x = (joy_pos(1)-start_joy_pos) ./ controlspeed .* (rb-lb) + lb; % only right direction
                    end
                elseif strcmp(controller, 'mouse')
                    [x,~,button] = GetMouse(theWindow);
                end
                
                
                if x < lb; x = lb; elseif x > rb; x = rb; end
                
                
                if joy_button(1) || button(1); break; end
                
                DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, orange, [], [], [], 2);
                
                [lb, rb, start_center] = draw_scale(scale);
                Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
                Screen('Flip', theWindow);
                
                cur_t = GetSecs;
                eval(['data.dat{run_i}{tr_i}.' scale '_time_fromstart(rec_i,1) = cur_t-start_t;']);
                eval(['data.dat{run_i}{tr_i}.' scale '_cont_rating(rec_i,1) = (x-lb)./(rb-lb);']);
                
                if cur_t-start_t >= S.ratetime_cont
                    break
                end
                
            end
            
            end_t = GetSecs;
            eval(['data.dat{run_i}{tr_i}.' scale '_rating = (x-lb)./(rb-lb);']);
            eval(['data.dat{run_i}{tr_i}.' scale '_RT = end_t - start_t;']);
            
            
            all_end_t = GetSecs;
            eval(['data.dat{run_i}{tr_i}.continuous_total_RT = all_end_t - all_start_t;']);

        else % not continuous rating
            WaitSecs(S.dur);
            if strcmp(S.type, 'PP') || strcmp(S.type, 'ODOR') 
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
            
            all_start_t = GetSecs;
            eval(['data.dat{run_i}{tr_i}.overall_rating_timestamp = all_start_t;']);
            
            % Parse scales and basic setting
            scale = S.overall_scale{1};
            
            [lb, rb, start_center] = draw_scale(scale); % Get information about scale.
            Screen(theWindow,'FillRect',bgcolor, window_rect); % Just getting information, and do not show the scale.
            
            start_t = GetSecs;
            eval(['data.dat{run_i}{tr_i}.' scale '_timestamp = start_t;']);
            Screen(theWindow,'FillRect',bgcolor, window_rect);
            Screen('Flip', theWindow);
            
            rec_i = 0;
            ratetype = strcmp(rating_types.alltypes, scale);
            joy_button(1) = 0;
            button(1) = 0;
            
            % Initial position
            if strcmp(controller, 'joy')
                [joy_pos, joy_button] = mat_joy(0);
                start_joy_pos = joy_pos(1); % getting initial poisition
            elseif strcmp(controller, 'mouse')
                if start_center
                    SetMouse((rb+lb)/2,H/2); % set mouse at the center
                else
                    SetMouse(lb,H/2); % set mouse at the left
                end
            end
            
            % Get ratings
            while true % Button
                rec_i = rec_i+1;
                
                if strcmp(controller, 'joy')
                    [joy_pos, joy_button] = mat_joy(0);
                    %             if abs(start_joy_pos) > .1 % if start point is too deviated
                    %                 start_joy_pos = joy_pos(1);
                    %             end
                    if start_center
                        x = (joy_pos(1)-start_joy_pos) ./ controlspeed .* (rb-lb) + (rb+lb)/2; % both direction
                    else
                        x = (joy_pos(1)-start_joy_pos) ./ controlspeed .* (rb-lb) + lb; % only right direction
                    end
                elseif strcmp(controller, 'mouse')
                    [x,~,button] = GetMouse(theWindow);
                end
                
                
                if x < lb; x = lb; elseif x > rb; x = rb; end
                
                
                if joy_button(1) || button(1); break; end
                
                DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, white, [], [], [], 2);
                
                [lb, rb, start_center] = draw_scale(scale);
                Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
                Screen('Flip', theWindow);
                
                cur_t = GetSecs;
                eval(['data.dat{run_i}{tr_i}.' scale '_time_fromstart(rec_i,1) = cur_t-start_t;']);
                eval(['data.dat{run_i}{tr_i}.' scale '_cont_rating(rec_i,1) = (x-lb)./(rb-lb);']);
                
                if cur_t-start_t >= S.ratetime_overall - 0.5
                    break
                end
                
            end
            
            end_t = GetSecs;
            eval(['data.dat{run_i}{tr_i}.' scale '_rating = (x-lb)./(rb-lb);']);
            eval(['data.dat{run_i}{tr_i}.' scale '_RT = end_t - start_t;']);
            
            % Freeze the screen 0.5 second with red line if overall type
            freeze_t = GetSecs;
            while true
                [lb, rb, start_center] = draw_scale(scale);
                DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, white, [], [], [], 2);
                Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
                Screen('Flip', theWindow);
                freeze_cur_t = GetSecs;
                if freeze_cur_t - freeze_t >= 0.5
                    break
                end
            end
            
            all_end_t = GetSecs;
            eval(['data.dat{run_i}{tr_i}.overall_total_RT = all_end_t - all_start_t;']);
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
            
            all_start_t = GetSecs;
            eval(['data.dat{run_i}{tr_i}.postrun_rating_timestamp = all_start_t;']);
            scales = postrun_questions{run_i};
            
            postrun_start_t = 2; % postrun start waiting time.
            postrun_between_t = 2; % postrun questionnaire waiting time.
            % '*' can be used as a wildcard.
            if ~isempty(strfind(scales{1}, '*'))
                scales = scales{1};
                ast = strfind(scales, '*') - 1;
                scales = rating_types.alltypes(strncmp(rating_types.alltypes, scales(1:ast), ast));
            end
            
            % Going through each scale
            for scale_i = 1:numel(scales)
                
                % (EXPLAIN or POSTRUN) First introduction
                if scale_i == 1
                    Screen(theWindow,'FillRect',bgcolor, window_rect);
                    msgtxt = [num2str(run_i) '��° run�� �������ϴ�.\n��� �� ����� ���õ� ���Դϴ�. ���ںв����� ��ٷ��ֽñ� �ٶ�ϴ�.'];
                    msgtxt = double(msgtxt); % korean to double
                    DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
                    Screen('Flip', theWindow);
                    
                    WaitSecs(postrun_start_t);
                end
                
                % Parse scales and basic setting
                scale = scales{scale_i};
                
                [lb, rb, start_center] = draw_scale(scale); % Get information about scale.
                Screen(theWindow,'FillRect',bgcolor, window_rect); % Just getting information, and do not show the scale.
                
                start_t = GetSecs;
                eval(['data.dat{run_i}{tr_i}.' scale '_timestamp = start_t;']);
                Screen(theWindow,'FillRect',bgcolor, window_rect);
                Screen('Flip', theWindow);
                
                rec_i = 0;
                ratetype = strcmp(rating_types.alltypes, scale);
                joy_button(1) = 0;
                button(1) = 0;
                
                
                % Initial position
                if strcmp(controller, 'joy')
                    [joy_pos, joy_button] = mat_joy(0);
                    start_joy_pos = joy_pos(1); % getting initial poisition
                elseif strcmp(controller, 'mouse')
                    if start_center
                        SetMouse((rb+lb)/2,H/2); % set mouse at the center
                    else
                        SetMouse(lb,H/2); % set mouse at the left
                    end
                end
                
                % Get ratings
                while true % Button
                    rec_i = rec_i+1;
                    
                    if strcmp(controller, 'joy')
                        [joy_pos, joy_button] = mat_joy(0);
                        %             if abs(start_joy_pos) > .1 % if start point is too deviated
                        %                 start_joy_pos = joy_pos(1);
                        %             end
                        if start_center
                            x = (joy_pos(1)-start_joy_pos) ./ controlspeed .* (rb-lb) + (rb+lb)/2; % both direction
                        else
                            x = (joy_pos(1)-start_joy_pos) ./ controlspeed .* (rb-lb) + lb; % only right direction
                        end
                    elseif strcmp(controller, 'mouse')
                        [x,~,button] = GetMouse(theWindow);
                    end
                    
                    
                    if x < lb; x = lb; elseif x > rb; x = rb; end
                    
                    
                    if joy_button(1) || button(1); break; end
                    
                    DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, white, [], [], [], 2);
                    
                    [lb, rb, start_center] = draw_scale(scale);
                    Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
                    Screen('Flip', theWindow);
                    
                    cur_t = GetSecs;
                    eval(['data.dat{run_i}{tr_i}.' scale '_time_fromstart(rec_i,1) = cur_t-start_t;']);
                    eval(['data.dat{run_i}{tr_i}.' scale '_cont_rating(rec_i,1) = (x-lb)./(rb-lb);']);
                    
                    if cur_t-start_t >= S.ratetime_post - 0.5
                        break
                    end
                    
                end
                
                end_t = GetSecs;
                eval(['data.dat{run_i}{tr_i}.' scale '_rating = (x-lb)./(rb-lb);']);
                eval(['data.dat{run_i}{tr_i}.' scale '_RT = end_t - start_t;']);
                
                %% Freeze the screen 0.5 second with red line if overall type
                freeze_t = GetSecs;
                while true
                    [lb, rb, start_center] = draw_scale(scale);
                    DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, white, [], [], [], 2);
                    Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
                    Screen('Flip', theWindow);
                    freeze_cur_t = GetSecs;
                    if freeze_cur_t - freeze_t > 0.5
                        break
                    end
                end
                
                
                % (EXPLAIN or POSTRUN) Move to next
                Screen(theWindow,'FillRect',bgcolor, window_rect);
                if scale_i ~= numel(scales)
                    msgtxt = '���ϰ� ���� ���� ���� ���� ��ٸ��ñ� �ٶ�ϴ�.';
                elseif scale_i == numel(scales)
                    msgtxt = '���� �������ϴ�.';
                end
                msgtxt = double(msgtxt); % korean to double
                DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
                Screen('Flip', theWindow);
                
                WaitSecs(postrun_between_t);
                
            end
            
            all_end_t = GetSecs;
            eval(['data.dat{run_i}{tr_i}.postrun_total_RT = all_end_t - all_start_t;']);
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
        
        Screen(theWindow,'FillRect',bgcolor, window_rect);
        if run_i < run_num
            msgtxt = [num2str(run_i) '��° run�� �������ϴ�.\n���ڰ� ���� run���� ������ �غ� �Ϸ�Ǹ� �����ڴ� SPACE Ű�� �����ֽñ� �ٶ�ϴ�.'];
        else
            msgtxt = 'session�� ��� �������ϴ�.\nsession�� ��ġ����, �����ڴ� SPACE Ű�� �����ֽñ� �ٶ�ϴ�.';
        end
        msgtxt = double(msgtxt); % korean to double
        DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
        Screen('Flip', theWindow);
        
    end
    
end % run ends

Screen('CloseAll');
disp('Done');
save(data.datafile, '-append', 'data');

if exist('t', 'var') && ~isempty(t); fclose(t); end
if exist('r', 'var') && ~isempty(r); fclose(r); end

