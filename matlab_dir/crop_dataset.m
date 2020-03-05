function crop_dataset(images)
    folder_name = 'cropped_dataset';
    % if the folder exists don't crop again
    if ~exist(folder_name, 'dir')
        mkdir(folder_name);
        original_folder_name = 'dataset';
        for i = 1:size(images)
            image = imread([original_folder_name '/' images{i}]);
            cropped = crop_image(image);
            imwrite(cropped.image, [folder_name '/' images{i}]);
        end
    else
        disp("Cropped dataset already exists");
    end
end
