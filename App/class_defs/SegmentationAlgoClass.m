classdef SegmentationAlgoClass  < handle % < matlab.mixin.SetGet
    %SegmentationAlgoClass Class to manage the parameters and execution of the Segmentation Algorithm.
    %   Will store parameters which the user choose with the main app
    %   Will run the algorithm when the user chooses to do so.
    
    properties
        Params= default_params();

        Masks_cell = {}  % the thing that we're looking for.
        ImagesManager % Class to controls the Behaviour, Manipulations, Additions and Acquisition  of Images
        WindowsManager ; % Manges and controls all open apps and windows
        
        State  = AlgorithmStateEnum.Idle;
    end
    
    methods (Access = public)
        %% C'tor:
        function obj = SegmentationAlgoClass(ImagesManager , WindowsManager)
            %SegmentationAlgoClass Construct an instance of this class
            obj.ImagesManager = ImagesManager;
            obj.WindowsManager = WindowsManager;
            obj.Params = default_params();
        end
        %% Set/Get:
        function [] = set(obj  , Name , Value)
            %set_param set the params that the user chose, and other important values.
            switch Name
                case "AlgorithmFunction"
                    obj.Params.General.ChosenAlgorithm = Value;
                case "MatlabFunctionMethod"
                    obj.Params.MatlabBuiltIn.Method = Value;
                case "ContractionBias"
                    obj.Params.MatlabBuiltIn.ContractionBias = Value;
                case "SmoothFactor"
                    obj.Params.MatlabBuiltIn.SmoothFactor = Value;
                case "IterationsPerFrame"
                    obj.Params.MatlabBuiltIn.IterationsPerFrame = Value;
                    
                otherwise
                        error("Unkown Name");
            end %Switch
        
        end
        %% Control:
        function [  ] = start_or_stop_algorithm(obj)
            switch obj.State
                case AlgorithmStateEnum.Idle
                    % Start"
                    obj.start_algorithm();
                    
                case AlgorithmStateEnum.InProgress
                    % User Asked to stop. Just update the new state.
                    obj.State = AlgorithmStateEnum.UserAskedToStop;
                    
                case AlgorithmStateEnum.UserAskedToStop
                    % Stop:
                    obj.stop_algorithm();
                    
                otherwise
                    error("Not a legit State");
            end % Switch
        end % start_or_stop_algorithm(obj)
        function [] = start_algorithm(obj)
            %check if we're ready:
            if isempty( obj.Masks_cell )
                warning("Choose Region Of Interest 'ROI'  before starting algorithm");
                obj.stop_algorithm();
                return
            end
            %update:
            obj.State = AlgorithmStateEnum.InProgress;
            obj.WindowsManager.set_algoInProgress(  "on" );
            %go:
            switch obj.Params.General.ChosenAlgorithm
                case AvailableAlgorithms.MatlabBuiltIn
                    obj.start_MatlabBuiltIn();
                case AvailableAlgorithms.Lankton
                    obj.start_Lankton();
                case AvailableAlgorithms.Watershed
                    obj.start_Watershed();
                otherwise
                        error("Unkown AlgorithmFunction");
            end%switch
            obj.stop_algorithm();
            obj.calc_and_show_mask_cover_percentage();
        end % start_algorithm 
        function  [] = stop_algorithm(obj)
            % Are we stopping, or just asking to stop:
            disp("Stopping Algorithm");
            obj.State = AlgorithmStateEnum.Idle;
            obj.WindowsManager.set_algoInProgress(  "off" );
        end % stop_algorithm
        %% Masks:
        function [] = add_mask(obj , Mask)
            obj.Masks_cell{end+1} = Mask;
        end
        function [] = clear_masks(obj)
            obj.Masks_cell = {};
        end
        function [ShrinkedTotalMask] = shrink_masks(obj)
            ShrinkedTotalMask = zeros(size(obj.Masks_cell{1}));
            for i = 1 : length(obj.Masks_cell)
                obj.Masks_cell{i} = center_of_mask(obj.Masks_cell{i});
                ShrinkedTotalMask = ShrinkedTotalMask | obj.Masks_cell{i};
            end
        end
        function maskPercentage = calc_and_show_mask_cover_percentage(obj )
            % Calc Mask Cover:
            TotalMask = zeros(size(obj.Masks_cell{1}));
            for i = 1 : length(obj.Masks_cell)
                obj.Masks_cell{i} = center_of_mask(obj.Masks_cell{i});
                TotalMask = TotalMask | obj.Masks_cell{i};
            end
            maskCover = sum(TotalMask ,'all');
            % Calc Image Totall Cover
            imageSize = size(obj.ImagesManager.ColoredImage2Use);
            imageCover = imageSize(1)*imageSize(2);
            % Calc Percentage:
            maskPercentage = 100*maskCover/imageCover;
            % Show:
            obj.WindowsManager.update_mask_cover_percentage(maskPercentage);
        end
    end % methods (Access = public)
    
    %%  Segmentation Algorithms:
    methods (Access = protected)
        function [] = start_MatlabBuiltIn(obj)
            
            
            % Reset ProgressBar:
            obj.WindowsManager.update_progress_bar( 0 );
            
            %parse Parameters:
            MaxIterationNum   = obj.Params.MatlabBuiltIn.MaxNumIteration;
            IterationsPerFrame  = obj.Params.MatlabBuiltIn.IterationsPerFrame;
            Im                              = obj.ImagesManager.GreyImage;
            Method                      = Method2MatlabString( obj.Params.MatlabBuiltIn.Method );
            SmoothFactor           = obj.Params.MatlabBuiltIn.SmoothFactor;
            ContractionBias        = obj.Params.MatlabBuiltIn.ContractionBias;
            
            % Iterate many times:
            for frameIndex = 1 : MaxIterationNum/IterationsPerFrame
                
                % Create a mask that is the results of all the masks in the current frame:
                NewMask2Show     = zeros( size( obj.ImagesManager.GreyImage  ) );
                
                %Go over all masks:
                for maskIndex = 1 : length( obj.Masks_cell )
                    
                    MaskIn = obj.Masks_cell{maskIndex};
                    % Active Contours on this mask:
                    MaskOut = activecontour(Im , MaskIn , IterationsPerFrame , Method , ...
                        'SmoothFactor' , SmoothFactor,...
                        'ContractionBias' , ContractionBias ...
                        );
                    % if masks is empty now, delete it and ignore it for next times
                    if any( MaskOut , 'all') % if it's not empty
                        obj.Masks_cell{maskIndex} = MaskOut;
                    else % if empty
                        obj.Masks_cell(maskIndex) = [];
                        disp("Deleted mask at index " + num2str( maskIndex ) );
                        break % Go back to before we've calculated    length( obj.Masks_cell )
                    end
                    % Update the next mask to show:
                    NewMask2Show = NewMask2Show  |  MaskOut;
    
                end % maskIndex
                
                % Print Progress:
                iterations_text = sprintf('Frame %04d / %d', frameIndex , MaxIterationNum/IterationsPerFrame) ;
                disp( iterations_text );
                    
                if  obj.State == AlgorithmStateEnum.UserAskedToStop
                    % If user asked to stop -  Terminate:
                    break
                else
                    % ProgressBar
                    val  =  frameIndex*IterationsPerFrame  / MaxIterationNum;
                    obj.WindowsManager.update_progress_bar( val );
                end
                
                %refresh all masks in image:
                obj.ImagesManager.mask_over_image(  NewMask2Show , "FromScratch");
                
                % Update Mask Cover Percentage:
                [~] = obj.calc_and_show_mask_cover_percentage();
                
            end % for frameIndex
        end % start_MatlabBuiltIn
        function [] = start_Lankton(obj)
      
        end % start_MatlabBuiltIn
        function [] = start_Watershed(obj)
            [newTotalMask ] = WaterShed(obj.ImagesManager.GreyImage , obj.Masks_cell , obj.Params.WaterShed);
            obj.ImagesManager.mask_over_image( newTotalMask  , "FromScratch" );
            obj.Masks_cell = seperate_mask(newTotalMask);
        end % start_Watershed
    end %  (Access = protected)
    
end % class




function MatlabMethodString =  Method2MatlabString(GivenMethodString)

    switch lower(GivenMethodString)
        case lower("Region")
            MatlabMethodString = "Chan-Vese";
        case lower("Edge")
            MatlabMethodString = "edge";
        otherwise
            error("Got: " + GivenMethodString + " .     Not a known Method");
    end

end % Method2MatlabString
