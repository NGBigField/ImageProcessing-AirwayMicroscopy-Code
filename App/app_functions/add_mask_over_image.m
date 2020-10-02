function ImageOut = add_mask_over_image(ImageIn ,MaskIn , rgb)
    
    if isempty(MaskIn)
        ImageOut = ImageIn;
        return
    end
    
    % In case input image is gray, Make an RGB Image, still gray :
    if size(ImageIn , 3) == 1
        [indexedImage , cmap] = gray2ind(ImageIn);
        ImageOut = ind2rgb(indexedImage , cmap);
    else
        ImageOut = im2double( ImageIn );
    end

    intensityFactor = 0.4;
    
    % Add rgb value to image:
    for rgbInd = 1 : 3
        ImageOut(:,:, rgbInd ) =  ImageOut(:,:, rgbInd ) +  intensityFactor*  MaskIn .* rgb(rgbInd)  ;
    end
    

end
