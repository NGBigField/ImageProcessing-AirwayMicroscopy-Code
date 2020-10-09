close all; clearvars ; clc;  
add_app_paths(pwd);
Paths = PathsClass( string(pwd) , "search" );

% Paths = PathsClass( string(pwd) , "given", "C:\Users\tarama\Technion\Image Processing - Airway Microscopy - General\Data" );
%% Load Settings:
% ImPath = Paths.ImagesForComparison.Coating ;
% ImPath = Paths.AllDirectories.SuperDirectory4 + filesep + "day 3" + filesep + "C+F" + filesep + "CALU_DAY3_E6_4.tif";  
% ImPath = Paths.AllDirectories.SuperDirectory4 + filesep + "day 5\None\none_C5_day 5_1.tif";
ImPath = "C:\Users\NGBig\Technion\Image processing for in vitro airway model microscopy - General\Data\4th set - Coatings\day 3\FBS\CALU_C4_FBS_DAY 3_2.tif" ;

Im = imread(ImPath);

ImageIndex         = Paths.ImagesForComparison.info.Coating.ImageIndex;
coatingTypeStruct  = Paths.ImagesForComparison.info.Coating.coatingTypeStruct;
dayStruct          = Paths.ImagesForComparison.info.Coating.dayStruct;

Settings = struct();
Settings.howManyImages2Save = "All" ; % "All"/"1 per type per day"/"Only first Image";
Settings.isJustShow = true;

%% Find intiall masks:
[Config , Params ] = default_CoatingCover_config("Coating");
Config.Smoothing_SERadius = [];
Config.isHistEqualization = false;
Config.ThreshouldingGrayLevel = 4;

Params.isShowMontage = true;

[ cell_coverage , binary_image ] =  calc_image_cell_coverage(Im , Config , Params);



%%


% Image_FullPath = Paths.Results.TempResults.tempMask_FullPath;
% save( Image_FullPath , "filttered_binary_image" );
% 
% Image_FullPath = Paths.Results.TempResults.tempGrayImage_FullPath;
% imwrite(gray_image, Image_FullPath )
% 


