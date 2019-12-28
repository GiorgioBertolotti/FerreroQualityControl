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
end
