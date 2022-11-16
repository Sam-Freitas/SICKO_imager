% this creates the ROI selection tool
% modified from the Worm Paparazzi inital script

plate_type = 't'; % 'w' or 't'

bottom_left = [39.9,50.4];   %A
top_right = [13.5,6.5];      %B

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

delta_x = (bottom_left(1)-top_right(1))/7;
delta_y = (bottom_left(2)-top_right(2))/11;

counter = 1;
j=0;
k=0;


for c = 1:8
    for r = 1:12

        well_key{counter, 4} = round((bottom_left(1)-(delta_x*k)),2);  
        well_key{counter, 5} = round((top_right(2)+(delta_y*j)),2);
        j = j + 1;
        counter = counter + 1;
    end
    j = 0;
    k = k+1;
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
