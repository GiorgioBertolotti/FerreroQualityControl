function out=run_classifier()
    images = readlists();
    groundtruth = read_groundtruth();
    num_input = length(images);
    num_groundtruth = length(groundtruth);
    
    if num_input ~= num_groundtruth
        disp("images.list and labels.list should have the same number of elements")
    end
    
    crop_dataset(images);
    separation = separate_types(images);
    result_beehives = check_valid_images(separation.beehives, 'beehive');
    result_grids = check_valid_images(separation.grids, 'grid');
    
    correct_counter = 0;
    
    for i = 1:num_input
        image_name = images{i};
        should_be = groundtruth{i};
        
        switch should_be
            case "grid_valid"
                if any(strcmp(result_grids.valids, image_name))
                    correct_counter = correct_counter + 1;
                end
            case "beehive_valid"
                if any(strcmp(result_beehives.valids, image_name))
                    correct_counter = correct_counter + 1;
                end
            case "grid_not_valid"
                if any(strcmp(result_grids.not_valids, image_name))
                    correct_counter = correct_counter + 1;
                end
            case "beehive_not_valid"
                if any(strcmp(result_beehives.not_valids, image_name))
                    correct_counter = correct_counter + 1;
                end
            otherwise
                disp("Groundtruth value not valid");
        end
    end
    
    out.precision = correct_counter / num_input;
end
