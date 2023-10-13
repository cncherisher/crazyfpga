%RGB转YCbCr算法
%原始公式：Y0 = R * 0.299 + G * 0.587 + B * 0.114
%扩大256倍后舍去小数点：Y1 = R * 76 + G * 150 + B * 29
%再对Y1右移8位，即Y2= (R * 76 + G * 150 + B * 29) >> 8
%Cb = (-R * 43 -G * 84 + B * 128 + 32678) >>8
%Cr = (R * 128 -G * 107 + B * 20 + 32678) >>8
clear all; close all; clc;
%---------------------------------------------
%Read PC image to Matlab
img1 = imread('./Lenna.jpg');   %读取JPG图像
h = size(img1,1);
w = size(img1,2);
subplot(2,2,1);
imshow(img1);
title('PC RGB image');

%---------------------------------------------
%开始转换
img1 = double(img1);
img_YCbCr = zeros(h,w,3);
for i=1 :h      %再遍历列
    for j=1:w   %先遍历行
        img_YCbCr(i,j,1) = bitshift ((img1(i,j,1) * 76 + img1(i,j,2) * 150 + img1(i,j,3) * 29),-8); %bitshift移位操作,Y通道
        img_YCbCr(i,j,2) = bitshift ((img1(i,j,1) * -43 - img1(i,j,2) * 84 + img1(i,j,3) * 128 + 128 * 256),-8); %bitshift移位操作,Y通道
        img_YCbCr(i,j,3) = bitshift ((img1(i,j,1) * 128 - img1(i,j,2) * 107 - img1(i,j,3) * 20 + 128 * 256),-8); %bitshift移位操作,Y通道
    end
end

%---------------------------------------------
%display Y Cb Cr channel
img_YCbCr = uint8(img_YCbCr);
subplot(2,2,2); imshow(img_YCbCr(:,:,1));   title('Y channel');
subplot(2,2,3); imshow(img_YCbCr(:,:,2));   title('Cb channel');
subplot(2,2,4); imshow(img_YCbCr(:,:,3));   title('Cr channel');

% -------------------------------------------------------------------------
% Generate image Source Data and Target Data
simulate(img1, img_YCbCr);