function setup_screen(testmode, screen_mode)
%setup_screen(testmode, screen_mode)
%This function help set up screen and open window.
%testmode : If 1, testmode is operated.
%screen_mode : 'full', 'semifull', 'middle', 'small'.

global window_rect W H theWindow; % window property
global white red orange bgcolor; % color
global font fontsize
global Exp_key Par_key Scan_key
global t r; % pressure device udp channel
global rating_types % dictionary for all rating types and matched prompts

%% Resolution
screens = Screen('Screens');
if ~testmode
    window_num = screens(end); % the last window
    Screen('Preference', 'SkipSyncTests', 0);
    HideCursor;
elseif testmode
    window_num = 0;
    Screen('Preference', 'SkipSyncTests', 1);
    ShowCursor;
end

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

% font
fontsize = 33;
%font = 'Helvetica';
font = 'NanumBarunGothic'; Screen('Preference', 'TextEncodingLocale', 'ko_KR.UTF-8');

% color
bgcolor = 100;
white = 255;
red = [158 1 66];
orange = [255 164 0];

% open window
theWindow = Screen('OpenWindow', window_num, bgcolor, window_rect); % start the screen
Screen('TextFont', theWindow, font);
Screen('TextSize', theWindow, fontsize);

end

