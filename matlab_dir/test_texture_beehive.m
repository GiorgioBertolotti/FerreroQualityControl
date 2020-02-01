I_nv = imread("cropped_dataset/061.jpg");
I_v = imread("cropped_dataset/017.jpg");

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