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
                    imwrite(result.image, [nv_folder_name '/' images{n}]);
                else
                    imwrite(image, [v_folder_name '/' images{n}]);
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
        if area_perc < 0.0008
            valid = 0;
            for pixelIdx = stats(i).PixelIdxList
                mask(pixelIdx) = 0;
            end
        end
    end
    
    image_copy = image;

    labeled = bwlabel(mask);

    left_most_point = find_left_most_point(mask);
    right_most_point = find_right_most_point(mask);
    top_most_point = find_top_most_point(mask);
    bottom_most_point = find_bottom_most_point(mask);

    r = image_copy(:,:,1);
    mr = r < 40;
    fmr = medfilt2(mr);
    ffmr = imfill(fmr, 'holes');
    left_most_point2 = find_left_most_point(ffmr);
    right_most_point2 = find_right_most_point(ffmr);
    top_most_point2 = find_top_most_point(ffmr);
    bottom_most_point2 = find_bottom_most_point(ffmr);

    start_pt = [min(top_most_point(1),top_most_point2(1)),min(left_most_point(2),left_most_point2(2))];
    end_pt = [max(bottom_most_point(1),bottom_most_point2(1)),max(right_most_point(2),right_most_point2(2))];

    image_copy = check_external_ring(image_copy, labeled, start_pt, end_pt);
    image_copy = check_middle_ring(image_copy, labeled, start_pt, end_pt);
    image_copy = check_internal_ring(image_copy, labeled, start_pt, end_pt);
    
    out.image = image_copy;
    out.valid = valid;
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

function out=check_internal_ring(image, labeled, start_pt, end_pt)
    w = end_pt(2) - start_pt(2);
    h = end_pt(1) - start_pt(1);
    candy_size = [floor(h/5), floor(w/5)];
    start_pt = [start_pt(1) + (candy_size(1)*2) - floor(candy_size(1)*5/10), start_pt(2) + (candy_size(2)*2) - floor(candy_size(2)*5/10)];
    % ext row 1
    x = start_pt(2);
    y = start_pt(1);
    for i=1:2
        middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
        circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
        tmp_mask = zeros(size(labeled));
        tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
        tmp_mask = logical(rgb2gray(tmp_mask));
        count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
        if count == 0
            image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
        end
        x = x + candy_size(2);
    end
    % ext row 3
    x = start_pt(2);
    y = start_pt(1) + candy_size(1);
    for i=1:2
        middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
        circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
        tmp_mask = zeros(size(labeled));
        tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
        tmp_mask = logical(rgb2gray(tmp_mask));
        count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
        if count == 0
            image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
        end
        x = x + candy_size(2);
    end
    out = image;
end

function out=check_middle_ring(image, labeled, start_pt, end_pt)
    w = end_pt(2) - start_pt(2);
    h = end_pt(1) - start_pt(1);
    candy_size = [floor(h/5), floor(w/5)];
    start_pt = [start_pt(1) + candy_size(1) - floor(candy_size(1)*2/10), start_pt(2) + candy_size(2) - floor(candy_size(2)*2/10)];
    end_pt = [end_pt(1) - candy_size(1) + floor(candy_size(1)*2/10), end_pt(2) - candy_size(2) + floor(candy_size(2)*2/10)];
    spacing_h = floor(candy_size(2) / 4);
    spacing_v = floor(candy_size(1) / 4);
    % ext row 1
    x = start_pt(2);
    y = start_pt(1);
    for i=1:3
        middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
        circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
        tmp_mask = zeros(size(labeled));
        tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
        tmp_mask = logical(rgb2gray(tmp_mask));
        count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
        if count == 0
            image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
        end
        x = x + candy_size(2) + spacing_h;
    end
    % ext row 2
    x = start_pt(2);
    y = start_pt(1) + candy_size(1) + spacing_v;
    middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
    circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
    tmp_mask = zeros(size(labeled));
    tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
    tmp_mask = logical(rgb2gray(tmp_mask));
    count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
    if count == 0
        image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
    end
    x = end_pt(2) - candy_size(2);
    y = start_pt(1) + candy_size(1) + spacing_v;
    middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
    circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
    tmp_mask = zeros(size(labeled));
    tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
    tmp_mask = logical(rgb2gray(tmp_mask));
    count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
    if count == 0
        image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
    end
    % ext row 3
    x = start_pt(2);
    y = start_pt(1) + (candy_size(1) * 2) + (spacing_v * 2);
    for i=1:3
        middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
        circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
        tmp_mask = zeros(size(labeled));
        tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
        tmp_mask = logical(rgb2gray(tmp_mask));
        count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
        if count == 0
            image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
        end
        x = x + candy_size(2) + spacing_h;
    end
    out = image;
