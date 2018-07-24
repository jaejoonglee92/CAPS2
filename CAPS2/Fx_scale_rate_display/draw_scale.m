function [lb, rb, start_center] = draw_scale(scale)

global theWindow lb1 rb1 lb2 rb2 H W scale_W anchor_lms space korean alpnum special bgcolor white orange red

%% Basic setting
lb = lb1;
rb = rb1;
start_center = false;


%% Drawing scale
switch scale
    case 'line'
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('����'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ִ�'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'lms'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('����'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ִ�'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        for i = 1:5
            Screen('DrawLine', theWindow, 0, anchor_lms(i), H/2+scale_W, anchor_lms(i), H/2, 2);
        end
        DrawFormattedText_CAPS(theWindow, double('����\n����'), anchor_lms(1)-korean.x-10, H/2-korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����'), anchor_lms(2)-korean.x+10, H/2-korean.y/2, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����'), anchor_lms(3)-korean.x, H/2-korean.y/2, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����'), anchor_lms(4)-korean.x, H/2-korean.y/2, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ�\n����'), anchor_lms(5)-korean.x, H/2-korean.y, white, [], [], [], 0, 1);
        
    case 'overall_int'
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('���� ��������\n      ����'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����� �� �ִ�\n   ���� ����'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_int_numel'
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('0 kg/cm^2'), lb1-alpnum.x*3-special.x-space.x/2, H/2+scale_W+alpnum.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('10 kg/cm^2'), rb1-alpnum.x*3-special.x-space.x/2, H/2+scale_W+alpnum.y, white, [], [], [], 0, 1);
        
    case 'overall_avoidance'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('����'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ִ�'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_unpleasant'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('���� ��������\n      ����'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����� �� �ִ�\n  ���� ������'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'cont_int'
        
        xy = [lb1 H/6+scale_W; rb1 H/6+scale_W; rb1 H/6];
        Screen(theWindow, 'FillPoly', orange, xy);
        DrawFormattedText_CAPS(theWindow, double('���� ��������\n      ����'), lb1-korean.x*3-space.x/2, H/6+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����� �� �ִ�\n   ���� ����'), rb1-korean.x*3-space.x, H/6+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'cont_avoidance'
        
        xy = [lb1 H/6+scale_W; rb1 H/6+scale_W; rb1 H/6];
        Screen(theWindow, 'FillPoly', orange, xy);
        DrawFormattedText_CAPS(theWindow, double('���� ����\n�ʿ� ����'), lb1-korean.x*2-space.x/2, H/6+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double(' ����� �ٽ�\n�����ϰ� ����\n      ����'), rb1-korean.x*3-space.x/2, H/6+scale_W+korean.y, white, [], [], [], 0, 1);
    
    case 'cont_avoidance_exp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', white, xy);
        DrawFormattedText_CAPS(theWindow, double('����'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ִ�'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_aversive_ornot'
        start_center = true;
        lb = lb2;
        rb = rb2;
        lb2_middle = lb2+((rb2-lb2).*0.4);
        rb2_middle = rb2-((rb2-lb2).*0.4);
        
        xy = [lb2 lb2 lb2 lb2_middle lb2_middle lb2_middle;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        xy2 = [rb2 rb2 rb2 rb2_middle rb2_middle rb2_middle;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawLines', xy2, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('��'), (lb2+lb2_middle)/2-korean.x/2,  H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ƴϿ�'), (rb2+rb2_middle)/2-korean.x*3/2,  H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_pain_ornot'
        start_center = true;
        lb = lb2;
        rb = rb2;
        lb2_middle = lb2+((rb2-lb2).*0.4);
        rb2_middle = rb2-((rb2-lb2).*0.4);
        
        xy = [lb2 lb2 lb2 lb2_middle lb2_middle lb2_middle;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        xy2 = [rb2 rb2 rb2 rb2_middle rb2_middle rb2_middle;
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        Screen(theWindow,'DrawLines', xy2, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('��'), (lb2+lb2_middle)/2-korean.x/2,  H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ƴϿ�'), (rb2+rb2_middle)/2-korean.x*3/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_boredness'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('���� ������\n     ����'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ� ���ܿ�'), rb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);

        
    case 'overall_alertness'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('�ſ� ����'), lb1-korean.x*2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ� �Ƿ�'), rb1-korean.x*2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);

        
    case 'overall_relaxed'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('�ſ� ������'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ� ����'), rb1-korean.x*2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);

        
    case 'overall_attention'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('���� ���ߵ���\n      ����'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ� ����\n   �� ��'), rb1-korean.x*2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
        
    case 'overall_resting_positive'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('���� �׷���\n     �ʴ�'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ� �׷���'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);

        
    case 'overall_resting_negative'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('���� �׷���\n     �ʴ�'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ� �׷���'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_myself'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('���� �׷���\n     �ʴ�'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ� �׷���'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_others'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('���� �׷���\n     �ʴ�'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ� �׷���'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_imagery'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('���� �׷���\n     �ʴ�'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ� �׷���'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_present'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('���� �׷���\n     �ʴ�'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ� �׷���'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_past'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('���� �׷���\n     �ʴ�'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ� �׷���'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_future'
        start_center = true;
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('���� �׷���\n     �ʴ�'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ� �׷���'), rb1-korean.x*5/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_bitter_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('����'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ִ�'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_bitter_unp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('����'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ִ�'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_capsai_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('����'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ִ�'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_capsai_unp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('����'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ִ�'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_odor_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('����'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ִ�'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_resting_odor_unp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('����'), lb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ִ�'), rb1-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_thermal_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('���� ��������\n      ����'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����� �� �ִ�\n   ���� ����'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_thermal_unp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('���� ��������\n      ����'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����� �� �ִ�\n  ���� ������'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_pressure_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('���� ��������\n      ����'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����� �� �ִ�\n   ���� ����'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_pressure_unp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('���� ��������\n      ����'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����� �� �ִ�\n  ���� ������'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_negvis_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('���� ��������\n      ����'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����� �� �ִ�\n   ���� ����'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_negvis_unp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('���� ��������\n      ����'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����� �� �ִ�\n  ���� ������'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_negaud_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('���� ��������\n      ����'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����� �� �ִ�\n   ���� ����'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_negaud_unp'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('���� ��������\n      ����'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����� �� �ִ�\n  ���� ������'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_posvis_int'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('���� ��������\n      ����'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����� �� �ִ�\n   ���� ����'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_posvis_ple'
        
        xy = [lb1 H/2+scale_W; rb1 H/2+scale_W; rb1 H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        DrawFormattedText_CAPS(theWindow, double('���� ��������\n      ����'), lb1-korean.x*3-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('����� �� �ִ�\n���� ��� ����'), rb1-korean.x*3-space.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_comfortness'
        
        xy = [lb1 lb1 lb1 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('�ſ� ������'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ� ����'), rb1-korean.x*2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
    case 'overall_mood'
        start_center = true;
        
        xy = [lb1 lb1 lb1 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 (lb1+rb1)/2 rb1 rb1 rb1; ...
            H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W H/2+scale_W/2 H/2+scale_W/2 H/2 H/2+scale_W];
        Screen(theWindow,'DrawLines', xy, 5, 255);
        DrawFormattedText_CAPS(theWindow, double('�ſ� ������'), lb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�߰�'), (lb1+rb1)/2-korean.x, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        DrawFormattedText_CAPS(theWindow, double('�ſ� ������'), rb1-korean.x*5/2-space.x/2, H/2+scale_W+korean.y, white, [], [], [], 0, 1);
        
           
end

end


