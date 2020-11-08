function [Config] = default_params( ImageType )
    arguments
        ImageType string {mustBeMember(ImageType,["Unknown" "Red" "Natural" "Flask" "Coating"])} = "Unknown";
    end
    
    Config = struct();
    
    Config.General = struct();
    Config.General.ChosenAlgorithm     =  AvailableAlgorithms.MatlabBuiltIn;
    
    % Matlab built-in:
    % ===============
    Config.MatlabBuiltIn = struct();
    Config.MatlabBuiltIn.SmoothFactor         =  0.9;
    Config.MatlabBuiltIn.ContractionBias      =  0.01;
    Config.MatlabBuiltIn.Method               =  AvailableAlgorithms.MatlabBuiltInMethods.Edge;
    Config.MatlabBuiltIn.MaxNumIteration      =  1000;
    Config.MatlabBuiltIn.IterationsPerFrame   = 2;
    Config.MatlabBuiltIn.MasksRecombination   = false;
    
    % Watershed:
    % =========
    Config.WaterShed = struct();
    Config.WaterShed.Tolerance = 12; % in the range [0 , 255]
    
    % Adaptive Threshold:
    % ==================
    Config.AdaptiveThreshold = struct();
    Config.AdaptiveThreshold.WindowSize = 50;
    Config.AdaptiveThreshold.MeanOrMedian = 0; %0 = mean, 1 = median
    Config.AdaptiveThreshold.Threshold = 0.03;
    Config.AdaptiveThreshold.DistRadius = 3;
    Config.AdaptiveThreshold.SolidityLowerThresh = 0.25;
    Config.AdaptiveThreshold.SolidityUpperThresh = 0.95;
    
    %  Params.AdaptiveThreshold.SE = strel('disk',DistRadius);
    
    % Coating Cover algo:   
    % Canny Thresholding Fusion:
    % =========================
    [Config.CannyThresholdingFusion , Config.CannyThresholdingFusion.PlotSettings ] = default_CannyThresholdingFusion_config(ImageType);
    
    
    Config.ImageManipulations = struct();
    % empty for now;

    
   switch ImageType
       case "Unknown"
           
       case "Red"
           % What will be actually used:
           Config.General.ChosenAlgorithm     =  AvailableAlgorithms.Watershed;
           Config.WaterShed.Tolerance = 12;
           % Other params:
           Config.MatlabBuiltIn.SmoothFactor         =  0.5;
           Config.MatlabBuiltIn.ContractionBias      =  0.5;
           Config.MatlabBuiltIn.Method               =  AvailableAlgorithms.MatlabBuiltInMethods.Region;
           Config.MatlabBuiltIn.MaxNumIteration      =  1000;
           
       case "Natural"
           Config.General.ChosenAlgorithm           =  AvailableAlgorithms.MatlabBuiltIn;
           Config.MatlabBuiltIn.SmoothFactor        =   0.1;
           Config.MatlabBuiltIn.ContractionBias     =  -0.8;
           Config.MatlabBuiltIn.Method              =  AvailableAlgorithms.MatlabBuiltInMethods.Region;
           Config.MatlabBuiltIn.MaxNumIteration     =  200;
           Config.MatlabBuiltIn.IterationsPerFrame  =  5;
           
       case "Flask"
           Config.General.ChosenAlgorithm           =  AvailableAlgorithms.MatlabBuiltIn;
           Config.MatlabBuiltIn.SmoothFactor        =  1.1;
           Config.MatlabBuiltIn.ContractionBias     = -0.4;
           Config.MatlabBuiltIn.Method              =  AvailableAlgorithms.MatlabBuiltInMethods.Edge;
           Config.MatlabBuiltIn.MaxNumIteration     =  200;
           Config.MatlabBuiltIn.IterationsPerFrame  =  10;
           Config.MatlabBuiltIn.MasksRecombination  =  true;
       case "Coating"
           Config.General.ChosenAlgorithm   =  AvailableAlgorithms.CannyThresholdingFusion;
       otherwise
           error("Not a legit Type")
   end % switch
   
   
   
   
end % function

