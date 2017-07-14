function scale_test(scale, screen_mode)
%scale_test(scale, screen_mode)
%This function helps test scale in testmode by setup_screen.
%scale : scale to be drawn.
%screen_mode : it needs to be specifed to call setup_screen(if you don`t
%              know about the setup_screen, type help)
%mouse left click can abort this function.

global window_rect W H theWindow; % window property
global white red orange bgcolor; % color
global font fontsize
global Exp_key Par_key Scan_key
global t r; % pressure device udp channel
global rating_types % dictionary for all rating types and matched prompts

testmode = 1;
setup_screen(testmode, screen_mode);
draw_scale(scale);
Screen('Flip', theWindow);

while true
    [~,~,buttons] = GetMouse;
    if buttons(1)
        sca
        break
    end
end

end