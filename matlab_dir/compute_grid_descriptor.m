function out=compute_grid_descriptor(image)
    [r,c,~] = size(image);
    cell_r = floor(r/4);
    cell_c = floor(c/6);
    resized = imresize(image, [4*cell_r, 6*cell_c]);
    sections = mat2cell(resized, cell_r * ones(4,1), cell_c * ones(6,1), [3]);
    descriptor = [];
    for i=1:4
        for j=1:6
            section = cell2mat(sections(i,j));
            computed_white = compute_whites(section);
            avg_whites_without_this = compute_avg_whites_without(sections, i, j);
            computed_black = compute_blacks(section);
            avg_blacks_without_this = compute_avg_blacks_without(sections, i, j);
            score = 1 - abs(avg_whites_without_this - computed_white) - abs(avg_blacks_without_this - computed_black);
            descriptor = [descriptor, score];
        end
    end
    out = descriptor;
end

function out=compute_avg_whites_without(sections, lineindex, skipindex)
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

function out=compute_avg_blacks_without(sections, lineindex, skipindex)
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