clc
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

% get basica data path
curr_path = pwd;
mkdir(fullfile(curr_path, 'Data'));
data_path = fullfile(curr_path, 'Data');

%select current experiment or make a new one
dlg_choice = questdlg({'Select Current Experiment or Start New?',...
    ''},'Experiment Selection','Select','Start New','Select');

if isequal(dlg_choice,'Select')
    session_path = select_experiment_func(data_path);
    session_wells = select_wells_to_image();
elseif isequal(dlg_choice,'Start New') %Input Experiment name
    start_new_experiment(data_path)
    session_path = select_experiment_func(data_path);
    session_wells = select_wells_to_image();
    % this promps the user to create the basic structure of an experiment
else %If no selection
    dlg_choice = [];
    error('Experiment not selected.  try again')
end

disp('Starting data setup')
%find how many sessions exist, add on or create new
mkdir(session_path)

% number_images_per_session = 3; % usually 25 12bef 12aft
% time_between_images = 0; % usually 5
% warm_up_amout = 10; %60*5;
% red_DAC = 0;
% % blue_DAC = 1;
% 
% % this needs to be added to the dependencies
% vid = videoinput('tisimaq_r2013_64', 1, 'Y800 (5472x3648)');
% src = getselectedsource(vid);
% 
% vid.FramesPerTrigger = 1;
% 
% % it takes into account amount of time that has passed during each session
% % as well, so if you want recording every hour just put in 3600 seconds
% 
% % make sure everything is off
% LabJack_cycle(red_DAC,0)
% pause(0.1);
% 
% images_per_iter = (number_images_per_session-1)/2;

% turn background light on for 2 minutes to help stabalize image quality

disp(['Beginning experiment'])
% % warm up red leds
% disp('Warming up LEDs');
% LabJack_cycle(red_DAC,5)
% pause(warm_up_amout);
% 
% images = take_N_images_every_X_seconds(src,vid,images_per_iter,time_between_images);
% % write images to disk
% disp('Recording data')
% 
% write_images_to_session_new(session_path, images)
% 
% LabJack_cycle(red_DAC,0);


disp('Done');

function output_path = select_experiment_func(data_path)
% get the dir of the data folder to select a specific experiment
data_dir = dir(data_path);
dirFlags = [data_dir.isdir];
data_dir = data_dir(dirFlags);
data_dir(ismember( {data_dir.name}, {'.', '..'})) = [];

% isolate the experiment names and create a selection
experiments_list = {data_dir.name};
[indx,tf] = listdlg('PromptString','Select an experiment.',...
    'SelectionMode','single','ListString',experiments_list);

if tf == 1
    exp_path = fullfile(data_path, experiments_list{indx});
elseif tf == 0
    error('Experiment not selected.  try again');
end

% isolate the repeat names and create a selection
data_dir = dir(exp_path);
dirFlags = [data_dir.isdir];
data_dir = data_dir(dirFlags);
data_dir(ismember( {data_dir.name}, {'.', '..'})) = [];

% isolate the experiment names and create a selection
repeats_list = {data_dir.name};
[indx,tf] = listdlg('PromptString','Select a repeat.',...
    'SelectionMode','single','ListString',repeats_list);

if tf == 1
    repeat_path = fullfile(exp_path, repeats_list{indx});
elseif tf == 0
    error('Repeat not selected.  try again');
end

% isolate the condition names and create a selection
data_dir = dir(repeat_path);
dirFlags = [data_dir.isdir];
data_dir = data_dir(dirFlags);
data_dir(ismember( {data_dir.name}, {'.', '..'})) = [];

conditions_list = {data_dir.name};
[indx,tf] = listdlg('PromptString','Select a condition.',...
    'SelectionMode','single','ListString',conditions_list);

if tf == 1
    this_condition =  conditions_list{indx};
    conditions_path = fullfile(repeat_path, this_condition);
elseif tf == 0
    error('Repeat not selected.  try again');
end

