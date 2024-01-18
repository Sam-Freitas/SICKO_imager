% this is a testing script to see if we can execute two scripts at the same
% time 
% this uses a pause statement as a movement statement and a create a random
% image as a imaging statement
% (imaging and movement)
clc
clear all
close all
mkdir('test_data')
warning('off', 'MATLAB:MKDIR:DirectoryExists');
warning('off','serialport:serialport:ReadlineWarning');

file_type = 'tiff';

delete('test_data\*')

delete(gcp('nocreate'))
write_0();

parpool('Processes');
for i = 1:10
    pause(5)
    disp(['i' num2str(i)])
    write_0();
    parfor j = 1:1000
        if j == 1
%             disp('Move')
            write_0();
            write_1();
            pause(5)
            write_0();
        else
            if read_txt() == 1
                pause(0.00001)
                t = char(get_datetime());
                imwrite(rand(1024),fullfile('test_data',[num2str(i) '  ' t '.' file_type]))
%                 disp('imaging')
            end
%             disp(j)
            pause(0.001)
        end 
    end
    write_0();
end

function t = get_datetime()
t = datetime('now','Format','yyyy-MM-DD-HH-mm-ss-ms');
% disp(t)
end

function write_1()
fileID = fopen('moving.txt','w');
fprintf(fileID, '1');
fclose(fileID);
end

function write_0()
fileID = fopen('moving.txt','w');
fprintf(fileID, '0');
fclose(fileID);
end

function out = read_txt()
fileID = fopen('moving.txt','r');
formatSpec = '%f';
out = fscanf(fileID,formatSpec);
fclose(fileID);
end