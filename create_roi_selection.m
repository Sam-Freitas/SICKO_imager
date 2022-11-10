clear all

plate_type = 't'; % 'w' or 't'

rows = upper(["a","b","c","d","e","f","g","h","i","j","k","l"]);
cols = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20"];

cols_terasaki = upper(["a","b","c","d","e","f","g","h"]);
rows_terasaki = ["1","2","3","4","5","6","7","8","9","10","11","12"];

if isequal(plate_type,'w')
    
    [X,Y] = meshgrid(cols,rows);
    Z = X+Y;
    Z2 = Z(:);
    
    I = zeros(3000,1500,'uint8');
    
    basic_square = ones(100,100);
    
    from_side = 200;
    square_size = 40;
    
    x_centers = round(linspace(0+from_side,1500-from_side,length(rows)));
    y_centers = round(linspace(0+from_side+200,3000-from_side-200,length(cols)));
    
    [X_cen,Y_cen] = meshgrid(y_centers,x_centers);
    Z_cen = cat(3,X_cen,Y_cen);
    Z_cen2 = reshape(Z_cen,240,2);
    
    for i = 1:length(Z_cen2)
        
        x = Z_cen2(i,1);
        y = Z_cen2(i,2);
        
        I(y-square_size:y+square_size,...
            x-square_size:x+square_size) = i;
        
        I = insertText(I,[x,y],Z2(i),'FontSize',35,'BoxOpacity',0,'AnchorPoint','Center');
        I = rgb2gray(I);
        
    end
    
    I2 = zeros(size(I),'uint8');
    
    for i = 1:length(Z_cen2)
        I2 = I2 + (uint8(bwareafilt(I==i,1))*i);
    end
    
    imwrite(I2,'Basic_wells_template.png');
    
else
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
    
    decoder = cell(1,2);
    for i = 1:length(Z_cen2)
        
        x = Z_cen2(i,1);
        y = Z_cen2(i,2);
        
        I(y-square_size:y+square_size,...
            x-square_size:x+square_size) = i;
        
        I = insertText(I,[x,y],Z2(i),'FontSize',60,'BoxOpacity',0,'AnchorPoint','Center');
        I = rgb2gray(I);

        decoder{i,1} = i; 
        decoder{i,2} = Z2(i);
        header = ["inten","label"];

        writetable(cell2table(decoder,'VariableNames',header), 'well_key.csv')
        
    end
    
    I2 = zeros(size(I),'uint8');
    
    for i = 1:length(Z_cen2)
        I2 = I2 + (uint8(bwareaopen(I==i,250,4))*i);
    end
    
    imwrite(I2,'Basic_wells_template_terasaki.png');
end