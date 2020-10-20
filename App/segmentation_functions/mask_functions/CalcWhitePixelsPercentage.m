function white_pixels_rel_value = CalcWhitePixelsPercentage(binary_image)
    totalPixelNum = size(binary_image,1)* size(binary_image,2);
    white_pixels_num = sum(binary_image(:));
    %return the percentage of white pixels in the image (0-100)
    white_pixels_rel_value = (white_pixels_num/totalPixelNum)*100;
end
