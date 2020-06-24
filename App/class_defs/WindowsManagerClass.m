classdef WindowsManagerClass  < handle
    %WindowsManager Manges and controls all open apps and windows
 
    properties
        MainApp
        ImagesControl
        ImageWindow
        has_ImageWindow = false;
    end
    
    methods (Access = public)
        %% C'tor:
        function self = WindowsManagerClass( MainAppHandle)
            %self = SubWindows()  ; C'tor
            self.MainApp = MainAppHandle ; 
        end
        function [] = set_ImagesControl(obj , ImagesControlHandle)
            obj.ImagesControl = ImagesControlHandle;
        end
        %% Images Commands:
        function [] = show_image(obj , Im)
            if obj.has_ImageWindow
                obj.ImageWindow.show_image(Im);
            else
                 obj.MainApp.show_image(Im);
            end
        end
        %% Windows:
        function [] = show_image_window(obj )
            %METHOD1 Open and Show ImageWindow
            %   if already exist somewhere,  bring it into view
            
            if obj.has_ImageWindow
                %
            else
                obj.ImageWindow = ImageWindowApp( obj );
                obj.has_ImageWindow = true;
            end
            Im = obj.ImagesControl.Image2Show ;
            obj.show_image(Im);
        end % show_image_window
        
        function [] = close(obj, window_name_str)
            switch lower(string(window_name_str))
                case "mainapp" % Close main app and all other apps:
                    delete(obj.MainApp)
                    delete(obj.ImageWindow)
                case "imagewindow"
                    delete(obj.ImageWindow)  
                    obj.has_ImageWindow = false;
                otherwise
                        error('Wrong windiw_name_str string ');
            end % switch
        end
        
    end % methods (Access = public)
    
end % classdef

