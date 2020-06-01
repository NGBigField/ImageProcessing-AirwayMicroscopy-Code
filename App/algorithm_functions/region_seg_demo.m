% Demo of "Region Based Active Contours"
%
% Example:
% seg_demo
%
% Coded by: Shawn Lankton (www.shawnlankton.com)

close all ; clear; clc;
% Paths = Paths(pwd);

% I = imread('airplane.jpg');  %-- load the image
fig = figure();
I = imread("21_B2L_1.tif");
I = imcrop(I);
delete(fig);


fig = figure();
imshow(I);

%% Create mask:
ax = fig.Children;
roi = drawrectangle(ax);
Mask = roi.createMask;
%% 

I = imresize(I,.5);  %-- make image smaller 
Mask = imresize(Mask,.5);  %     for fast computation

subplot(2,2,1); imshow(I); title('Input Image');
subplot(2,2,2); imshow(Mask); title('Initialization');
subplot(2,2,3); title('Segmentation');

seg = region_seg(I, Mask, 1500); %-- Run segmentation

subplot(2,2,4); imshow(seg); title('Global Region-Based Segmentation');


