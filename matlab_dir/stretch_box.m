function out=stretch_box(image, mask, corners, new_size)
    d_mask = size(mask);
    corners_prop = [corners(:,1)./d_mask(1), corners(:,2)./d_mask(2)];
    new_size_prop = [new_size(1)/d_mask(1), new_size(2)/d_mask(2)];
    p_corners = [0,0; new_size_prop(2),0; new_size_prop(2),new_size_prop(1); 0,new_size_prop(1)];
    tform = maketform('projective', fliplr(corners_prop), p_corners);
    udata = [0 1];  vdata = [0 1];
    [new_cropped, ~, ~] = imtransform(image, tform, 'bicubic', 'udata', udata, 'vdata', vdata, 'size', size(image), 'fill', 0);
    [new_mask, ~, ~] = imtransform(mask, tform, 'bicubic', 'udata', udata, 'vdata', vdata, 'size', size(mask), 'fill', 0);
    out = crop_rest_mask(new_cropped, new_mask);
end
