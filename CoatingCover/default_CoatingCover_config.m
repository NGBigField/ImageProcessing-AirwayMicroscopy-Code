function Config = default_CoatingCover_config()
    
    Config = struct();
    
    Config.isOpen = false;
    Config.openRadius = 2;
    
    Config.isOpenAgain = false;
    Config.openRadiusAgain = 3;
    
    Config.isClose = false;
    Config.closeRadius = 4;
    
    Config.isMaxWindow = false;
    Config.MaxWindowRadius = 5;

end % default_CoatingCover_config