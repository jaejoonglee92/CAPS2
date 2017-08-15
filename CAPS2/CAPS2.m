%% SETUP : Basic parameter

clear;

global theWindow lb1 rb1 lb2 rb2 H W scale_W anchor_lms space korean alpnum special bgcolor white orange red;

basedir = pwd;
cd(basedir); addpath(genpath(basedir));

USE_BIOPAC = true;
show_cursor = false;%true;
screen_mode = 'full';
set_input = false;
exp_scale = {'cont_avoidance_exp', 'overall_avoidance'};
main_scale = {'cont_avoidance_exp'};


%% SETUP : Check subject info

subjID = input('\nSubject ID? ', 's');
subjID = strtrim(subjID);

subjnum = input('\nSubject number? ');

subjrun = input('\nRun number? ');


%% SETUP : Load randomized run data and Compare the markers

rundatdir = fullfile(basedir, 'CAPS2_randomized_run_data_v1.mat');
load(rundatdir, 'runs', 'subjmarker', 'runmarker');

if subjmarker ~= subjnum
    cont_or_not = input(['\nYou type the subject number that is inconsistent with the data previously saved.', ...
        '\nWill you go on with your subject number that typed just before?', ...
        '\n1: Yes, continue with typed subject number.  ,   2: No, I made a mistake. I`ll break.\n:  ']);
    if cont_or_not == 1
        subjmarker = subjnum;
    elseif cont_or_not == 2
        error('Breaked.')
    else
        error('You type the wrong number.')
    end
end

if runmarker ~= subjrun
    cont_or_not = input(['\nYou type the run number that is inconsistent with the data previously saved.', ...
        '\nWill you go on with your run number that typed just before?', ...
        '\n1: Yes, continue with typed run number.  ,   2: No, it`s a mistake. I`ll break.\n:  ']);
    if cont_or_not == 1
        runmarker = subjrun;
    elseif cont_or_not == 2
        error('Breaked.')
    else
        error('You type the wrong number.')
    end
end

save(rundatdir, '-append', 'subjmarker', 'runmarker');


%% SETUP : Save data in first

savedir = fullfile(basedir, 'Data');
if ~exist(savedir, 'dir')
    mkdir(savedir);
end

nowtime = clock;
subjtime = sprintf('%.2d%.2d%.2d', nowtime(1), nowtime(2), nowtime(3));

data.subject = subjID;
data.datafile = fullfile(savedir, [subjtime, '_', subjID, '_subj', sprintf('%.3d', subjnum), ...
    '_r', sprintf('%.2d', subjrun), '.mat']);
data.version = 'CAPS2_v1_08-14-2017_Cocoanlab';
data.starttime = datestr(clock, 0);
data.starttime_getsecs = GetSecs;

save(data.datafile, 'data');


%% SETUP : Paradigm

S.type = runs{subjnum, subjrun};
S.dur = 20*60 - 10; % 20 mins - 10 secs for disdaq
%S.dur = 30;
if strcmp(S.type, 'ODOR')
    S.odordur = 5 * 60; % 5 mins
    %S.odordur = 10;
    S.airdur = S.dur - S.odordur; % residual (almost 15 mins)
end
    
S.stimtext = '+';
S.int = '0001';

data.dat.type = S.type;
data.dat.duration = S.dur;
data.dat.stimtext = S.stimtext;
data.dat.int = str2double(S.int);
data.dat.exp_scale = exp_scale;
data.dat.main_scale = main_scale;

rating_types = call_ratingtypes;

postrun_start_t = 2; % postrun start waiting time.
postrun_between_t = 2; % postrun questionnaire waiting time.


%% SETUP : BIOPAC

if USE_BIOPAC
    channel_n = 1;
    biopac_channel = 0;
    ljHandle = BIOPAC_setup(channel_n);
end


%% SETUP : MASTER-9 and PPD for ODOR run

if strcmp(S.type, 'ODOR')
    
    % PPD
    [t, r] = pressure_pain_setup;
    
    % MASTER-9
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
    Master9.SetChannelDuration(1, S.odordur);
    Master9.SetChannelDelay(1, 0);
    
    Master9.ChangeChannelMode(2, cmTrig);
    Master9.SetChannelDuration(2, S.airdur);
    Master9.SetChannelDelay(2, S.odordur);
    
