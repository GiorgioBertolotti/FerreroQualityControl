function out=find_mask_corners(mask)
    dimens = size(mask);
    found = 0;
    % upper corners
    upper_corners = [];
    for i=1:dimens(1)
        for j=1:dimens(2)
            if mask(i,j) == 1
                upper_corners = [upper_corners; [i, j]];
                found = 1;
                break;
            end
        end
        if found == 1
            break;
        end
    end
    found = 0;
    for i=1:dimens(1)
        for j=dimens(2):-1:1
            if mask(i,j) == 1
                upper_corners = [upper_corners; [i, j]];
                found = 1;
                break;
            end
        end
        if found == 1
            break;
        end
    end
    found = 0;
    % right-most corners
    right_corners = [];
    for j=dimens(2):-1:1
        for i=1:dimens(1)
            if mask(i,j) == 1
                right_corners = [right_corners; [i, j]];
                found = 1;
                break;
            end
        end
        if found == 1
            break;
        end
    end
    found = 0;
    for j=dimens(2):-1:1
        for i=dimens(1):-1:1
            if mask(i,j) == 1
                right_corners = [right_corners; [i, j]];
                found = 1;
                break;
            end
        end
        if found == 1
            break;
        end
    end
    found = 0;
    % left-most corners
    left_corners = [];
    for j=1:dimens(2)
        for i=1:dimens(1)
            if mask(i,j) == 1
                left_corners = [left_corners; [i, j]];
                found = 1;
                break;
            end
        end
        if found == 1
            break;
        end
    end
    found = 0;
    for j=1:dimens(2)
        for i=dimens(1):-1:1
            if mask(i,j) == 1
                left_corners = [left_corners; [i, j]];
                found = 1;
                break;
            end
        end
        if found == 1
            break;
        end
    end
    found = 0;
    % bottom corners
    bottom_corners = [];
    for i=dimens(1):-1:1
        for j=1:dimens(2)
            if mask(i,j) == 1
                bottom_corners = [bottom_corners; [i, j]];
                found = 1;
                break;
            end
        end
        if found == 1
            break;
        end
    end
    found = 0;
    for i=dimens(1):-1:1
        for j=dimens(2):-1:1
            if mask(i,j) == 1
                bottom_corners = [bottom_corners; [i, j]];
                found = 1;
                break;
            end
        end
        if found == 1
            break;
        end
    end
    % distances between top-left and top-right
    pt_top_l = min(upper_corners);
    pt_top_r = max(upper_corners);
    pt_left = min(left_corners);
    pt_right = min(right_corners);
    top_left_dist = pitagora_dist(pt_top_l(1)-pt_left(1),pt_top_l(2)-pt_left(2));
    top_right_dist = pitagora_dist(pt_top_r(1)-pt_right(1),pt_top_r(2)-pt_right(2));
    % uniquify getting the most external points
    if top_left_dist > top_right_dist
        corners = [pt_left; pt_top_l; max(right_corners); max(bottom_corners)];
    else
        corners = [pt_top_r; min(right_corners); min(bottom_corners); max(left_corners)];
    end
    % uniquify
    out = [];
    for i=1:size(corners, 1)
        found = 0;
        for j=1:size(out, 1)
            if sum(corners(i, :) == out(j, :)) > 0
                found = 1;
                break;
            end
        end
        if found == 0
            out = [out; corners(i, :)];
        end
    end
end