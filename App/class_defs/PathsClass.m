classdef  PathsClass
    
   properties
       
       % Directory Tree class:
       DirectoryTree DirTreeClass
       
       % Handy Containers:
       AllDirectories
       AllPictures
       AvailablePictures
       
       % Spesific Containers:
       CoatingDirectory
       ImagesForComparison
       Results
       
       
   end
    
   methods ( Access = public)
       function self = PathsClass(app_main_folder , method , given_data_folder)
           %function self = PathsClass(app_main_folder , method , given_data_folder)
           %  Construcor of calss PathsClass
           % 
           %  input arguments:
           %     * app_main_folder   (string)
           %     * method            (string) must be 'Relative','Search','Given'.   Default Value = 'Relative'.
           %     * given_data_folder (string) only give it if method=="Given".
       

           arguments
               app_main_folder   string
               method            string = "choose"
               given_data_folder string = string.empty()
           end
           


           % act according to input:
           switch lower(string(method)) % lower case (insesitive string switch)
               case "search"
                   DataDir = search_DataDir(app_main_folder);
               case "given"
                   if (nargin >= 3)
                       DataDir =  given_data_folder;
                   else
                       error("With 'given' must also give full path to data, as third input ");
                   end
               case "relative"
                   DataDir = app_main_folder  + "\..\..\Data" ;
               case "choose"
                   MsgStr = "Choose ""Main Data Folder"" with the selection tool. ";
                   disp(MsgStr);
                   Title = "Choose Main Data Folder:";                   
                   res = uigetdir(app_main_folder,Title);
                   if isnumeric(res) && res==0
                       error("User Didn't choose the main Data Folder");
                   else
                       DataDir = string(res);
                   end
                   
               otherwise
                   error("Method input is wrong. See correct input");
           end % switch
           
           %Make DataDir into a full path not relative (without  '\..\..\'):
           DataDir=string(GetFullPath(char(DataDir)));
           
           % complete all paths
           [ self.AllDirectories , self.AllPictures ] = get_all_paths(app_main_folder , DataDir);
           
           self.DirectoryTree = DirTreeClass(DataDir,true,"","Data Folder");
           
           % Coating Directory needs some specail attention:
           self.CoatingDirectory = organzie_CoatingDirectory_sub_dirs(self.AllDirectories.SuperDirectory4);
           
           % Images for comparison needs a seperate slot:
           self.ImagesForComparison = organize_ImagesForComparison(self.AllDirectories.SuperDirectory_ImagesForComparison , self );
           
           % Results Directory:
           self.Results = organize_Results_sub_dirs(self.AllDirectories , self);
           
           %For easy use, seperate all good pictures that can be used.
           self.AvailablePictures = struct(); 
           self.AvailablePictures.RedImage1     = self.AllPictures.RedlImage;
           self.AvailablePictures.NaturalImage1 = self.AllPictures.NaturalImage;
           self.AvailablePictures.Coating       = self.CoatingDirectory.day_5.C_F.Images{1};
           
       end %Paths (c'tor)
       

        function cell_array = AvailablePictures_string_cell_array(self)    
            cell_array = fieldnames( self.AvailablePictures );
        end

   end % methods
   
end



function [ Directories , Pictures] =  get_all_paths(CurrentDir , DataDir)

    Directories = struct();
    Pictures = struct();
    
    Directories.CurrentDir = CurrentDir;
    Directories.DataDir = DataDir;
    
    
    Directories.SuperDirectory1 = DataDir + filesep + "1st set - Red";
    Pictures.RedlImage =  Directories.SuperDirectory1 + filesep +  "2 - no segmentation"+".png" ;
    
    Directories.SuperDirectory2_Before = DataDir + filesep + "2nd set - Natural Light" + filesep +"BEFORE";
    Directories.SuperDirectory2_After  = DataDir + filesep + "2nd set - Natural Light" + filesep +"AFTER"  ;    
    Directories.After21 = Directories.SuperDirectory2_After +  filesep  + "21" ;
    Pictures.NaturalImage = Directories.After21 + filesep + "21_B2L.tif"  ;
    
    Directories.SuperDirectory4 = DataDir + filesep + "4th set - Coatings";
    
    Directories.SuperDirectory_TrialsAndError = DataDir + filesep + "Trial and Error";
    Pictures.grey_coating = Directories.SuperDirectory_TrialsAndError  + filesep + "grey_coating.tif";
    
    Directories.SuperDirectory_ImagesForComparison = DataDir + filesep + "Images for comparison";
    Pictures.Coating = Directories.SuperDirectory_ImagesForComparison  + filesep + "day 7_collagen_D5_2.tif";
    
    
end

function DataDir = search_DataDir(mainAppPath)
current_folder=string(mainAppPath);
%forbiedn directory (where to stop)  is base directory:
C = strsplit(mainAppPath,filesep);
rootFolder = C(1)+filesep;

prev_folder = current_folder;
DataDir = string.empty ;
StartTime = cputime;
while prev_folder ~= rootFolder  % Don't go too deep
    % Don't search for more than 5 seconds:
    CurrentTime = cputime;
    if CurrentTime  - StartTime > 5000
        break
    end    
    prev_folder = cd(current_folder+filesep+"..")    ; % go to parent folder 
    prev_folder  = string(prev_folder );
    current_folder = string(GetFullPath(char(current_folder+filesep+".."))) ; %update current folder as parent folder
    [is_found] = check_exist_folder(current_folder , "Data");
    if is_found
        DataDir = current_folder + filesep + "Data";
        cd(mainAppPath);
        return
    end
end

error("Couldn't find ""Data"" folder");

end


function  CoatingDirectory = organzie_CoatingDirectory_sub_dirs(CoatingDirPath)

    CoatingDirectory = struct();
    CoatingDirectory.subDirectories = {};
    CoatingDirectory.Path = CoatingDirPath;

    %{ find all sub-folders of main: }%
    daysDirs = dir(CoatingDirPath);
    for i = 1:length(daysDirs)
       dayDir = daysDirs(i);
       if ( string(dayDir.name) == "." ) || ( string(dayDir.name) == ".." )
          % do nothing 
       else
           nameParts = strsplit(dayDir.name," ");
           dayKeyName   = string(nameParts{1})+"_"+string(nameParts{2});
           % Create sub-struct:
           CoatingDirectory.( dayKeyName ) = struct();
           CoatingDirectory.( dayKeyName ).Path           = string(GetFullPath(dayDir.folder))+filesep+string(dayDir.name);         
           CoatingDirectory.( dayKeyName ).subDirectories = {}; 
           CoatingDirectory.( dayKeyName ).Name           = string(dayDir.name);
           CoatingDirectory.( dayKeyName ).key            = dayKeyName;
           % add to subDirectories cell array:
           CoatingDirectory.subDirectories{end+1} = dayKeyName ;                                          
       end
    end % for i
    
    
    %{ for each sub-folder (day-3, day-5, day-7), find its sub-folders :}%
    for i = 1 : length(CoatingDirectory.subDirectories)
        dayDirKeyName = CoatingDirectory.subDirectories{i};
        dayDir = CoatingDirectory.(dayDirKeyName) ;
        subFolders = dir(dayDir.Path);
        
        for j = 1:length(subFolders)
            subFolder = subFolders(j);
            if ( string(subFolder.name) == "." ) || ( string(subFolder.name) == ".." )
                % do nothing
            else
                nameParts = strsplit(subFolder.name,"+");
                if length(nameParts) >= 2
                    daySubFolderKeyName = string(nameParts{1})+"_"+string(nameParts{2});
                else
                    daySubFolderKeyName = string(nameParts{1});
                end
                % Create sub-struct:
                dayDir.( daySubFolderKeyName ) = struct();
                dayDir.( daySubFolderKeyName ).Path   = dayDir.Path + filesep + string(subFolder.name) ;
                dayDir.( daySubFolderKeyName ).Images = {};
                dayDir.( daySubFolderKeyName ).Name   = string(subFolder.name);
                dayDir.( daySubFolderKeyName ).key    = daySubFolderKeyName;
                % add to subDirectories cell array:
                dayDir.subDirectories{end+1} = daySubFolderKeyName ;
                
                % find all Images inside:
                ImagesFiles = dir(dayDir.( daySubFolderKeyName ).Path);
                for k = 1:length(ImagesFiles)
                    ImagesFile = ImagesFiles(k);
                    if ( string(ImagesFile.name) == "." ) || ( string(ImagesFile.name) == ".." )
                        % do nothing
                    else
                       dayDir.( daySubFolderKeyName ).Images{end+1} = string(ImagesFile.folder) + filesep + string(ImagesFile.name);
                    end
                    
                end % for k
                
                % replace new dayDir struct with old dayDir struct in CoatingDirectory:
                CoatingDirectory.(dayDirKeyName) = dayDir;
                
            end
        end % for j
        
    end % for i
    

end



function ImagesForComparison = organize_ImagesForComparison(SuperDirectory_ImagesForComparison , Paths)

    % dir(SuperDirectory_ImagesForComparison)
    
    ImagesForComparison = struct();
    % images
    ImagesForComparison.Red     = SuperDirectory_ImagesForComparison + filesep + "red.png";
    ImagesForComparison.Natural = SuperDirectory_ImagesForComparison + filesep + "23_B1_2.tif";
    ImagesForComparison.Flask   = SuperDirectory_ImagesForComparison + filesep + "flask 5_17.5.20.tif";
    ImagesForComparison.Coating = SuperDirectory_ImagesForComparison + filesep + "day 7_collagen_D5_2.tif";
    
    % info
    ImagesForComparison.info = struct();
    ImagesForComparison.info.Coating = struct();
    ImagesForComparison.info.Coating.dayStruct         = Paths.CoatingDirectory.day_7  ;
    ImagesForComparison.info.Coating.coatingTypeStruct = Paths.CoatingDirectory.day_7.C;
    ImagesForComparison.info.Coating.ImageIndex        = 6 ;

end


function Results = organize_Results_sub_dirs(AllDirectories , Paths)

    % Main struct:
    %============% 
    
    Results = struct();
    ResultsDir = AllDirectories.DataDir + filesep + ".." + filesep + "Results";
    ResultsDir = string( GetFullPath( char( ResultsDir ) ) );
    Results.Path = ResultsDir;
    
    % Sub Struct:
    %============% 
    
    % ImagesForComparison:
    Results.ImagesForComparison = struct();
    Results.ImagesForComparison.Path = Results.Path + filesep + "Images for comparison";
    Results.ImagesForComparison.SegmentationAppResults = struct();
    Results.ImagesForComparison.SegmentationAppResults.Path =  Results.ImagesForComparison.Path + filesep + "SegmentationApp Results" ;
    
    % Coating:
    Results.Coating = struct();
    Results.Coating.Path       = Results.Path  + filesep + "Coating";
    Results.Coating.OurResults = struct();
    Results.Coating.OurResults.Path = Results.Coating.Path  + filesep + "Our Results";
    Results.Coating.OurResults.SegmentationImages = struct();
    Results.Coating.OurResults.SegmentationImages.Path = Results.Coating.OurResults.Path + filesep + "Segmentation Images";    
    
    % Temp Results:
    Results.TempResults = struct();
    Results.TempResults.Path = Paths.AllDirectories.DataDir + filesep + "tempResults";
    Results.TempResults.tempMask_FullPath      = Results.TempResults.Path + filesep + "tempMask.mat";
    Results.TempResults.tempGrayImage_FullPath = Results.TempResults.Path + filesep + "tempGrayImage.tif";
    
    % Recording:
    Results.Recording = struct();
    Results.Recording.Path = Results.Path  + filesep + "Recordings";


end % self.Results = organize_Results_sub_dirs(self.AllDirectories)