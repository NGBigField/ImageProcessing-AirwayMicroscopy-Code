function  [Images , figH] = SegmentCoatingImageFusion(originalIm , Config , Settings , options)
      
    arguments
       originalIm
       Config
       Settings
       
       options.isPlot logical = true
        
    end


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
    
    GrainFiltering_WhiteRadius = Config.EdgeDetection.GrainFiltering_WhiteRadius_pre; 
    if ~isempty( GrainFiltering_WhiteRadius )
        % FilteredCanny = medfilt2(CannyIm,[GrainFiltering_WhiteRadius GrainFiltering_WhiteRadius]);
        FilteredCanny = bwpropfilt(CannyIm , "ConvexArea", [GrainFiltering_WhiteRadius,inf] ); 
    else
        FilteredCanny = CannyIm;
    end
        
    % Close:
    smallCloseRadius = Config.EdgeDetection.smallCloseRadius ;
    bigCloseRadius   = Config.EdgeDetection.bigCloseRadius   ;
    
    if ~isempty(smallCloseRadius)             
        SE = strel('disk', smallCloseRadius );
        smallClosedCannyIm   = imclose( FilteredCanny , SE );
    else
        smallClosedCannyIm = FilteredCanny;
    end    

    if ~isempty(bigCloseRadius)             
        SE = strel('disk', bigCloseRadius );
        bigClosedCannyIm   = imclose( FilteredCanny , SE );
    else
        bigClosedCannyIm = FilteredCanny;
    end
    
    
    GrainFiltering_WhiteRadius = Config.EdgeDetection.GrainFiltering_WhiteRadius_post; 
    if ~isempty( GrainFiltering_WhiteRadius )
        FilteredSmallClosedCannyIm = bwpropfilt(smallClosedCannyIm , "ConvexArea", [GrainFiltering_WhiteRadius,inf] ); 
        FilteredBigClosedCannyIm   = bwpropfilt(bigClosedCannyIm , "ConvexArea", [GrainFiltering_WhiteRadius,inf] ); 
    else
        FilteredSmallClosedCannyIm = smallClosedCannyIm;
        FilteredBigClosedCannyIm   = bigClosedCannyIm;
    end
    
    
    
    
    ExpansionFromSmallToBig = FilteredBigClosedCannyIm-FilteredSmallClosedCannyIm;
    
    % For visualizations:
    [Gmag,~] = imgradient(grayIm,'sobel');
    % Normalization:
    Gmag = Gmag/max(Gmag,[],'all');

   
    
    %% Fusion
    %see where gray levels and close expansion agree:
    AgreementIm = closedThresholding & ExpansionFromSmallToBig;
    
    CannyExpandedWithGrayAgreement = FilteredSmallClosedCannyIm | AgreementIm;
    
    
    GrainFiltering_Black = Config.Fusion.GrainFiltering_BlackRadius_post;
    if ~isempty( GrainFiltering_WhiteRadius )
        CannyExpandedWithGrayAgreementFiltered   = ~bwpropfilt(~CannyExpandedWithGrayAgreement , "ConvexArea", [GrainFiltering_Black,inf] ); 
    else
        CannyExpandedWithGrayAgreementFiltered   = CannyExpandedWithGrayAgreement;
    end
    
    %% Epilog:
    
    Images.originalIm =originalIm;
    Images.grayHisteqIm = grayHisteqIm;
    Images.canny = CannyIm;
    Images.SegmentedBWIm = CannyExpandedWithGrayAgreement;
    Images.SegmentedBWImFiltered = CannyExpandedWithGrayAgreementFiltered;
    
    if Settings.isShowMontage && options.isPlot
        ImCell      = {originalIm     ,  grayHisteqIm            , Gmag                    , CannyIm , smallClosedCannyIm    , FilteredSmallClosedCannyIm    ,  bigClosedCannyIm   , FilteredBigClosedCannyIm   , ExpansionFromSmallToBig   , GrayLevelThresholdingIm  , closedThresholding    , AgreementIm                        , CannyExpandedWithGrayAgreement , CannyExpandedWithGrayAgreementFiltered};
        TitlesArray = ["Original"     , "Histogram Equalization" , "Gmag = sobel magnitude", "Canny" , "Small Closed canny"  , "Filtered Small Closed Canny" , "Big Closed canny"  ,"Filtered Big Closed Canny" , "Close Expansion"         , "Gray Thresholding"      , "closed Thresholding" , "Expansion-Thresholding Agreement" , "Expansion + Agreement"        , "Filtered Final"                      ];
        
        figH = figure();
        [SubPlotHandleArray , options] = LinkedMontage( ImCell , TitlesArray , "Layout" , [3 inf ] , "FigureHandle" , figH , "ImageRelativeSize", 0.9);
        figH.Name = "Montage";
    else
        figH = gobjects;
    end
    
   
    
end
