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
        RGB_mask = rgb2gray(rgbimage) > 220;
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
