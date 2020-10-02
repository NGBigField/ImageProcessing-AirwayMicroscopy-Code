function [cell_coverage , binary_image , gray_image] = calc_image_cell_coverage(Im , Config)
%[cell_coverage , binary_image] = calc_image_cell_coverage(Im)
% Calculates the Cell Coverage of a dead-babies-lugns-iamge.
% 
% Input: Colored Image
%
% Outputs:
%    * cell_coverage (double): 0 to 100;
%    * binary_image (BW Image Matrix): what was segmented by our algorithms.
%
arguments
    Im % Image
    Config = []  % Structure
end


[binary_image , gray_image]  = segment_coating_image(Im , Config);
cell_coverage = calc_white_pixels_percentage(binary_image);


end % function calc_image_cell_coverage


%% sub functions:
function [binary_im , gray_image] = segment_coating_image(original_image , Config)
    %get grey image:
    gray_image = rgb2gray(original_image);
    %Subtract background:
    if Config.SubstructBackgroundRadius ~= 0
        gray_image = image_substruct_background(gray_image , Config.SubstructBackgroundRadius);
    end
    %histogram equalization:
    gray_image = histeq(gray_image);
    % Get the Gray Value of the  <x> [%] darkest pixels:
    most_dark_grey_level = most_x_percent_darkest_level( Config.PercentDarkest , gray_image );
    %thresholding:
    binary_im = gray_image > most_dark_grey_level;
    
    % morphological opening on the binary image
    

    if ~isempty(Config) && isfield(Config , "openRadius") && Config.openRadius > 0      
        SE = strel('disk',   Config.openRadius  );
        binary_im  = imopen(binary_im,SE);
    end

    if  ~isempty(Config) && isfield(Config , "MaxWindowRadius") && Config.MaxWindowRadius > 0
        Radius =  Config.MaxWindowRadius;
        binary_im = ordfilt2(binary_im, Radius^2 ,ones(Radius,Radius));
    end
    

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


function most_dark_grey_level = most_x_percent_darkest_level(x , gray_image)

    totalPixelNum =  size(gray_image,1)* size(gray_image,2);
    
    [counts,~] = imhist(gray_image);

    binLocationIdx = 0;
    totalCount = 0;

    while totalCount < (x/100)*totalPixelNum
        binLocationIdx = binLocationIdx + 1;
        currCount = counts(binLocationIdx);
        totalCount = totalCount + currCount;
    end

    most_dark_grey_level = binLocationIdx;
end
