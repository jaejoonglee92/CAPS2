% % 2017-04-19 ActionPotentials TeamProject Main
% % Insub Kim

clear all;
ppd = 56;
addpath(genpath('./OrientTuning_fx'));



% % ==========================================
% % File I/O
% % ==========================================
data_dir = fullfile(pwd, 'ToM');
if ~exist(data_dir,'dir'); mkdir(data_dir); end;
subName = input('Initials of subject? (default="01SSS")  ','s');		% get subject's initials from user
if length(subName) < 1; subName = '01SSS'; end;
Condition = input('subject Number?(odd: car first even: person first):   ');
CurRun = input('Run Number? ');

listen = str2double(input('Listen for scanner 1=yes, 2=no? ','s'));
if isnan(listen); listen = 1; end;

baseName=[subName '_TomMain_' num2str(CurRun)];
fileName = ['datRaw_' baseName '.txt'];	dataFile = fopen(fullfile(data_dir, fileName), 'at');
fileName = ['datStm_' baseName '.txt'];	stimFile = fopen(fullfile(data_dir, fileName), 'at');
matlabFile=[subName '_TomMain_' num2str(CurRun)];
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

% % wininfo.pixelSize



poly = [ cx-ppd*6, cy-ppd*1.5; cx+ppd*6, cy-ppd*1.5; cx+ppd*30, cy+ppd*10; cx-ppd*30, cy+ppd*10];

%poly = [ cx+80, cy+100; cx-80, cy+100;cx-100, cy-100; cx+100, cy-100];



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
keysOfInterest(KbName({'1!', '2@', '3#', '4$','5%','6^','7&','8*','9('}))=1;
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
orientation_base = [90 60 30 0 120 150]; % 6 orientations
ambiguous_base =[0]; % 0 Face 1 Car
targetL_base = [0 1]; %0 = left 1 = right
Iteration = 2;

[orientation,ambiguous,targetLocation] =BalanceFactors(Iteration,1,orientation_base,ambiguous_base,targetL_base);
%trial= [1:length(ambiguous)]';

emat1 = [ambiguous orientation targetLocation];
temp = length(emat1)/2;
emat1_1 = emat1(1:temp,:);
emat1_2 = emat1(temp+1:end,:);

%%%emat_condition 2
orientation_base = [90 60 30 0 120 150]; % 6 orientations
ambiguous_base =[1]; % 0 Face 1 Car
targetL_base = [0 1]; %0 = left 1 = right
Iteration = 2;

[orientation2,ambiguous2,targetLocation2] =BalanceFactors(Iteration,1,orientation_base,ambiguous_base,targetL_base);

emat2 = [ambiguous2 orientation2  targetLocation2];
temp = length(emat1)/2;
emat2_1 = emat2(1:temp,:);
emat2_2 = emat2(temp+1:end,:);

% % combined emat
trial= [1:length(orientation2)*2]';

% odd number subj : car first, even number subj : face first
if mod(Condition,2) ~= 0 % odd number
    if mod(CurRun,2) ~= 0
        emat = [emat2_1;emat1_1;emat2_2;emat1_2]; % car face car face
    else
        emat = [emat1_1;emat2_1;emat1_2;emat2_2];
    end
end
if mod(Condition,2) == 0 % even number
    if mod(CurRun,2) ~= 0
        emat = [emat1_1;emat2_1;emat1_2;emat2_2]; % face car face car
    else
        emat = [emat2_1;emat1_1;emat2_2;emat1_2];
    end
end

emat = [trial emat];

ambiguous = emat(:,2);

for i = 1:length(ambiguous)
    if ambiguous(i) == 0
        fixColor{i} = [0 0 255];
    elseif ambiguous(i) == 1
        fixColor{i}  = [0 255 0];
    end
end

save(matlabFile,'emat');

% % ==========================================
% % picture stims
% % ==========================================

% % Car and Face
theImageLocation = [pwd filesep 'image2.png'];
theImage = imread(theImageLocation);
imageTexture = Screen('MakeTexture', w, theImage);


faceSize = size(theImage);
yPos_img = cy - (3.6*ppd);
xPos_img = cx;
baseRect = [0 0 faceSize(2) faceSize(1)];% 5.3 * 6.4 degrees

dstRects = nan(4,1);
dstRects(:, 1) = CenterRectOnPointd(baseRect, xPos_img, yPos_img);

