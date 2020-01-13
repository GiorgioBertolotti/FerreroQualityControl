function view_corners(image, corners)
    im_copy = im2double(image);
    for i=1:size(corners, 1)
        corner = corners(i,:);
        for n=max(1,corner(1)-10):max(1,corner(1)+10)
            for m=max(1,corner(2)-10):max(1,corner(2)+10)
                if size(im_copy, 3) == 3
                    im_copy(n,m,1) = 255;
                    im_copy(n,m,2) = 0;
                    im_copy(n,m,3) = 0;
                else
                    im_copy(n,m) = 0.5;
                end
            end
        end
    end
    figure(1);
    imshow(im_copy);
end