end


%% SETUP : Notify the run order

if subjrun == 1
    paradigm = runs(subjmarker, :)
    input(['\nTo continue, press any key.'])
end


%% SETUP : Screen

screens = Screen('Screens');
window_num = screens(end);
if ~show_cursor
    HideCursor;
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

anchor_lms = [0.014 0.061 0.172 0.354 0.533].*(rb1-lb1)+lb1;

% font
fontsize = 33;
%font = 'Helvetica';
%font = 'NanumBarunGothic';
Screen('Preference', 'TextEncodingLocale', 'ko_KR.UTF-8');

% color
bgcolor = 50;
white = 255;
red = [158 1 66];
orange = [255 164 0];

% open window
theWindow = Screen('OpenWindow', window_num, bgcolor, window_rect); % start the screen
%Screen('TextFont', theWindow, font);
Screen('TextSize', theWindow, fontsize);

% get font parameter
[~, ~, wordrect0, ~] = DrawFormattedText(theWindow, double(' '), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect1, ~] = DrawFormattedText(theWindow, double('코'), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect2, ~] = DrawFormattedText(theWindow, double('p'), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect3, ~] = DrawFormattedText(theWindow, double('^'), lb1-30, H/2+scale_W+40, bgcolor);
[space.x space.y korean.x korean.y alpnum.x alpnum.y special.x special.y] = deal(wordrect0(3)-wordrect0(1), wordrect0(4)-wordrect0(2), ...
    wordrect1(3)-wordrect1(1), wordrect1(4)-wordrect1(2), wordrect2(3)-wordrect2(1), wordrect2(4)-wordrect2(2), ...
    wordrect3(3)-wordrect3(1), wordrect3(4)-wordrect3(2));

Screen(theWindow, 'FillRect', bgcolor, window_rect); % Just getting information, and do not show the scale.
Screen('Flip', theWindow);


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


%% MAIN : Explain scale

