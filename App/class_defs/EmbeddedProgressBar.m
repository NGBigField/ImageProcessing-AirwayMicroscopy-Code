classdef EmbeddedProgressBar
    %EMBEDDEDPROGRESSBAR To be visible while the app is running
    %   Use this object to update the progress bar
    
    properties
        MainApp
        
        Patch
        Text
        
        BackgroundColor =  [0.9375 0.9375 0.9375];  %gray
        ProgressColor  = [0.67578 1 0.18359];  %yelloish
    end
    
    methods
        function obj = EmbeddedProgressBar(app)
            %EMBEDDEDPROGRESSBAR Construct an instance of this class
            %   Use the app as an input
            obj.MainApp = app;
            
            % define apearance of progress bar:
            Ax = app.ProgressBarAxes;
            Ax.Box = 'on';
            Ax.XTick = [];
            Ax.YTick = [];
            Ax.XLim = [0,1];
            Ax.YLim = [0,1];
            Ax.Color = obj.BackgroundColor;
            %no texts:
            Ax.Title.String = '';
            Ax.XLabel.String  = '';
            Ax.YLabel.String  = '';
            
            % Create empty patch that will be updated
            obj.Patch = patch(Ax,[0 0 0 0],[0 0 1 1],obj.ProgressColor); %greenyellow
            obj.Patch.LineStyle ='none';
            
            % Create the percent-complete text that will be updated
            obj.Text= app.ProgressBarText;
            obj.Text.Text ="";
            
            % Popup toolbar behaviour:
            Toolbar = obj.Patch.Parent.Toolbar;
            Toolbar.Visible = 'off' ;
        end
        
        function [] = update(obj,value)
            %UPDATE update the progress bar
            %   Value must be in the range [0,1].
            
                % update patch size and percentage text
                obj.Patch.XData = [0 value value 0];
                obj.Text.Text = sprintf('%.0f%%',round(value*100));
                drawnow limitrate %update graphics
        end
    end
end

