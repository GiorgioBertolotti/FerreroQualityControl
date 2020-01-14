I1 = imread('dataset/04.jpg');
im = equalize_image(im2double(I1));
out = find_sides(im);
view_sides(I1, out);