function [Params] = default_params( ImageType )
    arguments
        ImageType string = "Unkown";
    end
    
    Params = struct();
    
    Params.General = struct();
    Params.General.ChosenAlgorithm     =  AvailableAlgorithms.MatlabBuiltIn;
    
    Params.MatlabBuiltIn = struct();
    Params.MatlabBuiltIn.SmoothFactor         =  0.9;
    Params.MatlabBuiltIn.ContractionBias      =  0.01;
    Params.MatlabBuiltIn.Method                    =  AvailableAlgorithms.MatlabBuiltInMethods.Edge;
    Params.MatlabBuiltIn.MaxNumIteration  =  1000;
    Params.MatlabBuiltIn.IterationsPerFrame = 2;
    
    Params.WaterShed = struct();
    Params.WaterShed.Tolerance = 12; % in the range [0 , 255]
    
    Params.AdaptiveThreshold = struct();
    Params.AdaptiveThreshold.WindowSize = 50;
    Params.AdaptiveThreshold.MeanOrMedian = 0; %0 = mean, 1 = median
    Params.AdaptiveThreshold.Threshold = 0.03;
    Params.AdaptiveThreshold.DistRadius = 3;
    Params.AdaptiveThreshold.SolidityLowerThresh = 0.25;
    Params.AdaptiveThreshold.SolidityUpperThresh = 0.95;
    
    %  Params.AdaptiveThreshold.SE = strel('disk',DistRadius);
    
    
    Params.ImageManipulations = struct();
   % empty
    
   switch ImageType
       case "Unkown"
           return % as is
       case "Red"
           Params.General.ChosenAlgorithm     =  AvailableAlgorithms.Watershed;
           Params.WaterShed.Tolerance = 12;
           
       case "Natural"
           Params.General.ChosenAlgorithm     =  AvailableAlgorithms.MatlabBuiltIn;
           Params.MatlabBuiltIn.SmoothFactor        =  0.1;
           Params.MatlabBuiltIn.ContractionBias     =  -0.4;
           Params.MatlabBuiltIn.Method              =  AvailableAlgorithms.MatlabBuiltInMethods.Region;
           Params.MatlabBuiltIn.MaxNumIteration     =  200;
           Params.MatlabBuiltIn.IterationsPerFrame  =  2;
           
       case "Flask"
           return
       otherwise
           
   end % switch
   
end % function