% % back ground
% % theImageLocation2 = [pwd filesep 'back_img.png'];
% % [theImage2 map alpha]= imread(theImageLocation2);
% % alpha=0.5
% % theImage2(:,:,4) = alpha;
% % imageTexture2 = Screen('MakeTexture', w, theImage2);
% %
% %
% % faceSize = size(theImage);
% % yPos_img = cy ;
% % xPos_img = cx;
% % baseRect = [0 0 faceSize(2) faceSize(1)];% 5.3 * 6.4 degrees
% %
% % back_rect = nan(4,1);
% % back_rect(:, 1) = CenterRectOnPointd(baseRect, xPos_img, yPos_img);

% % ==========================================
% % Gabor
% % ==========================================

gaborDimPix = ppd*7; %3 degree
sigma = gaborDimPix / 6;
orientation = 90;
contrast = 0.9; %contrst 20
aspectRatio = 1.0;
nGabors = length(emat);

gabortex = CreateProceduralGabor(w, gaborDimPix, gaborDimPix,...
    [], [0.5 0.5 0.5 0.0], 1, 0.5);

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
phaseLine = rand(1, nGabors) .* 360; % Randomise the phase of the Gabors
%spatial freqeuncy
numCycles = 5;
%freq = numCycles / gaborDimPix;
freq = 1 / ppd; % 1 cycle per degree



propertiesMat = repmat([NaN, NaN, sigma, contrast, aspectRatio, 0, 0, 0],...
    nGabors, 1);
propertiesMat(:, 1) = phaseLine';
propertiesMat(:, 2) = freq; %spatial freqeuncy



% % Example Gabor
gaborDimPix2 = 3 * ppd;
gabortex2 = CreateProceduralGabor(w, gaborDimPix2, gaborDimPix2,...
    [], [0.5 0.5 0.5 0.0], 1, 0.5);


xPos_exmaple = [cx-ppd*8-((cx-ppd*4)-(cx-ppd*8)) cx-ppd*8 cx-ppd*4 cx+ppd*4 cx+ppd*8 cx+ppd*8+((cx-ppd*4)-(cx-ppd*8))];
exmapleRects = nan(4,length(xPos2));
gRect2 = [0 0 gaborDimPix2 gaborDimPix2];
yPos2= cy;
for i = 1:length(xPos_exmaple)
    exmapleRects(:, i) = CenterRectOnPointd(gRect2, xPos_exmaple(i), yPos2);
end

numCycles = 5;
freq2 = numCycles / gaborDimPix2;
nGabors2=6;
phaseLine = rand(1, nGabors2) .* 360;
sigma2 = gaborDimPix2 / 6;
propertiesMat2 = repmat([NaN, NaN, sigma2, contrast, aspectRatio, 0, 0, 0],...
    nGabors2, 1);
propertiesMat2(:, 1) = phaseLine';
propertiesMat2(:, 2) = freq2; %spatial freqeuncy





% % ==========================================
% % Start-up
% % ==========================================

