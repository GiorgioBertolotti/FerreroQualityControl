function out=crop_image(image)
    im = equalize_image(im2double(image));
    sides = find_sides(im);
    result = find_valid_corners(im, sides);
    if result.valid == true
        cropped = crop_with_corners(im, result.corners);
    else
        sides = find_sides_alt(im);
        result = find_valid_corners(im, sides);
        if result.valid == true
            cropped = crop_with_corners(im, result.corners);
        else
            cropped = crop_with_mask(im);
        end
    end
    % rotate the image in landscape
    [rows, columns, ~] = size(cropped);
    if rows > columns
        cropped = imrotate(cropped, 90);
    end
    % flip up/down the image if the white ferreros are on the bottom
    [rows, ~, ~] = size(cropped);
    bw = rgb2gray(cropped);
    mask = bw > 0.5;
    bottom_half_count = sum(sum(mask(floor(rows/2):rows, :)));
    top_half_count = sum(sum(mask(1:floor(rows/2), :)));
    if bottom_half_count > top_half_count
        cropped = flipud(cropped);
    end
    out.image = cropped;
end
