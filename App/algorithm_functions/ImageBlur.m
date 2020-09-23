function [GrayImageOut] = ImageBlur(GrayImageIn)

    hsize = 15;
    sigma = 10;

    gaussianFilter = fspecial('gaussian',hsize,sigma);
    GrayImageOut = imfilter(GrayImageIn, gaussianFilter , "replicate");


end % function [GrayImageOut] = ImageBlurr(GrayImageIn)