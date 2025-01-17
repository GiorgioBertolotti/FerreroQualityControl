I_nv = imread("cropped_dataset/048.jpg");
I_v = imread("cropped_dataset/03.jpg");

image = I_v;
equalized_image = equalize_image(image);

[r,c,~] = size(image);
cell_r = floor(r/4);
cell_c = floor(c/6);

resized = imresize(equalized_image, [4*cell_r, 6*cell_c]);
sections = mat2cell(resized, cell_r * ones(4,1), cell_c * ones(6,1), (3));

image_copy = image;
    
valid = 0;
res = check_first_row(image_copy, sections(1,:));
valid = valid + res.valid;
res = check_middle_row(res.image, res.image(cell_r:2*cell_r,:,:), 2);
valid = valid + res.valid;
res = check_middle_row(res.image, res.image(2*cell_r:3*cell_r,:,:), 3);
valid = valid + res.valid;
res = check_last_row(res.image, sections(4,:));
valid = valid + res.valid;

%{
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
%}

function out=check_first_row(image, sections)
    valid = 1;
    for i=1:6
        section = cell2mat(sections(i));
        [cell_r, cell_c, ~] = size(section);
        
        r = section(:,:,1);
        mr = r > 180;
        fmr = medfilt2(mr);
        
        mask_count = sum(sum(fmr));
        perc_mask = mask_count / (size(section, 1) * size(section, 2));
        if perc_mask < 0.35
            section_center = [floor(cell_r / 2),floor(mean([cell_c * (i-1), cell_c * i]))];
            circle_props = [section_center(2), section_center(1), floor(min(cell_r,cell_c)/2)];
            image = insertShape(image,'circle',circle_props,'LineWidth',5,'Color','red');
            valid = 0;
        end
        %{
        figure;
        subplot(1,2,1);
        imshow(mr);
        subplot(1,2,2);
        imhist(r);
        %}
    end
    out.image = image;
    out.valid = valid;
end

function out=check_middle_row(image, line_image, row_index)
    hsv = rgb2hsv(line_image);
    s = hsv(:,:,2);
    ms = s < 0.35;
    fms = medfilt2(ms);
    ffms = imfill(fms, 'holes');
    
    mask = ffms;
    cc = bwconncomp(mask);
    stats = regionprops(cc, 'Area', 'Perimeter');
    for i = 1: cc.NumObjects
       circ = (4*pi*stats(i).Area)/((stats(i).Perimeter)^2);
       if or(circ < 0.3, circ > 1.1)
           mask(cc.PixelIdxList{i}) = 0;
           stats(i).Area = 0;
       end
       stats(i).PixelIdxList = cc.PixelIdxList{i};
       stats(i).Circularity = circ;
    end

    T = struct2table(stats);
    sortedT = sortrows(T, 'Area', {'descend'});
    stats = table2struct(sortedT);

    for i = 7:size(stats)
        for pixelIdx = stats(i).PixelIdxList
            mask(pixelIdx) = 0;
        end
    end
    
    image_area = (size(line_image, 1) * size(line_image, 2));
    for i = 1:6
        area_perc = stats(i).Area / image_area;
        if area_perc < 0.0008
            for pixelIdx = stats(i).PixelIdxList
                mask(pixelIdx) = 0;
            end
        end
    end
    
    [r,c,~] = size(mask);
    cell_c = floor(c/6);

    resized = imresize(mask, [r, 6 * cell_c]);
    sections = mat2cell(resized, r * ones(1), cell_c * ones(6,1));
    
    candy_size = [r, cell_c];
    
    x = 0;
    y = r * (row_index - 1);
    valid = 1;
    for n=1:6
        section = cell2mat(sections(n));
        middle_point = [floor(candy_size(1)/2), floor(candy_size(2)/2)];
        circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
        tmp_mask = zeros(size(section));
        tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
        tmp_mask = logical(rgb2gray(tmp_mask));
        count = sum(sum(and(tmp_mask == 1, section ~= 0)));
        if count == 0
            middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
            circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
            image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
            valid = 0;
        end
        x = x + candy_size(2);
    end
    out.image = image;
    out.valid = valid;
end

function out=check_last_row(image, sections)
    valid = 1;
    for i=1:6
        section = cell2mat(sections(i));
        [cell_r, cell_c, ~] = size(section);
        
        hsv = rgb2hsv(section);
        s = hsv(:,:,2);
        ms = s > 0.8;
        fms = medfilt2(ms);
        
        mask_count = sum(sum(fms));
        perc_mask = mask_count / (size(section, 1) * size(section, 2));
        if perc_mask < 0.1
            section_center = [(cell_r * 3) + floor(cell_r / 2),floor(mean([cell_c * (i-1), cell_c * i]))];
            circle_props = [section_center(2), section_center(1), floor(min(cell_r,cell_c)/2)];
            image = insertShape(image,'circle',circle_props,'LineWidth',5,'Color','red');
            valid = 0;
        end
    end
    out.image = image;
    out.valid = valid;
end