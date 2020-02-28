I_nv = imread("cropped_dataset/061.jpg");
I_v = imread("cropped_dataset/059.jpg");

hsv = rgb2hsv(I_v);
s = hsv(:,:,2);
ms = s < 0.35;
fms = medfilt2(ms);
ffms = imfill(fms, 'holes');

ycbcr = rgb2ycbcr(I_v);
cb = ycbcr(:,:,2);
mcb = cb > 105;
fmcb = medfilt2(mcb);

b = I_v(:,:,3);
mb = b > 120;
fmb = medfilt2(mb);

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

image_area = (size(I_v, 1) * size(I_v, 2));
valid = 1;
for i = 1:24
    area_perc = stats(i).Area / image_area;
    if area_perc < 0.001
        valid = 0;
        for pixelIdx = stats(i).PixelIdxList
            mask(pixelIdx) = 0;
        end
    end
end

%{
r = I_v(:,:,1);
figure(1);
subplot(1,2,1);
imshow(r);
subplot(1,2,2);
imhist(r);

g = I_v(:,:,2);
figure(2);
subplot(1,2,1);
imshow(g);
subplot(1,2,2);
imhist(g);

b = I_v(:,:,3);
figure(3);
subplot(1,2,1);
imshow(b);
subplot(1,2,2);
imhist(b);

ycbcr = rgb2ycbcr(I_v);
%{
y = ycbcr(:,:,1);
figure(4);
subplot(1,2,1);
imshow(y);
subplot(1,2,2);
imhist(y);
%}

cb = ycbcr(:,:,2);
figure(5);
subplot(1,2,1);
imshow(cb);
subplot(1,2,2);
imhist(cb);

cr = ycbcr(:,:,3);
figure(6);
subplot(1,2,1);
imshow(cr);
subplot(1,2,2);
imhist(cr);

hsv = rgb2hsv(I_v);

h = hsv(:,:,3);
figure(7);
subplot(1,2,1);
imshow(h);
subplot(1,2,2);
imhist(h);

s = hsv(:,:,2);
figure(8);
subplot(1,2,1);
imshow(s);
subplot(1,2,2);
imhist(s);
%{
v = hsv(:,:,3);
figure(9);
subplot(1,2,1);
imshow(v);
subplot(1,2,2);
imhist(v);
%}
%}
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