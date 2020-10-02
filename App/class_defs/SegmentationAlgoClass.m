classdef SegmentationAlgoClass  < handle % < matlab.mixin.SetGet
    %SegmentationAlgoClass Class to manage the parameters and execution of the Segmentation Algorithm.
    %   Will store parameters which the user choose with the main app
    %   Will run the algorithm when the user chooses to do so.
    
    properties
        Params = default_params();

        Masks_cell = {}  % the thing that we're looking for. Each mask in the cell array is for a seperate ROI and finally for a seperate living/dead cell area.
        ImagesManager % Class to controls the Behaviour, Manipulations, Additions and Acquisition  of Images
        WindowsManager ; % Manges and controls all open apps and windows 
        
        State  = AlgorithmStateEnum.Idle;
        scaling = 1;
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
                % General:
                case "AlgorithmFunction"
                    obj.Params.General.ChosenAlgorithm = ChosenMethodEnumFromString( Value );
                 % Snakes: Matlab Built in:
                case "MatlabFunctionMethod"
                    obj.Params.MatlabBuiltIn.Method = Value;
                case "ContractionBias"
                    obj.Params.MatlabBuiltIn.ContractionBias = Value;
                case "SmoothFactor"
                    obj.Params.MatlabBuiltIn.SmoothFactor = Value;
                case "IterationsPerFrame"
                    obj.Params.MatlabBuiltIn.IterationsPerFrame = Value;
                 % WaterShed:
                case "WaterShed Tolerance"
                    obj.Params.WaterShed.Tolerance = Value;
                 % Adaptive Threshold:
                case "Adaptive WindowSize"
                    obj.Params.AdaptiveThreshold.WindowSize = Value;
                case "Adaptive Threshold"
                    obj.Params.AdaptiveThreshold.Threshold = Value;
                case "Adaptive DiskRadius"
                    obj.Params.AdaptiveThreshold.DistRadius = Value;
                case "Adaptive SolidityUpperThreshold"
                    obj.Params.AdaptiveThreshold.SolidityUpperThresh = Value;
                case "Adaptive SolidityLowerThreshold"
                    obj.Params.AdaptiveThreshold.SolidityLowerThresh = Value;
                case "Adaptive MedianOrMean"
                    if Value ~= 0 && Value ~= 1 
                        error("Wrong Input");
                    end
                    obj.Params.AdaptiveThreshold.MeanOrMedian = Value;
                        
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
            if isempty( obj.Masks_cell ) && (obj.Params.General.ChosenAlgorithm ~= AvailableAlgorithms.AdaptiveThreshold) % AdaptiveThreshold doesn't need exisitng masks
                warning("Choose Region Of Interest 'ROI'  before starting algorithm");
                obj.stop_algorithm();
                return
            end
            %update:
            obj.State = AlgorithmStateEnum.InProgress;
            obj.WindowsManager.set_algoInProgress(  "on" );
            %go:
            switch obj.Params.General.ChosenAlgorithm
                case AvailableAlgorithms.AdaptiveThreshold
                    obj.start_AdaptiveThreshold();
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
            obj.WindowsManager.update_progress_bar(0); % reset progress bar;
        end % stop_algorithm
        %% Masks:
        function [] = add_mask(obj , Mask)
            obj.Masks_cell{end+1} = sparse( obj.resize_mask_to_full_resolution(Mask) );
        end
        function [] = clear_masks(obj)
            obj.Masks_cell = {};
        end
        function [ShrinkedTotalMask] = shrink_masks(obj)
            ShrinkedTotalMask = false(size(obj.Masks_cell{1}));
            for i = 1 : length(obj.Masks_cell)
                obj.Masks_cell{i} = sparse( center_of_mask(obj.Masks_cell{i}) );
                ShrinkedTotalMask = ShrinkedTotalMask | obj.Masks_cell{i};
            end
        end
        function maskPercentage = calc_and_show_mask_cover_percentage(obj )
            % Calc Mask Cover:
            TotalMask = obj.total_mask();
            maskCover = sum(TotalMask ,'all');
            % Calc Image Totall Cover            
            imageSize = obj.ImagesManager.get("Image2Show_Size");
            imageCover = imageSize(1)*imageSize(2);
            % Calc Percentage:
            maskPercentage = 100*maskCover/imageCover;
            % Show:
            obj.WindowsManager.update_mask_cover_percentage(maskPercentage);
        end
        function mask_index =  find_mask(obj , location)
            location = round(location);
            y_pointer = location(1);
            x_pointer = location(2);
            for i = 1 : length(obj.Masks_cell)
                Mask = obj.Masks_cell{i};
                [x_mask,y_mask] = find(Mask==1);
                if any(x_pointer == x_mask & y_pointer == y_mask )
                    mask_index = i;
                    return
                end
            end
            %we got here, we found nothing:
            mask_index = [];
            
        end
        function [] =  remove_mask(obj , mask_index)
            obj.Masks_cell(mask_index) = [];
        end
        function [TotalMask] = total_mask(obj)
            arguments
                obj SegmentationAlgoClass                
            end
            
            if  isempty(obj.Masks_cell)
                TotalMask = [];
            else
                scalingFactor = obj.scaling;
                
                ImSize = obj.ImagesManager.get("Image2Show_Size");                
                TotalMask = false([ImSize(1) , ImSize(2)]);
                for i = 1 : length(obj.Masks_cell)
                    Mask = full(obj.Masks_cell{i});
                    if scalingFactor<1
                        Mask = imresize(Mask , scalingFactor);
                    end
                    TotalMask = TotalMask | Mask ;
                end
            end            
        end % total_mask
        function [] = replot_all_masks(obj)
            arguments
                obj SegmentationAlgoClass                
            end
            
            NumMasksCell = length(obj.Masks_cell);
            if NumMasksCell == 0
                return
            end
            
            TotalMask = obj.total_mask();
            obj.ImagesManager.mask_over_image(TotalMask , "FromScratch");            
        end
        function [resized_mask_cell_array] = resized_masks_cell_array(obj , mask_cell_array ,  resizeStr)
            % resizeStr == "Back2OriginalSize" / "ReducedSize" ;
            if isempty(mask_cell_array)
                return
            end
                
            resized_mask_cell_array = cell(size(mask_cell_array));
            for i = 1 : length(obj.Masks_cell)
                if obj.scaling == 1
                    resized_mask_cell_array{i} = mask_cell_array{i};
                elseif obj.scaling < 1 && obj.scaling > 0
                    if resizeStr == "ReducedSize"
                        resized_mask_cell_array{i} = sparse( imresize( full( mask_cell_array{i} ) , obj.scaling) );
                    elseif resizeStr == "Back2OriginalSize"
                        resized_mask_cell_array{i} = sparse( obj.resize_mask_to_full_resolution( full(mask_cell_array{i}) ) );
                    else
                       error("Not a legit resizeStr. We got resizeStr = " + string(resizeStr)); 
                    end                    
                else
                   error("not a legit scaling.  We got scaling="+string(obj.scaling)); 
                end
                
            end % for i
            
        end % resize_masks_cell_array
        function MaskOut = resize_mask_to_full_resolution(obj , MaskIn)
            if obj.scaling < 1                            
                OriginalImageSize = obj.ImagesManager.get("OriginalImage_Size") ;
                MaskOut = imresize( MaskIn , [OriginalImageSize(1) , OriginalImageSize(2) ] );                            
            else
                MaskOut = MaskIn;
            end
        end % resize_mask_to_full_resolution
    end % methods (Access = public)
    
    %%  Segmentation Algorithms:
    methods (Access = protected)
        function [] =start_AdaptiveThreshold(obj)
            
            im = obj.ImagesManager.get("GrayImage");                        
            obj.WindowsManager.update_progress_bar(10/100); % Update progressbar:            
            % find all blobs (mask of everything):
            TotalMask = AdaptiveThreshold(im, obj.Params.AdaptiveThreshold.WindowSize,          obj.Params.AdaptiveThreshold.Threshold, ...
                                              obj.Params.AdaptiveThreshold.MeanOrMedian,        obj.Params.AdaptiveThreshold.DistRadius, ...
                                              obj.Params.AdaptiveThreshold.SolidityLowerThresh, obj.Params.AdaptiveThreshold.SolidityUpperThresh);           
            obj.WindowsManager.update_progress_bar(20/100); % Update progressbar:            
            % split the mask into seperate mask for each blob:
            obj.Masks_cell = seperate_mask(TotalMask , "sparse");
            obj.WindowsManager.update_progress_bar(50/100); % Update progressbar:              
            % Update image in window
            obj.replot_all_masks();
            obj.WindowsManager.update_progress_bar(100/100); % Update progressbar:        
            
        end % start_AdaptiveThreshold
        function [] = start_MatlabBuiltIn(obj)
            
            
            % Reset ProgressBar:
            obj.WindowsManager.update_progress_bar( 0 );
            
            %parse Parameters:
            MaxIterationNum     = obj.Params.MatlabBuiltIn.MaxNumIteration;
            IterationsPerFrame  = obj.Params.MatlabBuiltIn.IterationsPerFrame;
            Im                  = obj.ImagesManager.get("GrayImage");
            Method              = Method2MatlabString( obj.Params.MatlabBuiltIn.Method );
            SmoothFactor        = obj.Params.MatlabBuiltIn.SmoothFactor;
            ContractionBias     = obj.Params.MatlabBuiltIn.ContractionBias;
            
            
            % Iterate many times:
            for frameIndex = 1 : MaxIterationNum/IterationsPerFrame
                
                % Create a mask that is the results of all the masks in the current frame:
                TotallMask2Show     = zeros( size( Im ) );
                
                %Go over all masks:
                if isempty( obj.Masks_cell )
                    break                    
                end
                for maskIndex = 1 : length( obj.Masks_cell )
                                       
                    MaskIn = full( obj.Masks_cell{maskIndex} );
                    % Rescale Mask:
                    if obj.scaling < 1
                        MaskIn = imresize(MaskIn , obj.scaling);
                    end
                    
                    % Active Contours on this mask:
                    MaskOut = activecontour(Im , MaskIn , IterationsPerFrame , Method , ...
                        'SmoothFactor' , SmoothFactor,...
                        'ContractionBias' , ContractionBias ...
                        );
                    % if masks is empty now, delete it and ignore it for next times
                    if any( MaskOut , 'all') % if it's not empty, save it:
                        Mask2SaveBack = obj.resize_mask_to_full_resolution(MaskOut);
                        obj.Masks_cell{maskIndex} = sparse(  Mask2SaveBack );
                    else % if empty
                        obj.Masks_cell(maskIndex) = [];
                        disp("Deleted mask at index " + num2str( maskIndex ) );
                        break % Go back to before we've calculated    length( obj.Masks_cell )
                    end
                    % Update the next mask to show:
                    TotallMask2Show = TotallMask2Show  |  MaskOut;
    
                end % maskIndex
                
                % Print Progress:
                fprintf('Frame %04d / %d \n', frameIndex , MaxIterationNum/IterationsPerFrame) ;                
                    
                if  obj.State == AlgorithmStateEnum.UserAskedToStop
                    % If user asked to stop -  Terminate:
                    break
                else
                    % ProgressBar
                    val  =  frameIndex*IterationsPerFrame  / MaxIterationNum;
                    obj.WindowsManager.update_progress_bar( val );
                end
                
                %refresh all masks in image:
                obj.ImagesManager.mask_over_image(  TotallMask2Show , "FromScratch");
                
                % Update Mask Cover Percentage:
                [~] = obj.calc_and_show_mask_cover_percentage();
                
            end % for frameIndex
        end % start_MatlabBuiltIn
        function [] = start_Lankton(obj)
            error("start_Lankton is not yet part of what we can run.");
        end % start_MatlabBuiltIn
        function [] = start_Watershed(obj)
            input_Mask_cell_array = obj.resized_masks_cell_array( obj.Masks_cell , "ReducedSize" );
            [newTotalMask ] = WaterShed( obj.ImagesManager.get("GrayImage") , input_Mask_cell_array , obj.Params.WaterShed);
            obj.ImagesManager.mask_over_image( newTotalMask  , "FromScratch" );
            output_Mask_cell_array  = seperate_mask(newTotalMask ,"sparse");
            obj.Masks_cell = obj.resized_masks_cell_array( output_Mask_cell_array , "Back2OriginalSize" );
        end % start_Watershed
    end %  (Access = protected)
    
end % class

function [Method] = ChosenMethodEnumFromString(String)
    switch string(String)
        case "Adaptive Threshold"
            Method = AvailableAlgorithms.AdaptiveThreshold;            
        case "MATLAB's Snakes"
            Method = AvailableAlgorithms.MatlabBuiltIn;
        case "Lankton's Snakes"
            Method = AvailableAlgorithms.Lankton;
        case "Watershed"
            Method = AvailableAlgorithms.Watershed;
        otherwise
            error("Unkown String");
    end
end % ChosenMethodEnumFromString

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
