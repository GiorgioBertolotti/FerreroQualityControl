I_nv = imread("cropped_dataset/061.jpg");
I_v = imread("cropped_dataset/057.jpg");

se = strel('diamond', 4);

hsv = rgb2hsv(I_v);
s = hsv(:,:,2);
ms = s < 0.3;
fms = medfilt2(ms);
ffms = imfill(fms, 'holes');
cffms = imclose(ffms, se);

ycbcr = rgb2ycbcr(I_v);
y = ycbcr(:,:,1);
my = y < 105;
fmy = medfilt2(my);
cb = ycbcr(:,:,2);
mcb = cb > 105;
fmcb = medfilt2(mcb);

b = I_v(:,:,3);
mb = b > 120;
fmb = medfilt2(mb);

r = I_v(:,:,1);
mr = r < 50;
fmr = medfilt2(mr);
ffmr = imfill(fmr, 'holes');
cffmr = imdilate(ffmr, se);

mask = and(ffms==1,cffmr==0);
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

image_area = (size(I_v, 1) * size(I_v, 2));
valid = 1;
for i = 1:24
    area_perc = stats(i).Area / image_area;
    if area_perc < 0.0008
        valid = 0;
        for pixelIdx = stats(i).PixelIdxList
            mask(pixelIdx) = 0;
        end
    end
end

labeled = bwlabel(mask);

left_most_point = find_left_most_point(mask);
right_most_point = find_right_most_point(mask);
top_most_point = find_top_most_point(mask);
bottom_most_point = find_bottom_most_point(mask);

left_most_point2 = find_left_most_point(ffmr);
right_most_point2 = find_right_most_point(ffmr);
top_most_point2 = find_top_most_point(ffmr);
bottom_most_point2 = find_bottom_most_point(ffmr);

start_pt = [min(top_most_point(1),top_most_point2(1)),min(left_most_point(2),left_most_point2(2))];
end_pt = [max(bottom_most_point(1),bottom_most_point2(1)),max(right_most_point(2),right_most_point2(2))];

I_v = check_external_candies(I_v, labeled, start_pt, end_pt);
I_v = check_middle_candies(I_v, labeled, start_pt, end_pt);
I_v = check_internal_candies(I_v, labeled, start_pt, end_pt);

figure; imshow(I_v);

function out=check_internal_candies(image, labeled, start_pt, end_pt)
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

function out=check_middle_candies(image, labeled, start_pt, end_pt)
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

function out=check_external_candies(image, labeled, start_pt, end_pt)
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

function out=find_missing_component(labeled, start_pt, end_pt, counter)
    min_x_side_counter = [11, 5, 2, 1];
    min_x_side = min_x_side_counter(counter);
    middle_h = floor((start_pt(2) + end_pt(2)) / 2);
    middle_v = floor((start_pt(1) + end_pt(1)) / 2);
    if mod(counter,2) == 0
        first_labels = get_labels(labeled, start_pt, [middle_v, end_pt(2)]);
        second_labels = get_labels(labeled, [middle_v, start_pt(2)], end_pt);
    else
        first_labels = get_labels(labeled, start_pt, [end_pt(1), middle_h]);
        second_labels = get_labels(labeled, [start_pt(1), middle_h], end_pt);
    end
    val = intersect(first_labels, second_labels);
    for i = 1:length(val)
        first_labels = first_labels(first_labels~=val(i));
        second_labels = second_labels(second_labels~=val(i));
    end
    coords = [];
    if length(first_labels) < min_x_side
        if isempty(first_labels)
            if mod(counter,2) == 0
                coords = [coords; [floor((start_pt(1) + middle_h) / 2), middle_h]];
            else
                coords = [coords; [middle_v, floor((start_pt(2) + middle_h) / 2)]];
            end
        else
            if mod(counter,2) == 0
                coords = [coords; find_missing_component(labeled, start_pt, [middle_v, end_pt(2)], counter + 1)];
            else
                coords = [coords; find_missing_component(labeled, start_pt, [end_pt(1), middle_h], counter + 1)];
            end
        end
    end
    if length(second_labels) < min_x_side
        if isempty(second_labels)
            if mod(counter,2) == 0
                coords = [coords; [floor((end_pt(1) + middle_h) / 2), middle_h]];
            else
                coords = [coords; [middle_v, floor((end_pt(2) + middle_h) / 2)]];
            end
        else
            if mod(counter,2) == 0
                coords = [coords; find_missing_component(labeled, [middle_v, start_pt(2)], end_pt, counter + 1)];
            else
                coords = [coords; find_missing_component(labeled, [start_pt(1), middle_h], end_pt, counter + 1)];
            end
        end
    end
    out = coords;
end

function out=get_labels(labeled, start_pt, end_pt)
    labels = [];
    for y=start_pt(1):end_pt(1)
        for x=start_pt(2):end_pt(2)
            if labeled(y,x) ~= 0
                labels = [labels, labeled(y,x)];
            end
        end
    end
    out = unique(labels);
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