function Config = default_cell_cover_config(ImageType)
    arguments
        ImageType string = "Unkown"
    end
    
    Config = struct();
    Config.ImageType = ImageType;
    
    Config.SubstructBackgroundRadius = 2;
    Config.PercentDarkest = 35;   
    
    Config.openRadius = 2;  % set to 0  to not-open.
    Config.MaxWindowRadius = 0; % set to zero to not-use
    
    
    
    switch ImageType
        case "Unkown"
            return % as is
        case "Red"

        case "Natural"
            
        case "Flask"
            Config.SubstructBackgroundRadius = 0;
            Config.PercentDarkest = 80;
        case "Coating"
            Config.openRadius = 0;
            Config.PercentDarkest = 35;
        otherwise
            error("No such type")
           
   end % switch

end % default_CoatingCover_config