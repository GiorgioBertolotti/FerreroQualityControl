function out=check_valid_beehive_image(image)
    hsv = rgb2hsv(image);
    s = hsv(:,:,2);
    ms = s < 0.35;
    fms = medfilt2(ms);
    ffms = imfill(fms, 'holes');
    %{
    ycbcr = rgb2ycbcr(image);
    cb = ycbcr(:,:,2);
    mcb = cb > 105;
    fmcb = medfilt2(mcb);

    b = image(:,:,3);
    mb = b > 120;
    fmb = medfilt2(mb);
    %}
    mask = ffms;
    cc = bwconncomp(mask);
    stats = regionprops(cc, 'Area', 'Perimeter');
    for i = 1: cc.NumObjects
       circ = (4*pi*stats(i).Area)/((stats(i).Perimeter)^2);
       if or(circ < 0.2, circ > 1.1)
           mask(cc.PixelIdxList{i}) = 0;
           stats(i).Area = 0;
       end
       stats(i).PixelIdxList = cc.PixelIdxList{i};
       stats(i).Circularity = circ;
    end

    T = struct2table(stats);
    sortedT = sortrows(T, 'Area', {'descend'});
    stats = table2struct(sortedT);

    for i = 25:size(stats)
        for pixelIdx = stats(i).PixelIdxList
            mask(pixelIdx) = 0;
        end
    end

    image_area = (size(image, 1) * size(image, 2));
    valid = 1;
    for i = 1:min(24, size(stats))
        area_perc = stats(i).Area / image_area;
        if area_perc < 0.0008
            valid = 0;
            for pixelIdx = stats(i).PixelIdxList
                mask(pixelIdx) = 0;
            end
        end
    end
    
    image_copy = image;

    labeled = bwlabel(mask);

    left_most_point = find_left_most_point(mask);
    right_most_point = find_right_most_point(mask);
    top_most_point = find_top_most_point(mask);
    bottom_most_point = find_bottom_most_point(mask);

    r = image_copy(:,:,1);
    mr = r < 40;
    fmr = medfilt2(mr);
    ffmr = imfill(fmr, 'holes');
    left_most_point2 = find_left_most_point(ffmr);
    right_most_point2 = find_right_most_point(ffmr);
    top_most_point2 = find_top_most_point(ffmr);
    bottom_most_point2 = find_bottom_most_point(ffmr);

    start_pt = [min(top_most_point(1),top_most_point2(1)),min(left_most_point(2),left_most_point2(2))];
    end_pt = [max(bottom_most_point(1),bottom_most_point2(1)),max(right_most_point(2),right_most_point2(2))];

    image_copy = check_external_ring(image_copy, labeled, start_pt, end_pt);
    image_copy = check_middle_ring(image_copy, labeled, start_pt, end_pt);
    image_copy = check_internal_ring(image_copy, labeled, start_pt, end_pt);
    
    out.image = image_copy;
    out.valid = valid;
end

function out=check_internal_ring(image, labeled, start_pt, end_pt)
    w = end_pt(2) - start_pt(2);
    h = end_pt(1) - start_pt(1);
    candy_size = [floor(h/5), floor(w/5)];
    start_pt = [start_pt(1) + (candy_size(1)*2) - floor(candy_size(1)*5/10), start_pt(2) + (candy_size(2)*2) - floor(candy_size(2)*5/10)];
    % ext row 1
    x = start_pt(2);
    y = start_pt(1);
    for i=1:2
        middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
        circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
        tmp_mask = zeros(size(labeled));
        tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
        tmp_mask = logical(rgb2gray(tmp_mask));
        count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
        if count == 0
            image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
        end
        x = x + candy_size(2);
    end
    % ext row 3
    x = start_pt(2);
    y = start_pt(1) + candy_size(1);
    for i=1:2
        middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
        circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
        tmp_mask = zeros(size(labeled));
        tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
        tmp_mask = logical(rgb2gray(tmp_mask));
        count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
        if count == 0
            image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
        end
        x = x + candy_size(2);
    end
    out = image;
end

