close all; clearvars ; clc;  
CurrentFolderPath = assert_correct_app_folder();

segmentObj = ActiveContoursObject();
Paths = segmentObj.Paths;
% Paths = PathsClass( string(pwd) , "given", "C:\Users\Tomer Arama\Technion\Image Processing - Airway Microscopy - General\Data" );
%% Load Image:

% ImPath = Paths.ImagesForComparison.Coating ;
% ImPath = Paths.AllDirectories.SuperDirectory4 + filesep + "day 3" + filesep + "C+F" + filesep + "CALU_DAY3_E6_4.tif";  
% ImPath = Paths.AllDirectories.SuperDirectory4 + filesep + "day 5\None\none_C5_day 5_1.tif";
% ImPath = "C:\Users\NGBig\Technion\Image processing for in vitro airway model microscopy - General\Data\4th set - Coatings\day 3\FBS\CALU_C4_FBS_DAY 3_2.tif" ;
% ImPath = "C:\Users\NGBig\Technion\Image processing for in vitro airway model microscopy - General\Data\4th set - Coatings\day 3\FBS\CALU_e4_FBS_DAY 3_4.tif";
% ImPath = "C:\Users\Tomer Arama\Technion\Image Processing - Airway Microscopy - General\Data\4th set - Coatings\day 3\FBS\CALU_e4_FBS_DAY 3_4.tif" ;
% ImPath = "C:\Users\Tomer Arama\Technion\Image Processing - Airway Microscopy - General\Data\4th set - Coatings\day 5\C\COLLAGEN_DAY5_D5_2.tif";
% ImPath = "C:\Users\Tomer Arama\Technion\Image Processing - Airway Microscopy - General\Data\4th set - Coatings\day 3\C\CALU_DAY3_e5_4.tif"?
% ImPath = "C:\Users\NGBig\Technion\Image processing for in vitro airway model microscopy - General\Data\4th set - Coatings\day 3\None" + "\CALU_day 3_E3_none_1.tif";
ImPath = "C:\Users\NGBig\Technion\Image processing for in vitro airway model microscopy - General\Data\3rd set - Flask\flask 10_17.5.20.tif";

Im = imread(ImPath);

%{
%% OOP:
segmentObj.ImagesManager.set_original_image(Im);
segmentObj.SegmentAlgo.Params = default_params( ImageTypeEnum.Coating );
segmentObj.SegmentAlgo.Params.CannyThresholdingFusion.PlotSettings.isShowMontage = true;

segmentObj.SegmentAlgo.start_or_stop_algorithm();
%%
%}

%% Find intiall masks:
[Config ] = default_params("Coating");
PlotSettings = Config.CannyThresholdingFusion.PlotSettings;

PlotSettings.isShowMontage = true;

[ Images , FigH]    = SegmentCoatingImageFusion(   Im , Config.CannyThresholdingFusion , PlotSettings  ,"isPlot",false);

figure();
montage({Im ,  Images.SegmentedBWImFiltered })
