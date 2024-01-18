function write_images_to_session_new(session,images,label)


for i = 1:length(images)
    file_name = fullfile(session, [label '00' num2str(i) '.png']);
    imwrite(images{i}, file_name);
end


end
