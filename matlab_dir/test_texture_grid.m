I_nv = imread("cropped_dataset/048.jpg");
I_v = imread("cropped_dataset/01.jpg");

bw = rgb2gray(I_v);

figure(1);
subplot(1,2,1);
imshow(bw);
subplot(1,2,2);
imhist(bw);

ycbcr = rgb2ycbcr(I_v);

y = ycbcr(:,:,1);
figure(2);
subplot(1,2,1);
imshow(y);
subplot(1,2,2);
imhist(y);

%interessante
cb = ycbcr(:,:,2);
figure(3);
subplot(1,2,1);
imshow(cb);
subplot(1,2,2);
imhist(cb);

cr = ycbcr(:,:,3);
figure(4);
subplot(1,2,1);
imshow(cr);
subplot(1,2,2);
imhist(cr);

hsv = rgb2hsv(I_v);

h = hsv(:,:,1);
figure(5);
subplot(1,2,1);
imshow(h);
subplot(1,2,2);
imhist(h);

s = hsv(:,:,2);
figure(6);
subplot(1,2,1);
imshow(s);
subplot(1,2,2);
imhist(s);

v = hsv(:,:,3);
figure(7);
subplot(1,2,1);
imshow(v);
subplot(1,2,2);
imhist(v);