function  [Smoothed_BW , BW1 , grayIm , FigH] = segment_coating_image_edgeDetection(original_image , Config , Settings)
      
    %get grey image:
    grayIm = rgb2gray(original_image);
    %Subtract background:
    if ~isempty(Config.SubstructBackground_SERadius)
        grayIm = image_substruct_background(grayIm , Config.SubstructBackground_SERadius);
    end
    %histogram equalization:
    if Config.EdgeDetection.isHistEqualization
        grayIm = histeq(grayIm);
    end

    %%    
    CannyLow  = Config.EdgeDetection.cannyLow;
    CannyHigh = Config.EdgeDetection.cannyHigh;
    CannyIm = edge(grayIm,'canny' , [ CannyLow ,  CannyHigh ]);   %  'canny',[low high] where:  0 < low < high < 1 ;
    
    smallCloseRadius= 3;
    SE = strel('disk', smallCloseRadius );
    smallClosedCannyIm = imclose( CannyIm , SE );    
        
    
    % Close:
    % bigCloseRadius = Config.EdgeDetection.close_SERadius;
    bigCloseRadius = 15;
    if ~isempty(bigCloseRadius)             
        SE = strel('disk', Config.EdgeDetection.close_SERadius );
        bigClosedCannyIm   = imclose( CannyIm , SE );
    else
        bigClosedCannyIm = CannyIm;
    end
    
    ExpansionFromSmallToBig = bigClosedCannyIm-smallClosedCannyIm;
    
    [Gmag,Gdir] = imgradient(grayIm,'sobel');
    Gmag = Gmag/max(Gmag,[],'all');
    histeq_im = histeq(grayIm);
%     blended_im = imshowpair(CannyIm, histeq_im); 
    
    grayThreshold = 10;
    GrayLevelThresholding = grayIm > grayThreshold ;
    
    SE = strel('disk', 3 );
    closedThresholding = imclose( GrayLevelThresholding , SE );      
    
    %see where gray levels and close expansion agree:
    AgreementIm = closedThresholding & ExpansionFromSmallToBig;
    
    CannyExpandedWithGrayAgreement = smallClosedCannyIm | AgreementIm;
    
    %%
    if Settings.isShowMontage
        ImCell      = {original_image ,  histeq_im               , Gmag                    , CannyIm ,  smallClosedCannyIm                                         ,  bigClosedCannyIm                                        , ExpansionFromSmallToBig   , GrayLevelThresholding  , closedThresholding   , AgreementIm                                          , CannyExpandedWithGrayAgreement};
        TitlesArray = ["Original"     , "Histogram Equalization" , "Gmag = sobel magnitude", "Canny" , "Closed canny"+newline+ "radius="+string(smallCloseRadius)  , "Closed canny"+newline+ "radius="+string(bigCloseRadius) , "Close Expansion"         , "Gray Thresholding"    , "closedThresholding" , "Agreement between Close Expansion And Thresholding" , "Expansion with Gray Agreement"];
        
        FigH = figure();
        [a , b] = LinkedMontage( ImCell , TitlesArray , "Layout" , [3 inf ] , "FigureHandle" , FigH , "ImageRelativeSize", 0.9);
        FigH.Name = "Montage";
    end
    
    %%
    Smoothed_BW = bigClosedCannyIm;
    
    
end


function without_background =  image_substruct_background(im , disk_radius )
SE = strel('disk',   disk_radius  );
eroded = imerode(im,SE);
without_background = im - eroded;
end