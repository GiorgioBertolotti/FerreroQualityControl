function plot_corners(image, corners)
    im_copy = im2double(image);
    for i=1:size(corners, 1)
        corner = corners(i,:);
        im_copy = plot_point(im_copy, corner);
    end
    figure(1);
    imshow(im_copy);
end
