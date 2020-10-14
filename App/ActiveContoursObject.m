classdef ActiveContoursObject < handle
    
    properties (Access = private)
        Paths ; % Class of all possible paths and images
        SegmentAlgo ; % Class to manage the parameters and execution of the Segmentation Algorithm 
        ImagesManager ;  % Class to controls the Behaviour, Manipulations, Additions and Acquisition  of Images
        WindowsManager ; % Manges and controls all open apps and windows
        ApearanceDefaultVals = struct('DefaultButtonColor' , [0.96, 0.96,0.96] , ...
                                      'ActiveButtonColor'  , [0.5 , 0.5 , 0  ] , ...
                                      'WaitingButtonColor' , [0.2 , 0.6 , 1  ] ,...
                                      'MaskColor'          , struct("ColoredImage" , [0,1,0] , ...
                                                                    "GrayImage"    , [1,0,0]   )...
                                   )
                                                                       
    end
    
    properties (Access = public)
        EmbeddedProgressBar
        pressOnScreenState = "idle";
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
            [currentDir] = app.assert_correct_app_folder(currentDir);
            
            %Continue creating the app's Object/Class properties:
            obj.Paths = PathsClass( string(currentDir) ,"Search");
%             app.Paths = PathsClass( "C:\Users\tarama\OneDrive - Intel Corporation\Desktop\???????\????? ?'\?????? ?\ImageProcessing-AirwayMicroscopy-Code\App" ,"given", "C:\Users\tarama\OneDrive - Intel Corporation\Desktop\???????\????? ?'\?????? ?\Data");
            obj.WindowsManager = WindowsManagerClass(obj , "object without app") ; % Manges and controls all open apps and windows
            app.ImagesManager  = ImagesManagerClass(app.WindowsManager , app.ApearanceDefaultVals ) ;
            app.SegmentAlgo    = SegmentationAlgoClass(app.ImagesManager , app.WindowsManager); 
            app.ImagesManager.SegmentAlgo = app.SegmentAlgo; % let ImagesManager know about SegmentAlgo
            app.EmbeddedProgressBar = EmbeddedProgressBar(app);
            
            % Set App default values at loading:
            app.set_default_values();
            app.WindowsManager.set("Image2Show_color" , "Colored");
            
            %Take care of images:            
            app.read_user_chosen_image();
        end % function obj = ActiveContoursObject()
        
        
        
    end %   methods (Access = public)
    
end % classdef
