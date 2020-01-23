function out=crop_with_sides(im, sides)
    % find corners using lines intersection
    %view_sides(im, sides);
    corners = [];
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
                if and(and(corner(1) > 0, corner(2) > 0), and(corner(1) < size(im, 1) + 200, corner(2) < size(im, 2) + 200))
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
        upper_corner = corners(1,:);
        bottom_corner = corners(1,:);
        left_corner = corners(1,:);
        right_corner = corners(1,:);
        for i = 2:4
            if corners(i,1) < upper_corner(1)
                upper_corner = corners(i,:);
            end
            if corners(i,1) > bottom_corner(1)
                bottom_corner = corners(i,:);
            end
            if corners(i,2) < left_corner(2)
                left_corner = corners(i,:);
            end
            if corners(i,2) > right_corner(2)
                right_corner = corners(i,:);
            end
        end
        % when there are points with the same coordinates we have to find
        % if there's one that has not been picked up for the projection
        pt_to_fix = [];
        for i = 1:4
            if and(and(sum(corners(i,:)~=upper_corner) > 0,sum(corners(i,:)~=bottom_corner) > 0),and(sum(corners(i,:)~=left_corner) > 0,sum(corners(i,:)~=right_corner) > 0))
                pt_to_fix = corners(i,:);
            end
        end
        if ~isempty(pt_to_fix)
            if upper_corner == right_corner
                if pt_to_fix(1) < upper_corner(1)
                    upper_corner = pt_to_fix;
                else
                    right_corner = pt_to_fix;
                end
            end
            if upper_corner == left_corner
                if pt_to_fix(1) < upper_corner(1)
                    upper_corner = pt_to_fix;
                else
                    left_corner = pt_to_fix;
                end
            end
            if bottom_corner == right_corner
                if pt_to_fix(1) < bottom_corner(1)
                    right_corner = pt_to_fix;
                else
                    bottom_corner = pt_to_fix;
                end
            end
            if bottom_corner == left_corner
                if pt_to_fix(1) < bottom_corner(1)
                    left_corner = pt_to_fix;
                else
                    bottom_corner = pt_to_fix;
                end
            end
        end
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