function out=reorder_corners(corners)
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
    out.upper_corner = upper_corner;
    out.bottom_corner = bottom_corner;
    out.left_corner = left_corner;
    out.right_corner = right_corner;
    top_left_dist = pitagora_dist(upper_corner(1)-left_corner(1),upper_corner(2)-left_corner(2));
    top_right_dist = pitagora_dist(upper_corner(1)-right_corner(1),upper_corner(2)-right_corner(2));
    if top_left_dist > top_right_dist
        out.corners = [left_corner; upper_corner; right_corner; bottom_corner];
    else
        out.corners = [upper_corner; right_corner; bottom_corner; left_corner];
    end
end