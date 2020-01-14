function out=stretch_box(image, mask, corners)
    d_mask = size(mask);
    corners = [corners(:,1)./d_mask(1), corners(:,2)./d_mask(2)];
    p_corners = [0,0; 1,0; 1,1; 0,1];
    tform = maketform('projective', fliplr(corners), p_corners);
    udata = [0 1];  vdata = [0 1];
    [new_cropped, ~, ~] = imtransform(image, tform, 'bicubic', 'udata', udata, 'vdata', vdata, 'size', size(image), 'fill', 0);
    [new_mask, ~, ~] = imtransform(mask, tform, 'bicubic', 'udata', udata, 'vdata', vdata, 'size', size(mask), 'fill', 0);
    out = crop_rest_mask(new_cropped, new_mask);
end
