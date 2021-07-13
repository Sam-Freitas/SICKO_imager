try
    try
        stop(vid)
        flushdata(vid);
        delete(vid);
        clear all
        close all force hidden
    catch
        flushdata(vid);
        delete(vid);
        clear all
        close all force hidden
    end
catch
    clear all
    close all force hidden
end
warning('off', 'MATLAB:MKDIR:DirectoryExists');

curr_path = pwd;

mkdir(fullfile(curr_path, 'Data'));
data_path = fullfile(curr_path, 'Data');

%select current experiment or make a new one
dlg_choice = questdlg({'Select Current Experiment or Start New?',...
                ''},'Experiment Selection','Select','Start New','Select');

if isequal(dlg_choice,'Select')
    data_dir = dir(data_path);
    dirFlags = [data_dir.isdir];
    data_dir = data_dir(dirFlags);
    data_dir(ismember( {data_dir.name}, {'.', '..'})) = [];
    
    exp_list = {data_dir.name};
    [indx,tf] = listdlg('PromptString','Select an experiment.',...
    'SelectionMode','single','ListString',exp_list);

    if tf == 1
        exp_path = fullfile(data_path, exp_list{indx});
    elseif tf == 0
        error('Experiment not selected.  try again');
    end
    
elseif isequal(dlg_choice,'Start New') %Input Experiment name
     prompt = 'What is the name of the experiment?';
     answer = inputdlg(prompt,'Experiment Name',[1 35]);
     mkdir(fullfile(data_path, char(answer)));
     exp_path = fullfile(data_path, char(answer));
     
else %If no selection
    dlg_choice = [];
    error('Experiment not selected.  try again')
end

%find how many sessions exist, add on or create new
exp_dir = dir(exp_path);
dirFlags = [exp_dir.isdir];
exp_dir = exp_dir(dirFlags);
exp_dir(ismember( {exp_dir.name}, {'.', '..'})) = [];

session_num = length(exp_dir) + 1;        %adding a new session

mkdir(fullfile(exp_path, ['Session' num2str(session_num)]));
session_path = fullfile(exp_path, ['Session' num2str(session_num)]);

warning('off', 'MATLAB:MKDIR:DirectoryExists');


number_images_per_session = 25; % usually 25 12bef 12aft
time_between_images = 0; % usually 5
% excitation_light_exposure = 9; % usually 9
% number_of_sessions = 7; % how long ti will run 
% time_between_sessions = 3600*8; % in seconds 3600->repeat every hour
warm_up_amout = 10; %60*5;
red_DAC = 0;
% blue_DAC = 1;

vid = videoinput('tisimaq_r2013_64', 1, 'Y800 (5472x3648)');
src = getselectedsource(vid);

vid.FramesPerTrigger = 1;

% it takes into account amount of time that has passed during each session
% as well, so if you want recording every hour just put in 3600 seconds 

% make sure everything is off
LabJack_cycle(red_DAC,0)
pause(0.1);

images_per_iter = (number_images_per_session-1)/2;

% turn background light on for 2 minutes to help stabalize image quality

disp(['Beginning experiment ' exp_list{indx}]);
disp(['Running session ' num2str(session_num)]);

% warm up red leds
disp('Warming up LEDs');
LabJack_cycle(red_DAC,5)
pause(warm_up_amout);

images = take_N_images_every_X_seconds(src,vid,images_per_iter,time_between_images);
% write images to disk
disp('Recording data')

write_images_to_session_new(session_path, images)

LabJack_cycle(red_DAC,0);


disp('Done');
