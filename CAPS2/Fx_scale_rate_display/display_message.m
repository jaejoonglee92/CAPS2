function display_message(msgtype, run_i)
%display_message(msgtype, run_i)
%This function can display message by various purpose.
%msgtype : 'start', 'run_fmri', 'run_behavior', 'scanstart', 
%          'postrunstart', 'postrunwait', 'postrunwaitend',
%          'endrun', 'endall'.
%run_i : run number.


global window_rect W H theWindow; % window property
global white red orange bgcolor; % color
global font fontsize
global Exp_key Par_key Scan_key
global t r; % pressure device udp channel
global rating_types % dictionary for all rating types and matched prompts

Screen(theWindow,'FillRect',bgcolor, window_rect);

switch msgtype
    
    case 'start'
        msgtxt = '실험자는 모든 세팅이 완료되었는지 확인하시기 바랍니다.(BIOPAC, PPD, 등등...)\n준비가 완료되면 실험자는 SPACE 키를 눌러주시기 바랍니다.';
        
    case 'run_fmri'
        msgtxt = '참가자가 모든 준비가 완료되면 스캔을 시작합니다.';
        
    case 'run_behavior'
        msgtxt = '참가자는 모든 준비가 완료되면 R 키를 눌러주시기 바랍니다.';
        
    case 'scanstart'
        msgtxt = '시작하는 중...';
        
    case 'postrunstart'
        msgtxt = [num2str(run_i) '번째 run이 끝났습니다.\n잠시 후 질문들이 제시될 것입니다. 참가자분께서는 기다려주시기 바랍니다.'];
        
    case 'postrunwait'
        msgtxt = '편하게 손을 놓고 다음 질문을 기다리시기 바랍니다.';
        
    case 'postrunwaitend'
        msgtxt = '질문이 끝났습니다.';
        
    case 'endrun'
        msgtxt = [num2str(run_i) '번째 run이 끝났습니다.\n참가자가 다음 run으로 진행할 준비가 완료되면 실험자는 SPACE 키를 눌러주시기 바랍니다.'];
        
    case 'endall'
        msgtxt = 'session이 모두 끝났습니다.\nsession을 마치려면, 실험자는 SPACE 키를 눌러주시기 바랍니다.';
        
end

msgtxt = double(msgtxt); % Korean to Double

DrawFormattedText(theWindow, msgtxt, 'center', 'center', white, [], [], [], 2);
Screen('Flip', theWindow);

end