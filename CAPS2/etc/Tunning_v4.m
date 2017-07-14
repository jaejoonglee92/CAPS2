% % 2017-04-19 ActionPotentials TeamProject Main
% % Insub Kim

clear all;
ppd = 56;
addpath(genpath('./OrientTuning_fx'));



% % ==========================================
% % File I/O
% % ==========================================
data_dir = fullfile(pwd, 'ToM_Tunning');
if ~exist(data_dir,'dir'); mkdir(data_dir); end;
subName = input('Initials of subject? (default="01SSS")  ','s');		% get subject's initials from user
if length(subName) < 1; subName = '01SSS'; end;
CurRun = str2double(input('Run Number? ','s'));

listen = str2double(input('Listen for scanner 1=yes, 2=no? ','s'));
if isnan(listen); listen = 1; end;

baseName=[subName '_ToM_Tunning_' num2str(CurRun)];
fileName = ['datRaw_' baseName '.txt'];	dataFile = fopen(fullfile(data_dir, fileName), 'wt');
fileName = ['datStm_' baseName '.txt'];	stimFile = fopen(fullfile(data_dir, fileName), 'wt');
matlabFile=[subName '_emotion_Face_' num2str(CurRun)];
% %
% % if CurRun == 1
% %     oriOrderFile = [subName '_oriOrder_' num2str(CurRun)];
% %     orientation_base = [0 30 60 90 120 150]; % 4 orientations
% %     orientation_base = Shuffle(orientation_base);
% %     save(oriOrderFile,'orientation_base');
% %     orientation_base=orientation_base(CurRun);
% % else
% %     loadOriOrderFile = [pwd filesep subName '_oriOrder_1.mat'];
% %     load(loadOriOrderFile);
% %     orientation_base=orientation_base(CurRun);
% % end

if mod(CurRun,2) ~= 0
   targetL = 1; %odd Run left 
else
   targetL = 2; % even Run right
end


% % ==========================================
% % setting up screen
% % ==========================================
Screen('Preference', 'SkipSyncTests', 0);
wininfo = Screen('Resolution', 0);   % width,heigth,pixelSize,hz
screens=Screen('Screens');
screenNumber=max(screens);
bgcolor = [127.5,127.5,127.5 0];
white=255;
black=0;
gray=(white+black)/2;
gray2 = [135 135 135 0.5];

[w, rect]=Screen('OpenWindow', screenNumber,bgcolor, [0 0 1024 768]); %, [100 100 900 700]
%[w, rect]=Screen('OpenWindow', screenNumber,bgcolor); %, [100 100 900 700]



[screenXpixels, screenYpixels] = Screen('WindowSize', w);

