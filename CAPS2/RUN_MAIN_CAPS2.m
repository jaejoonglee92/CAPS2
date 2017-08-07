%% MAIN

clear;
caps2_scriptdir = 'C:\Users\Cocoanlab_WL01\Downloads\CAPS2\CAPS2-master\CAPS2_revised';
cd(caps2_scriptdir); addpath(genpath(caps2_scriptdir));

caps2_exp = {'overall_avoidance'};
caps2_screen = 'full';
caps2_controller = 'mouse';
caps2_scriptdir = 'C:\Users\PC\Documents\Documents\My Experiments\CAPS2_170703';
caps2_speed = 0.8;
[caps2_ts, caps2_post_q] = generate_ts;
data = CAPS2_main(caps2_ts, 'explain_scale', caps2_exp, ...
    'master-9','screenmode', caps2_screen, 'fmri', 'postrun_questions', caps2_post_q, 'controller', caps2_controller, 'controlspeed', caps2_speed); %'biopac',


%% for TEST

clear;
%caps2_scriptdir = 'C:\Users\Cocoanlab_WL01\Downloads\CAPS2\CAPS2-master\CAPS2_revised';
caps2_scriptdir =  '/Users/jaejoonglee/Documents/github/CAPS2'
cd(caps2_scriptdir); addpath(genpath(caps2_scriptdir));

caps2_exp = {'overall_avoidance'};
caps2_screen = 'middle';
caps2_controller = 'mouse';
caps2_speed = 0.8;
[caps2_ts, caps2_post_q] = generate_ts;
data = CAPS2_main(caps2_ts, 'explain_scale', caps2_exp, ...
    'test', 'setinput', 'screenmode', caps2_screen, 'fmri',  'postrun_questions', caps2_post_q, 'controller', caps2_controller, 'controlspeed', caps2_speed);%'biopac', 'master-9', 

