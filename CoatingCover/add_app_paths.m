function [] = add_app_paths(currentDir)
    arguments
        currentDir string 
    end
    
    ParentDir = currentDir+filesep+"..";
    FolderContentWithoutWhiteSpaces = strtrim( reshape( string( ls(ParentDir) )  , 1 , [] ) );
    
    if any(FolderContentWithoutWhiteSpaces=="App")
        AppDir = ParentDir+filesep+"App";
        addpath(genpath(AppDir))
    else
       error("Didn't find App folder in parent directory"); 
    end
    


end % function