function out=compute_grid_descriptor(image)
    centroid_pos = compute_white_centroid(image)./[size(image,1), size(image,2)];
    dimens = size(image);
    cell_r = floor(dimens(1)/4);
    cell_c = floor(dimens(2)/6);
    resized = imresize(image, [4*cell_r, 6*cell_c]);
    sections = mat2cell(resized, cell_r * ones(4,1), cell_c * ones(6,1), [3]);
    descriptor = centroid_pos;
    for i=1:4
        for j=1:6
            section = cell2mat(sections(i,j));
            descriptor = [descriptor, compute_whites(section), compute_blacks(section)];
        end
    end
    out = descriptor;
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