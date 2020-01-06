function out=rotate_poly(poly, center, deg)
    len = length(poly);
    new_poly = [];
    for i=1:len
        if mod(i, 2) ~= 0
            x = poly(i);
            y = poly(i + 1);
            x1 = ((x - center(1)) * cos(deg)) - ((y - center(2)) * sin(deg)) + center(1);
            y1 = ((x - center(1)) * sin(deg)) - ((y - center(2)) * cos(deg)) + center(2);
            new_poly(i) = x1;
            new_poly(i + 1) = y1;
        end
    end
    out = new_poly;
end
