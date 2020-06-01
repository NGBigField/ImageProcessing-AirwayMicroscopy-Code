classdef WindowsManagerClass  < handle
    %WindowsManager Manges and controls all open apps and windows
 
    
    properties
        MainApp
        ImageWindow
        has_ImageWindow = false;
    end
    
    methods (Access = public)
        
        
        function self = WindowsManagerClass( MainAppHandle)
            %self = SubWindows()  ; C'tor
            self.MainApp = MainAppHandle ; 
        end
        
        function [] = show_image_window(self )
            %METHOD1 Open and Show ImageWindow
            %   if already exist somewhere,  bring it into view
            
            if self.has_ImageWindow
                %
            else
                self.ImageWindow = ImageWindowApp( self );
                self.has_ImageWindow = true;
            end
        end % show_image_window
        
        function [] = close(self, windiw_name_str)
            switch lower(windiw_name_str)
                case lower('MainApp') % Close main app and all other apps:
                    delete(self.MainApp)
                    delete(self.ImageWindow)
                case lower('ImageWindow')
                    delete(self.ImageWindow)                
                otherwise
                        error('Wrong windiw_name_str string ');
            end % switch
        end
        
    end % methods (Access = public)
    
end % classdef

