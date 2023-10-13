%RGBתYCbCr�㷨
%ԭʼ��ʽ��Y0 = R * 0.299 + G * 0.587 + B * 0.114
%����256������ȥС���㣺Y1 = R * 76 + G * 150 + B * 29
%�ٶ�Y1����8λ����Y2= (R * 76 + G * 150 + B * 29) >> 8
%Cb = (-R * 43 -G * 84 + B * 128 + 32678) >>8
%Cr = (R * 128 -G * 107 + B * 20 + 32678) >>8
clear all; close all; clc;
%---------------------------------------------
%Read PC image to Matlab
img1 = imread('./Lenna.jpg');   %��ȡJPGͼ��
h = size(img1,1);
w = size(img1,2);
subplot(2,2,1);
imshow(img1);
title('PC RGB image');

%---------------------------------------------
%��ʼת��
img1 = double(img1);
img_YCbCr = zeros(h,w,3);
for i=1 :h      %�ٱ�����
    for j=1:w   %�ȱ�����
        img_YCbCr(i,j,1) = bitshift ((img1(i,j,1) * 76 + img1(i,j,2) * 150 + img1(i,j,3) * 29),-8); %bitshift��λ����,Yͨ��
        img_YCbCr(i,j,2) = bitshift ((img1(i,j,1) * -43 - img1(i,j,2) * 84 + img1(i,j,3) * 128 + 128 * 256),-8); %bitshift��λ����,Yͨ��
        img_YCbCr(i,j,3) = bitshift ((img1(i,j,1) * 128 - img1(i,j,2) * 107 - img1(i,j,3) * 20 + 128 * 256),-8); %bitshift��λ����,Yͨ��
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