function check_valid_images(images, type)
    if and(~strcmp(type,'grid'), ~strcmp(type,'beehive'))
        error('Type should be grid or beehive')
    end
    folder_name = 'cropped_dataset';
    if ~exist(folder_name, 'dir')
        error('Please call crop_dataset() first.');
    else
        nimages = numel(images);
        desc_cd = [];
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
                    imwrite(image, [nv_folder_name '/' images{n}]);
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
    sections = mat2cell(resized, cell_r * ones(4,1), cell_c * ones(6,1), [3]);
    image_copy = image;
    valid = 1;
    for i=1:4
        for j=1:6
            section = cell2mat(sections(i,j));
            computed_white = compute_whites(section);
            avg_whites_without_this = compute_line_whites(sections, i, j);
            computed_black = compute_blacks(section);
            avg_blacks_without_this = compute_line_blacks(sections, i, j);
            score = 1 - abs(avg_whites_without_this - computed_white) - abs(avg_blacks_without_this - computed_black);
            if score < 0.9
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
%{
function out=check_valid_beehive_image(image)
    image = imrotate(image, 45);
    [r,c,~] = size(image);
    cell_r = floor(r/6);
    cell_c = floor(c/6);
    resized = imresize(image, [6*cell_r, 6*cell_c]);
    sections = mat2cell(resized, cell_r * ones(6,1), cell_c * ones(6,1), [3]);
    image_copy = image;
    for i=1:6
        for j=1:6
            section = cell2mat(sections(i,j));
            computed_white = compute_whites(section);
            avg_whites_without_this = compute_line_whites(sections, i, j);
            computed_black = compute_blacks(section);
            avg_blacks_without_this = compute_line_blacks(sections, i, j);
            score = 1 - abs(avg_whites_without_this - computed_white) - abs(avg_blacks_without_this - computed_black);
            if score < 0.9
                valid = 0;
                section_center = [floor(mean([cell_r * (i-1), cell_r * i])),floor(mean([cell_c * (j-1), cell_c * j]))];
                circle_props = [section_center(1), section_center(2), floor(min(cell_r,cell_c)/2)];
                image_copy = insertShape(image_copy,'circle',circle_props,'LineWidth',5,'Color','red');
            end
        end
    end
    out.image = image_copy;
    out.valid = valid;
end

stavo provando a fare la robba che ruoti di 45 e poi tracci le linee ma non
funge. magari a te viene in mente qualcosa (beehive type)
%}

function out=compute_line_whites(sections, lineindex, skipindex)
    whites = [];
    for i=1:6
        if i ~= skipindex
            section = cell2mat(sections(lineindex,i));
            computed_white = compute_whites(section);
            whites = [whites; computed_white];
        end
    end
    out = mean(whites);
end

function out=compute_line_blacks(sections, lineindex, skipindex)
    black = [];
    for i=1:6
        if i ~= skipindex
            section = cell2mat(sections(lineindex,i));
            computed_black = compute_blacks(section);
            black = [black; computed_black];
        end
    end
    out = mean(black);
end

function out=compute_whites(rgbimage)
    if size(rgbimage,3) ~= 3
        RGB_mask = rgbimage > 220;
        count_whites = sum(sum(RGB_mask==1));
        out = count_whites/numel(rgbimage);
    else
        RGB_mask = rgb2gray(rgbimage) > 220;
        count_whites = sum(sum(RGB_mask==1));
        out = count_whites/numel(rgbimage);
    end
end

function out=compute_blacks(rgbimage)
    if size(rgbimage,3) ~= 3
        RGB_mask = rgbimage < 30;
        count_blacks = sum(sum(RGB_mask==1));
        out = count_blacks/numel(rgbimage);
    else
        RGB_mask = rgb2gray(rgbimage) < 30;
        count_blacks = sum(sum(RGB_mask==1));
        out = count_blacks/numel(rgbimage);
    end
end