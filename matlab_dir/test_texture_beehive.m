I_nv = imread("cropped_dataset/061.jpg");
I_v = imread("cropped_dataset/017.jpg");

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

mh = and(h>0.5,h<0.55);
bh = imbinarize(h); %non per forza così
figure(8);
subplot(1,2,1);
imshow(mh);
subplot(1,2,2);
imshow(bh);

ms = and(s~=0,s<0.1);
figure(9);
imshow(ms);

fms = medfilt2(ms);
ffms = imfill(fms, 'holes');
figure(10);
subplot(1,2,1);
imshow(fms);
subplot(1,2,2);
imshow(ffms);

%{
I_nv = rgb2gray(I_nv);
E_nv = entropyfilt(I_nv);
Eim_nv = rescale(E_nv);
%figure(2)
%imshow(Eim_nv);
BW1_nv = imbinarize(Eim_nv, 0.8);
%figure(3);
%imshow(BW1_nv);
BWao_nv = bwareaopen(BW1_nv,2000);
%figure(4);
%imshow(BWao_nv);
nhood = true(9);
closeBWao_nv = imclose(BWao_nv,nhood);
figure(5);
imshow(closeBWao_nv);
%}
%{
I_v = rgb2gray(I_v);
E_v = entropyfilt(I_v);
Eim_v = rescale(E_v);
figure(6)
imshow(Eim_v);
BW1_v = imbinarize(Eim_v, 0.8);
figure(7);
imshow(BW1_v);
BWao_v = bwareaopen(BW1_v,2000);
figure(10);
imshow(BWao_v);
nhood = true(9);
closeBWao_v = imclose(BWao_v,nhood);
figure(11);
imshow(closeBWao_v);
%}