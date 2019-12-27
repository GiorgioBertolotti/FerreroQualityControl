function crop_dataset(images)
    folder_name = 'cropped_dataset';
    if ~exist(folder_name, 'dir')
        mkdir(folder_name);
        original_folder_name = 'equalized_dataset';
        for i = 1:size(images)
            image = imread([original_folder_name '/' images{i}]);
            cropped = crop_image(image);
            imwrite(cropped, [folder_name '/' images{i}]);
        end
    else
        disp("Cropped dataset already exists");
    end
end
