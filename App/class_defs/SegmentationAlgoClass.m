classdef SegmentationAlgoClass  < handle % < matlab.mixin.SetGet
    %SegmentationAlgoClass Class to manage the parameters and execution of the Segmentation Algorithm.
    %   Will store parameters which the user choose with the main app
    %   Will run the algorithm when the user chooses to do so.
    
    properties
        Params = default_params();

        Masks_cell  = {}  % the thing that we're looking for. Each mask in the cell array is for a seperate ROI and finally for a seperate living/dead cell area.
        Masks_Total = [];
        
        ImagesManager ImagesManagerClass   % Class to controls the Behaviour, Manipulations, Additions and Acquisition  of Images
        WindowsManager ; % Manges and controls all open apps and windows 
        
        State AlgorithmStateEnum  = AlgorithmStateEnum.Idle;
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
                case "MatlabBuiltIn MaxIterations"
                    obj.Params.MatlabBuiltIn.MaxNumIteration = Value;
                case "IterationsPerFrame"
                    obj.Params.MatlabBuiltIn.IterationsPerFrame = Value;
                case "MatlabBuildIn MasksRecombination"
                    obj.Params.MatlabBuiltIn.MasksRecombination = Value;
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
            if isempty( obj.Masks_cell ) && ( ~ismember(obj.Params.General.ChosenAlgorithm, AvailableAlgorithms.AlgorithmsWithoutPriorROI() ))  % for example AdaptiveThreshold doesn't need exisitng masks
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
                case AvailableAlgorithms.Watershed
                    obj.start_Watershed();
                case AvailableAlgorithms.CannyThresholdingFusion
                    obj.start_CannyThresholdingFusion();
                    
                otherwise
                        error("Unkown AlgorithmFunction");
            end%switch
            obj.stop_algorithm();
        end % start_algorithm 
        function  [] = stop_algorithm(obj)
            disp("Stopping Algorithm");
            obj.State = AlgorithmStateEnum.Idle;
            % Update last segmentation results:
            
            % Show numerical results:
            obj.WindowsManager.set_algoInProgress(  "off" );
            obj.WindowsManager.update_progress_bar(0); % reset progress bar;
            obj.calc_and_show_mask_cover_percentage();
            % update images with the new mask and show it:
            obj.ImagesManager.mask_over_image( obj.total_mask("CurrentResolution") , "FromScratch" )
            obj.ImagesManager.show_image();
        end % stop_algorithm
        %% Data from other objects:
        function [Scaling] = scaling(obj)
            Scaling = obj.ImagesManager.Config.Resolution/100;
            if Scaling < 0 || Scaling > 1
                error("Scaling is not legit. Scaling="+string(Scaling));
            end
        end        
        %% Masks:
        function tf = is_exist_masks(obj)
             if     (  isempty(obj.Masks_cell) && ~isempty(obj.Masks_Total) ) 
                 if any(obj.Masks_Total) % is there any non-zero element in mask?
                     error("Seems that only Masks_cell is empty. What about Masks_Total? ");
                 else
                     tf = true;
                 end
             elseif ( ~isempty(obj.Masks_cell) &&  isempty(obj.Masks_Total) )
                 error("Seems that only Masks_Total is empty. What about Masks_cell? ");
             elseif ( ~isempty(obj.Masks_cell) && ~isempty(obj.Masks_Total) ) 
                 tf = true;
             elseif (  isempty(obj.Masks_cell) &&  isempty(obj.Masks_Total) ) 
                 tf = false;
             else
                 error("Impossible option");
             end
        end % function is_no_masks
        function [] = add_mask(obj , Mask)
            FullResolutionMask = obj.resize_mask_to_full_resolution(Mask) ;
            if ~obj.is_exist_masks()
                obj.Masks_Total = zeros(size(FullResolutionMask));
            end            
            % Keep in Object:
            obj.Masks_cell{end+1} = sparse(FullResolutionMask );
            % Add to Mask_Total:
            obj.Masks_Total = obj.Masks_Total | FullResolutionMask;
        end % function [] = add_mask(obj , Mask)
        function [] = clear_masks(obj)
            obj.Masks_cell = {};
            obj.Masks_Total = [];
        end
        function [ShrinkedTotalMask2Show] = shrink_masks(obj )
            arguments
                obj SegmentationAlgoClass
            end
            
            CurrResolutionImSize = obj.ImagesManager.get("Image2Show_Size");
            FullResolutionImSize = obj.ImagesManager.get("OriginalImage_Size");
            
            ShrinkedTotalMask = false( [ FullResolutionImSize(1) , FullResolutionImSize(2) ] );            
            for i = 1 : length(obj.Masks_cell)
                shrinkedMask      = center_of_mask(obj.Masks_cell{i}) ;
                obj.Masks_cell{i} = sparse(shrinkedMask);
                ShrinkedTotalMask = ShrinkedTotalMask | shrinkedMask;
            end
            obj.Masks_Total = ShrinkedTotalMask; 
            ShrinkedTotalMask2Show = imresize( ShrinkedTotalMask , [CurrResolutionImSize(1) , CurrResolutionImSize(2)]);
            
        end
        function maskPercentage = calc_and_show_mask_cover_percentage(obj , TotalMask , ImageSize)
            arguments
               obj SegmentationAlgoClass
               TotalMask = []
               ImageSize = []
            end
            
            %if inputs are not given, use full resolution globally known OriginalImage_Size and object own obj.Masks_total to compute maskPercentage
            if isempty(TotalMask)
                TotalMask = obj.total_mask("FullResolution");
            end
            if isempty(ImageSize)
                ImageSize = obj.ImagesManager.get("OriginalImage_Size");
            end
                        
            % Calc Mask Cover:
            maskCover = sum(TotalMask ,'all');
            % Calc Image Totall Cover            
            imageCover = ImageSize(1)*ImageSize(2);
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
        function [TotalMask] = total_mask(obj , ResolutionStr)
            arguments
                obj SegmentationAlgoClass
                ResolutionStr string {mustBeMember(ResolutionStr,["FullResolution","LowerResolution","CurrentResolution"])} = "FullResolution"
            end
            
            % get TotalMask at Full Resolution:
            if obj.is_exist_masks()
                TotalMask = obj.Masks_Total;                      
            else
                ImageSize = obj.ImagesManager.get("OriginalImage_Size");
                TotalMask = zeros([ImageSize(1) , ImageSize(2)]);
            end
            
            %Convert to lower resolution if that's what we asked for:
            if (ResolutionStr=="LowerResolution" || ResolutionStr=="CurrentResolution" )  
                if obj.scaling<1
                    TotalMask = imresize(TotalMask , obj.scaling);
                else
                    % do nothing
                end
            elseif ResolutionStr=="FullResolution"
                % Do nothing
            else
                error("ResolutionStr="""+ResolutionStr+""". Not a legit string.");
            end
            
        end % total_mask
        function [] = replot_all_masks(obj)

            if ~obj.is_exist_masks()
                return
            end
            
            TotalMask = obj.total_mask();
            obj.ImagesManager.mask_over_image(TotalMask , "FromScratch");            
        end
        function [resized_mask_cell_array] = resized_masks_cell_array(obj , mask_cell_array ,  resizeStr , matrixTypeStr)
            %function [resized_mask_cell_array] = resized_masks_cell_array(obj , mask_cell_array ,  resizeStr , matrixTypeStr)
            % input arguments:
            %     * obj (SegmentationAlgoClass)
            %     * mask_cell_array (cell array if sparse/full masks)
            %     * resizeStr (string).  Default = "FullResolution". Can be "FullResolution"/"LowerResolution"/"CurrentResolution"
            %     * matrixTypeStr (string).  Default = "sparse".  Can be "sparse"/"full"
            % 
            arguments
                obj SegmentationAlgoClass
                mask_cell_array 
                resizeStr string  {mustBeMember(resizeStr,["FullResolution","LowerResolution","CurrentResolution"])} = "FullResolution"
                matrixTypeStr string {mustBeMember(matrixTypeStr,["sparse","full"])}  = "sparse"
            end
            

            if isempty(mask_cell_array)
                resized_mask_cell_array = {};
                return
            end
                
            resized_mask_cell_array = cell(size(mask_cell_array));
            for i = 1 : length(mask_cell_array)
                if obj.scaling == 1
                    resized_mask_cell_array{i} = SparseOrFull( mask_cell_array{i} , matrixTypeStr );
                elseif obj.scaling < 1 && obj.scaling > 0
                    if resizeStr == "LowerResolution" || resizeStr=="CurrentResolution"
                        resized_mask_cell_array{i} = SparseOrFull( imresize( full( mask_cell_array{i} ) , obj.scaling) , matrixTypeStr);
                    elseif resizeStr=="FullResolution" 
                        resized_mask_cell_array{i} = SparseOrFull( obj.resize_mask_to_full_resolution( full(mask_cell_array{i}) ) , matrixTypeStr);                        
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
            obj.Masks_cell = obj.resized_masks_cell_array( seperate_mask(TotalMask , "sparse"), "FullResolution" );
            obj.Masks_Total = obj.resize_mask_to_full_resolution(TotalMask);
            obj.WindowsManager.update_progress_bar(50/100); % Update progressbar:              
            % Update image in window
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
            
            ImageSize           = size(Im);
            
            % masks and mask control
            MasksCellArray      = obj.resized_masks_cell_array(obj.Masks_cell , "CurrentResolution" , "full");
            MasksRecentChanges  = cell(size(MasksCellArray));  
            is_maskFinished     = false(size(MasksCellArray));
            
            % Iterate many times:
            for frameIndex = 1 : MaxIterationNum/IterationsPerFrame
                
                %Go over all masks:
                if checkStopMatlabBuiltIn(MasksCellArray , is_maskFinished)
                    break                    
                end
                % Create a mask that is the results of all the masks in the current frame:
                TotallMask2Show     = zeros( ImageSize );
                
                for maskIndex = 1 : length( MasksCellArray )   
                    
                    MaskIn = MasksCellArray{maskIndex};
                    % if this mask is already done, skip this itteration
                    if is_maskFinished(maskIndex) || (obj.State == AlgorithmStateEnum.UserAskedToStop )
                        TotallMask2Show = TotallMask2Show  |  MaskIn;
                        continue
                    end

                    
                    % Active Contours on this mask:
                    MaskOut = activecontour(Im , MaskIn , IterationsPerFrame , Method , ...
                        'SmoothFactor' , SmoothFactor,...
                        'ContractionBias' , ContractionBias ...
                        );                    
                    % keep track on mask's changes:
                    [MasksRecentChanges{maskIndex} , is_maskFinished(maskIndex)] = update_mask_recent_changes(MasksRecentChanges{maskIndex} , MaskIn , MaskOut );
                    
                    % if masks is empty now, delete it and ignore it for next times
                    if any( MaskOut , 'all') % if it's not empty, save it:
                        MasksCellArray{maskIndex} = MaskOut;
                    else % if empty
                        MasksCellArray(maskIndex)     = [];
                        MasksRecentChanges(maskIndex) = [];
                        is_maskFinished(maskIndex)    = [];
                        disp("Deleted mask at index " + num2str( maskIndex ) );
                        break % Go back to before we've calculated    length( obj.Masks_cell )
                    end                       
                    
                    % Mask recombination:
                    if obj.Params.MatlabBuiltIn.IterationsPerFrame
                        maskAnd = and( TotallMask2Show , MaskOut );
                        if any(maskAnd,'all') 
                           disp("Recombining Masks");                            
                           % Find recombination Indices:
                           [maskJointIndex1 , maskJointIndex2] = findRecombinedMasks(MasksCellArray);                           
                           % Recomine 2 into 1:                           
                           MasksCellArray{maskJointIndex1} = MasksCellArray{maskJointIndex1} | MasksCellArray{maskJointIndex2};
                           % Delete 2
                           MasksCellArray(maskJointIndex2)     = [];
                           MasksRecentChanges(maskJointIndex2) = [];
                           is_maskFinished(maskJointIndex2)    = [];
                           break % Go back to before we've calculated    length( obj.Masks_cell )
                        end
                    end
                    
                    % Update the next mask to show:
                    TotallMask2Show = TotallMask2Show  |  MaskOut;
                    
              
                end % maskIndex
                
                % Print Progress:
                fprintf('Frame %04d / %04d \n', frameIndex , MaxIterationNum/IterationsPerFrame) ;     
                
                %refresh image's with Mask:
                obj.ImagesManager.mask_over_image(  TotallMask2Show , "FromScratch");
                obj.ImagesManager.show_image()
                
                % Update Mask Cover Percentage:
                [~] = obj.calc_and_show_mask_cover_percentage( TotallMask2Show , ImageSize );
                
                % check if user asked to terminate else update ProgressBar:
                if obj.State == AlgorithmStateEnum.UserAskedToStop                    
                    break
                else
                    val  =  frameIndex*IterationsPerFrame  / MaxIterationNum;
                    obj.WindowsManager.update_progress_bar( val );
                end
                
            end % for frameIndex
            
            % When we finish. Update this object's properties:
            obj.Masks_cell  = obj.resized_masks_cell_array( MasksCellArray , "FullResolution" , "sparse" );
            obj.Masks_Total = obj.resize_mask_to_full_resolution( TotallMask2Show );
            
        end % start_MatlabBuiltIn
        function [] = start_Lankton(obj)
            error("start_Lankton is not yet part of what we can run.");
        end % start_MatlabBuiltIn
        function [] = start_Watershed(obj)
            % get masks with correct dimensions (before or after resolution reduction):
            input_Mask_cell_array = obj.resized_masks_cell_array( obj.Masks_cell , "LowerResolution" );
            % Watershed algo:
            [newTotalMask ] = WaterShed( obj.ImagesManager.get("GrayImage") , input_Mask_cell_array , obj.Params.WaterShed);
            FullResolutionTotalMask = obj.resize_mask_to_full_resolution(newTotalMask);
            % update this object with the new masks:
            obj.Masks_cell  = seperate_mask(FullResolutionTotalMask ,"sparse");
            obj.Masks_Total = FullResolutionTotalMask;
            
        end % start_Watershed
        function [] = start_CannyThresholdingFusion(obj)
            Config       = obj.Params.CannyThresholdingFusion;            
            PlotSettings = obj.Params.CannyThresholdingFusion.PlotSettings;       
            Im           = obj.ImagesManager.get("GrayImage");         
            [ Images , MontageFigH]    = SegmentCoatingImageFusion(  Im , Config , PlotSettings);
            % Takes too long:
            %obj.Masks_cell  = seperate_mask(Images.SegmentedBWIm ,"sparse");
            obj.Masks_Total = Images.SegmentedBWIm;
        end
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
        case "Canny Thresholding Fusion"
            Method = AvailableAlgorithms.CannyThresholdingFusion;
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

function OutputMatrix = SparseOrFull(InputMatrix , matrixTypeStr)
    arguments
        InputMatrix
        matrixTypeStr string {mustBeMember(matrixTypeStr,["sparse","full"])} = "sparse"
    end
    
    if     lower(matrixTypeStr)=="sparse"
        OutputMatrix = sparse(InputMatrix);
    elseif  lower(matrixTypeStr)=="full"
        OutputMatrix = full(InputMatrix);
    else 
        error("matrixTypeStr="""+matrixTypeStr+""".  Not a legit input string.") ;
    end
        
    
end

function is_stop = checkStopMatlabBuiltIn(MasksCellArray , is_maskFinishedArray)
    
    is_stop = false;
    
    if isempty(MasksCellArray)
        is_stop = true;
    end
    if all(is_maskFinishedArray)
        is_stop = true;
    end
    
end


function [ MaskRecentChanges , is_maskedFinished ]= update_mask_recent_changes(MaskRecentChanges , MaskIn , MaskOut )
    
    is_maskedFinished = false;

    % Constants:
    MemoryLength = 3;
    ChangesToFinishThreshold = 10;

    % calculate
    current_change = xor(MaskIn, MaskOut);
    current_change_count = sum(current_change , 'all');
    % montage({MaskIn , MaskOut , current_change})
    
    % update:
    MaskRecentChanges = [MaskRecentChanges , current_change_count];
    
    % trim if we remember too much:
    if length(MaskRecentChanges) > MemoryLength
        MaskRecentChanges(1) = [];
    end
    
    % if all recent memory is without much change, mask is finished
    if length(MaskRecentChanges) >= MemoryLength
        if all(MaskRecentChanges < ChangesToFinishThreshold)
            is_maskedFinished = true;
        end
    end
    

end


function [maskJointIndex1 , maskJointIndex2] = findRecombinedMasks(MasksCellArray)
    
    for i = 1 : ( length(MasksCellArray) - 1)
        maskI = MasksCellArray{i};
        for j = (i+1) : length(MasksCellArray)
            maskJ = MasksCellArray{j};
            
            isRecomined = any(and(maskI,maskJ),'all');
            if isRecomined
               maskJointIndex1=i;
               maskJointIndex2=j;
               return
            end
            
        end % j        
    end % i

    % If we got here there was no recombination!
    error("No Recombination");
    
end