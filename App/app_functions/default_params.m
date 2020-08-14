function [Params] = default_params()

    Params = struct();
    
    Params.General = struct();
    Params.General.ChosenAlgorithm     =  AvailableAlgorithms.MatlabBuiltIn;
    
    Params.MatlabBuiltIn = struct();
    Params.MatlabBuiltIn.SmoothFactor         =  4;
    Params.MatlabBuiltIn.ContractionBias      =  0.01;
    Params.MatlabBuiltIn.Method                    =  AvailableAlgorithms.MatlabBuiltInMethods.Edge;
    Params.MatlabBuiltIn.MaxNumIteration  =  1000;
    
    Params.WaterShed = struct();
    Params.WaterShed.Tolerance = 12; % in the range [0 , 255]
    
    
end

