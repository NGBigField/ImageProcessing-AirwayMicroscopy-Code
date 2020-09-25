function [cell_coverage , binary_image] = calc_image_cell_coverage(Im)
%[cell_coverage , binary_image] = calc_image_cell_coverage(Im)
% Calculates the Cell Coverage of a dead-babies-lugns-iamge.
% 
% Input: Colored Image
%
% Outputs:
%    * cell_coverage (double): 0 to 100;
%    * binary_image (BW Image Matrix): what was segmented by our algorithms.
%

binary_image = segment_coating_image(Im);
cell_coverage = calc_white_pixels_percentage(binary_image);


end % function calc_image_cell_coverage


%% sub functions:
function binary_im = segment_coating_image(original_image)
    %get grey image:
    grey_image = rgb2gray(original_image);
    %Subtract background:
    grey_image = image_substruct_background(grey_image , 4);
    %histogram equalization:
    grey_image = histeq(grey_image);

    totalPixelNum =  size(grey_image,1)* size(grey_image,2);

    [counts,~] = imhist(grey_image);

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

    open_binary_im  = imopen(binary_im,SE);
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