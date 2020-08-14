classdef  PathsClass
    
   properties
       AllDirectories
       AllPictures
       AvailablePictures
       
   end
    
   methods ( Access = public)
       function self = PathsClass(current_data_path , method , given_data_path)
           %PathsClass(FullPath)  c'tor for Paths object
           % input: 1.  fullpath 
           %            2.  method:  'Relative' (Default)   /  'Search'   / 'Given'    : methods for searching for data.
           %            3. if method=='Given' :  path to Data folder
           
           % check input arguments
           if (nargin >= 2) &&  ~ischar(method) && ~isstring(method) 
               error("Method input must be a string");
           end
           if (nargin == 1) %complete data with relative path
               method = "relative";
           end
           % act according to input:
           method = lower(string(method)); % lower case (insesitive string switch)
           switch method
               case "search"
                   DataDir = search_DataDir(current_data_path);
               case "given"
                   if (nargin >= 3)
                       DataDir =  given_data_path;
                   else
                       error("With 'given' must also give full path to data, as third input ");
                   end
               case "relative"
                   DataDir = current_data_path  + "\..\..\Data" ;
               otherwise
                   error("Method input is wrong. See correct input");
           end % switch
           
           %Make DataDir into a full path not relative (without  '\..\..\'):
           DataDir=string(GetFullPath(char(DataDir)));
           
           % complete all paths
           [ self.AllDirectories , self.AllPictures ] = get_all_paths(current_data_path , DataDir);
           
           %For easy use, seperate all good pictures that can be used.
           self.AvailablePictures = struct(); 
           self.AvailablePictures.RedImage1 = self.AllPictures.RedlImage;
           self.AvailablePictures.NaturalImage1 = self.AllPictures.NaturalImage;
           self.AvailablePictures.Brain =  self.AllPictures.Brain;
       end %Paths (c'tor)
       

        function cell_array = AvailablePictures_string_cell_array(self)    
            cell_array = fieldnames( self.AvailablePictures);
        end

   end % methods
   
end



function [ Directories , Pictures] =  get_all_paths(CurrentDir , DataDir)

    Directories = struct();
    Pictures = struct();
    
    Directories.CurrentDir = CurrentDir;
    Directories.DataDir = DataDir;
    
    Pictures.Brain =  CurrentDir + filesep + "example_data"  + filesep +  "medtest.png" ;
    
    Directories.SuperDirectory2_Before = DataDir + filesep + "2nd set - light"+ filesep +"BEFORE";
    Directories.SuperDirectory2_After   = DataDir + filesep  + "2nd set - light"+ filesep +"AFTER"  ;
    Directories.After21 = Directories.SuperDirectory2_After +  filesep  + "21" ;
    Pictures.NaturalImage = Directories.After21 + filesep + "21_B2L"  + ".tif'" ;
    
    Directories.SuperDirectory1 = DataDir + filesep + "1st set - red";
    Pictures.RedlImage =  Directories.SuperDirectory1 + filesep +  "2 - no segmentation"  + ".png" ;
    
end

function DataDir = search_DataDir(mainAppPath)
current_folder=mainAppPath;
%forbiedn directory (where to stop)  is base directory:
C = strsplit(mainAppPath,filesep);
rootFolder = C(1)+filesep+C(2);

prev_folder = current_folder;
DataDir = [] ;
while prev_folder ~= rootFolder  % Don't go too deep
    prev_folder = cd(current_folder+filesep+"..")    ; % go to parent folder 
    prev_folder  = string(prev_folder );
    current_folder = prev_folder+filesep+".." ; %update current folder as parent folder
    [is_found] = check_exist_folder(current_folder , "Data");
    if is_found
        DataDir = current_folder + filesep + "Data";
        cd(mainAppPath);
        return
    end
end

error("Couldn't find ""Data"" folder");

end