Screen('TextFont',	w, 'Arial'); Screen('TextSize',	w, 20);
Screen('TextColor', w, 255); Screen('TextStyle', w, 0);
Screen('DrawText', w', 'Press 1: Left Press 2: Right', cx/2, cy/2, [0 0 0]);
Screen('DrawTextures', w, gabortex2, [], exmapleRects, orientation_base',...
    [], [], [], [], kPsychDontDoRotation, propertiesMat2');

%

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

GaborTime = 1;
blankDur  = 4;
fixChangeTime = 0.5;
fixBlank = 0.5;
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
fprintf(stimFile, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n', ...
    'nRun', 'trial', 'condition', 'response1', 'response2', 'P_target','A_target','P_acc','A_acc','RT1','RT2');

StartCycle = GetSecs;
for a = 1:round(buffer/ifi)
    Screen('FramePoly', w,gray2, poly,ppd);
    Screen('FillOval',w,[0 0 0], [cx - 4, cy - 4, cx + 4, cy + 4]);
    Screen('DrawTextures', w, imageTexture,[],dstRects);
    vbl = Screen('Flip', w, vbl + 0.5 * ifi);
end


%length(emat)
for k = 1:length(emat)
    FixDurDur = GetSecs;
    color = fixColor{k};
    for a = 1:round(fixChangeTime/ifi) % fixation
        %Screen('FillRect', w, gray);
        %Screen('DrawTextures', w, imageTexture2,[],back_rect);
        Screen('FramePoly', w,gray2, poly,ppd);
        Screen('FillOval',w,color, [cx - 4, cy - 4, cx + 4, cy + 4]);
        Screen('DrawTextures', w, imageTexture,[],dstRects);
        vbl = Screen('Flip', w, vbl + 0.5 * ifi);
    end
    for b = 1:round(fixBlank/ifi) % fixation
        Screen('FramePoly', w,gray2, poly,ppd);
        Screen('FillOval',w,[0 0 0], [cx - 4, cy - 4, cx + 4, cy + 4]);
        Screen('DrawTextures', w, imageTexture,[],dstRects);
        vbl = Screen('Flip', w, vbl + 0.5 * ifi);
    end
%    FixTIME=GetSecs-FixDurDur
    
    Onset = GetSecs;
    % %left gabor
    if emat(k,4) == 0
        for c = 1:round(GaborTime/ifi) % fixation
            Screen('FramePoly', w,gray2, poly,ppd);
            Screen('DrawTextures', w, imageTexture,[],dstRects);
            Screen('FillOval',w,[0 0 0], [cx - 4, cy - 4, cx + 4, cy + 4]);
            
            Screen('DrawTextures', w, gabortex, [], gabor_rect(:,1), emat(k, 3),...
                [], [], [], [], kPsychDontDoRotation, propertiesMat(k,:)');
            vbl = Screen('Flip', w, vbl + 0.5 * ifi);
        end  
    end
    % %right gabor
    if emat(k,4) == 1
        for c = 1:round(GaborTime/ifi) % fixation
            Screen('FramePoly', w,gray2, poly,ppd);
            Screen('DrawTextures', w, imageTexture,[],dstRects);
            Screen('FillOval',w,[0 0 0], [cx - 4, cy - 4, cx + 4, cy + 4]);
            
            Screen('DrawTextures', w, gabortex, [], gabor_rect(:,1), emat(k, 3),...
                [], [], [], [], kPsychDontDoRotation, propertiesMat(k,:)');
            vbl = Screen('Flip', w, vbl + 0.5 * ifi);
        end 
    end
%    GaborDURR = GetSecs-Onset

    
    Onset2 = GetSecs;
    for c = 1: (blankDur - syncTime)/ifi
        Screen('FramePoly', w,gray2, poly,ppd);
        
        Screen('FillOval',w,[0 0 0], [cx - 4, cy - 4, cx + 4, cy + 4]);
        Screen('DrawTextures', w, imageTexture,[],dstRects);
        vbl = Screen('Flip', w, vbl + 0.5 * ifi);
        
        
        [pressed, firstPress]=KbQueueCheck;
        if pressed
            if firstPress(KbName('1!'))
                response = [response  1];
                RTT = [RTT GetSecs-Onset];
            elseif firstPress(KbName('2@'))
                response = [response  2];
                RTT = [RTT GetSecs-Onset];
            elseif firstPress(KbName('3#'))
                response = [response  3];
                RTT = [RTT GetSecs-Onset];
            elseif firstPress(KbName('4$'))
                response = [response  4];
                RTT = [RTT GetSecs-Onset];
            elseif firstPress(KbName('6^'))
                response = [response  6];
                RTT = [RTT GetSecs-Onset];
            elseif firstPress(KbName('7&'))
                response = [response  7];
                RTT = [RTT GetSecs-Onset];
            elseif firstPress(KbName('8*'))
                response = [response  8];
                RTT = [RTT GetSecs-Onset];
            elseif firstPress(KbName('9('))
                response = [response  9];
                RTT = [RTT GetSecs-Onset];
            end
        end
    end

    
    blankblankDur1 = GetSecs - Onset2;
    onlyblank = GetSecs - Onset2;
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
        Screen('FramePoly', w,gray2, poly,ppd);
        Screen('FillOval',w,[0 0 0], [cx - 4, cy - 4, cx + 4, cy + 4]);
        Screen('DrawTextures', w, imageTexture,[],dstRects);
        vbl = Screen('Flip', w, vbl + 0.5 * ifi);
        while GetSecs - Onset2 < blankDur  % sync
        end
    end
    
    
    % % calculate target responses (reverse of correct responses)
    switch emat(k,4)
        case 0
            P_target = 4;
        case 1
            P_target = 9;
    end
    switch emat(k,3)
        case 90
            A_target = 1;
        case 60
            A_target = 2;
        case 30
            A_target = 3;
        case 0
            A_target = 6;
        case 120
            A_target = 7;
        case 150
            A_target = 8;
    end
    
    % % position Accuracy
    if length(response) == 0 % no response
        P_accuracy= 0;
        A_accuracy= 0;
        response(1)= 0;
        response(2)= 0;
    else % 1 or 2 response
        switch P_target
            case 4 % right target  --> need to press left
                if response(1)==9 %pressed left
                    P_accuracy= 1;
                else
                    P_accuracy= 0;
                end
            case 9 % left target  --> need to press right
                if response(1)==4 %pressed left
                    P_accuracy= 1;
                else
                    P_accuracy= 0;
                end
        end
        
        % % Angle Accuracy
        %    90(1)    60(2)    30(3)     0(6)   120(7)   150(8)
        if length(response) == 2
            switch A_target
                case 1 % 90 target  --> need to press 90
                    if response(2)==1 %pressed 90
                        A_accuracy= 1;
                    else
                        A_accuracy= 0;
                    end
                case 2 % 60 target  --> need to press 120
                    if response(2)==7 %pressed 120
                        A_accuracy= 1;
                    else
                        A_accuracy= 0;
                    end
                case 3 % 30 target  --> need to press 150
                    if response(2)==8 %pressed 150
                        A_accuracy= 1;
                    else
                        A_accuracy= 0;
                    end
                case 6 % 0 target  --> need to press 0
                    if response(2)==6 %pressed 0
                        A_accuracy= 1;
                    else
                        A_accuracy= 0;
                    end
                case 8 % 150 target  --> need to press 30
                    if response(2)==3 %pressed 30
                        A_accuracy= 1;
                    else
                        A_accuracy= 0;
                    end
                case 7 % 120 target  --> need to press 60
                    if response(2)==2 %pressed 60
                        A_accuracy= 1;
                    else
                        A_accuracy= 0;
                    end
            end
        elseif length(response) == 1
            A_accuracy = 0;
            response(2)= 0;
        end
        
    end
  
    
    response
    %A_accuracy
    %P_accuracy

    % % Response Recording
    if length(RTT) > 1
        RTT = RTT(1:2);
    elseif length(RTT) == 1
        RTT(2) = 0;
    else
        RTT(1) = 0;
        RTT(2) = 0;
    end
    
    responseSum{k} = response;
    P_targetSum{k} = P_target;
    A_targetSum{k} = A_target;
    P_accuracySum{k} = P_accuracy;
    A_accuracySum{k} = A_accuracy;
    RTSum{k} = RTT;
    
    
    % run, trial, ambiguous, P_target, A_target, P_accuracy, A_accuracy, RT
    fprintf(stimFile, '%5i\t %5i\t %5i\t %5i\t %5i\t %5i\t %5i\t %5i\t %5i\t %1.4f\t %1.4f\t \n', ...
        CurRun, emat(k,1), emat(k,2), response(1), response(2), P_target, A_target, P_accuracy, A_accuracy, RTT(1),RTT(2));
    
    fprintf(dataFile, '%5i\t %5i\t %5i\t %5i\t %5i\t %5i\t %5i\t %5i\t %5i\t %1.4f\t %1.4f\t \n', ...
        CurRun, emat(k,1), emat(k,2), response(1), response(2), P_target, A_target, P_accuracy, A_accuracy, RTT(1),RTT(2));
    
    
    response   = [];
    P_target   = [];
    A_target   = [];
    P_accuracy = [];
    A_accuracy = [];
    RTT        = [];
    
    KbQueueFlush();
    
    %blankblankDur2 = GetSecs - Onset2

    %TrialDur = GetSecs-FixDurDur
end
CycleDur = GetSecs - StartCycle;
% % 
% % P_acp = (sum(P_accuracySum(:))/length(P_accuracySum))*100
% % A_acp = (sum(A_accuracySum(:))/length(A_accuracySum))*100

% % emat2 = [num2cell(emat) emotionPics];
% % save(matlabFile,'emat','emat2');



fprintf(stimFile, 'Cycle Dur = %2.4f \t *********************\n', CycleDur);
fprintf(stimFile, 'EndCycle = %s\t*********************\n', datestr(now));
fclose('all');
sca;
