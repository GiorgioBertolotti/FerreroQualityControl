function out=crop_image(image)
    im = equalize_image(im2double(image));
    % search the box sides with Hough transform
    sides = find_sides(im);
    result = find_valid_corners(im, sides);
    if result.valid == true
        % corners found with Hough
        cropped = crop_with_corners(image, result.corners);
    else
        % search the box sides with another configuration of Hough 
        % transform
        sides = find_sides_alt(im);
        result = find_valid_corners(im, sides);
        if result.valid == true
            % corners found with Hough v2
            cropped = crop_with_corners(image, result.corners);
        else
            % corners not found with Hough v2, try to get the corners from 
            % a mask of the box
            mask = get_mask(im);
            corners = find_mask_corners(mask);
            if valid_corners(corners)
                % corners found with the mask
                cropped_eq = crop_with_corners(im, corners);
                cropped = crop_with_corners(image, corners);
            else
                % corners not found, crop with mask bounds and adjust angle
                cropped_eq = crop_with_mask(im, mask);
                cropped = crop_with_mask(image, mask);
            end
            % flip the image to have white ferreros at the top
            [rows, ~, ~] = size(cropped_eq);
            bw = rgb2gray(cropped_eq);
            mask = bw > 0.5;
            bottom_half_count = sum(sum(mask(floor(rows/2):rows, :)));
            top_half_count = sum(sum(mask(1:floor(rows/2), :)));
            if bottom_half_count > top_half_count
                cropped_eq = flipud(cropped_eq);
                cropped = flipud(cropped);
            end
            % search again the sides with Hough transform
            im = equalize_image(im2double(cropped_eq));
            sides = find_sides(im);
            result = find_valid_corners(im, sides);
            if result.valid == true
                % corners found in the image cropped with mask
                cropped = crop_with_corners(cropped, result.corners);
            end
        end
    end
    % rotate the image in landscape
    [rows, columns, ~] = size(cropped);
    if rows > columns
        cropped = imrotate(cropped, 90);
    end
    % flip the image to have white ferreros at the top
    [rows, ~, ~] = size(cropped);
    ycbcr = rgb2ycbcr(cropped);
    y = ycbcr(:,:,1);
    mask = y > 128;
    bottom_half_count = sum(sum(mask(floor(rows/2):rows, :)));
    top_half_count = sum(sum(mask(1:floor(rows/2), :)));
    if bottom_half_count > top_half_count
        cropped = flipud(cropped);
    end
    out.image = cropped;
end

function out=crop_with_corners(im, corners)
    corner_1 = corners(1,:);
    corner_2 = corners(2,:);
    corner_3 = corners(3,:);
    corner_4 = corners(4,:);
    len_a = pitagora_dist(corner_1(1)-corner_2(1),corner_1(2)-corner_2(2));
    len_b = pitagora_dist(corner_1(1)-corner_4(1),corner_1(2)-corner_4(2));
    len_c = pitagora_dist(corner_3(1)-corner_4(1),corner_3(2)-corner_4(2));
    len_d = pitagora_dist(corner_3(1)-corner_2(1),corner_3(2)-corner_2(2));
    % create a mask
    d_mask = size(im);
    pos_shape = [flip(corners(1,:)), flip(corners(2,:)), flip(corners(3,:)), flip(corners(4,:))];
    rgb_mask = zeros(d_mask(1), d_mask(2), 3);
    rgb_mask = insertShape(rgb_mask, 'FilledPolygon', pos_shape, 'Color', 'white', 'Opacity', 1.0);
    bw = rgb2gray(rgb_mask);
    mask = logical(bw);
    % project the box to fill the image rectangle
    cropped = stretch_box(im, mask, corners, [min(len_b,len_d),min(len_a, len_c)]);
    out = cropped;
end