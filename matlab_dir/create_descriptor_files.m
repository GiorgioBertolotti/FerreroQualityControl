function create_descriptor_files(images, labels)
    folder_name = 'cropped_dataset';
    if ~exist(folder_name, 'dir')
        error('Please call crop_dataset() first.');
    else
        nimages = numel(images);
        desc_cd = [];
        for n = 1 : nimages
            im = imread([folder_name '/' images{n}]);
            cd = compute_grid_descriptor(im);
            desc_cd = [desc_cd; cd];
        end
        save('descriptors.mat','desc_cd');
        save('input.mat', 'images', 'labels');
    end
end