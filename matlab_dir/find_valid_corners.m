function out=find_valid_corners(im, sides)
    if size(sides, 1) == 4
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
        if size(corners,1) == 4
            reordered_corners = reorder_corners(corners);
            out.corners = reordered_corners.corners;
            out.valid = valid_corners(reordered_corners.corners);
        else
            out.corners = [];
            out.valid = false;
        end
    else
        out.corners = [];
        out.valid = false;
    end
end
