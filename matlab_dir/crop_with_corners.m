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