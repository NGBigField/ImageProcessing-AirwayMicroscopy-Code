classdef DirTreeClass <  dynamicprops 
    %DIRTREECLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Path           (1,1) string        
        Name           (1,1) string
        Key            (1,1) string
        
        % Subdirectories will be set as new properties, but can be also accessed here:
        subDirectories       struct
        
        % What we're keeping track of:
        Images               struct
        hasImages      (1,1) logical
    end
    
    methods
        function obj = DirTreeClass(FullPath , isRoot , Key , Name , ImageType )
            %DIRTREECLASS Construct an instance of this class
            %   Detailed explanation goes here
            
            arguments
               FullPath (1,1) string
               isRoot   (1,1) logical = false
               Key      (1,1) string  = ""    
               Name     (1,1) string  = ""
               ImageType ImageTypeEnum = ImageTypeEnum.Unknown
            end
            
            obj.Path = FullPath;
            
            if (Key=="" || Name=="") && ~isRoot
                error("Only root of DirTree can be without key and name");
            end
            obj.Key  = Key;
            obj.Name = Name;
            
            
            InsideData  = dir(FullPath);
            insideNames = strtrim(string(strvcat(InsideData.name)));
            
            % sub dirs:
            % ========
            
            insideDirNames = insideNames(  [InsideData.isdir].' & ( insideNames~=".") &  (insideNames~="..")  );            
            insideDirKeys  = namesToKeys(insideDirNames);            
            obj.subDirectories = struct();
            for i = 1 : length(insideDirNames)
                subKey      = insideDirKeys(i);
                subFullPath = FullPath+filesep+insideDirNames(i);
                subName     =  insideDirNames(i);
                % add this field to the object:
                if isRoot
                   ImageType = parseImageTypeFromDirName(subName);
                end
                obj.addprop(subKey);
                obj.(subKey) = DirTreeClass(subFullPath , false , subKey , subName , ImageType );
                obj.subDirectories.(subKey) = obj.(subKey); % ponit to the same place
            end % for i 
            
            % images:
            % ======
            obj.Images = struct();
            obj.hasImages = false;
            for i = 1 : length(insideNames)
                subFullName = insideNames(i);
                [~,subName,ext] = fileparts(subFullName);
                ext = char(ext);                
                ext = string(ext(2:end));
                if ismember(ext, legitImagesExtensions() )
                    obj.hasImages = true;
                    subKey      = namesToKeys(subName);
                    subFullPath = FullPath+filesep+subFullName;
                    obj.Images.(subKey) = struct("Path" , subFullPath ,...
                                                 "Name" , subName     ,...
                                                 "Key"  , subKey      ,...
                                                 "Type" , ImageType   );
                end
            end
            

        end % c'tor


        
    end % methods
end



function [res] = legitImagesExtensions()
    res = ["jpg", "png", "tiff", "tif", "bmp"];
end


function [DirKeys] = namesToKeys(DirNames)

    DirKeys = DirNames;

    for i = 1 : length(DirNames)
        dirName = DirNames(i);
                
        DirKeys(i) = matlab.lang.makeUniqueStrings( matlab.lang.makeValidName( dirName ) );
    end % for i

end


function ImageType = parseImageTypeFromDirName(dirName)


    if      contains(dirName,"red"    , 'IgnoreCase',true) 
        ImageType = ImageTypeEnum.Red;
    elseif  contains(dirName,"light"  , 'IgnoreCase',true)  ||  contains(dirName,"Natural", 'IgnoreCase',true) 
        ImageType = ImageTypeEnum.Natural;
    elseif  contains(dirName,"Flask"  , 'IgnoreCase',true) 
        ImageType = ImageTypeEnum.Flask;
    elseif  contains(dirName,"Coating", 'IgnoreCase',true) 
        ImageType = ImageTypeEnum.Coating;
    else
        ImageType = ImageTypeEnum.Unknown;
    end
    

end
