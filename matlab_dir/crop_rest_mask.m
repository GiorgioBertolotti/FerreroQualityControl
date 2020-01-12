function out=crop_rest_mask(image, mask)
    okind = find(mask > 0);
    [ii,jj] = ind2sub(size(mask), okind);
    ymin = min(ii);
    ymax = max(ii);
    xmin = min(jj);
    xmax = max(jj);
    out = imcrop(image, [xmin + 1, ymin + 1, xmax - xmin - 1, ymax - ymin - 1]);
end
