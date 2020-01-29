function create_descriptor_files(images, labels, type)
    if and(~strcmp(type,'grid'), ~strcmp(type,'beehive'))
        error('Type should be grid or beehive')
    end
    folder_name = 'cropped_dataset';
    if ~exist(folder_name, 'dir')
        error('Please call crop_dataset() first.');
    else
        nimages = numel(images);
        desc_cd = [];
        for n = 1 : nimages
            image = imread([folder_name '/' images{n}]);
            if type == 'grid'
                cd = compute_grid_descriptor(image);
                desc_cd = [desc_cd; cd];
            end
        end
        save('descriptors.mat','desc_cd');
        save('input.mat', 'images', 'labels');
    end
end