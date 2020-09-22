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
        %% Set/Get:
        function [] = set(obj , key , value )
            switch key
                case "Image2Show_color"
                    if value == "Colored"
                        obj.MainApp.ColoredMenu.Checked = "on";
                        obj.MainApp.GrayMenu.Checked = "off";
                    elseif value == "Gray"
                        obj.MainApp.ColoredMenu.Checked = "off";
                        obj.MainApp.GrayMenu.Checked = "on";
                    else
                        error("Unrecognized Color");
                    end
                otherwise 
                    error("Unknown key to set");
            end % switch
        end % set
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
        function [] = set_algoInProgress( obj , on_off_str )
            switch lower(string(on_off_str))
                case "on"
                    disp("WindowsManagerClass: setting algo in progress: 'on' ");
                case "off"
                    disp("WindowsManagerClass: setting algo in progress: 'off' ");
                otherwise
            end % switch
            obj.MainApp.set_algoInProgress(on_off_str)
        end % set_algoInProgress( on_off_str )
        function [] = update_progress_bar(obj , progressValue)
            if progressValue>1 || progressValue<0
                error("Invalid Value for ProgressBar");
            else
                obj.MainApp.EmbeddedProgressBar.update( progressValue );
            end            
        end % update_progress_bar
        function [] = update_mask_cover_percentage(obj , percentageValue)
            obj.MainApp.MaskCoverPercentageEditField.Value = percentageValue;
        end % function update_mask_cover_percentage()
    end % methods (Access = public)
    
end % classdef

