function [fname, SID, start_line, data] = subjectinfo_check(savedir)
%[fname, SID, start_line, data] = subjectinfo_check(savedir)
%This function can check subject information, and get startpoint.
%fname : file name. it`ll be used in saving.
%SID : subject ID. this is obtained by input function.
%start_line : startpoint. the value means total elapsed trial + 1.
%             ex. if a run consists of 10 trials and 2 run 4 trial
%             elapsed, start_line will be (2*10+4) + 1 = 25.
%data : data. if the data file exist in same file name, it`ll be loaded or
%       not depending on the decision of experimenter(1:Save new file or 2:Save
%       the data from where we left off)

%% Basic parameter setting
start_line = 1;
data = [];

%% Get subject ID 
fprintf('\n');
SID = input('Subject ID? ','s');
fname = fullfile(savedir, ['s' SID '.mat']);
    
%% Check if the data file exists
if ~exist(savedir, 'dir')
    mkdir(savedir);
else
    if exist(fname, 'file')
        checkdat = input(['The Subject ' SID ' data file exists. Press a button for the following options.\n', ...
            '1:Save new file, 2:Save the data from where we left off, Ctrl+C:Abort? ']);
        
        if checkdat == 2 % if file exists, get the start line
            load(fname);
            datafields = fields(data);
            for data_i = 1:numel(datafields)
                if strcmp(datafields{data_i}, 'dat') % find whether the dat substructure is exist.
                    for i = 1:numel(data.dat)
                        start_line = start_line + numel(data.dat{i});
                    end
                end
            end
        end
        
    end
    
end


end