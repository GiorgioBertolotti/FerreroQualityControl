function out=crop_with_mask(im, mask)
    % crop out the rest of the image
    cropped = crop_rest_mask(im, mask);
    cropped_mask = crop_rest_mask(mask, mask);
    % rotate the image in landscape
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
    % uncomment to plot the lines
    %{
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
    % rotate the image in landscape
    [rows, columns, ~] = size(cropped);
    if rows > columns
        cropped = imrotate(cropped, 90);
    end
    out = cropped;
end