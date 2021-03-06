function [Config , Settings ] = default_CannyThresholdingFusion_config(ImageType)
    arguments
        ImageType string = "Unknown"
    end
    %% Config:
    
    Config = struct();
    Config.ImageType = ImageType;
    
    %% Config.Prolog
    Config.Prolog.SubstructBackground_SERadius = 2;
    
    %% Config.GrayLevelThresholding: 
    Config.GrayLevelThresholding = struct();    
    Config.GrayLevelThresholding.isHistEqualization = false;        
    
    Config.GrayLevelThresholding.ThreshouldingGrayPercent = [] ; % 35 is good.   in range [0 100]
    Config.GrayLevelThresholding.ThreshouldingGrayLevel   = 10 ; % in range [0 to 255]   
    
    Config.GrayLevelThresholding.GrainFiltering_BlackArea = 500; %1000
    Config.GrayLevelThresholding.GrainFiltering_WhiteArea = 500;
    
    Config.GrayLevelThresholding.closeRadius = 3;
    %% Config.DensityWindowFilter 
    Config.DensityWindowFilter = struct();
    Config.DensityWindowFilter.isOn                    = true;
    Config.DensityWindowFilter.DensityWindowSize       = 5 ;
    Config.DensityWindowFilter.DensityPercentThreshold = 50 ;
    Config.DensityWindowFilter.BoundaryPolicy          = "White" ;    % ["symmetric","replicate","circular","Black","White"]
    
    
    %% Config.EdgeDetection:
    Config.EdgeDetection = struct();
    
    Config.EdgeDetection.isHistEqualization = false;

    Config.EdgeDetection.cannyLow   = 0.05;
    Config.EdgeDetection.cannyHigh  = 0.15;
    
    Config.EdgeDetection.smallCloseRadius = 3 ;
    Config.EdgeDetection.bigCloseRadius   = 15; 
    
    % Grain Filtering
    Config.EdgeDetection.GrainFiltering_WhiteRadius_pre  = [];
    Config.EdgeDetection.GrainFiltering_WhiteRadius_post = 800;
    
    %% Config.Fusion:
  
    Config.Fusion.isOn = true;
    Config.Fusion.GrainFiltering_BlackRadius_post = 1000;
    
    
    %% Params
    Settings = struct();
    Settings.isShowMontage = false;
    
    switch ImageType
        case "Unknown"
            
        case "Red"

        case "Natural"
            
        case "Flask"
            
        case "Coating"
     
        otherwise
            error("No such type")
           
   end % switch
end % default_CoatingCover_config