function out=check_middle_ring(image, labeled, start_pt, end_pt)
    w = end_pt(2) - start_pt(2);
    h = end_pt(1) - start_pt(1);
    candy_size = [floor(h/5), floor(w/5)];
    start_pt = [start_pt(1) + candy_size(1) - floor(candy_size(1)*2/10), start_pt(2) + candy_size(2) - floor(candy_size(2)*2/10)];
    end_pt = [end_pt(1) - candy_size(1) + floor(candy_size(1)*2/10), end_pt(2) - candy_size(2) + floor(candy_size(2)*2/10)];
    spacing_h = floor(candy_size(2) / 4);
    spacing_v = floor(candy_size(1) / 4);
    % ext row 1
    x = start_pt(2);
    y = start_pt(1);
    for i=1:3
        middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
        circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
        tmp_mask = zeros(size(labeled));
        tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
        tmp_mask = logical(rgb2gray(tmp_mask));
        count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
        if count == 0
            image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
        end
        x = x + candy_size(2) + spacing_h;
    end
    % ext row 2
    x = start_pt(2);
    y = start_pt(1) + candy_size(1) + spacing_v;
    middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
    circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
    tmp_mask = zeros(size(labeled));
    tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
    tmp_mask = logical(rgb2gray(tmp_mask));
    count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
    if count == 0
        image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
    end
    x = end_pt(2) - candy_size(2);
    y = start_pt(1) + candy_size(1) + spacing_v;
    middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
    circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
    tmp_mask = zeros(size(labeled));
    tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
    tmp_mask = logical(rgb2gray(tmp_mask));
    count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
    if count == 0
        image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
    end
    % ext row 3
    x = start_pt(2);
    y = start_pt(1) + (candy_size(1) * 2) + (spacing_v * 2);
    for i=1:3
        middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
        circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
        tmp_mask = zeros(size(labeled));
        tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
        tmp_mask = logical(rgb2gray(tmp_mask));
        count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
        if count == 0
            image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
        end
        x = x + candy_size(2) + spacing_h;
    end
    out = image;
end

function out=check_external_ring(image, labeled, start_pt, end_pt)
    w = end_pt(2) - start_pt(2);
    h = end_pt(1) - start_pt(1);
    candy_size = [floor(h/5), floor(w/5)];
    spacing_h = floor(candy_size(2) / 3);
    spacing_v = floor(candy_size(1) / 3);
    % ext row 1
    x = start_pt(2);
    y = start_pt(1);
    for i=1:4
        middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
        circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
        tmp_mask = zeros(size(labeled));
        tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
        tmp_mask = logical(rgb2gray(tmp_mask));
        count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
        if count == 0
            image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
        end
        x = x + candy_size(2) + spacing_h;
    end
    % ext row 2
    x = start_pt(2);
    y = start_pt(1) + candy_size(1) + spacing_v;
    middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
    circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
    tmp_mask = zeros(size(labeled));
    tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
    tmp_mask = logical(rgb2gray(tmp_mask));
    count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
    if count == 0
        image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
    end
    x = end_pt(2) - candy_size(2);
    y = start_pt(1) + candy_size(1) + spacing_v;
    middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
    circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
    tmp_mask = zeros(size(labeled));
    tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
    tmp_mask = logical(rgb2gray(tmp_mask));
    count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
    if count == 0
        image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
    end
    % ext row 3
    x = start_pt(2);
    y = start_pt(1) + (candy_size(1) * 2) + (spacing_v * 2);
    middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
    circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
    tmp_mask = zeros(size(labeled));
    tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
    tmp_mask = logical(rgb2gray(tmp_mask));
    count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
    if count == 0
        image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
    end
    x = end_pt(2) - candy_size(2);
    y = start_pt(1) + (candy_size(1) * 2) + (spacing_v * 2);
    middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
    circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
    tmp_mask = zeros(size(labeled));
    tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
    tmp_mask = logical(rgb2gray(tmp_mask));
    count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
    if count == 0
        image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
    end
    % ext row 4
    x = start_pt(2);
    y = start_pt(1) + (candy_size(1) * 3) + (spacing_v * 3);
    for i=1:4
        middle_point = [y + floor(candy_size(1)/2), x + floor(candy_size(2)/2)];
        circle_props = [middle_point(2), middle_point(1), floor(max(candy_size)/2)];
        tmp_mask = zeros(size(labeled));
        tmp_mask = insertShape(tmp_mask,'FilledCircle',circle_props,'Color','white');
        tmp_mask = logical(rgb2gray(tmp_mask));
        count = sum(sum(and(tmp_mask == 1, labeled ~= 0)));
        if count == 0
            image = insertShape(image,'Circle',circle_props,'LineWidth',5,'Color','red');
        end
        x = x + candy_size(2) + spacing_h;
    end
    out = image;
end

function out=find_left_most_point(mask)
    pt = [];
    for i = 1:size(mask, 2)
        for j = 1:size(mask, 1)
            if mask(j,i) == 1
                pt = [j,i];
                break;
            end
        end
        if ~isempty(pt)
            break;
        end
    end
    out = pt;
end

function out=find_right_most_point(mask)
    pt = [];
    for i = size(mask, 2):-1:1
        for j = 1:size(mask, 1)
            if mask(j,i) == 1
                pt = [j,i];
                break;
            end
        end
        if ~isempty(pt)
            break;
        end
    end
    out = pt;
end

function out=find_top_most_point(mask)
    pt = [];
    for i = 1:size(mask, 1)
        for j = 1:size(mask, 2)
            if mask(i,j) == 1
                pt = [i,j];
                break;
            end
        end
        if ~isempty(pt)
            break;
        end
    end
    out = pt;
end

function out=find_bottom_most_point(mask)
    pt = [];
    for i = size(mask, 1):-1:1
        for j = 1:size(mask, 2)
            if mask(i,j) == 1
                pt = [i,j];
                break;
            end
        end
        if ~isempty(pt)
            break;
        end
    end
    out = pt;
end