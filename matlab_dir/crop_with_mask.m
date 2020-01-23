function out=crop_with_mask(im)
    % use a threshold on CR channel to get a mask of the box
    ycbcr = rgb2ycbcr(im);
    CR = ycbcr(:,:,3);
    T = 100/255;
    mask1 = CR < T;
    % remove salt&pepper on mask
    mask1 = medfilt2(mask1);
    % use a threshold on BLUE channel to get a mask of the box
    B = im(:,:,3);
    T = 30/255;
    mask2 = B < T;
    % remove salt&pepper on mask
    mask2 = medfilt2(mask2, [10, 10]);
    se = strel("diamond", floor(min(size(mask2)) / 100));
    mask2 = imclose(mask2, se);
    % get the largest pixel area
    mask2 = bwareafilt(mask2, 1);
    % mix masks
    mask = or(mask1,mask2);
    % close mask perimeter
    mask = imclose(mask, se);
    % fill mask holes
    mask = imfill(mask, 'holes');
    % get the largest pixel area
    mask = bwareafilt(mask, 1);
    corners = find_corners(mask);
    if valid_corners(corners)
        % reorder corner
        reordered_corners = reorder_corners(corners);
        upper_corner = reordered_corners.upper_corner;
        bottom_corner = reordered_corners.bottom_corner;
        left_corner = reordered_corners.left_corner;
        right_corner = reordered_corners.right_corner;
        top_left_dist = pitagora_dist(upper_corner(1)-left_corner(1),upper_corner(2)-left_corner(2));
        top_right_dist = pitagora_dist(upper_corner(1)-right_corner(1),upper_corner(2)-right_corner(2));
        bottom_left_dist = pitagora_dist(bottom_corner(1)-left_corner(1),bottom_corner(2)-left_corner(2));
        bottom_right_dist = pitagora_dist(bottom_corner(1)-right_corner(1),bottom_corner(2)-right_corner(2));
        % project the box to fill the image rectangle
        %view_corners(im, corners);
        if top_left_dist > top_right_dist
            cropped = stretch_box(im, mask, corners, [min(top_right_dist, bottom_left_dist),min(top_left_dist, bottom_right_dist)]);
        else
            cropped = stretch_box(im, mask, corners, [min(top_left_dist, bottom_right_dist),min(top_right_dist, bottom_left_dist)]);
        end
    else
        % crop out the rest of the image
        cropped = crop_rest_mask(im, mask);
        cropped_mask = crop_rest_mask(mask, mask);
        % if necessary rotate the image to get the long side of the box
        % horizontally aligned
        [rows, columns, ~] = size(cropped);
        if rows > columns
            cropped = imrotate(cropped, 90);
            cropped_mask = imrotate(cropped_mask, 90);
            [rows, columns, ~] = size(cropped);
        end
        % get the bounds of the mask
        boundaries = bwboundaries(cropped_mask);
        x = boundaries{1}(:, 2);
        y = boundaries{1}(:, 1);
        % get lines on top side
        top_pt = [];
        for i=1:rows
            for j=1:columns
                if cropped_mask(i, j) == 1
                    top_pt = j;
                    break;
                end
            end
            if not(isempty(top_pt))
                break;
            end
        end
        side_elements = y < rows/20 & x < top_pt;
        top_side_x = x(side_elements);
        top_side_y = y(side_elements);
        % get lines on bottom side
        bottom_pt = [];
        for i=rows:-1:1
            for j=columns:-1:1
                if cropped_mask(i, j) == 1
                    bottom_pt = j;
                    break;
                end
            end
            if not(isempty(bottom_pt))
                break;
            end
        end
        side_elements = y > rows/20*19 & x > bottom_pt;
        bottom_side_x = x(side_elements);
        bottom_side_y = y(side_elements);
        %{
        % show the sides
        imshow(cropped_mask, []);
        axis on;
        hold on;
        plot(top_side_x, top_side_y, 'r-', 'LineWidth', 3);
        plot(bottom_side_x, bottom_side_y, 'r-', 'LineWidth', 3);
        %}
        % fit line to get the angle
        top_coeffs = polyfit(top_side_x, top_side_y, 1);
        bottom_coeffs = polyfit(bottom_side_x, bottom_side_y, 1);
        % get the top angle
        mean_slope = mean([top_coeffs(1), bottom_coeffs(1)]);
        angle = atand(mean_slope);
        % rotate the mask and the image to get the top side aligned
        r_mask = imrotate(mask, angle);
        r_im = imrotate(im, angle);
        % crop out all the rest of the image
        cropped = crop_rest_mask(r_im, r_mask);
    end
    out = cropped;
end