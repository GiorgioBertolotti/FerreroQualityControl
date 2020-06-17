function out=check_valid_images(images, type)
    if and(~strcmp(type,'grid'), ~strcmp(type,'beehive'))
        error('Type should be grid or beehive')
    end
    
    folder_name = 'cropped_dataset';
    
    if ~exist(folder_name, 'dir')
        error('Please call crop_dataset() first.');
    else
        nimages = numel(images);
        valids = [];
        not_valids = [];
        
        v_folder_name = 'valid_images';
        if ~exist(v_folder_name, 'dir')
            mkdir(v_folder_name);
        end
        
        nv_folder_name = 'not_valid_images';
        if ~exist(nv_folder_name, 'dir')
            mkdir(nv_folder_name);
        end
        
        for n = 1 : nimages
            image = imread([folder_name '/' images{n}]);
            
            if strcmp(type,'grid')
                result = check_valid_grid_image(image);
                
                if result.valid == 0
                    imwrite(result.image, [nv_folder_name '/' images{n}]);
                    not_valids = [not_valids, images(n)];
                else
                    imwrite(image, [v_folder_name '/' images{n}]);
                    valids = [valids, images(n)];
                end
             elseif strcmp(type,'beehive')
                result = check_valid_beehive_image(image);
                
                if result.valid == 0
                    imwrite(result.image, [nv_folder_name '/' images{n}]);
                    not_valids = [not_valids, images(n)];
                else
                    imwrite(image, [v_folder_name '/' images{n}]);
                    valids = [valids, images(n)];
                end
            end
        end
        
        out.valids = valids;
        out.not_valids = not_valids;
    end
end
