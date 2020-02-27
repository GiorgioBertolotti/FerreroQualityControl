function out=separate_lists(images, labels)
    folder_name = 'cropped_dataset';
    if ~exist(folder_name, 'dir')
        error('Please call crop_dataset() first.');
    else
        nimages = numel(images);
        grids = {};
        grid_labels = {};
        beehives = {};
        beehive_labels = {};
        for n = 1 : nimages
            image = imread([folder_name '/' images{n}]);
            [r,c,~] = size(image);
            centroid_pos = compute_white_centroid(image)./[r, c];
            proportions = c/r;
            % differenciate descriptors based on box type
            if or(proportions > 1.2, centroid_pos(1) <= 0.35)
                grids = [grids; images(n)];
                grid_labels = [grid_labels; labels(n)];
            else
                beehives = [beehives; images(n)];
                beehive_labels = [beehive_labels; labels(n)];
            end
        end
        out.grids = grids;
        out.beehives = beehives;
        out.grid_labels = grid_labels;
        out.beehive_labels = beehive_labels;
    end
end

function out=compute_white_centroid(rgbimage)
    if size(rgbimage,3) ~= 3
        disp("Input image should be rgb");
    else
        % provo le maschere sui canali dei colori dell'immagine
        %{
        R = rgbimage(:,:,1);
        G = rgbimage(:,:,2);
        B = rgbimage(:,:,3);
        ycbcrimage = rgb2ycbcr(rgbimage);
        Y = ycbcrimage(:,:,1);
        CB = ycbcrimage(:,:,2);
        CR = ycbcrimage(:,:,3);
        figure;
        subplot(2,3,1), imhist(R), title("R");
        subplot(2,3,2), imhist(G), title("G");
        subplot(2,3,3), imhist(B), title("B");
        subplot(2,3,4), imhist(Y), title("Y");
        subplot(2,3,5), imhist(CB), title("CB");
        subplot(2,3,6), imhist(CR), title("CR");
        %}
        % estraggo il baricentro della maschera ottenuta filtrando i punti
        % più chiari dell'immagine
        RGB_mask = rgb2gray(equalize_image(rgbimage)) > 220;
        [y, x] = ndgrid(1:size(RGB_mask, 1), 1:size(RGB_mask, 2));
        out = mean([y(logical(RGB_mask)), x(logical(RGB_mask))]);
        %{
        im_centroid = plot_point(rgbimage, floor(centroid));
        figure;
        subplot(1,2,1), imshow(RGB_mask), title("R+G");
        subplot(1,2,2), imshow(im_centroid), title((centroid./size(RGB_mask)));
        %}
    end
end