

binary_image = segment_coating_image(original_image);

white_pixels_rel_value = calc_white_pixels_percentage(binary_image);

figure(1);
imshow(binary_image);
title_str = "binary image - " + string(white_pixels_rel_value) + "% white pixels";
title(title_str);

%%
% 
% is_plot = false;
%
%
% %get grey image:
% grey_image = rgb2gray(original_image);
% %Subtract background:
% background_sub_kernel_size = 10;
% grey_image = image_substruct_background(grey_image , background_sub_kernel_size);
% %histogram equalization:
% grey_image = histeq(grey_image);
% 
% totalPixelNum =  size(grey_image,1)* size(grey_image,2);
% 
% [counts,binLocations] = imhist(grey_image);
% 
% binLocationIdx = 0;
% totalCount = 0;
% 
% while totalCount < 0.35*totalPixelNum
%     binLocationIdx = binLocationIdx + 1;
%     currCount = counts(binLocationIdx);
%     totalCount = totalCount + currCount;
% end
% 
% most_dark_grey_level = binLocationIdx;
% 
% %thresholding:
% binary_im = grey_image > most_dark_grey_level;
% 
% % morphological opening on the binary image
% SE = strel('disk',   2  );
% 
% open_binary_im = imopen(binary_im,SE);
% close_binary_im = imclose(binary_im,SE);
% 
% final_binary_image = binary_im;

if is_plot
    figure(1);
    imshow(open_binary_im);
    title_str("opened binary image");

    figure(2);
    imshow(close_binary_im);
    title_str("closed binary image");

    figure(3);
    imshow(binary_im);
    title_str("binary image");

    figure(4);
    imshow(grey_image);
    title_str("grey image");

    figure(5);
    imshow(original_image);
    title_str("original image");

    figure(6);
    subplot(2,2,1);
    imshow(original_image);
    title_str("original image");

    subplot(2,2,2);
    imshow(grey_image);
    title_str("grey image");

    subplot(2,2,3);
    imshow(binary_im);
    title_str("binary image");

    subplot(2,2,4);
    imshow(open_binary_im);
    title_str("open binary image");
end

%% sub functions:
function binary_im = segment_coating_image(original_image)
    %get grey image:
    grey_image = rgb2gray(original_image);
    %Subtract background:
    grey_image = image_substruct_background(grey_image , 4);
    %histogram equalization:
    grey_image = histeq(grey_image);

    totalPixelNum =  size(grey_image,1)* size(grey_image,2);

    [counts,binLocations] = imhist(grey_image);

    binLocationIdx = 0;
    totalCount = 0;

    while totalCount < 0.35*totalPixelNum
        binLocationIdx = binLocationIdx + 1;
        currCount = counts(binLocationIdx);
        totalCount = totalCount + currCount;
    end

    most_dark_grey_level = binLocationIdx;

    %thresholding:
    binary_im = grey_image > most_dark_grey_level;

    % morphological opening on the binary image
    SE = strel('disk',   2  );

    open_binary_im = imopen(binary_im,SE);
    close_binary_im = imclose(binary_im,SE);


end

function without_background =  image_substruct_background(im , disk_radius)
SE = strel('disk',   disk_radius  );
eroded = imerode(im,SE);
without_background = im - eroded;
end

function white_pixels_rel_value = calc_white_pixels_percentage(binary_image)
    totalPixelNum = size(binary_image,1)* size(binary_image,2);
    white_pixels_num = sum(binary_image(:));
    %return the percentage of white pixels in the image (0-100)
    white_pixels_rel_value = (white_pixels_num/totalPixelNum)*100;
end