if subjrun == 1
    
    % First introduction
    while true % Button
        DrawFormattedText(theWindow, rating_types.prompts_ex{1}, 'center', 100, white, [], [], [], 2);
        Screen('Flip', theWindow);
        
        [~,~,button] = GetMouse(theWindow);
        [~,~,keyCode_E] = KbCheck(Exp_key);
        
        if button(1)
            while button(1)
                [~,~,button] = GetMouse(theWindow);
            end
            break
        end
        
        if keyCode_E(KbName('q'))
            abort_experiment('manual');
            break
        end
        
    end
    
    %% (Explain) Continuous
    
    ratetype = strcmp(rating_types.alltypes, exp_scale{1});
    
    % Explain scale with visualization
    while true % Space
        
        [lb, rb, start_center] = draw_scale(exp_scale{1});
        
        DrawFormattedText(theWindow, rating_types.prompts_ex{2}, 'center', 100, orange, [], [], [], 1);
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 300, white, [], [], [], 1);
        Screen('Flip', theWindow);
        
        [~,~,keyCode_E] = KbCheck(Exp_key);
        
        if keyCode_E(KbName('space'))
            while keyCode_E(KbName('space'))
                [~,~,keyCode_E] = KbCheck(Exp_key);
            end
            break
        end
        
        if keyCode_E(KbName('q'))
            abort_experiment('manual');
            break
        end
        
    end
    
    % Initial position
    if start_center
        SetMouse((rb+lb)/2,H/2); % set mouse at the center
    else
        SetMouse(lb,H/2); % set mouse at the left
    end
    
    % Get ratings
    while true % Button
        
        [x,~,button] = GetMouse(theWindow);
        
        [lb, rb, start_center] = draw_scale(exp_scale{1});
        
        if x < lb; x = lb; elseif x > rb; x = rb; end
        
        if button(1)
            while button(1)
                [~,~,button] = GetMouse(theWindow);
            end
            break
        end
        
        DrawFormattedText(theWindow, rating_types.prompts_ex{3}, 'center', 100, orange, [], [], [], 2);
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 300, white, [], [], [], 2);
        
        Screen('DrawLine', theWindow, white, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);
        
        
    end
    
    % Move to the next
    while true % Button
        
        DrawFormattedText(theWindow, [rating_types.prompts_ex{4}], 'center', 200, orange, [], [], [], 2);
        Screen('Flip', theWindow);
        
        [~,~,button] = GetMouse(theWindow);
        [~,~,keyCode_E] = KbCheck(Exp_key);
        
        if button(1)
            while button(1)
                [~,~,button] = GetMouse(theWindow);
            end
            break
        end
        
        if keyCode_E(KbName('q'))
            abort_experiment('manual');
            break
        end
        
    end
    
    %% (Explain) Overall
    
    ratetype = strcmp(rating_types.alltypes, exp_scale{2});
    
    % Explain scale with visualization
    while true % Space
        
        [lb, rb, start_center] = draw_scale(exp_scale{2});
        
        DrawFormattedText(theWindow, rating_types.prompts_ex{2}, 'center', 100, orange, [], [], [], 1);
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 300, white, [], [], [], 1);
        Screen('Flip', theWindow);
        
        [~,~,keyCode_E] = KbCheck(Exp_key);
        
        if keyCode_E(KbName('space'))
            while keyCode_E(KbName('space'))
                [~,~,keyCode_E] = KbCheck(Exp_key);
            end
            break
        end
        
        if keyCode_E(KbName('q'))
            abort_experiment('manual');
            break
        end
        
    end
    
    % Initial position
    if start_center
        SetMouse((rb+lb)/2,H/2); % set mouse at the center
    else
        SetMouse(lb,H/2); % set mouse at the left
    end
    
    % Get ratings
    while true % Button
        
        [x,~,button] = GetMouse(theWindow);
        
        [lb, rb, start_center] = draw_scale(exp_scale{2});
        
        if x < lb; x = lb; elseif x > rb; x = rb; end
        
        if button(1)
            while button(1)
                [~,~,button] = GetMouse(theWindow);
            end
            break
        end
        
        DrawFormattedText(theWindow, rating_types.prompts_ex{3}, 'center', 100, orange, [], [], [], 2);
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 300, white, [], [], [], 2);
        
        Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);
        
        
    end
    
    % Freeze the screen 0.5 second with red line if overall type
    freeze_t = GetSecs;
    while true
        
        [lb, rb, start_center] = draw_scale(exp_scale{2});
        
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 300, white, [], [], [], 2);
        
        Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);
        
        freeze_cur_t = GetSecs;
        if freeze_cur_t - freeze_t > 0.5
            break
        end
        
    end
    
    % Move to next
    while true % Button
        
        DrawFormattedText(theWindow, rating_types.prompts_ex{5}, 'center', 100, orange, [], [], [], 1);
        Screen('Flip', theWindow);
        
        [~,~,button] = GetMouse(theWindow);
        [~,~,keyCode_E] = KbCheck(Exp_key);
        
        if button(1)
            while button(1)
                [~,~,button] = GetMouse(theWindow);
            end
            break
        end
        
        if keyCode_E(KbName('q'))
            abort_experiment('manual');
            break
        end
        
    end
    
end


%% Main : At first run, present '+' for structural scan

if subjrun == 1
    
    while true % Button
        
        msgtxt = '잠시 후 구조촬영이 시작될 예정입니다. 곧 나타날 화면 중앙의 + 표시를 응시하면서 편안히 계시기 바랍니다.\n준비가 완료되면 실험자는 SPACE 키를 눌러주시기 바랍니다.';
        msgtxt = double(msgtxt); % korean to double
        DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
        Screen('Flip', theWindow);
        
        [~,~,keyCode_E] = KbCheck(Exp_key);
        
        if keyCode_E(KbName('space'))
            while keyCode_E(KbName('space'))
                [~,~,keyCode_E] = KbCheck(Exp_key);
            end
            break
        end
        
        if keyCode_E(KbName('q'))
            abort_experiment('manual');
            break
        end
        
    end

    while true % Space
        
        DrawFormattedText(theWindow, S.stimtext, 'center', 'center', white, [], [], [], 2);
        Screen('Flip', theWindow);
        
        [~,~,keyCode_E] = KbCheck(Exp_key);
        
        if keyCode_E(KbName('space'))
            while keyCode_E(KbName('space'))
                [~,~,keyCode_E] = KbCheck(Exp_key);
            end
            break
        end
        
        if keyCode_E(KbName('q'))
            abort_experiment('manual');
            break
        end
        
    end
    
