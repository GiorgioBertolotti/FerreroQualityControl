function out=check_valid_grid_image_old(image)
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