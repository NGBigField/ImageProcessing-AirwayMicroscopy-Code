function [currentDir] = assert_correct_app_folder( appOrObject , currentDir , isErrorIfNotMainFolder)

    arguments
       appOrObject
       currentDir string
       isErrorIfNotMainFolder logical = true
    end

    folder_that_should_exist = [ "class_defs" , "app_functions"  ,"segmentation_functions"  ,"enumerations" ,"image_manipulations_functions"];
    is_exist_folder          = false(size(folder_that_should_exist));

    currentFolderData = dir(currentDir);

    % check if we're in one of the sub-folders by accident
    CurrentFullPath = currentFolderData(1).folder;
    [~,CurrentFolderName,~]=fileparts( CurrentFullPath );
    if any(string(CurrentFolderName) == folder_that_should_exist)
        % set MATLAB focux to currect estimation for main folder:
        cd(string(CurrentFullPath) + filesep + "..");
        % update current folder and run again:
        currentDir = string(GetFullPath(char(currentDir+filesep+"..")));
        [currentDir] = assert_correct_app_folder(app , currentDir);
        return
    end

    % Check if we're in the correct main folder:

    for i = 1:length(currentFolderData)
        fileOrFodlder = currentFolderData(i);
        index_of_found_folder = find(folder_that_should_exist==fileOrFodlder.name);
        %if current folder is not somwthing we're looknig for:
        if isempty(index_of_found_folder)
            % do nothing
        %else:  it is a necessary folder
        else
            % we should note that we've found it:
            is_exist_folder(index_of_found_folder) = true; 
            % and we should have it in Matlab's paths:
            addpath(genpath( fullfile(fileOrFodlder.folder,fileOrFodlder.name)  )) 
        end

    end

    if ~all(is_exist_folder)
        appOrObject.wrong_folder_msg(folder_that_should_exist, isErrorIfNotMainFolder)            
    end
end % endd function