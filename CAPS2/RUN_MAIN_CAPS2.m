%% MAIN

clear;
caps2_exp = {'overall_avoidance'};
caps2_screen = 'full';
caps2_controller = 'joy';
caps2_scriptdir = 'C:\Users\PC\Documents\Documents\My Experiments\CAPS2_170703';
[caps2_ts, caps2_post_q] = generate_ts;
data = CAPS2_main(caps2_ts, 'scriptdir', caps2_scriptdir, 'explain_scale', caps2_exp, ...
    'screenmode', caps2_screen, 'fmri', 'postrun_questions', caps2_post_q, 'controller', caps2_controller, 'controlspeed', 0.8);


%% for TEST

clear;
caps2_exp = {'overall_avoidance'};
caps2_screen = 'semifull';
caps2_controller = 'mouse';
caps2_scriptdir = '/Users/jaejoonglee/Documents/github/CAPS2';
caps2_speed = 0.8;
[caps2_ts, caps2_post_q] = generate_ts;
data = CAPS2_main(caps2_ts, 'scriptdir', caps2_scriptdir, 'explain_scale', caps2_exp, ...
    'test', 'screenmode', caps2_screen, 'setinput', 'fmri', 'postrun_questions', caps2_post_q, 'controller', caps2_controller, 'controlspeed', 0.8);
