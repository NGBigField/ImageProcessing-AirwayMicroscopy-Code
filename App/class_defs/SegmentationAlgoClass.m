classdef SegmentationAlgoClass  < handle % < matlab.mixin.SetGet
    %SegmentationAlgoClass Class to manage the parameters and execution of the Segmentation Algorithm.
    %   Will store parameters which the user choose with the main app
    %   Will run the algorithm when the user chooses to do so.
    
    properties
        Params= default_params();

        Mask  % the thing that we're looking for.
        ImagesManager % Class to controls the Behaviour, Manipulations, Additions and Acquisition  of Images
        
        is_inProgress = false;
    end
    
    methods (Access = public)
        function obj = SegmentationAlgoClass(ImagesManager)
            %SegmentationAlgoClass Construct an instance of this class
            obj.ImagesManager = ImagesManager;
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

        function [] = start_algorithm(obj)
            if isempty( obj.Mask )
                warning("Choose Region Of Interest 'Roi' before starting algorithm");
                return
            end
            obj.is_inProgress = true;
            switch obj.Params.General.ChosenAlgorithm
                case AvailableAlgorithms.MatlabBuiltIn
                    obj.start_MatlabBuiltIn();
                case AvailableAlgorithms.Lankton
                    obj.start_Lankton();
                case AvailableAlgorithms.Watershed
                    
                otherwise
                        error("Unkown AlgorithmFunction");
            end%switch
        end % start_algorithm 
        function  [] = stop_algorithm(obj)
            obj.is_inProgress = false;
        end % stop_algorithm
        
    end % methods (Access = public)
    
    methods (Access = protected)
        function [] = start_MatlabBuiltIn(obj)
            
        end % start_MatlabBuiltIn
        function [] = start_Lankton(obj)
            
        end % start_MatlabBuiltIn
        function [] = start_Watershed(obj)
            
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