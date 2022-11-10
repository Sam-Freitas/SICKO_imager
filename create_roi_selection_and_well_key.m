% this creates the ROI selection tool
% modified from the Worm Paparazzi inital script

plate_type = 't'; % 'w' or 't'

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
end

I2 = zeros(size(I),'uint8');

for i = 1:length(Z_cen2)
    I2 = I2 + (uint8(bwareaopen(I==i,250,4))*i);
end

% this creates the way in which the wells will be imaged
% in a snake pattern starting from the bottom right
movement_index = 1;
row_counter = 1;
pos = zeros(96,1);
for i = 12:-1:1
    % flip the starting point every time it goes to a new row
    if iseven(i)
        for j = 1:8
            pos(movement_index) = i + (j-1)*12;

            well_key{pos(movement_index),3} = movement_index;
            well_key{pos(movement_index),4} = j;
            well_key{pos(movement_index),5} = row_counter;

            movement_index = movement_index + 1;
        end
    else
        for j = 8:-1:1
            pos(movement_index) = i + (j-1)*12;

            well_key{pos(movement_index),3} = movement_index;
            well_key{pos(movement_index),4} = j;
            well_key{pos(movement_index),5} = row_counter;
            
            movement_index = movement_index + 1;
        end
    end
    row_counter = row_counter + 1;
end

writetable(cell2table(well_key,'VariableNames',well_key_header), 'well_key.csv')

imwrite(I2,'Basic_wells_template_terasaki.png');

function out = iseven(in)

remainder_of_2 = rem(in,2);
if isequal(remainder_of_2,0)
    out = 1;
else
    out = 0;
end
end
