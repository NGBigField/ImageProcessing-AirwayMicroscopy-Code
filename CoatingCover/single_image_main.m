close all; clearvars ; clc;  
add_app_paths(pwd);

Paths = PathsClass( string(pwd) , "search" );
% Paths = PathsClass( string(pwd) , "given", "C:\Users\Tomer Arama\Technion\Image Processing - Airway Microscopy - General\Data" );
%% Load Image:

% ImPath = Paths.ImagesForComparison.Coating ;
% ImPath = Paths.AllDirectories.SuperDirectory4 + filesep + "day 3" + filesep + "C+F" + filesep + "CALU_DAY3_E6_4.tif";  
% ImPath = Paths.AllDirectories.SuperDirectory4 + filesep + "day 5\None\none_C5_day 5_1.tif";
% ImPath = "C:\Users\NGBig\Technion\Image processing for in vitro airway model microscopy - General\Data\4th set - Coatings\day 3\FBS\CALU_C4_FBS_DAY 3_2.tif" ;
ImPath = "C:\Users\NGBig\Technion\Image processing for in vitro airway model microscopy - General\Data\4th set - Coatings\day 3\FBS\CALU_e4_FBS_DAY 3_4.tif";
% ImPath = "C:\Users\Tomer Arama\Technion\Image Processing - Airway Microscopy - General\Data\4th set - Coatings\day 3\FBS\CALU_e4_FBS_DAY 3_4.tif" ;
% ImPath = "C:\Users\Tomer Arama\Technion\Image Processing - Airway Microscopy - General\Data\4th set - Coatings\day 5\C\COLLAGEN_DAY5_D5_2.tif";
% ImPath = "C:\Users\Tomer Arama\Technion\Image Processing - Airway Microscopy - General\Data\4th set - Coatings\day 3\C\CALU_DAY3_e5_4.tif"?

Im = imread(ImPath);

%% Find intiall masks:
[Config , Settings ] = default_CoatingCover_config("Coating");
Config.Smoothing_SERadius = [];
Config.isHistEqualization = false;
Config.ThreshouldingGrayLevel = 4;

Config.EdgeDetection.isHistEqualization = false;
Config.EdgeDetection.cannyLow   = 0.05;
Config.EdgeDetection.cannyHigh  = 0.15;


Settings.isShowMontage = true;

ConfigVec = [ 10 ];



for i = 1 : length(ConfigVec)
    Config.EdgeDetection.close_SERadius = ConfigVec(i);
    [ Images , FigH]    = segment_coating_image_fusion(        Im , Config , Settings);
    FigH.Name = "close_SERadius = " + string(ConfigVec(i));
end


% [ cell_coverage , binary_image ] =  calc_image_cell_coverage(Im , Config , Params);



%%


% Image_FullPath = Paths.Results.TempResults.tempMask_FullPath;
% save( Image_FullPath , "filttered_binary_image" );
% 
% Image_FullPath = Paths.Results.TempResults.tempGrayImage_FullPath;
% imwrite(gray_image, Image_FullPath )
% 


