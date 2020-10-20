function  [Images , figH] = SegmentCoatingImageFusion(originalIm , Config , Settings)
      
    Images = struct;
    
    
    % ColoredImage ->  GrayImage :
    if ndims( originalIm )==3 % if Colored Image:
        grayIm = rgb2gray( originalIm );
    elseif ismatrix( originalIm )   %If gray Image:
        grayIm = originalIm;
    else
        error("Wrong number image dimensions");
    end
    

    
    %% porlog:
    
    %Subtract background:
    if ~isempty(Config.Prolog.SubstructBackground_SERadius)
        grayIm = ImSubstructBackground(grayIm , Config.Prolog.SubstructBackground_SERadius);
    end

    %% GrayLevelThresholding:

    %histogram equalization:
    if Config.GrayLevelThresholding.isHistEqualization
        grayIm = histeq(grayIm);
    end
    
    % Thresholding
    grayThreshold = Config.GrayLevelThresholding.ThreshouldingGrayLevel;
    GrayLevelThresholdingIm = grayIm > grayThreshold ;
    
    if ~isempty(Config.GrayLevelThresholding.closeRadius)
        SE = strel('disk', Config.GrayLevelThresholding.closeRadius );
        closedThresholding = imclose( GrayLevelThresholdingIm , SE );
    else
        closedThresholding=GrayLevelThresholdingIm;
    end
    
    % For visualization:
    grayHisteqIm = histeq(grayIm);
    %% Edge Detection:
    
    %histogram equalization:
    if Config.EdgeDetection.isHistEqualization
        grayIm = histeq(grayIm);
    end
    
    % Canny:
    CannyLow  = Config.EdgeDetection.cannyLow ;
    CannyHigh = Config.EdgeDetection.cannyHigh;

    CannyIm = edge(grayIm,'canny' , [ CannyLow ,  CannyHigh ]);   %  'canny',[low high] where:  0 < low < high < 1 ;
    
        
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
        SE = strel('disk', bigCloseRadius );
        bigClosedCannyIm   = imclose( CannyIm , SE );
    else
        bigClosedCannyIm = CannyIm;
    end
    
    ExpansionFromSmallToBig = bigClosedCannyIm-smallClosedCannyIm;
    
    % For visualizations:
    [Gmag,~] = imgradient(grayIm,'sobel');
    % Normalization:
    Gmag = Gmag/max(Gmag,[],'all');

   
    
    %% Fusion
    %see where gray levels and close expansion agree:
    AgreementIm = closedThresholding & ExpansionFromSmallToBig;
    
    CannyExpandedWithGrayAgreement = smallClosedCannyIm | AgreementIm;
    
    %% Epilog:
    
    Images.originalIm =originalIm;
    Images.grayHisteqIm = grayHisteqIm;
    Images.SegmentedBWIm = CannyExpandedWithGrayAgreement;
    
    
    if Settings.isShowMontage
        ImCell      = {originalIm     ,  grayHisteqIm            , Gmag                    , CannyIm ,  smallClosedCannyIm                                         ,  bigClosedCannyIm                                        , ExpansionFromSmallToBig   , GrayLevelThresholdingIm  , closedThresholding   , AgreementIm                                          , CannyExpandedWithGrayAgreement};
        TitlesArray = ["Original"     , "Histogram Equalization" , "Gmag = sobel magnitude", "Canny" , "Closed canny"+newline+ "radius="+string(smallCloseRadius)  , "Closed canny"+newline+ "radius="+string(bigCloseRadius) , "Close Expansion"         , "Gray Thresholding"    , "closedThresholding" , "Agreement between Close Expansion And Thresholding" , "Expansion with Gray Agreement"];
        
        figH = figure();
        [SubPlotHandleArray , options] = LinkedMontage( ImCell , TitlesArray , "Layout" , [3 inf ] , "FigureHandle" , figH , "ImageRelativeSize", 0.9);
        figH.Name = "Montage";
    else
        figH = gobjects;
    end
    
   
    
end
