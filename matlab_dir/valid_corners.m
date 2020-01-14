function out=valid_corners(corners)
    if length(corners) ~= 4
        out = false;
    else
        len_a = pitagora_dist(corners(1,1)-corners(2,1),corners(1,2)-corners(2,2));
        len_b = pitagora_dist(corners(1,1)-corners(4,1),corners(1,2)-corners(4,2));
        len_c = pitagora_dist(corners(3,1)-corners(4,1),corners(3,2)-corners(4,2));
        len_d = pitagora_dist(corners(3,1)-corners(2,1),corners(3,2)-corners(2,2));
        if or(min(len_a,len_c)<0.5*max(len_a,len_c),min(len_b,len_d)<0.5*max(len_b,len_d))
            out = false;
        else
            out = true;
        end
    end
end
