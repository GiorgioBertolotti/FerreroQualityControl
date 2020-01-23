function out=stretch_box(image, mask, corners, new_size)
    corners_prop = [corners(:,1), corners(:,2)];
    p_corners = [0,0; new_size(2),0; new_size(2),new_size(1); 0,new_size(1)];
    tform = maketform('projective', fliplr(corners_prop), p_corners);
    xdata = [1,size(image,2)];
    ydata = [1,size(image,1)];
    [new_cropped, ~, ~] = imtransform(image, tform, 'bicubic', 'XData', xdata,'YData', ydata, 'size', size(image), 'fill', 0);
    [new_mask, ~, ~] = imtransform(mask, tform, 'bicubic', 'XData', xdata,'YData', ydata, 'size', size(mask), 'fill', 0);
    out = crop_rest_mask(new_cropped, new_mask);
end