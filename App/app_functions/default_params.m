function [Params] = default_params()

    Params = struct();
    
    Params.General = struct();
    Params.General.ChosenAlgorithm     =  AvailableAlgorithms.MatlabBuiltIn;
    Params.General.MaxNumIteration    =  1000;
    
    Params.MatlabBuiltIn = struct();
    Params.MatlabBuiltIn.SmoothFactor    = 4;
    Params.MatlabBuiltIn.ContractionBias =  0.01;
    Params.MatlabBuiltIn.Method               = AvailableAlgorithms.MatlabBuiltInMethods.Edge;
    
end