% Ask the user for what day (in reality its session but for now its day) of
% the experiment
prompt = 'Enter the day to be recorded';
answer = inputdlg(prompt,'Experimental day selection',[1 35]);
day_of_exp = str2double(answer{1});

% get the current time
current_time = char(datetime('now','Format','yyyy_MM_dd_HH_mm_ss'));
% create the final output path
% super weird format but thats how it was previously done and it works
output_path = fullfile(conditions_path,[current_time '--' char(this_condition) '_D' num2str(day_of_exp)]);

disp('This sessions collected data will be exported to:')
disp(output_path)
end

function start_new_experiment(data_path)

prompt = 'What is the name of the experiment?';
answer = inputdlg(prompt,'Experiment Name',[1 35]);
if isempty(answer)
    error('Must enter selected field');
end
mkdir(fullfile(data_path, char(answer)));
exp_path = fullfile(data_path, char(answer));

% gets number of repeats
prompt = 'Enter the number of repeats';
answer = inputdlg(prompt,'Experiment repeats',[1 35]);
if isempty(answer)
    error('Must enter selected field');
end
num_repeats = str2double(answer{1});

% gets the conditions
prompt = 'Enter the conditions seperated by a comma (NOTE: dont use unecessary spaces) Corrent example: N2,GLS130,HT115,OP50,h5-102,A.1214';
answer = inputdlg(prompt,'Experiment conditions',[1 35]);
if isempty(answer)
    error('Must enter selected field');
end
conditions = strsplit(answer{1},',');

% creates the conditions and replicates folders
repeat_paths = cell(num_repeats,1);
conditions_paths = cell(num_repeats*length(conditions),1);
count = 1;
for i = 1:num_repeats
    repeat_paths{i} = fullfile(exp_path,['Repeat_' num2str(i)]);
    mkdir(repeat_paths{i});
    for j = 1:length(conditions)
        conditions_paths{count} = fullfile(repeat_paths{i},conditions{j});
        mkdir(conditions_paths{count})
        count = count + 1;
    end
end

disp('Finished creating new experiment')

end


function selected_wells = select_wells_to_image()

disp('selecting wells to image in this session')
decoder = readtable("well_key.csv","VariableNamingRule","preserve");

dlg_choice = questdlg({'Select specific wells for this condition?',...
    ''},'Experiment Selection','Yes','No - image every well','No - image every well');


if isequal(dlg_choice,'Yes')

    base = imread("Basic_wells_template_terasaki.png");
    bw_labels = uint8(base>0)*255;

    just_wells = imfill(base,'holes');

    selection_image = bw_labels;

    redo=char('Yes');
    while strcmpi(redo,'Yes')
        h=figure('units','normalized','outerposition',[0 0 1 1],...
            'NumberTitle','Off',...
            'Name','Selection selection window'); imshow(selection_image);
        title('Select the center of the wells that will be imaged --- double-click anywhere to end')
        [x,y]=getpts();

        x2 = round(x(1:length(x)-1));
        y2 = round(y(1:length(x)-1));

        temp_img = zeros(size(just_wells),'uint8');
        clear selected_wells_inten
        for i = 1:length(x2)
            selected_wells_inten(i) = just_wells(y2(i),x2(i));
            temp_img = temp_img + bw_labels.*uint8(just_wells==selected_wells_inten(i));
        end
        selected_wells_inten = nonzeros(unique(selected_wells_inten));
        imshow(temp_img>0)

        redo = questdlg('Do you want to redo this Selection? (double-click point not saved)','Redo?','Yes','No','No');
        close(h);
    end

    selected_wells = decoder(selected_wells_inten,:);

elseif isequal(dlg_choice,'No - image every well') %Input Experiment name
    selected_wells = decoder;
else %If no selection
    dlg_choice = [];
    error('Nothing selected.  try again')
end

l = strjoin(string(rot90(selected_wells.label)),',');

disp('Imaging these wells:')
disp(l)

end
