function out=crop_with_mask_corners(im, mask, corners)
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
    % rotate the image in landscape
    [rows, columns, ~] = size(cropped);
    if rows > columns
        cropped = imrotate(cropped, 90);
    end
    out = cropped;
end