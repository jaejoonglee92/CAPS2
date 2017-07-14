function setup_input(set_input)
%setup_input(set_input)
%This function can help specifying input device.
%set_input : if 1, this option will be activated.
%You should modify this function depending on the environment.


global window_rect W H theWindow; % window property
global white red orange bgcolor; % color
global font fontsize
global Exp_key Par_key Scan_key
global t r; % pressure device udp channel
global rating_types % dictionary for all rating types and matched prompts

%% Find out specific input devices. (This section need to be modified in each scan environment)
devices = PsychHID('Devices');  
devices_keyboard = [];
for i = 1:numel(devices)
    if strcmp(devices(i).usageName, 'Keyboard')
        devices_keyboard = [devices_keyboard, devices(i)];
    end
end

if ~set_input
    Exp_key = [];
    Par_key = [];
    Scan_key = [];
elseif set_input % JJ's mac setting
    Exp_key = devices_keyboard(3).index;
    Par_key = devices_keyboard(3).index;
    Scan_key = devices_keyboard(3).index;
end


%% Parameter setting
joy_speed = .8; % should be between 0.1 and .95(?) or 1, higher = slower


end

