function  [Smoothed_BW , BW1 , gray_image , FigH] = segment_coating_image_edgeDetection(original_image , Config , Settings)
      
    %get grey image:
    gray_image = rgb2gray(original_image);
    %Subtract background:
    if ~isempty(Config.SubstructBackground_SERadius)
        gray_image = image_substruct_background(gray_image , Config.SubstructBackground_SERadius);
    end
    %histogram equalization:
    if Config.EdgeDetection.isHistEqualization
        gray_image = histeq(gray_image);
    end

    %%    
    CannyLow  = Config.EdgeDetection.cannyLow;
    CannyHigh = Config.EdgeDetection.cannyHigh;
    BW1 = edge(gray_image,'canny' , [ CannyLow ,  CannyHigh ]);   %  'canny',[low high] where:  0 < low < high < 1 ;
    
    
    % Close:
    if ~isempty(Config.EdgeDetection.close_SERadius)        
        SE = strel('disk', Config.EdgeDetection.close_SERadius );
        BW2   = imclose( BW1 , SE );
    else
        BW2 = BW1;
    end
    
    
    
    if Settings.isShowMontage
        ImCell      = {original_image , gray_image , histeq(gray_image) , BW1, BW2} ;
        TitlesArray = ["Original" , "Gray" , "Histogram Equalization", "BW1" , "BW2 = Closed BW1"];
        
        FigH = figure();
        [a , b] = LinkedMontage( ImCell , TitlesArray , "Size" , [2 inf ] , "FigureHandle" , FigH );
        FigH.Name = "Gray Level Thresholding";
    end
    
    
    Smoothed_BW = BW2;
    
    
end


function without_background =  image_substruct_background(im , disk_radius )
SE = strel('disk',   disk_radius  );
eroded = imerode(im,SE);
without_background = im - eroded;
end