function out=crop_with_sides_alt(im, sides)
    % find corners using lines intersection
    %plot_sides_alt(im, sides);
    im_size = size(im);
    tollerance = max(floor([im_size(1)/10, im_size(2)/10]));
    corners = [];
    for i = 1:4
        for j = i+1:4
            line1 = sides(i);
            line2 = sides(j);
            A=[cos(line1.angle) sin(line1.angle); cos(line2.angle) sin(line2.angle)];
            B=[line1.rho;line2.rho];
            sol=floor(linsolve(A,B));
            corner = [sol(2), sol(1)];
            if and(and(corner(1) > -tollerance, corner(2) > -tollerance), and(corner(1) < im_size(1)+tollerance, corner(2) < im_size(2)+tollerance))
                there_is = false;
                for n = 1:size(corners, 1)
                    if and(corners(n, 1) == corner(1), corners(n, 2) == corner(2))
                        there_is = true;
                        break;
                    end
                end
                if ~there_is
                    corners = [corners; corner];
                end
            end
        end
    end
    if valid_corners(corners)
        % reorder the corners
        reordered_corners = reorder_corners(corners);
        upper_corner = reordered_corners.upper_corner;
        bottom_corner = reordered_corners.bottom_corner;
        left_corner = reordered_corners.left_corner;
        right_corner = reordered_corners.right_corner;
        top_left_dist = pitagora_dist(upper_corner(1)-left_corner(1),upper_corner(2)-left_corner(2));
        top_right_dist = pitagora_dist(upper_corner(1)-right_corner(1),upper_corner(2)-right_corner(2));
        bottom_left_dist = pitagora_dist(bottom_corner(1)-left_corner(1),bottom_corner(2)-left_corner(2));
        bottom_right_dist = pitagora_dist(bottom_corner(1)-right_corner(1),bottom_corner(2)-right_corner(2));
        if top_left_dist > top_right_dist
            corners = [left_corner; upper_corner; right_corner; bottom_corner];
        else
            corners = [upper_corner; right_corner; bottom_corner; left_corner];
        end
        % create a mask
        d_mask = size(im);
        pos_shape = [flip(upper_corner), flip(right_corner), flip(bottom_corner), flip(left_corner)];
        rgb_mask = zeros(d_mask(1), d_mask(2), 3);
        rgb_mask = insertShape(rgb_mask, 'FilledPolygon', pos_shape, 'Color', 'white', 'Opacity', 1.0);
        bw = rgb2gray(rgb_mask);
        mask = logical(bw);
        % project the box to fill the image rectangle
        %view_corners(im, corners);
        if top_left_dist > top_right_dist
            cropped = stretch_box(im, mask, corners, [min(top_right_dist, bottom_left_dist),min(top_left_dist, bottom_right_dist)]);
        else
            cropped = stretch_box(im, mask, corners, [min(top_left_dist, bottom_right_dist),min(top_right_dist, bottom_left_dist)]);
        end
    else
        cropped = crop_with_mask(im);
    end
    out = cropped;
end