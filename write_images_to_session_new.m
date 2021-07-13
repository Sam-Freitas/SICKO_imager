function write_images_to_session_new(session,images)


for i = 1:length(images)
    file_name = fullfile(session, [num2str(i) '.png']);
    imwrite(images{i}, file_name);
end


end
