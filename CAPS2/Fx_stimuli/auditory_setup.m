function players = auditory_setup

% auditory_setup

% fnames = filenames('knife_on_bottle_LV*');
fnames = {'knife_on_bottle_LV1_-3dball_-8db2000Hz.wav',...
    'knife_on_bottle_LV2_-3dball_-4db2000Hz.wav',...
    'knife_on_bottle_LV3_-3dball_-1db2000Hz.wav',...
    'knife_on_bottle_LV4.wav'};

for i = 1:4
    try
        y = audioread(fnames{i});
    catch
        %y = wavread(fnames{i});
    end
    players{i} = audioplayer(y, 44100);
end

end

