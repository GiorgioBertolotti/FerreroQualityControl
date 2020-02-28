function check_valid_images(images, type)
    if and(~strcmp(type,'grid'), ~strcmp(type,'beehive'))
        error('Type should be grid or beehive')
    end
    folder_name = 'cropped_dataset';
    if ~exist(folder_name, 'dir')
        error('Please call crop_dataset() first.');
    else
        nimages = numel(images);
        v_folder_name = 'valid_images';
        if ~exist(v_folder_name, 'dir')
            mkdir(v_folder_name);
        end
        nv_folder_name = 'not_valid_images';
        if ~exist(nv_folder_name, 'dir')
            mkdir(nv_folder_name);
        end
        v2_folder_name = 'valid_images2';%davide
        if ~exist(v2_folder_name, 'dir')
            mkdir(v2_folder_name);
        end
        nv2_folder_name = 'not_valid_images2';%davide
        if ~exist(nv2_folder_name, 'dir')
            mkdir(nv2_folder_name);
        end
        for n = 1 : nimages
            image = imread([folder_name '/' images{n}]);
            if strcmp(type,'grid')
                result = check_valid_grid_image(image);
                if result.valid == 0
                    imwrite(result.image, [nv_folder_name '/' images{n}]);
                else
                    imwrite(image, [v_folder_name '/' images{n}]);
                end
             elseif strcmp(type,'beehive')
                result = check_valid_beehive_image(image);
                if result.valid == 0
                    imwrite(image, [nv2_folder_name '/' images{n}]);
                else
                    imwrite(image, [v2_folder_name '/' images{n}]);
                end
            end
        end
    end
end

function out=check_valid_grid_image(image)
    [r,c,~] = size(image);
    cell_r = floor(r/4);
    cell_c = floor(c/6);
    resized = imresize(image, [4*cell_r, 6*cell_c]);
    sections = mat2cell(resized, cell_r * ones(4,1), cell_c * ones(6,1), (3));
    image_copy = image;
    valid = 1;
    min_score = 0.85;
    bonus_tollerance = 0.05;
    median_values = zeros(4, 1);
    median_saturations = zeros(4, 1);
    computed_values = zeros(4, 6);
    computed_saturations = zeros(4, 6);
    for i=1:4
        line_values = zeros(6, 1);
        line_saturations = zeros(6, 1);
        for j=1:6
            section = cell2mat(sections(i,j));
            line_values(j) = compute_value(section);
            line_saturations(j) = compute_saturation(section);
        end
        median_values(i) = median(line_values);
        median_saturations(i) = median(line_saturations);
        computed_values(i, :) = line_values;
        computed_saturations(i, :) = line_saturations;
    end
    for i=1:4
        for j=1:6
            computed_value = computed_values(i,j);
            computed_saturation = computed_saturations(i,j);
            % we calculate a score based on how different is the v
            % s in the section compared to the median of the line of the 
            % section
            % NB: this could create problems when there's a line has many
            % errors
            score = 1 - abs(median_values(i) - computed_value) - abs(median_saturations(i) - computed_saturation);
            tollerance = 0;
            if or(j == 1, j == 6)
                tollerance = bonus_tollerance;
            end
            if score < (min_score - min_score * tollerance)
                valid = 0;
                section_center = [floor(mean([cell_r * (i-1), cell_r * i])),floor(mean([cell_c * (j-1), cell_c * j]))];
                circle_props = [section_center(2), section_center(1), floor(min(cell_r,cell_c)/2)];
                image_copy = insertShape(image_copy,'circle',circle_props,'LineWidth',5,'Color','red');
            end
        end
    end
    out.image = image_copy;
    out.valid = valid;
end

function out=check_valid_beehive_image(image)
    hsv = rgb2hsv(image);
    s = hsv(:,:,2);
    ms = s < 0.35;
    fms = medfilt2(ms);
    ffms = imfill(fms, 'holes');
    %{
    ycbcr = rgb2ycbcr(image);
    cb = ycbcr(:,:,2);
    mcb = cb > 105;
    fmcb = medfilt2(mcb);

    b = image(:,:,3);
    mb = b > 120;
    fmb = medfilt2(mb);
    %}
    mask = ffms;
    cc = bwconncomp(mask);
    stats = regionprops(cc, 'Area', 'Perimeter');
    for i = 1: cc.NumObjects
       circ = (4*pi*stats(i).Area)/((stats(i).Perimeter)^2);
       if or(circ < 0.2, circ > 1.1)
           mask(cc.PixelIdxList{i}) = 0;
           stats(i).Area = 0;
       end
       stats(i).PixelIdxList = cc.PixelIdxList{i};
       stats(i).Circularity = circ;
    end

    T = struct2table(stats);
    sortedT = sortrows(T, 'Area', {'descend'});
    stats = table2struct(sortedT);

    for i = 25:size(stats)
        for pixelIdx = stats(i).PixelIdxList
            mask(pixelIdx) = 0;
        end
    end

    image_area = (size(image, 1) * size(image, 2));
    valid = 1;
    for i = 1:24
        area_perc = stats(i).Area / image_area;
        if area_perc < 0.001
            valid = 0;
            for pixelIdx = stats(i).PixelIdxList
                mask(pixelIdx) = 0;
            end
        end
    end

    out.valid = valid;
    out.tag_mask = mask;
end

function out=compute_line_whites(sections, lineindex, skipindex)
    whites = zeros(6, 1);
    for i=1:6
        if i ~= skipindex
            section = cell2mat(sections(lineindex,i));
            computed_white = compute_whites(section);
            whites(i) = computed_white;
        end
    end
    out = mean(whites);
end

function out=compute_line_blacks(sections, lineindex, skipindex)
    blacks = zeros(6, 1);
    for i=1:6
        if i ~= skipindex
            section = cell2mat(sections(lineindex,i));
            computed_black = compute_blacks(section);
            blacks(i) = computed_black;
        end
    end
    out = mean(blacks);
end

function out=compute_value(rgbimage)
    if size(rgbimage,3) ~= 3
        error("Input image should be RGB");
    else
        hsv = rgb2hsv(rgbimage);
        v = hsv(:,:,3);
        out = mean(mean(v));
    end
end

function out=compute_saturation(rgbimage)
    if size(rgbimage,3) ~= 3
        error("Input image should be RGB");
    else
        hsv = rgb2hsv(rgbimage);
        s = hsv(:,:,2);
        out = mean(mean(s));
    end
end

function out=compute_whites(rgbimage)
    if size(rgbimage,3) ~= 3
        RGB_mask = rgbimage > 220;
        count_whites = sum(sum(RGB_mask==1));
        out = count_whites/numel(RGB_mask);
    else
        RGB_mask = rgb2gray(rgbimage) > 220;
        count_whites = sum(sum(RGB_mask==1));
        out = count_whites/numel(RGB_mask);
    end
end

function out=compute_blacks(rgbimage)
    if size(rgbimage,3) ~= 3
        RGB_mask = rgbimage < 30;
        count_blacks = sum(sum(RGB_mask==1));
        out = count_blacks/numel(RGB_mask);
    else
        RGB_mask = rgb2gray(rgbimage) < 30;
        count_blacks = sum(sum(RGB_mask==1));
        out = count_blacks/numel(RGB_mask);
    end
end