function equalize_dataset(images)
    folder_name = 'equalized_dataset';
    if ~exist(folder_name, 'dir')
        mkdir(folder_name);
        original_folder_name = 'dataset';
        for i = 1:size(images)
            image = im2double(imread([original_folder_name '/' images{i}]));
            equalized = equalize_image(image);
            imwrite(equalized, [folder_name '/' images{i}]);
        end
    else
        disp("Equalized dataset already exists");
    end
end
