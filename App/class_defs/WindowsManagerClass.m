classdef WindowsManagerClass  < handle
    %WindowsManager Manges and controls all open apps and windows
 
    properties
        % Images Manager Class:
        ImagesManager
        
        % Apps and Windows
        MainApp
        MainObject
        SingleImageWindow
        
        has_MainApp           = false;
        has_MainObject        = false;
        has_SingleImageWindow = false;
        
        Config = struct("UpdateAllOpenWindows" , true)
    end
    
    methods (Access = public)
        %% C'tor:
        function obj = WindowsManagerClass( MainCallingObjectHandle , optionStr)
            arguments
                MainCallingObjectHandle
                optionStr string = string.empty  % can be  "object without app" / "app"
            end
            
            if optionStr == "app"            
                obj.MainApp = MainCallingObjectHandle ;
                obj.has_MainApp = true;
            elseif optionStr == "object without app"
                obj.MainObject = MainCallingObjectHandle ;
                obj.has_MainObject = true;
            else
                error("optionStr="""+ optionStr +""".  Unexpected optionStr");
            end
                
        end % c'tor
        function [] = set_ImagesManager(obj , ImagesManagerHandle)
            obj.ImagesManager = ImagesManagerHandle;
        end % set_ImagesManager
        %% Set/Get:
        function [] = set(obj , key , value )
            switch key
                case "Image2Show_color"
                    if ~obj.has_MainApp
                        return
                    end                    
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
            
            isPlotOnMainApp = false;
            isPlotOnMainObject = false;
            isPlotOnSingleImageWindow = false;
            
            % decide where to plot:
            if obj.has_SingleImageWindow
                isPlotOnSingleImageWindow = true;
                if obj.Config.UpdateAllOpenWindows && obj.has_MainApp
                    isPlotOnMainApp = true;
                end
                if obj.Config.UpdateAllOpenWindows  && obj.has_MainObject
                    isPlotOnMainObject = true;
                end
            else
                if obj.has_MainApp
                    isPlotOnMainApp =true;
                elseif obj.has_MainObject
                    isPlotOnMainObject = true;                    
                else
                    error("Seems like WindowsManagerClass has no open windows to show_image() on ");
                end
            end
            
            % plot according to decision:
            if isPlotOnMainApp
                obj.MainApp.show_image(Im);
            end
            if isPlotOnMainObject
                obj.MainObject.show_image(Im);
            end
            if isPlotOnSingleImageWindow                
                obj.SingleImageWindow.show_image(Im);
            end
        end
        %% Windows:
        function [] = show_image_window(obj )
            %METHOD1 Open and Show SingleImageWindow
            %   if already exist somewhere,  bring it into view
            
            if obj.has_SingleImageWindow
                %Do nothing
            else
                obj.SingleImageWindow = ImageWindowApp( obj );
                obj.has_SingleImageWindow = true;
            end
            Im = obj.ImagesManager.Image2Show ;
            obj.show_image(Im);
        end % show_image_window
        
        function [] = close(obj, window_name_str)
            switch lower(string(window_name_str))
                case "mainapp" % Close main app and all other apps:
                    delete(obj.MainApp)
                    delete(obj.SingleImageWindow)
                case "imagewindow"
                    delete(obj.SingleImageWindow)  
                    obj.has_SingleImageWindow = false;
                case "mainObject"
                    warning("We need to decide what to do in that case");
                otherwise
                        error("window_name_str="""+string(window_name_str)+""".  Wrong window_name_str string ");
            end % switch
        end
        function [] = set_algoInProgress( obj , on_off_str )
            switch lower(string(on_off_str))
                case "on"
                    disp("WindowsManagerClass: setting algo in progress: 'on' ");
                case "off"
                    disp("WindowsManagerClass: setting algo in progress: 'off' ");
                otherwise
                    error("on_off_str="""+on_off_str+"""  Not an expected string");
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
            arguments
                obj WindowsManagerClass
                percentageValue {mustBeReal , mustBeNonnegative}
            end            
            obj.MainApp.MaskCoverPercentageEditField.Value = percentageValue;
        end % function update_mask_cover_percentage()
    end % methods (Access = public)
    
end % classdef

