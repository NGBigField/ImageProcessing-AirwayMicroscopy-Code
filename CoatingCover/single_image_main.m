close all; clearvars ; clc;  
Paths = PathsClass( string(pwd) , "search" );
% Paths = PathsClass( string(pwd) , "given", "C:\Users\tarama\Technion\Image Processing - Airway Microscopy - General\Data" );
%% Load Settings:
Im = imread( Paths.ImagesForComparison.Coating );
ImageIndex         = Paths.ImagesForComparison.info.Coating.ImageIndex;
coatingTypeStruct  = Paths.ImagesForComparison.info.Coating.coatingTypeStruct;
dayStruct          = Paths.ImagesForComparison.info.Coating.dayStruct;

Settings = struct();
Settings.howManyImages2Save = "All" ; % "All"/"1 per type per day"/"Only first Image";
Settings.isJustShow = true;

%% Find intiall masks:
Config = default_CoatingCover_config("Coating");
Config.MaxWindowRadius = 30;
[ cell_coverage , binary_image , gray_image] =  calc_image_cell_coverage(Im , Config);

lowerAreaLimit = 1000;
filttered_binary_image = bwpropfilt(~binary_image, "Area" , [lowerAreaLimit , inf] );

%imiges_side_by_side_binary_with_original(    Im         , filttered_binary_image , ImageIndex ,  0              , coatingTypeStruct , dayStruct , cell_coverage , Paths , Settings );
figure();
montage({Im , gray_image , binary_image, filttered_binary_image});

%%


Image_FullPath = Paths.Results.TempResults.tempMask_FullPath;
save( Image_FullPath , "filttered_binary_image" );

Image_FullPath = Paths.Results.TempResults.tempGrayImage_FullPath;
imwrite(gray_image, Image_FullPath )


%% Flask   
% one segmentation of Flask Image:
%{



Config = default_CoatingCover_config("Flask");
Config.isPlotAllImages = true;

Config.SubstructBackgroundRadius = 0;
Config.PercentDarkest = 80;
Config.openRadius = 0;


Im = imread( Paths.ImagesForComparison.Flask );

[cell_coverage , binary_image] =  calc_image_cell_coverage(Im , Config);
disp(cell_coverage);



%}