function [lb, rb, start_center] = draw_scale(scale)
%[lb, rb, start_center] = draw_scale(scale) 
%This function can draw a scale, get left boarder and right boarder, and
%identify whether this scale starts from center or not.
%scale needs to be string(ex. 'line', 'overall_int', 'cont_avoidance', ...)

global window_rect W H theWindow scale_W; % window property
global white red orange bgcolor; % color
global font fontsize
global Exp_key Par_key Scan_key
global t r; % pressure device udp channel
global rating_types % dictionary for all rating types and matched prompts

%% Scale parameter
lb1 = W/4; % rating scale left bounds 1/4
rb1 = (3*W)/4; % rating scale right bounds 3/4

lb2 = W/3; % new bound for or not
rb2 = (W*2)/3; 

scale_W = (rb1-lb1).*0.1; % Height of the scale (10% of the width)

anchor_lms = [0.014 0.061 0.172 0.354 0.533].*(rb1-lb1)+lb1;

[~, ~, wordrect0, ~] = DrawFormattedText(theWindow, double(' '), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect1, ~] = DrawFormattedText(theWindow, double('코'), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect2, ~] = DrawFormattedText(theWindow, double('p'), lb1-30, H/2+scale_W+40, bgcolor);
[~, ~, wordrect3, ~] = DrawFormattedText(theWindow, double('^'), lb1-30, H/2+scale_W+40, bgcolor);
[space.x space.y korean.x korean.y alpnum.x alpnum.y special.x special.y] = deal(wordrect0(3)-wordrect0(1), wordrect0(4)-wordrect0(2), ...
    wordrect1(3)-wordrect1(1), wordrect1(4)-wordrect1(2), wordrect2(3)-wordrect2(1), wordrect2(4)-wordrect2(2), ...
    wordrect3(3)-wordrect3(1), wordrect3(4)-wordrect3(2));


%% Default setting of variable parameter
drawclass = 1;
start_center = false; 


%% Drawing scale
switch scale
    case 'line'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('전혀'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('최대'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'lms'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('최대'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        for i = 1:5
            Screen('DrawLine', theWindow, 0, anchor_lms(i), H/2+scale_W, anchor_lms(i), H/2, 2);
        end
        DrawFormattedText_CAPS(theWindow, double('거의\n없는'), anchor_lms(1)-korean.x-10, H/2-korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('약한'), anchor_lms(2)-korean.x+10, H/2-korean.y/2, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('보통'), anchor_lms(3)-korean.x, H/2-korean.y/2, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('강한'), anchor_lms(4)-korean.x, H/2-korean.y/2, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우\n강한'), anchor_lms(5)-korean.x, H/2-korean.y, white, [], [], [], 0, 1);
        
    case 'overall_int'
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_int_numel'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('0 kg/cm^2'), lb1-alpnum.x*3-special.x-space.x/2, H/2+scale_W+alpnum.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('10 kg/cm^2'), rb1-alpnum.x*3-special.x-space.x/2, H/2+scale_W+alpnum.y, white, [], [], [], 0, 1);
        
    case 'overall_avoidance'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 피할\n필요 없음'), lb1-korean.x*2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double(' 절대로 다시\n경험하고 싶지\n      않음'), rb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_unpleasant'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 불쾌하지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n  가장 불쾌한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'cont_int'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/6+scale_W; rb1 H/6+scale_W; rb1 H/6];
        Screen(theWindow, 'FillPoly', orange, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/6+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/6+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'cont_avoidance'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/6+scale_W; rb1 H/6+scale_W; rb1 H/6];
        Screen(theWindow, 'FillPoly', orange, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 피할\n필요 없음'), lb1-korean.x*2-space.x/2, H/6+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double(' 절대로 다시\n경험하고 싶지\n      않음'), rb1-korean.x*3-space.x/2, H/6+scale_W+korean.y, white, [], [], [], 0, 1);
    
    case 'cont_avoidance_exp'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', orange, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 피할\n필요 없음'), lb1-korean.x*2-space.x/2, H/6+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double(' 절대로 다시\n경험하고 싶지\n      않음'), rb1-korean.x*3-space.x/2, H/6+scale_W+korean.y, white, [], [], [], 0, 1);
 
    case 'overall_aversive_ornot'
        drawclass = 2;
        start_center = true;
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        lb2_middle = lb2+((rb2-lb2).*0.4);
        rb2_middle = rb2-((rb2-lb2).*0.4);
        
        xy = [lb2 lb2 lb2 lb2_middle lb2_middle lb2_middle;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        xy2 = [rb2 rb2 rb2 rb2_middle rb2_middle rb2_middle;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawLines', xy2, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('예'), (lb2+lb2_middle)/2-korean.x/2,  H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('아니오'), (rb2+rb2_middle)/2-korean.x*3/2,  H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_pain_ornot'
        drawclass = 2;
        start_center = true;
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        lb2_middle = lb2+((rb2-lb2).*0.4);
        rb2_middle = rb2-((rb2-lb2).*0.4);
        
        xy = [lb2 lb2 lb2 lb2_middle lb2_middle lb2_middle;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        xy2 = [rb2 rb2 rb2 rb2_middle rb2_middle rb2_middle;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawLines', xy2, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('예'), (lb2+lb2_middle)/2-korean.x/2,  H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('아니오'), (rb2+rb2_middle)/2-korean.x*3/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_boredness'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('전혀 지겹지\n     않음'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우 지겨움'), rb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_alertness'
        start_center = true;
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('매우 졸림'), lb1-korean.x*2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('중간'), (lb1+rb1)/2-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우 또렷'), rb1-korean.x*2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_relaxed'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('매우 불편함'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우 편함'), rb1-korean.x*2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_attention'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('전혀 집중되지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우 집중\n   잘 됨'), rb1-korean.x*2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_positive'
        start_center = true;
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('중간'), (lb1+rb1)/2-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_negative'
        start_center = true;
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('중간'), (lb1+rb1)/2-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_myself'
        start_center = true;
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('중간'), (lb1+rb1)/2-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_others'
        start_center = true;
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('중간'), (lb1+rb1)/2-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_imagery'
        start_center = true;
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('중간'), (lb1+rb1)/2-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_present'
        start_center = true;
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('중간'), (lb1+rb1)/2-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_past'
        start_center = true;
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('중간'), (lb1+rb1)/2-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_future'
        start_center = true;
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('전혀 그렇지\n     않다'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('중간'), (lb1+rb1)/2-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우 그렇다'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_bitter_int'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_bitter_unp'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 불쾌하지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n  가장 불쾌한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_capsai_int'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_capsai_unp'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 불쾌하지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n  가장 불쾌한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_thermal_int'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_thermal_unp'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 불쾌하지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n  가장 불쾌한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_pressure_int'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_pressure_unp'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 불쾌하지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n  가장 불쾌한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_negvis_int'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_negvis_unp'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 불쾌하지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n  가장 불쾌한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_negaud_int'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_negaud_unp'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 불쾌하지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n  가장 불쾌한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_posvis_int'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 느껴지지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n   가장 심한'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_posvis_ple'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('전혀 불쾌하지\n      않음'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('상상할 수 있는\n가장 기분 좋은'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_comfortness'
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('매우 불편함'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우 편함'), rb1-korean.x*2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_mood'
        start_center = true;
        eval(['lb = lb' num2str(drawclass) ';']); eval(['rb = rb' num2str(drawclass) ';']);
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('매우 부정적'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('중간'), (lb1+rb1)/2-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('매우 긍정적'), rb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
           
end

end

