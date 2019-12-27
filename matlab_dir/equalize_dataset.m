function equalize_dataset(images)
    folder_name = 'equalized_dataset';
    if ~exist(folder_name, 'dir')
        mkdir(folder_name);
        for i = 1:size(images)
            label = strcat('dataset/', string(images(i)));
            image = im2double(imread(label));
            equalized = equalize_image(image);
            imwrite(equalized, strcat(folder_name, '/', string(images(i))));
        end
    else
        disp("Equalized dataset already exists");
    end
end