end

%% Main : Ready for scan

while true
    
    msgtxt = '실험자는 모든 세팅이 완료되었는지 확인하시기 바랍니다.(BIOPAC, PPD, 등등...)\n준비가 완료되면 실험자는 SPACE 키를 눌러주시기 바랍니다.';
    msgtxt = double(msgtxt); % korean to double
    DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    
    [~,~,keyCode_E] = KbCheck(Exp_key);
    
    if keyCode_E(KbName('space'))
        while keyCode_E(KbName('space'))
            [~,~,keyCode_E] = KbCheck(Exp_key);
        end
        break
    end
    
    if keyCode_E(KbName('q'))
        abort_experiment('manual');
        break
    end
    
end



%% MAIN : Sync (S key)

while true
    
    msgtxt = '참가자가 모든 준비가 완료되면 스캔을 시작합니다. (S 키)';
    msgtxt = double(msgtxt); % korean to double
    DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    
    [~,~,keyCode_S] = KbCheck(Scan_key);
    [~,~,keyCode_E] = KbCheck(Exp_key);
    
    if keyCode_S(KbName('s')); break; end
    
    if keyCode_E(KbName('q'))
        abort_experiment('manual');
        break
    end
    
end


%% MAIN : Disdaq (4 + 4 + 2 = 10 secs)

% 4 secs : scanning...
start_t = GetSecs;
data.dat.runscan_starttime = start_t;

while true
    msgtxt = '시작하는 중...';
    msgtxt = double(msgtxt); % korean to double
    DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    
    cur_t = GetSecs;
    if cur_t - start_t >= 4 % Modify it
        break
    end
    
end

% 4 secs : blank
start_t = GetSecs;
while true
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('Flip', theWindow);
    
    cur_t = GetSecs;
    if cur_t - start_t >= 4 % Modify it
        break
    end
    
end

% 2 secs : BIOPAC
if USE_BIOPAC
    BIOPAC_trigger(ljHandle, biopac_channel, 'on');
end

start_t = GetSecs;
while true
    
    cur_t = GetSecs;
    if cur_t - start_t >= 2 % Modify it
        break
    end
    
end

if USE_BIOPAC
    BIOPAC_trigger(ljHandle, biopac_channel, 'off');
end


%% MAIN : Continuous rating

start_t = GetSecs;
data.dat.stim_timestamp = start_t;

if strcmp(S.type, 'ODOR')
    
    % PPD
    fwrite(t, ['1, ' S.int ', t']);
    
    % Master-9
    Master9.Trigger(1);
    Master9.Trigger(2);
    
end

% Basic setting
rec_i = 0;
ratetype = strcmp(rating_types.alltypes, main_scale{1});

[lb, rb, start_center] = draw_scale(main_scale{1}); % Getting information
Screen('FillRect', theWindow, bgcolor, window_rect); % clear the screen

% Initial position
if start_center
    SetMouse((rb+lb)/2,H/2); % set mouse at the center
else
    SetMouse(lb,H/2); % set mouse at the left
end

% Get ratings
while true % Button
    
    rec_i = rec_i + 1;
    
    [x,~,button] = GetMouse(theWindow);
    [~,~,keyCode_E] = KbCheck(Exp_key);
    
    if keyCode_E(KbName('q'))
        abort_experiment('manual');
        break
    end
    
    if x < lb; x = lb; elseif x > rb; x = rb; end
    
    [lb, rb, start_center] = draw_scale(main_scale{1});
    
    DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, orange, [], [], [], 2);
    
    Screen('DrawLine', theWindow, white, x, H/2, x, H/2+scale_W, 6);
    Screen('Flip', theWindow);
    
    
    cur_t = GetSecs;
    data.dat.time_fromstart(rec_i,1) = cur_t-start_t;
    data.dat.cont_rating(rec_i,1) = (x-lb)./(rb-lb);
    
    if cur_t - start_t >= S.dur
        if strcmp(S.type, 'ODOR')
            fwrite(t, ['1, ' S.int ', s']);
        end
        break
    end
    
end

data.dat.total_dur_recorded = GetSecs - start_t;


