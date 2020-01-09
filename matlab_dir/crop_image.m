function out=crop_image(image)
    % FIRST VERSION
    %{
    ycbcr = rgb2ycbcr(image);
    cr = ycbcr(:,:,3);
    out = edge(cr);

    f = fspecial('average', 4);
    filtered = imfilter(out, f);

    dimens = size(filtered);

    min_i = dimens(1);
    min_j = dimens(2);
    max_i = 1;
    max_j = 1;
    for i=2:dimens(1)-1
        for j=2:dimens(2)-1
            if filtered(i,j) == 1
                tot = 0;
                for n=i-1:i+1
                   for m=j-1:j+1
                       tot = tot + filtered(n,m);
                   end
                end
                if tot > 3
                    if i < min_i
                        min_i = i;
                    end
                    if j < min_j
                        min_j = j;
                    end
                    if i > max_i
                        max_i = i;
                    end
                    if j > max_j
                        max_j = j;
                    end
                end
            end
        end
    end

    mask = zeros(dimens(1), dimens(2));
    for i=min_i:max_i
        for j=min_j:max_j
            mask(i,j) = 1;
        end
    end

    out = image .* mask;
    %}
    
    % SECOND VERSION
    %{
    image_original = image;
    image = imresize(image, 0.25);
    dimens = size(image);
    tsize = floor(dimens(1) / 35);
    tstep = floor(tsize / 2);
    num_clusters = 2;
    out = compute_local_descriptors(image, tsize, tstep, @compute_lbp);
    labels = kmeans(out.descriptors, num_clusters);
    img_labels = reshape(labels, out.nt_rows, out.nt_cols);
    img_labels = imresize(img_labels, [dimens(1), dimens(2)], 'nearest');
    count_occurrence=zeros(num_clusters, 1);
    for i=1:dimens(1)
        for j=1:dimens(2)
            pos = img_labels(i, j);
            count_occurrence(pos) = count_occurrence(pos) + 1;
        end
    end
    max_pos = 1;
    for i=2:num_clusters
        if count_occurrence(i) >count_occurrence(max_pos)
            max_pos = i;
        end
    end
    mask = or(img_labels < max_pos, img_labels > max_pos);
    se = strel('diamond', tsize);
    mask = imdilate(mask, se);
    mask = imfill(mask, 'holes');
    new_mask = zeros(dimens(1), dimens(2));
    new_mask(1:dimens(1)-tstep+1,1:dimens(2)-tstep+1) = mask(tstep:dimens(1),tstep:dimens(2));

    mask_labels_original = bwlabel(new_mask);
    mask_labels = mask_labels_original;
    lab = unique(mask_labels);
    mask_labels = sort(mask_labels);
    occurrences = zeros(size(lab));
    for i = 1:length(lab)
        occurrences(i) = sum(sum(mask_labels == lab(i)));
    end
    [~, indexes] = sort(occurrences, 'descend');
    index = lab(indexes(2));
    new_mask = mask_labels_original == index;
    
    dimens_original = size(image_original);
    mask_original = imresize(new_mask, [dimens_original(1), dimens_original(2)]);
    
    out = im2double(image_original) .* mask_original;
    %}
    
    % THIRD VERSION
    %{
    image_original = image;
    image = imresize(image, 0.25);
    dimens = size(image);
    tsize = floor(dimens(1) / 35);
    tstep = floor(tsize / 2);
    num_clusters = 2;
    out = compute_local_descriptors(image, tsize, tstep, @compute_lbp);
    labels = kmeans(out.descriptors, num_clusters);
    img_labels = reshape(labels, out.nt_rows, out.nt_cols);
    img_labels = imresize(img_labels, [dimens(1), dimens(2)], 'nearest');

    img_labels_original = img_labels;
    lab = unique(img_labels);
    img_labels = sort(img_labels);
    count_occurrence = zeros(size(lab));
    for i = 1:length(lab)
        count_occurrence(i) = sum(sum(img_labels == lab(i)));
    end
    [~, indexes] = sort(count_occurrence, 'descend');
    max_pos = lab(indexes(1));

    mask = img_labels_original ~= max_pos;
    edges = edge(rgb2gray(image));
    se = strel('diamond', tstep);
    edges = imdilate(edges, se);
    mixed_mask = mask + edges;
    mixed_mask = imfill(mixed_mask, 'holes');
    new_mask = zeros(dimens(1), dimens(2));
    new_mask(1:dimens(1)-tstep+1,1:dimens(2)-tstep+1) = mixed_mask(tstep:dimens(1),tstep:dimens(2));

    mask_labels_original = bwlabel(new_mask);
    mask_labels = mask_labels_original;
    lab = unique(mask_labels);
    mask_labels = sort(mask_labels);
    occurrences = zeros(size(lab));
    for i = 1:length(lab)
        occurrences(i) = sum(sum(mask_labels == lab(i)));
    end
    [~, indexes] = sort(occurrences, 'descend');
    index = lab(indexes(2));
    new_mask = mask_labels_original == index;

    dimens_original = size(image_original);
    mask_original = imresize(new_mask, [dimens_original(1), dimens_original(2)]);

    out = im2double(image_original) .* mask_original;
    %}
    
    % FOURTH VERSION
    %{
    im = im2double(image);
    % use a threshold to get a mask of the box
    %R = im(:,:,1);
    %G = im(:,:,2);
    B = im(:,:,3);
    T = 50/255;
    mask = B < T;
    % close the mask
    se = strel("diamond", floor(min(size(mask)) / 70));
    mask_closed = imclose(mask, se);
    % get the 2nd greatest block of pixels (dangerous)
    mask_labels_original = bwlabel(mask_closed);
    mask_labels = mask_labels_original;
    lab = unique(mask_labels);
    mask_labels = sort(mask_labels);
    occurrences = zeros(size(lab));
    for i = 1:length(lab)
        occurrences(i) = sum(sum(mask_labels == lab(i)));
    end
    [~, indexes] = sort(occurrences, 'descend');
    index = lab(indexes(2));
    % get a new mask with only the block of pixels containing the box
    new_mask = mask_labels_original == index;
    new_mask = imfill(new_mask, "holes");
    % get the top, the bottom, the most-left and the most-right points of
    % the mask
    dimens = size(new_mask);
    min_i = [dimens(1), dimens(2)];
    min_j = [dimens(1), dimens(2)];
    max_i = [1, 1];
    max_j = [1, 1];
    for i=1:dimens(1)
        for j=1:dimens(2)
            if new_mask(i,j) == 1
                if i <= min_i(1)
                    min_i = [i, j];
                end
                if j <= min_j(2)
                    min_j = [i, j];
                end
                if i > max_i(1)
                    max_i = [i, j];
                end
                if j > max_j(2)
                    max_j = [i, j];
                end
            end
        end
    end
    % draw a polygon from this 4 points to get a better mask
    pos_shape = [flip(min_i), flip(max_j), flip(max_i), flip(min_j)];
    rgb_mask = zeros(dimens(1), dimens(2), 3);
    rgb_mask = insertShape(rgb_mask, 'FilledPolygon', pos_shape, 'Color', 'white', 'Opacity', 1.0);
    bw = rgb2gray(rgb_mask);
    final_mask = logical(bw);
    % apply the mask on the original image
    crop = im .* final_mask;
    % calculate the longest base and the longes height of the mask
    p1 = [pos_shape(1), pos_shape(2)];
    p2 = [pos_shape(3), pos_shape(4)];
    p3 = [pos_shape(5), pos_shape(6)];
    p4 = [pos_shape(7), pos_shape(8)];
    first_base = pdist([p1(1),p1(2);p2(1),p2(2)],'euclidean');
    second_base = pdist([p3(1),p3(2);p4(1),p4(2)],'euclidean');
    base = max(first_base, second_base);
    first_height = pdist([p1(1),p1(2);p4(1),p4(2)],'euclidean');
    second_height = pdist([p2(1),p2(2);p3(1),p3(2)],'euclidean');
    height = max(first_height, second_height);
    % calculate the inclination of the longest side
    if base > height
        if base == first_base
            x1 = p1(1);
            y1 = p1(2);
            x2 = p2(1);
            y2 = p2(2);
            med_side = [floor(min(x1,x2) + abs((x2-x1)/2)), floor(min(y1,y2) + abs((y2-y1)/2))];
            med_side_min = [floor(min(p3(1),p4(1)) + abs((p4(1)-p3(1))/2)), floor(min(p3(2),p4(2)) + abs((p4(2)-p3(2))/2))];
        else
            x1 = p3(1);
            y1 = p3(2);
            x2 = p4(1);
            y2 = p4(2);
            med_side = [floor(min(x1,x2) + abs((x2-x1)/2)), floor(min(y1,y2) + abs((y2-y1)/2))];
            med_side_min = [floor(min(p1(1),p2(1)) + abs((p2(1)-p1(1))/2)), floor(min(p1(2),p2(2)) + abs((p2(2)-p1(2))/2))];
        end
    else
        if height == first_height
            x1 = p1(1);
            y1 = p1(2);
            x2 = p4(1);
            y2 = p4(2);
            med_side = [floor(min(x1,x2) + abs((x2-x1)/2)), floor(min(y1,y2) + abs((y2-y1)/2))];
            med_side_min = [floor(min(p2(1),p3(1)) + abs((p3(1)-p2(1))/2)), floor(min(p2(2),p3(2)) + abs((p3(2)-p2(2))/2))];
        else
            x1 = p2(1);
            y1 = p2(2);
            x2 = p3(1);
            y2 = p3(2);
            med_side = [floor(min(x1,x2) + abs((x2-x1)/2)), floor(min(y1,y2) + abs((y2-y1)/2))];
            med_side_min = [floor(min(p1(1),p4(1)) + abs((p4(1)-p1(1))/2)), floor(min(p1(2),p4(2)) + abs((p4(2)-p1(2))/2))];
        end
    end
    k = (y2-y1)/(x2-x1);
    q = ((x1*y2)-(x2*y1))/(x1-x2);
    rad = atan(k);
    deg = rad * 180/pi();
    if height > base
        deg = deg + 90;
    end
    % calculate the center of the bounding box of the polygon
    %{
    inv_k = -1/k;
    cx = double(floor(med_side(1) - ((first_base + second_base) / 4)));
    cy = double(floor(inv_k * (cx - med_side(1)) + med_side(2)));
    %}
    % calculate the center of the polygon
    %{
    x1  = [p1(1), p3(1)];
    y1  = [p1(2), p3(2)];
    x2 = [p2(1), p4(1)];
    y2 = [p2(2), p4(2)];
    p1 = polyfit(x1,y1,1);
    p2 = polyfit(x2,y2,1);
    cx = fzero(@(x) polyval(p1-p2,x),3);
    cy = polyval(p1,x_intersect);
    %}
    cx = floor((med_side(1) + med_side_min(1)) / 2);
    cy = floor((med_side(2) + med_side_min(2)) / 2);
    % translate image to the top left corner
    dimens = size(crop);
    center_image = [(double(dimens(2) / 2)), (double(dimens(1) / 2))];
    center_mask = [cx, cy];
    translated = imtranslate(crop,[center_image(1) - center_mask(1), center_image(2) - center_mask(2)]);
    rotated = imrotate(translated, deg, 'crop');
    transl1 = (-double((dimens(2) - base) / 2));
    transl2 = (-double((dimens(1) - height) / 2));
    err_margin = 5;
    transl_err1 = abs(transl1 * err_margin / 100);
    transl_err2 = abs(transl2 * err_margin / 100);
    translated_origin = imtranslate(rotated, [transl1 + transl_err1, transl2 + transl_err2]);
    % crop out the empty parts
    out.image = imcrop(translated_origin, [0, 0, base + transl_err1, height + 2 * transl_err2]);
    out.poly = pos_shape;
    %}
    
    % FIFTH VERSION
    %{
    dimens = size(image);
    tsize = floor(dimens(1) / 30);
    tstep = floor(tsize / 2);
    num_clusters = 2;
    out = compute_local_descriptors(image, tsize, tstep, @compute_lbp);
    labels = kmeans(out.descriptors, num_clusters);
    img_labels = reshape(labels, out.nt_rows, out.nt_cols);
    img_labels = imresize(img_labels, [dimens(1), dimens(2)], 'nearest');
    
    img_labels_original = img_labels;
    lab = unique(img_labels);
    img_labels = sort(img_labels);
    count_occurrence = zeros(size(lab));
    for i = 1:length(lab)
        count_occurrence(i) = sum(sum(img_labels == lab(i)));
    end
    [~, indexes] = sort(count_occurrence, 'descend');
    max_pos = lab(indexes(1));

    mask = img_labels_original ~= max_pos;
    new_mask = zeros(dimens(1), dimens(2));
    new_mask(1:dimens(1)-tstep+1,1:dimens(2)-tstep+1) = mask(tstep:dimens(1),tstep:dimens(2));
    
    mask_labels_original = bwlabel(new_mask);
    mask_labels = mask_labels_original;
    lab = unique(mask_labels);
    mask_labels = sort(mask_labels);
    occurrences = zeros(size(lab));
    for i = 1:length(lab)
        occurrences(i) = sum(sum(mask_labels == lab(i)));
    end
    [~, indexes] = sort(occurrences, 'descend');
    index = lab(indexes(2));
    new_mask = mask_labels_original == index;
    
    % get the top, the bottom, the most-left and the most-right points of
    % the mask
    dimens = size(new_mask);
    min_i = [dimens(1), dimens(2)];
    min_j = [dimens(1), dimens(2)];
    max_i = [1, 1];
    max_j = [1, 1];
    for i=1:dimens(1)
        for j=1:dimens(2)
            if new_mask(i,j) == 1
                if i <= min_i(1)
                    min_i = [i, j];
                end
                if j < min_j(2)
                    min_j = [i, j];
                end
                if i > max_i(1)
                    max_i = [i, j];
                end
                if j >= max_j(2)
                    max_j = [i, j];
                end
            end
        end
    end
    % draw a polygon from this 4 points to get a better mask
    pos_shape = [flip(min_i), flip(max_j), flip(max_i), flip(min_j)];
    rgb_mask = zeros(dimens(1), dimens(2), 3);
    rgb_mask = insertShape(rgb_mask, 'FilledPolygon', pos_shape, 'Color', 'white', 'Opacity', 1.0);
    bw = rgb2gray(rgb_mask);
    final_mask = logical(bw);
    % apply the mask on the original image
    crop = im2double(image) .* final_mask;
    % calculate the longest base and the longes height of the mask
    p1 = [pos_shape(1), pos_shape(2)];
    p2 = [pos_shape(3), pos_shape(4)];
    p3 = [pos_shape(5), pos_shape(6)];
    p4 = [pos_shape(7), pos_shape(8)];
    first_base = pdist([p1(1),p1(2);p2(1),p2(2)],'euclidean');
    second_base = pdist([p3(1),p3(2);p4(1),p4(2)],'euclidean');
    base = max(first_base, second_base);
    first_height = pdist([p1(1),p1(2);p4(1),p4(2)],'euclidean');
    second_height = pdist([p2(1),p2(2);p3(1),p3(2)],'euclidean');
    height = max(first_height, second_height);
    % calculate the inclination of the longest side
    if base > height
        if base == first_base
            x1 = p1(1);
            y1 = p1(2);
            x2 = p2(1);
            y2 = p2(2);
            med_side = [floor(min(x1,x2) + abs((x2-x1)/2)), floor(min(y1,y2) + abs((y2-y1)/2))];
            med_side_min = [floor(min(p3(1),p4(1)) + abs((p4(1)-p3(1))/2)), floor(min(p3(2),p4(2)) + abs((p4(2)-p3(2))/2))];
        else
            x1 = p3(1);
            y1 = p3(2);
            x2 = p4(1);
            y2 = p4(2);
            med_side = [floor(min(x1,x2) + abs((x2-x1)/2)), floor(min(y1,y2) + abs((y2-y1)/2))];
            med_side_min = [floor(min(p1(1),p2(1)) + abs((p2(1)-p1(1))/2)), floor(min(p1(2),p2(2)) + abs((p2(2)-p1(2))/2))];
        end
    else
        if height == first_height
            x1 = p1(1);
            y1 = p1(2);
            x2 = p4(1);
            y2 = p4(2);
            med_side = [floor(min(x1,x2) + abs((x2-x1)/2)), floor(min(y1,y2) + abs((y2-y1)/2))];
            med_side_min = [floor(min(p2(1),p3(1)) + abs((p3(1)-p2(1))/2)), floor(min(p2(2),p3(2)) + abs((p3(2)-p2(2))/2))];
        else
            x1 = p2(1);
            y1 = p2(2);
            x2 = p3(1);
            y2 = p3(2);
            med_side = [floor(min(x1,x2) + abs((x2-x1)/2)), floor(min(y1,y2) + abs((y2-y1)/2))];
            med_side_min = [floor(min(p1(1),p4(1)) + abs((p4(1)-p1(1))/2)), floor(min(p1(2),p4(2)) + abs((p4(2)-p1(2))/2))];
        end
    end
    k = (y2-y1)/(x2-x1);
    q = ((x1*y2)-(x2*y1))/(x1-x2);
    rad = atan(k);
    deg = rad * 180/pi();
    if height > base
        deg = deg + 90;
    end
    % calculate the center of the bounding box of the polygon
    %{
    inv_k = -1/k;
    cx = double(floor(med_side(1) - ((first_base + second_base) / 4)));
    cy = double(floor(inv_k * (cx - med_side(1)) + med_side(2)));
    %}
    % calculate the center of the polygon
    %{
    x1  = [p1(1), p3(1)];
    y1  = [p1(2), p3(2)];
    x2 = [p2(1), p4(1)];
    y2 = [p2(2), p4(2)];
    p1 = polyfit(x1,y1,1);
    p2 = polyfit(x2,y2,1);
    cx = fzero(@(x) polyval(p1-p2,x),3);
    cy = polyval(p1,x_intersect);
    %}
    cx = floor((med_side(1) + med_side_min(1)) / 2);
    cy = floor((med_side(2) + med_side_min(2)) / 2);
    % translate image to the top left corner
    dimens = size(crop);
    center_image = [(double(dimens(2) / 2)), (double(dimens(1) / 2))];
    center_mask = [cx, cy];
    translated = imtranslate(crop,[center_image(1) - center_mask(1), center_image(2) - center_mask(2)]);
    rotated = imrotate(translated, deg, 'crop');
    transl1 = (-double((dimens(2) - base) / 2));
    transl2 = (-double((dimens(1) - height) / 2));
    err_margin = 5;
    transl_err1 = abs(transl1 * err_margin / 100);
    transl_err2 = abs(transl2 * err_margin / 100);
    translated_origin = imtranslate(rotated, [transl1 + transl_err1, transl2 + transl_err2]);
    % crop out the empty parts
    out.image = imcrop(translated_origin, [0, 0, base + transl_err1, height + 2 * transl_err2]);
    out.poly = pos_shape;
    %}
    
    % SIXTH VERSION
    %{
    im = im2double(image);
    % use a threshold to get a mask of the box
    %R = im(:,:,1);
    %G = im(:,:,2);
    B = im(:,:,3);
    T = 35/255;
    mask = B < T;
    % close the mask
    se = strel("diamond", floor(min(size(mask)) / 70));
    mask_closed = imclose(mask, se);
    % get the 2nd greatest block of pixels (dangerous)
    mask_labels_original = bwlabel(mask_closed);
    mask_labels = mask_labels_original;
    lab = unique(mask_labels);
    mask_labels = sort(mask_labels);
    occurrences = zeros(size(lab));
    for i = 1:length(lab)
        occurrences(i) = sum(sum(mask_labels == lab(i)));
    end
    [~, indexes] = sort(occurrences, 'descend');
    index = lab(indexes(2));
    % get a new mask with only the block of pixels containing the box
    new_mask = mask_labels_original == index;
    new_mask = imfill(new_mask, "holes");
    % crop out the rest of the image
    okind = find(new_mask > 0);
    [ii,jj] = ind2sub(size(new_mask), okind);
    ymin = min(ii);
    ymax = max(ii);
    xmin = min(jj);
    xmax = max(jj);
    out.image = imcrop(image, [xmin, ymin, xmax - xmin + 1, ymax - ymin + 1]);
    %}
    
    % SEVENTH VERSION
    im = equalize_image(im2double(image));
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
    % crop out the rest of the image
    okind = find(mask > 0);
    [ii,jj] = ind2sub(size(mask), okind);
    ymin = min(ii);
    ymax = max(ii);
    xmin = min(jj);
    xmax = max(jj);
    cropped = imcrop(image, [xmin, ymin, xmax - xmin + 1, ymax - ymin + 1]);
    cropped_mask = imcrop(mask, [xmin, ymin, xmax - xmin + 1, ymax - ymin + 1]);
    % if necessary rotate the image to get the long side of the box
    % horizontally aligned
    [rows, columns, ~] = size(cropped);
    if rows > columns
        cropped = imrotate(cropped, 90);
        cropped_mask = imrotate(cropped_mask, 90);
        [rows, columns, ~] = size(cropped);
    end
    % get the bounds of the mask
    boundaries = bwboundaries(cropped_mask);
    x = boundaries{1}(:, 2);
    y = boundaries{1}(:, 1);
    % get lines on top side
    top_pt = [];
    for i=1:rows
        for j=1:columns
            if cropped_mask(i, j) == 1
                top_pt = j;
                break;
            end
        end
        if not(isempty(top_pt))
            break;
        end
    end
    side_elements = y < rows/2 & x < top_pt;
    top_side_x = x(side_elements);
    top_side_y = y(side_elements);
    % get lines on bottom side
    bottom_pt = [];
    for i=rows:-1:1
        for j=columns:-1:1
            if cropped_mask(i, j) == 1
                bottom_pt = j;
                break;
            end
        end
        if not(isempty(bottom_pt))
            break;
        end
    end
    side_elements = y > rows/2 & x > bottom_pt;
    bottom_side_x = x(side_elements);
    bottom_side_y = y(side_elements);
    % fit line to get the angle
    top_coeffs = polyfit(top_side_x, top_side_y, 1);
    bottom_coeffs = polyfit(bottom_side_x, bottom_side_y, 1);
    % get the top angle
    mean_slope = mean([top_coeffs(1), bottom_coeffs(1)]);
    angle = atand(mean_slope);
    % rotate the mask and the image to get the top side aligned
    r_mask = imrotate(mask, angle);
    r_im = imrotate(image, angle);
    % crop out all the rest of the image
    okind = find(r_mask > 0);
    [ii,jj] = ind2sub(size(r_mask), okind);
    ymin = min(ii);
    ymax = max(ii);
    xmin = min(jj);
    xmax = max(jj);
    cropped = imcrop(r_im, [xmin, ymin, xmax - xmin + 1, ymax - ymin + 1]);
    [rows, columns, ~] = size(cropped);
    if rows > columns
        cropped = imrotate(cropped, 90);
    end
    out.image = cropped;
end
