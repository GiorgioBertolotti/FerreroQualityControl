function out=find_corners(mask)
    dimens = size(mask);
    corners = [];
    found = 0;
    % i first
    for i=1:dimens(1)
        for j=1:dimens(2)
            if mask(i,j) == 1
                corners = [corners; [i, j]];
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
        for j=1:dimens(2)
            if mask(i,j) == 1
                corners = [corners; [i, j]];
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
                corners = [corners; [i, j]];
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
                corners = [corners; [i, j]];
                found = 1;
                break;
            end
        end
        if found == 1
            break;
        end
    end
    %j first
    found = 0;
    for j=1:dimens(2)
        for i=1:dimens(1)
            if mask(i,j) == 1
                corners = [corners; [i, j]];
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
                corners = [corners; [i, j]];
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
        for i=1:dimens(1)
            if mask(i,j) == 1
                corners = [corners; [i, j]];
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
                corners = [corners; [i, j]];
                found = 1;
                break;
            end
        end
        if found == 1
            break;
        end
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
    out = out.';
    out = flip(out);
end
