function [GrayImageOut] = ImageBlur(GrayImageIn , options)

    hsize = options.WindowSize;
    sigma = options.Sigma;

    gaussianFilter = fspecial('gaussian',hsize,sigma);
    GrayImageOut = imfilter(GrayImageIn, gaussianFilter , "replicate");


end % function [GrayImageOut] = ImageBlurr(GrayImageIn)