function out=plot_point(image, point)
    for n=max(1,point(1)-10):max(1,point(1)+10)
        for m=max(1,point(2)-10):max(1,point(2)+10)
            if size(image, 3) == 3
                image(n,m,1) = 255;
                image(n,m,2) = 0;
                image(n,m,3) = 0;
            else
                image(n,m) = 0.5;
            end
        end
    end
    out = image;
end
