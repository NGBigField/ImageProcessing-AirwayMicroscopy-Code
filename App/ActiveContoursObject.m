classdef ActiveContoursObject < handle
    
    properties (Access = public)
        Paths              PathsClass            % Class of all possible paths and images
        SegmentAlgo        SegmentationAlgoClass % Class to manage the parameters and execution of the Segmentation Algorithm 
        ImagesManager      ImagesManagerClass    % Class to controls the Behaviour, Manipulations, Additions and Acquisition  of Images
        WindowsManager     WindowsManagerClass   % Manges and controls all open apps and windows

        pressOnScreenState = "idle";
        
        ImageFigH 
    end
    
    properties (Access = private)        
        ApearanceDefaultVals = struct('DefaultButtonColor' , [0.96, 0.96,0.96] , ...
                                      'ActiveButtonColor'  , [0.5 , 0.5 , 0  ] , ...
                                      'WaitingButtonColor' , [0.2 , 0.6 , 1  ] ,...
                                      'MaskColor'          , struct("ColoredImage" , [0,1,0] , ...
                                                                    "GrayImage"    , [1,0,0]   )...
                                   )                                                              
    end
    

    
    
    methods (Access = public) 
        %% methods (Access = public) 
        
        function obj = ActiveContoursObject()
        % App folder:
            if isdeployed % Stand-alone mode.
                [status, result] = system('path');
                disp(status);
                currentDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
            else % MATLAB mode.
                currentDir = pwd;
            end           
            % check correct path and add to MATLAB'S paths:
            currentDir = string(currentDir);
            [currentDir] = assert_correct_app_folder(obj , currentDir , false);
            
            %Continue creating the app's Object/Class properties:
            obj.Paths = PathsClass( string(currentDir) ,"Search");
%             app.Paths = PathsClass( "C:\Users\tarama\OneDrive - Intel Corporation\Desktop\???????\????? ?'\?????? ?\ImageProcessing-AirwayMicroscopy-Code\App" ,"given", "C:\Users\tarama\OneDrive - Intel Corporation\Desktop\???????\????? ?'\?????? ?\Data");
            obj.WindowsManager = WindowsManagerClass(obj , "object without app") ; % Manges and controls all open apps and windows
            obj.ImagesManager  = ImagesManagerClass(obj.WindowsManager , obj.ApearanceDefaultVals ) ;
            obj.SegmentAlgo    = SegmentationAlgoClass(obj.ImagesManager , obj.WindowsManager); 
            obj.ImagesManager.SegmentAlgo = obj.SegmentAlgo; % let ImagesManager know about SegmentAlgo
%             obj.EmbeddedProgressBar = EmbeddedProgressBar(obj);
            
            % Set App default values at loading:
            [Config] = default_params(  );
%             obj.set_default_values();
            obj.WindowsManager.set("Image2Show_color" , "Colored");
            
            %Take care of images:            
%             obj.read_user_chosen_image();
        end % function obj = ActiveContoursObject()
        
        function [] = show_image(obj , Im)
            arguments
               obj ActiveContoursObject
               Im 
            end
            
            if isempty(obj.ImageFigH) || ~isgraphics(obj.ImageFigH)
                obj.ImageFigH = figure();  
                obj.ImageFigH.Name = "ActiveContoursObject Image Figure";
            end
            % Focus image into view:
            figure(obj.ImageFigH)
            % show:
            imshow(Im);
            
        end
        
        function wrong_folder_msg(obj , folder_that_should_exist , isErrorIfNotMainFolder)            
            
            arguments
                obj ActiveContoursObject
                folder_that_should_exist (:,1) string
                isErrorIfNotMainFolder logical = true
            end
            
            ErrorMsg = "Object Loading Error: Object should run on its main folder with subfolders:";
            for i = 1 : length(folder_that_should_exist)
                ErrorMsg = ErrorMsg + newline + "    - " + folder_that_should_exist(i);
            end
            
            if isErrorIfNotMainFolder
                error(ErrorMsg);
            else
                warning(ErrorMsg)
            end
            
        end % wrong_folder_msg
        
    end %   methods (Access = public)
    
end % classdef
