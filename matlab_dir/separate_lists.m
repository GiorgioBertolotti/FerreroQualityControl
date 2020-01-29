function out=separate_lists(images, labels)
    folder_name = 'cropped_dataset';
    if ~exist(folder_name, 'dir')
        error('Please call crop_dataset() first.');
    else
        nimages = numel(images);
        grids = {};
        grid_labels = {};
        beehives = {};
        beehive_labels = {};
        for n = 1 : nimages
            image = imread([folder_name '/' images{n}]);
            [r,c,~] = size(image);
            centroid_pos = compute_white_centroid(image)./[r, c];
            proportions = c/r;
            % differenciate descriptors based on box type
            if or(proportions > 1.2, centroid_pos(1) <= 0.4)
                grids = [grids; images(n)];
                grid_labels = [grid_labels; labels(n)];
            else
                beehives = [beehives; images(n)];
                beehive_labels = [beehive_labels; labels(n)];
            end
        end
        out.grids = grids;
        out.beehives = beehives;
        out.grid_labels = grid_labels;
        out.beehive_labels = beehive_labels;
    end
end