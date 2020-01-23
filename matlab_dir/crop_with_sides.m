function out=crop_with_sides(im, sides)
    % find corners using lines intersection
    %view_sides(im, sides);
    corners = [];
    im_size = size(im);
    tollerance = max(floor([im_size(1)/10, im_size(2)/10]));
    for i = 1:3
        for j = 1:4
            if i ~= j
                line1 = sides(i);
                x1 = line1.point1(2); x2=line1.point2(2);
                y1 = line1.point1(1); y2=line1.point2(1);
                line2 = sides(j);
                x3 = line2.point1(2); x4=line2.point2(2);
                y3 = line2.point1(1); y4=line2.point2(1);
                %{
                % uncomment to plot lines
                imshow(im), axis on, hold on;
                xy = [line1.point1; line1.point2];
                plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
                plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
                plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
                xy = [line2.point1; line2.point2];
                plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
                plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
                plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
                %}
                corner = floor([x1*y2-x2*y1,x3*y4-x4*y3]/[y2-y1,y4-y3;-(x2-x1),-(x4-x3)]);
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