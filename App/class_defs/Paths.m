classdef  Paths
    
   properties
       AllDirectories
       AllPictures
       AvailablePictures
       
   end
    
   methods ( Access = public)
       function self = Paths(current_data_path , method , given_data_path)
           %self = Paths(FullPath)  c'tor for Paths object
           % input: 1.  fullpath 
           %            2.  method:  'Relative'   /  'Search'   / 'Given'  - method for searching for data.
           %            3. if method=='Given' :  path to Data folder
           
           % check input arguments
           if (nargin >= 2) && (~ischar(method) || ~isstring(method))
               error("Method input must be a string");
           end
           if (nargin == 1) %complete data with relative path
               method = 'relative';
           end
           % act according to input:
           method = lower(method); % lower case (insesitive string switch)
           switch method
               case 'search'
                   %Not yet implementd
               case 'given'
                   if (nargin >= 3)
                       DataDir =  given_data_path;
                   else
                       error("With 'given' must also give full path to data, as third input ");
                   end
               case 'relative'
                   DataDir = current_data_path  + "\..\..\Data" ;
               otherwise
                   error("Method input is wrong. See correct input");
           end % switch
           
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
    Pictures.NaturalImage = Directories.After21 + filesep + "21_B2R_1"  + ".tif'" ;
    
    Directories.SuperDirectory1 = DataDir + filesep + "1st set - red";
    Pictures.RedlImage =  Directories.SuperDirectory1 + filesep +  "2 - no segmentation"  + ".png" ;
    
end