%% MAIN : Postrun questionnaire

all_start_t = GetSecs;
data.dat.postrun_rating_timestamp = all_start_t;
ratestim = strcmp(rating_types.postallstims, S.type);
scales = rating_types.postalltypes{ratestim};

% Going through each scale
for scale_i = 1:numel(scales)
    
    % First introduction
    if scale_i == 1
        
        msgtxt = [num2str(subjrun) '번째 세션이 끝났습니다.\n잠시 후 질문들이 제시될 것입니다. 참가자분께서는 기다려주시기 바랍니다.'];
        msgtxt = double(msgtxt); % korean to double
        DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
        Screen('Flip', theWindow);
        
        start_t = GetSecs;
        while true
            cur_t = GetSecs;
            if cur_t - start_t >= postrun_start_t
                break
            end
        end
        
    end
    
    % Parse scales and basic setting
    scale = scales{scale_i};
    
    [lb, rb, start_center] = draw_scale(scale);
    Screen(theWindow, 'FillRect', bgcolor, window_rect);
    
    start_t = GetSecs;
    eval(['data.dat.' scale '_timestamp = start_t;']);
    
    rec_i = 0;
    ratetype = strcmp(rating_types.alltypes, scale);
    
    % Initial position
    if start_center
        SetMouse((rb+lb)/2,H/2); % set mouse at the center
    else
        SetMouse(lb,H/2); % set mouse at the left
    end
    
    % Get ratings
    while true % Button
        rec_i = rec_i + 1;
        
        [x,~,button] = GetMouse(theWindow);
        
        [lb, rb, start_center] = draw_scale(scale);
        
        if x < lb; x = lb; elseif x > rb; x = rb; end
        
        DrawFormattedText(theWindow, rating_types.prompts{ratetype}, 'center', 200, white, [], [], [], 2);
        
        Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);
        
        if button(1)
            while button(1)
                [~,~,button] = GetMouse(theWindow);
            end
            break
        end
        
        cur_t = GetSecs;
        eval(['data.dat.' scale '_time_fromstart(rec_i,1) = cur_t-start_t;']);
        eval(['data.dat.' scale '_cont_rating(rec_i,1) = (x-lb)./(rb-lb);']);
        
    end
    
    end_t = GetSecs;
    eval(['data.dat.' scale '_rating = (x-lb)./(rb-lb);']);
    eval(['data.dat.' scale '_RT = end_t - start_t;']);
    
    % Freeze the screen 0.5 second with red line if overall type
    
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
    
    
    % Move to the next
    if scale_i ~= numel(scales)
        msgtxt = '편하게 손을 놓고 다음 질문을 기다리시기 바랍니다.';
    elseif scale_i == numel(scales)
        msgtxt = '질문이 끝났습니다.';
    end
    msgtxt = double(msgtxt); % korean to double
    DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    
    start_t = GetSecs;
    while true
        cur_t = GetSecs;
        if cur_t - start_t >= postrun_between_t
            break
        end
    end
    
end

all_end_t = GetSecs;
data.dat.postrun_total_RT = all_end_t - all_start_t;

save(data.datafile, '-append', 'data');


%% Closing screen

while true % Space
    
    [~,~,keyCode_E] = KbCheck(Exp_key);
    if keyCode_E(KbName('space'))
        while keyCode_E(KbName('space'))
            [~,~,keyCode_E] = KbCheck(Exp_key);
        end
        break
    end
    
    if keyCode_E(KbName('q'))
        abort_experiment('manual');
        break
    end
    
    msgtxt = [num2str(subjrun) '번째 세션이 끝났습니다.\n세션을 마치려면, 실험자는 SPACE 키를 눌러주시기 바랍니다.'];
    msgtxt = double(msgtxt); % korean to double
    DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
    Screen('Flip', theWindow);
    
end

Screen('CloseAll');

if exist('t', 'var') && ~isempty(t); fclose(t); end
if exist('r', 'var') && ~isempty(r); fclose(r); end

%% Update markers and finish experiment

if runmarker < 4
    runmarker = runmarker + 1;
elseif runmarker == 4
    subjmarker = subjmarker + 1;
    runmarker = 1;
end
save(rundatdir, '-append', 'subjmarker', 'runmarker');

disp('Done');
