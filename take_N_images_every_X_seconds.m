function [out_images,time_between_images] = take_N_images_every_X_seconds(src,vid,N,X)

out_images = cell(1,N);
this_img_timer = zeros(1,N);
time_between_images = zeros(1,N);

for i = 1:N
    image_timer = tic;
    try
        start(vid)
        out_images{i} = getdata(vid,1);
        stop(vid)
    catch
        disp(['error on image ' num2str(i)])
    end
    this_img_timer(i) = toc(image_timer);
    
    time_to_pause = X-this_img_timer(i);
        
    if time_to_pause>0
        pause(time_to_pause)
        time_between_images(i) = this_img_timer(i)+time_to_pause;
    else
        time_between_images(i) = this_img_timer(i);
    end
    
end


end