classdef SegmentationAlgoClass  < handle % < matlab.mixin.SetGet
    %SegmentationAlgoClass Class to manage the parameters and execution of the Segmentation Algorithm.
    %   Will store parameters which the user choose with the main app
    %   Will run the algorithm when the user chooses to do so.
    
    properties
        Params= default_params();

        Masks_cell = {}  % the thing that we're looking for.
        ImagesManager % Class to controls the Behaviour, Manipulations, Additions and Acquisition  of Images
        WindowsManager ; % Manges and controls all open apps and windows
        
        is_inProgress = false;
    end
    
    methods (Access = public)
        function obj = SegmentationAlgoClass(ImagesManager , WindowsManager)
            %SegmentationAlgoClass Construct an instance of this class
            obj.ImagesManager = ImagesManager;
            obj.WindowsManager = WindowsManager;
            obj.Params = default_params();
        end
        
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
                otherwise
                        error("Unkown Name");
            end %Switch
        
        end
        function [  ] = start_or_stop_algorithm(obj)
            if obj.is_inProgress
                % Stop"
                obj.stop_algorithm();
            else
                % Start:
                obj.start_algorithm();
            end
        end % start_or_stop_algorithm(obj)
        function [] = start_algorithm(obj)
            %check if we're ready:
            if isempty( obj.Masks_cell )
                warning("Choose Region Of Interest 'ROI'  before starting algorithm");
                obj.stop_algorithm();
                return
            end
            %update:
            obj.is_inProgress = true;
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
        end % start_algorithm 
        function  [] = stop_algorithm(obj)
            %update:
            obj.is_inProgress = false;
            obj.WindowsManager.set_algoInProgress(  "off" );
        end % stop_algorithm
        function [] = add_mask(obj , Mask)
            obj.Masks_cell{end+1} = Mask;
        end
        function [] = clear_masks(obj)
            obj.Masks_cell = {};
        end
    end % methods (Access = public)
    
    methods (Access = protected)
        function [] = start_MatlabBuiltIn(obj)
            obj.stop_algorithm();
        end % start_MatlabBuiltIn
        function [] = start_Lankton(obj)
            obj.stop_algorithm();
        end % start_MatlabBuiltIn
        function [] = start_Watershed(obj)
            [newMask ] = WaterShed(obj.ImagesManager.GreyImage , obj.Masks_cell , obj.Params.WaterShed);
            obj.ImagesManager.mask_over_image( newMask  , "FromScratch" );
            obj.stop_algorithm();
        end % start_Watershed
    end %  (Access = protected)
    
end % class

%{
for i = 1 : MaxIterationNum/NumIterationsPerPlot
    
    MaskOut = activecontour(Section , MaskIn , NumIterationsPerPlot , AlgoParams.Method , ...
        'SmoothFactor' , AlgoParams.SmoothFactor ,...
        'ContractionBias' , AlgoParams.ContractionBias);
    maskHandle.CData =  add_mask( Section ,MaskOut , rgb) ;
    MaskIn = MaskOut;
    
    %update plot:
    if Control.is_animate
        iterationsText  =  sprintf('Iteration %04d / %d', i , MaxIterationNum) ;
        Graphics.text.String = iterationsText;
        drawnow
        
        %progress bar
        if Control.is_progress_bar && Graphics.progressbar_bar.CancelRequested
            Graphics.progressbar_bar.close();
            delete(Graphics.progressbar_fig);
            break
        else
            val  =  i*NumIterationsPerPlot  / MaxIterationNum;
            Graphics.progressbar_bar.Value = val;
        end
    end
    
end
%}