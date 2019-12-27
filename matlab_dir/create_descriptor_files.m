function create_descriptor_files()
    folder_name = 'equalized_dataset';
    if ~exist(folder_name, 'dir')
        error('Please call equalize_dataset() first.');
    else
        [images, labels] = readlists();
        nimages = numel(images);
        desc_lbp = [];
        for n = 1 : nimages
            im = imread([folder_name '/' images{n}]);
            lb = compute_lbp(im);
            desc_lbp = [desc_lbp; lb];
        end
        save('descriptors.mat','desc_lbp');
        save('input.mat', 'images', 'labels');
    end
end