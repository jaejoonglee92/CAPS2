function data = get_ratings(scales, scaletype, controller, controlspeed, run_i, tr_i, rate_time, data)

%data = get_ratings(scales, scaletype, controller, controlspeed, run_i, tr_i, rate_time, data)
%scales : all the scales to be displayed.
%scaletype : 'explain', 'overall', 'continuous', 'postrun'.
%controller : 'joy', 'mouse'.
%controlspeed : speed of controller.
%run_i : Run number.
%tr_i : Trial number.
%rate_time : Rating time. If explain mode, it is fixed as infinite number.
%data : data.

global window_rect W H theWindow scale_W; % window property
global white red orange bgcolor; % color
global font fontsize
global Exp_key Par_key Scan_key
global t r; % pressure device udp channel
global rating_types % dictionary for all rating types and matched prompts

%% Basic setting

all_start_t = GetSecs;
eval(['data.dat{run_i}{tr_i}.' scaletype '_rating_timestamp = all_start_t;']);

if scaletype == 'explain'
    rate_time = Inf;
elseif scaletype == 'postrun'
    postrun_start_t = 2; % postrun start waiting time.
    postrun_between_t = 2; % postrun questionnaire waiting time.
    % '*' can be used as a wildcard.
    if ~isempty(strfind(scales{1}, '*'))
        scales = scales{1};
        ast = strfind(scales, '*') - 1;
        scales = rating_types.alltypes(strncmp(rating_types.alltypes, scales(1:ast), ast));
    end
end

if strcmp(controller, 'joy')
    joy_speed = controlspeed;
end


%% Going through each scale
for scale_i = 1:numel(scales)
    
    %% (EXPLAIN or POSTRUN) First introduction
    if scale_i == 1
        if scaletype == 'explain'
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
        elseif scaletype == 'postrun'
            display_message('postrunstart', run_i)
            WaitSecs(postrun_start_t);
        end
    end
    
    
    %% Parse scales and basic setting
    scale = scales{scale_i};
    
    [lb, rb, start_center] = draw_scale(scale); % Get information about scale.
    Screen(theWindow,'FillRect',bgcolor, window_rect); % Just getting information, and do not show the scale.

    start_t = GetSecs;
    eval(['data.dat{run_i}{tr_i}.' scale '_timestamp = start_t;']);
    Screen(theWindow,'FillRect',bgcolor, window_rect);
    Screen('Flip', theWindow);
    
    rec_i = 0;
    i = strcmp(rating_types.alltypes, scale);
    joy_button(1) = 0; button(1) = 0;
    
    %% (EXPLAIN) explain scale with visualization
    if scaletype == 'explain'
        while true % Space
            [lb, rb, start_center] = draw_scale(scale); % draw scale
            DrawFormattedText(theWindow, rating_types.prompts_ex{2}, 'center', 100, orange, [], [], [], 1);
            DrawFormattedText(theWindow, rating_types.prompts{i}, 'center', 300, white, [], [], [], 1);
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
    
    
    %% Initial position
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
    
    %% Get ratings
    while true % Button
        rec_i = rec_i+1;
        
        if strcmp(controller, 'joy')
            [joy_pos, joy_button] = mat_joy(0);
            if abs(start_joy_pos) > .1 % if start point is too deviated
                start_joy_pos = joy_pos(1);
            end
            if start_center
                x = (joy_pos(1)-start_joy_pos) ./ joy_speed .* (rb-lb) + (rb+lb)/2; % both direction
            else
                x = (joy_pos(1)-start_joy_pos) ./ joy_speed .* (rb-lb) + lb; % only right direction
            end
        elseif strcmp(controller, 'mouse')
            [x,~,button] = GetMouse(theWindow);
        end
        
      
        if x < lb; x = lb; elseif x > rb; x = rb; end
            
        
        if joy_button(1) || button(1); break; end
        
        if strcmp(scaletype, 'explain')
            DrawFormattedText(theWindow, rating_types.prompts_ex{3}, 'center', 100, orange, [], [], [], 2);
            DrawFormattedText(theWindow, rating_types.prompts{i}, 'center', 300, white, [], [], [], 2);
        else
            if strncmp(scale, 'overall_', length('overall_'))
                DrawFormattedText(theWindow, rating_types.prompts{i}, 'center', 200, white, [], [], [], 2);
            elseif strncmp(scale, 'cont_', length('cont_'))
                DrawFormattedText(theWindow, rating_types.prompts{i}, 'center', 200, orange, [], [], [], 2);
            end
        end
        
        [lb, rb, start_center] = draw_scale(scale);
        Screen('DrawLine', theWindow, orange, x, H/2, x, H/2+scale_W, 6);
        Screen('Flip', theWindow);
        
        cur_t = GetSecs;
        eval(['data.dat{run_i}{tr_i}.' scale '_time_fromstart(rec_i,1) = cur_t-start_t;']);
        eval(['data.dat{run_i}{tr_i}.' scale '_cont_rating(rec_i,1) = (x-lb)./(rb-lb);']);
        
        if cur_t-start_t >= rate_time
            break
        end
        
    end
    
    end_t = GetSecs;
    eval(['data.dat{run_i}{tr_i}.' scale '_rating = (x-lb)./(rb-lb);']);
    eval(['data.dat{run_i}{tr_i}.' scale '_RT = end_t - start_t;']);
    
    %% Freeze the screen 0.5 second with red line if overall type
    freeze_t = GetSecs;
    if strncmp(scale, 'overall_', length('overall_')) % to include 1)overall in explain mode & 2)overall mode 3)postrun mode
        while true
            [lb, rb, start_center] = draw_scale(scale);
            if strcmp(scaletype, 'explain')
                DrawFormattedText(theWindow, rating_types.prompts{i}, 'center', 300, white, [], [], [], 2);
            else
                DrawFormattedText(theWindow, rating_types.prompts{i}, 'center', 200, white, [], [], [], 2);
            end
            Screen('DrawLine', theWindow, red, x, H/2, x, H/2+scale_W, 6);
            Screen('Flip', theWindow);
            WaitSecs(0.5);
            freeze_cur_t = GetSecs;
            if freeze_cur_t - freeze_t > 0.5
                break
            end
        end
    end
    
    
    %% (EXPLAIN or POSTRUN) Move to next
    if strcmp(scaletype, 'explain')
        while true % Space
            if strncmp(scale, 'cont_', numel('cont_'))
                if scale_i < numel(scales)
                    DrawFormattedText(theWindow, [rating_types.prompts_ex{4} '\n\n' ...
                        rating_types.prompts_ex{6}], 'center', 100, orange, [], [], [], 2);
                else
                    DrawFormattedText(theWindow, [rating_types.prompts_ex{5} '\n\n' ...
                        rating_types.prompts_ex{6}], 'center', 100, orange, [], [], [], 2);
                end
            elseif strncmp(scale, 'overall_', numel('overall_'))
                if scale_i < numel(scales)
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
    elseif strcmp(scaletype, 'postrun')
        if scale_i ~= numel(scales)
            display_message('postrunwait', run_i);
        elseif scale_i == numel(scales)
            display_message('postrunwaitend', run_i);
        end
        WaitSecs(postrun_between_t);
    end
    
end

all_end_t = GetSecs;
eval(['data.dat{run_i}{tr_i}.' scaletype '_total_RT = all_end_t - all_start_t;']);

end