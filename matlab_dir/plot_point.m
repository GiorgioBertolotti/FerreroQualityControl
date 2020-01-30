function plot_point(image, point)
    image_copy = image;
    for n=max(1,point(1)-10):max(1,point(1)+10)
        for m=max(1,point(2)-10):max(1,point(2)+10)
            if size(image_copy, 3) == 3
                image_copy(n,m,1) = 255;
                image_copy(n,m,2) = 0;
                image_copy(n,m,3) = 0;
            else
                image_copy(n,m) = 0.5;
            end
        end
    end
    imshow(image_copy);
end
