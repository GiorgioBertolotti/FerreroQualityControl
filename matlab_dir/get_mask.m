function out=get_mask(im)
    % use a threshold on CR channel to get a mask of the box
    ycbcr = rgb2ycbcr(im);
    CR = ycbcr(:,:,3);
    T = 100/255;
    mask1 = CR < T;
    % remove salt&pepper on mask
    mask1 = medfilt2(mask1);
    % use a threshold on BLUE channel to get a mask of the box
    B = im(:,:,3);
    T = 30/255;
    mask2 = B < T;
    % remove salt&pepper on mask
    mask2 = medfilt2(mask2, [10, 10]);
    se = strel("diamond", floor(min(size(mask2)) / 100));
    mask2 = imclose(mask2, se);
    % get the largest pixel area
    mask2 = bwareafilt(mask2, 1);
    % mix masks
    mask = or(mask1,mask2);
    % close mask perimeter
    mask = imclose(mask, se);
    % fill mask holes
    mask = imfill(mask, 'holes');
    % get the largest pixel area
    mask = bwareafilt(mask, 1);
    out = mask;
end