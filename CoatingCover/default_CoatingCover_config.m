function [Config , Params ] = default_cell_cover_config(ImageType)
    arguments
        ImageType string = "Unkown"
    end
    %% Config:
    
    Config = struct();
    Config.ImageType = ImageType;
    
    Config.isHistEqualization = true;
    
    Config.SubstructBackground_SERadius = 2;
    
    Config.ThreshouldingGrayPercent =  [] ; % 35 is good.   in range [0 100]
    Config.ThreshouldingGrayLevel    = 85; % in range [0 to 255]
%     Config.ThreshouldingGrayLevel    = 5; % in range [0 to 255]
    
    Config.MaxWindowRadius = [] ; % set to zero to not-use
    
    Config.GrainFiltering_BlackArea = 500; %1000
    Config.GrainFiltering_WhiteArea = 500;
    
    
    Config.Smoothing_SERadius = 3;
    
    %% Config.DensityWindowFilter 
    Config.DensityWindowFilter = struct();
    Config.DensityWindowFilter.isOn                    = true;
    Config.DensityWindowFilter.DensityWindowSize       = 5 ;
    Config.DensityWindowFilter.DensityPercentThreshold = 50 ;
    Config.DensityWindowFilter.BoundaryPolicy          = "White" ;    % ["symmetric","replicate","circular","Black","White"]
    
    
    %% Params
    Params = struct();
    Params.isShowMontage = false;
    
    switch ImageType
        case "Unkown"
            return % as is
        case "Red"

        case "Natural"
            
        case "Flask"
            
        case "Coating"
     
        otherwise
            error("No such type")
           
   end % switch

end % default_CoatingCover_config