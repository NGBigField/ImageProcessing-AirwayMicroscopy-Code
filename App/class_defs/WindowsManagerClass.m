classdef WindowsManagerClass  < handle
    %WindowsManager Manges and controls all open apps and windows
 
    properties
        % Other classes we should know about:        
        ImagesManager          ImagesManagerClass
        Paths                  PathsClass
        
        % Apps and Windows
        MainApp                ActiveContoursApp
        MainObject             ActiveContoursObject
        SingleImageWindow      ImagesManagerClass
        
        has_MainApp            logical = false;
        has_MainObject         logical = false;
        has_SingleImageWindow  logical = false;
        
        %Recording:
        Recording = struct( "isRecording"   , false                       )
                            
        
        Config = struct("UpdateAllOpenWindows"        , true ,  ...
                        "SaveRecordingInPathsResults" , true       );
        
    end
    
    methods (Access = public)
        %% C'tor:
        function obj = WindowsManagerClass( MainCallingObjectHandle , optionStr)
            arguments
                MainCallingObjectHandle
                optionStr string = string.empty  % can be  "object without app" / "app"
            end
            
            if     optionStr == "app"            
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
            switch lower(string(key))
                case lower("Image2Show_color")
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
                case lower("Recording")
                    if     value == "start"
                        obj.Recording.isRecording = true;
                        % Full path:                        
                        if obj.Config.SaveRecordingInPathsResults
                            folder = obj.Paths.Results.Recording.Path;
                        else
                            folder = string(pwd); 
                        end                        
                        time = clock;
                        timeStamp = string(time(1)) + "-" + sprintf("%02d",time(2)) + "-" + sprintf("%02d",time(3)) + " " + sprintf("%02d",time(4)) + "-" + sprintf("%02d",time(5)) + "-" + sprintf("%02d",round(time(6)));
                        fullPath = folder + filesep + "Recording " + timeStamp + ".avi";                        
                        % start video writer:
                        obj.Recording.writerObj = VideoWriter(fullPath);
                        obj.Recording.writerObj.Quality    = 100;
                        obj.Recording.writerObj.FrameRate  = 10;                                                
                        %open
                        obj.Recording.writerObj.open();
                    elseif value == "stop"
                        obj.Recording.isRecording = false;                        
                        % close
                        obj.Recording.writerObj.close();
                    elseif value == "pause"
                        obj.Recording.isRecording = false;

                    else
                        error( string(value)+" not supproted for set recording");
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
            
            % Record Image if needed:
            if obj.Recording.isRecording
                % Adjust Frame
                Im = obj.AdjustFrame4VideoWriter(Im);
                % record Frame:
                obj.Recording.writerObj.writeVideo( Im );
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
            if obj.has_MainApp
                obj.MainApp.set_algoInProgress(on_off_str)
            end
        end % set_algoInProgress( on_off_str )
        function [] = update_progress_bar(obj , progressValue)
            if progressValue>1 || progressValue<0
                error("Invalid Value for ProgressBar");
            else
                if obj.has_MainApp
                    obj.MainApp.EmbeddedProgressBar.update( progressValue );
                end
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
    
    methods (Access = protected)
       %% Video Writer Functions: 
       
       function Im = AdjustFrame4VideoWriter(obj,Im)
           % Correct Image size:
           if ~isempty(obj.Recording.writerObj.Height)
               requiredImSize = [obj.Recording.writerObj.Height, obj.Recording.writerObj.Width];
               incomingImSize = [size(Im,1) , size(Im,2)];
               if  any(requiredImSize ~= incomingImSize)
                   Im = imresize(Im, requiredImSize);
               end
           end
           % Correct Pixel Values:
           if min(Im,[],'all') < 0
               Im = Im - min(Im,[],'all') ;
           end
           if max(Im,[],'all') > 1
               Im = Im ./ max(Im,[],'all');
           end
       end % AdjustFrame4VideoWriter
       
    end
end % classdef


