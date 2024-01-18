% this creates the ROI selection tool
% modified from the Worm Paparazzi inital script
clear all 
close all

plate_type = 't'; % 'w' or 't'

bottom_left = [39.55,50.3];   %A
bottom_right = [13.2,50.45];
top_left = [39.25,6];
top_right = [12.9,6.1];      %B

cols_terasaki = upper(["a","b","c","d","e","f","g","h"]);
rows_terasaki = ["1","2","3","4","5","6","7","8","9","10","11","12"];

[X,Y] = meshgrid(cols_terasaki,rows_terasaki);
Z = X+Y;
Z2 = Z(:);

I = zeros(1500*1.5,1500,'uint8');

basic_square = ones(100,100);

from_side = 200;
square_size = 60;

x_centers = round(linspace(from_side,1500*1.5-from_side,length(rows_terasaki)));
y_centers = round(linspace(0+from_side,1500-from_side,length(cols_terasaki)));

[X_cen,Y_cen] = meshgrid(y_centers,x_centers);
Z_cen = cat(3,X_cen,Y_cen);
Z_cen2 = reshape(Z_cen,96,2);

well_key_header = ["intensity_in_img","label","movement_order","x","y"];
well_key = cell(1,4);
for i = 1:length(Z_cen2)

    x = Z_cen2(i,1);
    y = Z_cen2(i,2);

    I(y-square_size:y+square_size,...
        x-square_size:x+square_size) = i;

    I = insertText(I,[x,y],Z2(i),'FontSize',60,'BoxOpacity',0,'AnchorPoint','Center');
    I = rgb2gray(I);

    well_key{i,1} = i;
    well_key{i,2} = Z2(i);
    well_key{i,3} = i;       %intensity = movement order
end

I2 = zeros(size(I),'uint8');

for i = 1:length(Z_cen2)
    I2 = I2 + (uint8(bwareaopen(I==i,250,4))*i);
end

% this assigns the well coordinates

Width = 8;
Height = 12;
Finer_X_Points = linspace(1,2,Width);
Finer_Y_Points = linspace(1,2,Height)';

Matrix(1,1) = top_left(1); %Top-left corner%
Matrix(1,2) = top_right(1); %Top-right corner%
Matrix(2,1) = bottom_left(1); %Bottom-left corner%
Matrix(2,2) = bottom_right(1); %Bottom-right corner%

Finer_Matrix_X = interp2(Matrix,Finer_X_Points,Finer_Y_Points,'linear');

Matrix(1,1) = top_left(2); %Top-left corner%
Matrix(1,2) = top_right(2); %Top-right corner%
Matrix(2,1) = bottom_left(2); %Bottom-left corner%
Matrix(2,2) = bottom_right(2); %Bottom-right corner%

Finer_Matrix_Y = interp2(Matrix,Finer_X_Points,Finer_Y_Points,'linear');

matrix_of_coords = cat(3,Finer_Matrix_X, Finer_Matrix_Y);

matrix_of_coords2d = reshape(matrix_of_coords,[Width*Height,2]);

for i = 1:96
    well_key{i,4} = round(matrix_of_coords2d(i,1),4);  
    well_key{i,5} = round(matrix_of_coords2d(i,2),4);  
end

writetable(cell2table(well_key,'VariableNames',well_key_header), 'well_key.csv')

imwrite(I2,'Basic_wells_template_terasaki.png');

% function out = iseven(in)
% 
% remainder_of_2 = rem(in,2);
% if isequal(remainder_of_2,0)
%     out = 1;
% else
%     out = 0;
% end
% end