Screen('BlendFunction', w, 'GL_ONE', 'GL_ZERO');
%Screen('BlendFunction', w, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

Screen('HideCursorHelper', w);
winfo = Screen('Resolution', 0);
[cx, cy] = RectCenter(rect); %960/540 in PC-2
center = [cx,cy];
blanking = Screen('GetFlipInterval', w);
ifi = Screen('GetFlipInterval', w);


%room 152
% % load C:\Experiments\Info_files\gammaTable_152.mat;
% % myClut = gammaTable;
% % Screen('LoadNormalizedGammaTable', w, myClut);

% % ==========================================
% % keyboard & input device set up
% % ==========================================
% [keyboardIndex, deviceName, allInfo] = GetKeyboardIndices

% ===== Experimenter
device(1).product = 'Apple Wireless Keyboard';	%
device(1).vendorID= 1452;
% % ===== Participant
device(2).product = '932';	% Or, device(2).product = 'Current Designs, Inc.';
device(2).vendorID= [1240 6171];	% list of vendor IDs for valid FORP devices
% ===== Scanner
device(3).product = 'KeyWarrior8 Flex';
device(3).vendorID= 1984;

if listen == 1 % for scan
    Experimenter = IDKeyboards(device(1));
    Participant = IDKeyboards(device(2));
    Scanner = IDKeyboards(device(3));
    %Experimenter =[]; Scanner = [];   Participant =[];
else
    Experimenter =[]; Scanner = [];   Participant =[];
    %     Experimenter = IDKeyboards(device(1));
    %     Participant = Experimenter;
    %     Scanner = Experimenter;
end

% % key set-up
syncNum = KbName('s'); % NNL Sync
% CorrectRespNum = KbName('1');
%codQ=KbName('q');
%Respkey1 = KbName('1!'); % -85
%Respkey2 = KbName('9('); % -85
%Respkey3 = KbName('5%'); % -85


% %KbQue
keysOfInterest=zeros(1,256);
keysOfInterest(KbName({'1!', '2@', '3#', '5%','6^','7&'}))=1;
KbQueueCreate(-1, keysOfInterest);


% % ExpMatrix================================================
% % emat
% % 1st col: trial number
% % 2nd col: ambigouse: 0 Face 1 Car
% % 3th col: Orientation
% % 4th col: targetL [0 1] 0 = left 1 = right


% % Spatial Frequency (Cycles Per Pixel)
% % sfCyclesDeg = 2.1;
% % frq_gabor1 = sfCyclesDeg /ppd;


%%%emat_condition 1
orientation_base = [90 60 30 0 150 120]; % 6 orientations
Iteration = 2;

[orientation] =BalanceFactors(Iteration,1,orientation_base);
%trial= [1:length(ambiguous)]';


% % combined emat
trial= [1:length(orientation)]';
emat = [trial orientation];


% % ==========================================
% % Gabor
% % ==========================================

gaborDimPix = ppd*7; %3 degree
sigma = gaborDimPix / 6;


orientation = 90;
contrast = 1; %contrst 20
aspectRatio = 1.0;
nGabors = 72;

gabortex = CreateProceduralGabor(w, gaborDimPix, gaborDimPix,...
    [], [0.5 0.5 0.5 0.0], 1, 0.5);
%[gabortex,gratingrect] = CreateProceduralSineGrating(w, gaborDimPix, gaborDimPix, [0.5,0.5,0.5,0], gaborDimPix/2, 0.5);

% % Gabor rect
xPos = cx;
yPos = cy + (4.8*ppd);
xPos2 = [cx-(ppd*8.5) cx+(ppd*8.5)]; % 4 deg
gRect = [0 0 gaborDimPix gaborDimPix];
gabor_rect = nan(4,length(xPos2));
for i = 1:length(xPos2)
    gabor_rect(:, i) = CenterRectOnPointd(gRect, xPos2(i), yPos);
end

% % propMat: phase freq sigma contrast aspectRatio
%spatial freqeuncy
numCycles = 5;
%freq = numCycles / gaborDimPix;
freq = 1 / ppd; % 1 cycle per degree
%
propertiesMat = repmat([NaN, NaN, sigma, contrast, aspectRatio, 0, 0, 0],...
    nGabors, 1);

propertiesMat(:, 2) = freq; %spatial freqeuncy



% low contrast(blink)
blinkperiod = randperm(nGabors/6 -3, 3)'; % 6 blinkperiod per 1 blink, and 3 blink per 1 trial, not first period blink
blinkperiod = [blinkperiod*6 + 3];
blinkperiod = blinkperiod(:);

attratio = 0.2;
propertiesMat(blinkperiod, 4) = attratio;

% randomize phase
phaseperiod = rand(nGabors/12, 1) .* 360; % 6 randomized phase per 72 trials
phaseperiod = [repmat(phaseperiod(1), 12, 1); repmat(phaseperiod(2), 12, 1); repmat(phaseperiod(3), 12, 1); ...
    repmat(phaseperiod(4), 12, 1); repmat(phaseperiod(5), 12, 1); repmat(phaseperiod(6), 12, 1)];
propertiesMat(:, 1) = phaseperiod;




% % ==========================================
% % Start-up
% % ==========================================

Screen('TextFont',	w, 'Arial'); Screen('TextSize',	w, 20);
Screen('TextColor', w, 255); Screen('TextStyle', w, 0);
Screen('DrawText', w', 'Press 1: Left Press 2: Right', cx/2, cy/2, [0 0 0]);

Screen('Flip',w);

% % wait for the 's' key press to initiate the experimental code
scanPulse = 0;
while scanPulse ~= 1
    [keyIsDown, ~, keyCode] = KbCheck(Scanner);
    %[keyIsDown,secs,keyCode]=PsychHID('KbCheck');
    %[keyIsDown, ~, keyCode] = KbCheck();
    if keyIsDown
        if  keyCode(syncNum)==1
            scanPulse = 1;
            break;
        end
    end
end

% if listen ~= 1
%     Screen('FillOval',w,[100 100 100], [cx - 4, cy - 4, cx + 4, cy + 4]);
%     Screen('Flip', w);
%     WaitSecs (1);
% end

KbQueueStart;
KbQueueFlush();%%
% ==========================================
% Trial starts
% ==========================================

totalPeriod=72;

flicker_stim =  0.0833;
blankDur  = 2;
fixChangeTime = 0.5;
fixBlank = 1;
syncTime  = 0.5;
buffer     = 4;
RespT    = []; %
CorrT    = []; %
response = [];
accuracy = [];
P_accuracy = [];
A_accuracy = [];
RTT      = [];
responseSum = [];
RTSum = [];


vbl = Screen('Flip', w); % initial flip


fprintf(stimFile, 'StartCycle = %s\t*********************\n', datestr(now));
fprintf(stimFile, '%s\t %s\t %s\t %s\t %s\t %s\t  \n', ...
    'nRun', 'trial', 'angle', 'responseNum', 'Accuracy','targetL');


StartCycle = GetSecs;

for i=1:length(emat)
    number_of_periods=1;
    %present checker for 12s
    Time=GetSecs;
    while number_of_periods < totalPeriod+1

        for a = 1:round(flicker_stim/ifi) % Gabor
            Screen('DrawTexture', w, gabortex, [], gabor_rect(:,targetL), emat(i,2),...
                [], [], [] , [], kPsychDontDoRotation, propertiesMat(number_of_periods,:));
            Screen('FillOval',w,255, [cx - 4, cy - 4, cx + 4, cy + 4]);
            Screen('Flip',w);
        end
        
        for b = 1:round(flicker_stim/ifi) % Blink
            Screen('FillRect',w,gray);
            Screen('FillOval',w,255, [cx - 4, cy - 4, cx + 4, cy + 4]);
            Screen('Flip',w);
            
            [pressed, firstPress]=KbQueueCheck;
            if pressed
                if firstPress(KbName('1!'))
                    response = [response  1];
                end
            end
        end
        
        
        
        
        number_of_periods = number_of_periods+1;
        
    end
    StimTime=GetSecs-Time
    
    %blank for 2 s
    Onset2 = GetSecs;
    for c=1:(blankDur - syncTime)/ifi
        Screen('FillOval',w,255, [cx - 4, cy - 4, cx + 4, cy + 4]);
        Screen('Flip',w);
        
    end
    
    tflip = [];
    % sync
    if i < length(emat)
        if listen == 1
            scanPulse = 0;
            while scanPulse ~= 1
                [keyIsDown, ~, keyCode] = KbCheck(Scanner);
                if keyIsDown
                    if keyCode(syncNum)
                        scanPulse = 1;
                        tflip = GetSecs;
                        break;
                    end
                end
            end
        elseif listen ~= 1
            while GetSecs - Onset2 < blankDur  % sync
            end
        end
    elseif i == length(emat)  % final trial
        Screen('FillRect',w,gray);
        Screen('FillOval',w,255, [cx - 4, cy - 4, cx + 4, cy + 4]);
        Screen('Flip',w);
        while GetSecs - Onset2 < blankDur  % sync
        end
    end
    BlankTime = GetSecs-Onset2
    
    response
    if length(response) == 3
        Accuracy=1;
    else
        Accuracy=0;
    end
    
    responseSum{i} = response;
    
    
    % run, trial, ambiguous, P_target, A_target, P_accuracy, A_accuracy, RT
    
    fprintf(stimFile, '%5i\t %5i\t %5i\t %5i\t %5i\t %5i\t \n', ...
        CurRun, emat(i,1), emat(i,2), length(response), Accuracy, targetL);
    fprintf(dataFile, '%5i\t %5i\t %5i\t %5i\t %5i\t %5i\t \n', ...
        CurRun, emat(i,1), emat(i,2), length(response), Accuracy, targetL);
    
    
    response   = [];
    A_target   = [];
    A_accuracy = [];
    
    KbQueueFlush();
    
    
    
    
end


CycleDur = GetSecs - StartCycle;

%acp = (sum(accuracy(:))/length(accuracy))*100
% % emat2 = [num2cell(emat) emotionPics];
% % save(matlabFile,'emat','emat2');



fprintf(stimFile, 'Cycle Dur = %2.4f \t *********************\n', CycleDur);
fprintf(stimFile, 'EndCycle = %s\t*********************\n', datestr(now));
fclose('all');
sca;