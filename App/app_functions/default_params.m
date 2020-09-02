function [Params] = default_params()

    Params = struct();
    
    Params.General = struct();
    Params.General.ChosenAlgorithm     =  AvailableAlgorithms.MatlabBuiltIn;
    
    Params.MatlabBuiltIn = struct();
    Params.MatlabBuiltIn.SmoothFactor         =  4;
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
    Params.AdaptiveThreshold.SE = strel('disk',3);
    Params.AdaptiveThreshold.LowerThresh = 0.25;
    Params.AdaptiveThreshold.UpperThresh = 0.95;
end

