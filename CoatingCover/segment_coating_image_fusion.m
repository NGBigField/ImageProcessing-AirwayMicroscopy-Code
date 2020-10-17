function  [Images , figH] = segment_coating_image_fusion(originalIm , Config , Settings)
      
    Images = struct;
    
    %get grey image:
    gray = rgb2gray(originalIm);
    
    %% porlog:
    
    %Subtract background:
    if ~isempty(Config.Prolog.SubstructBackground_SERadius)
        gray = image_substruct_background(gray , Config.Prolog.SubstructBackground_SERadius);
    end

    %% GrayLevelThresholding:

    %histogram equalization:
    if Config.GrayLevelThresholding.isHistEqualization
        gray = histeq(gray);
    end
    
    % Thresholding
    grayThreshold = Config.GrayLevelThresholding.ThreshouldingGrayLevel;
    GrayLevelThresholdingIm = gray > grayThreshold ;
    
    if ~isempty(Config.GrayLevelThresholding.closeRadius)
        SE = strel('disk', Config.GrayLevelThresholding.closeRadius );
        closedThresholding = imclose( GrayLevelThresholdingIm , SE );
    else
        closedThresholding=GrayLevelThresholdingIm;
    end
    
    % For visualization:
    grayHisteqIm = histeq(gray);
    %% Edge Detection:
    
    %histogram equalization:
    if Config.EdgeDetection.isHistEqualization
        gray = histeq(gray);
    end
    
    % Canny:
    CannyLow  = Config.EdgeDetection.cannyLow ;
    CannyHigh = Config.EdgeDetection.cannyHigh;

    CannyIm = edge(gray,'canny' , [ CannyLow ,  CannyHigh ]);   %  'canny',[low high] where:  0 < low < high < 1 ;
    
        
    % Close:
    smallCloseRadius = Config.EdgeDetection.smallCloseRadius ;
    bigCloseRadius   = Config.EdgeDetection.bigCloseRadius   ;
    
    if ~isempty(smallCloseRadius)             
        SE = strel('disk', smallCloseRadius );
        smallClosedCannyIm   = imclose( CannyIm , SE );
    else
        smallClosedCannyIm = CannyIm;
    end    

    if ~isempty(bigCloseRadius)             
        SE = strel('disk', Config.EdgeDetection.close_SERadius );
        bigClosedCannyIm   = imclose( CannyIm , SE );
    else
        bigClosedCannyIm = CannyIm;
    end
    
    ExpansionFromSmallToBig = bigClosedCannyIm-smallClosedCannyIm;
    
    % For visualizations:
    [Gmag,~] = imgradient(gray,'sobel');
    % Normalization:
    Gmag = Gmag/max(Gmag,[],'all');

   
    
    %% Fusion
    %see where gray levels and close expansion agree:
    AgreementIm = closedThresholding & ExpansionFromSmallToBig;
    
    CannyExpandedWithGrayAgreement = smallClosedCannyIm | AgreementIm;
    
    %% Epilog:
    
    Images.originalIm =originalIm;
    Images.grayHisteqIm = grayHisteqIm;
    
    
    if Settings.isShowMontage
        ImCell      = {originalIm     ,  grayHisteqIm            , Gmag                    , CannyIm ,  smallClosedCannyIm                                         ,  bigClosedCannyIm                                        , ExpansionFromSmallToBig   , GrayLevelThresholdingIm  , closedThresholding   , AgreementIm                                          , CannyExpandedWithGrayAgreement};
        TitlesArray = ["Original"     , "Histogram Equalization" , "Gmag = sobel magnitude", "Canny" , "Closed canny"+newline+ "radius="+string(smallCloseRadius)  , "Closed canny"+newline+ "radius="+string(bigCloseRadius) , "Close Expansion"         , "Gray Thresholding"    , "closedThresholding" , "Agreement between Close Expansion And Thresholding" , "Expansion with Gray Agreement"];
        
        figH = figure();
        [SubPlotHandleArray , options] = LinkedMontage( ImCell , TitlesArray , "Layout" , [3 inf ] , "FigureHandle" , figH , "ImageRelativeSize", 0.9);
        figH.Name = "Montage";
    end
    
   
    
end


function without_background =  image_substruct_background(im , disk_radius )
SE = strel('disk',   disk_radius  );
eroded = imerode(im,SE);
without_background = im - eroded;
end