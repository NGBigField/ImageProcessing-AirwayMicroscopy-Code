close all; clearvars ; clc;  
add_app_paths(pwd);
Paths = PathsClass( string(pwd) , "search" );

% Paths = PathsClass( string(pwd) , "given", "C:\Users\tarama\Technion\Image Processing - Airway Microscopy - General\Data" );
%% Load Settings:
% Im = imread( Paths.ImagesForComparison.Coating );
Im = imread( Paths.AllDirectories.SuperDirectory4 + filesep + "day 3" + filesep + "C+F" + filesep + "CALU_DAY3_E6_4.tif");

ImageIndex         = Paths.ImagesForComparison.info.Coating.ImageIndex;
coatingTypeStruct  = Paths.ImagesForComparison.info.Coating.coatingTypeStruct;
dayStruct          = Paths.ImagesForComparison.info.Coating.dayStruct;

Settings = struct();
Settings.howManyImages2Save = "All" ; % "All"/"1 per type per day"/"Only first Image";
Settings.isJustShow = true;

%% Find intiall masks:
[Config , Params ] = default_CoatingCover_config("Coating");
Params.isShowMontage = true;

[ cell_coverage , binary_image ] =  calc_image_cell_coverage(Im , Config , Params);



%%


% Image_FullPath = Paths.Results.TempResults.tempMask_FullPath;
% save( Image_FullPath , "filttered_binary_image" );
% 
% Image_FullPath = Paths.Results.TempResults.tempGrayImage_FullPath;
% imwrite(gray_image, Image_FullPath )
% 


