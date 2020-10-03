function [is_exist] = check_exist_folder(ParentFolder , FolderName)
%CHECK_EXIST_FOLDER finds Folder with name 'FolderName'  in ParentFolder

listing = dir(ParentFolder);
for i = 1:length(listing)
    file = listing(i);
    if (string(file.name) == FolderName)
        is_exist = true;
        return
    end
end

is_exist = false;
end

