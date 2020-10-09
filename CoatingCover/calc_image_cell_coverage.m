%[cell_coverage , binary_image] = calc_image_cell_coverage(Im)
% Calculates the Cell Coverage of a dead-babies-lugns-iamge.
% 
% Input: Colored Image
%
% Outputs:
%    * cell_coverage (double): 0 to 100;
%    * binary_image (BW Image Matrix): what was segmented by our algorithms.
function [cell_coverage , binary_image ] = calc_image_cell_coverage(Im , Config , Settings)
arguments
    Im      % Image
    Config  % Structure
    Settings  % structure
end

[binary_image , ~]  = segment_coating_image(Im , Config , Settings);
cell_coverage = calc_white_pixels_percentage(binary_image);


end % function calc_image_cell_coverage


%% sub functions:
function [binary_image_edge , gray_image]  = segment_coating_image(Original_Image , Config , Settings)

    [ binary_image_edge , gray_image]           = segment_coating_image_edgeDetection(        Original_Image , Config , Settings);
    [binary_image_thresholding_smoothed, ~ , ~] = segment_coating_image_grayLevelThresholding(Original_Image , Config , Settings);
    
    
    ImCell     = {Original_Image , binary_image_edge, binary_image_thresholding_smoothed} ;
    TitleArray = ["Original Image" ,"Edge" , "Thresholding"] ;
    FigH = images_side_by_side( ImCell , TitleArray );
    
    disp("Done");
end




function  [BW1 , gray_image] = segment_coating_image_edgeDetection(original_image , Config , Settings)
      
    %get grey image:
    gray_image = rgb2gray(original_image);
    %Subtract background:
    if ~isempty(Config.SubstructBackground_SERadius)
        gray_image = image_substruct_background(gray_image , Config.SubstructBackground_SERadius);
    end
    %histogram equalization:
    gray_image = histeq(gray_image);

    %%    
    BW1 = edge(gray_image,'canny' , [ 0.24 ,  0.61 ]);   %  'canny',[low high] where:  0 < low < high < 1 ;
    
%     FigH = images_side_by_side(original_image, BW1);
  
    return
    %%
%     BW2 = bwpropfilt(BW1 ,"Area" ,[50 inf]);
%     figure()
%     imshow(BW2)
%     
    
    SE = strel('disk' , 4 , 0);
    BW_test1 = imdilate(BW1,SE);

    
    BW_test2 = bwpropfilt(BW_test1 ,"EulerNumber" ,[-inf  0]);

    
    BW_test3 = imerode(BW_test2,SE);

    
    SE = strel('disk' , 10 , 0);
    BW_test4 = imclose(BW_test3 , SE);

    
    BW_test5 = ~bwpropfilt(~BW_test4 ,"Area" ,[2000  inf]);
    figure()
    imshow(BW_test5)
end

function [Smoothed_binary_image , binary_image , gray_image] = segment_coating_image_grayLevelThresholding(original_image , Config , Settings)

    %get grey image:
    gray_image = rgb2gray(original_image);
    %Subtract background:
    if ~isempty(Config.SubstructBackground_SERadius)
        gray_image = image_substruct_background(gray_image , Config.SubstructBackground_SERadius);
    end
    %histogram equalization:
    if Config.isHistEqualization        
        gray_image = histeq(gray_image);
    end
    % Get the Gray Value of the  <x> [%] darkest pixels:
    
    if ~isempty(Config.ThreshouldingGrayPercent) && isempty(Config.ThreshouldingGrayLevel)
        most_dark_grey_level = most_x_percent_darkest_level( Config.ThreshouldingGrayPercent , gray_image );
    elseif ~isempty(Config.ThreshouldingGrayLevel) && isempty(Config.ThreshouldingGrayPercent)
        most_dark_grey_level = Config.ThreshouldingGrayLevel;
    else
        error("Must choose between Given Gray Level Threshold  or Percent Gray Level Threshold");
    end

    %thresholding:
    binary_image = gray_image > most_dark_grey_level;
    
   
%     binary_image = DensityWindowFilter( binary_image , Config.DensityWindowFilter );
    
    % Grain Filtering - Black:
    if ~isempty(Config.GrainFiltering_BlackArea)
        filttered_binary_image  = ~bwpropfilt(~binary_image,           "Area" , [Config.GrainFiltering_BlackArea  , inf] , 4);
    else
        filttered_binary_image  = binary_image;
    end
    % Grain Filtering - White:
    if ~isempty(Config.GrainFiltering_WhiteArea )
        filttered_binary_image2 =  bwpropfilt( filttered_binary_image, "Area" , [Config.GrainFiltering_WhiteArea  , inf] , 4);
    else
        filttered_binary_image2 = filttered_binary_image;
    end

    % Smoothing:
    if ~isempty(Config.Smoothing_SERadius)        
        SE = strel('disk', Config.Smoothing_SERadius );
        Smoothed_binary_image   = imerode( filttered_binary_image2 , SE );
    else
        Smoothed_binary_image   = filttered_binary_image2;
    end
    
    if Settings.isShowMontage
        figure();
        MontageG = montage({original_image , gray_image , binary_image, filttered_binary_image , filttered_binary_image2 , Smoothed_binary_image});
        pretty_montage( MontageG );
        impixelinfo
    end


end

function without_background =  image_substruct_background(im , disk_radius )
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

function pretty_montage( MontageG )

    return
    disp(0);
    Axis = MontageG.Parent;
    Axis.XAxis.TickValues = 1:7;
    Axis.XAxis.TickLabelsMode = 'manual';
    Axis.XAxis.TickLabels{2} = "Test1"
    Axis.Visible = 'on';
    

end