end

function out=check_external_ring(image, labeled, start_pt, end_pt)
    w = end_pt(2) - start_pt(2);
    h = end_pt(1) - start_pt(1);
    candy_size = [floor(h/5), floor(w/5)];
    spacing_h = floor(candy_size(2) / 3);
    spacing_v = floor(candy_size(1) / 3);
    % ext row 1
    x = start_pt(2);
    y = start_pt(1);
    for i=1:4
        middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
        circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
        tmp_mask = zeros(size(labeled));
        tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
        tmp_mask = logical(rgb2gray(tmp_mask));
        count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
        if count == 0
            image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
        end
        x = x + candy_size(2) + spacing_h;
    end
    % ext row 2
    x = start_pt(2);
    y = start_pt(1) + candy_size(1) + spacing_v;
    middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
    circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
    tmp_mask = zeros(size(labeled));
    tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
    tmp_mask = logical(rgb2gray(tmp_mask));
    count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
    if count == 0
        image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
    end
    x = end_pt(2) - candy_size(2);
    y = start_pt(1) + candy_size(1) + spacing_v;
    middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
    circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
    tmp_mask = zeros(size(labeled));
    tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
    tmp_mask = logical(rgb2gray(tmp_mask));
    count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
    if count == 0
        image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
    end
    % ext row 3
    x = start_pt(2);
    y = start_pt(1) + (candy_size(1) * 2) + (spacing_v * 2);
    middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
    circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
    tmp_mask = zeros(size(labeled));
    tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
    tmp_mask = logical(rgb2gray(tmp_mask));
    count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
    if count == 0
        image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
    end
    x = end_pt(2) - candy_size(2);
    y = start_pt(1) + (candy_size(1) * 2) + (spacing_v * 2);
    middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
    circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
    tmp_mask = zeros(size(labeled));
    tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
    tmp_mask = logical(rgb2gray(tmp_mask));
    count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
    if count == 0
        image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
    end
    % ext row 4
    x = start_pt(2);
    y = start_pt(1) + (candy_size(1) * 3) + (spacing_v * 3);
    for i=1:4
        middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
        circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
        tmp_mask = zeros(size(labeled));
        tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
        tmp_mask = logical(rgb2gray(tmp_mask));
        count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
        if count == 0
            image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
        end
        x = x + candy_size(2) + spacing_h;
    end
    out = image;
end

function out=find_left_most_point(mask)
    pt = [];
    for i = 1:size(mask, 2)
        for j = 1:size(mask, 1)
            if mask(j,i) == 1
                pt = [j,i];
                break;
            end
        end
        if ~isempty(pt)
            break;
        end
    end
    out = pt;
end

function out=find_right_most_point(mask)
    pt = [];
    for i = size(mask, 2):-1:1
        for j = 1:size(mask, 1)
            if mask(j,i) == 1
                pt = [j,i];
                break;
            end
        end
        if ~isempty(pt)
            break;
        end
    end
    out = pt;
end

function out=find_top_most_point(mask)
    pt = [];
    for i = 1:size(mask, 1)
        for j = 1:size(mask, 2)
            if mask(i,j) == 1
                pt = [i,j];
                break;
            end
        end
        if ~isempty(pt)
            break;
        end
    end
    out = pt;
end

function out=find_bottom_most_point(mask)
    pt = [];
    for i = size(mask, 1):-1:1
        for j = 1:size(mask, 2)
            if mask(i,j) == 1
                pt = [i,j];
                break;
            end
        end
        if ~isempty(pt)
            break;
        end
    end
    out = pt;
end