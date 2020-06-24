classdef SegmentationAlgoClass  < handle % < matlab.mixin.SetGet
    %SegmentationAlgoClass Class to manage the parameters and execution of the Segmentation Algorithm.
    %   Will store parameters which the user choose with the main app
    %   Will run the algorithm when the user chooses to do so.
    
    properties
        Params = struct(  'SmoothFactor' , 4 , ...
                                     'ContractionBias' , 0.01 , ...
                                     'MaxNumIteration' , 1000 , ...
                                     'AlgorithmFunction' , AvailableAlgorithms.MatlabBuiltIn , ...
                                     'MatlabFunctionMethod' , AvailableAlgorithms.MatlabBuiltInMethods.Edge )  ;
        mask  % the thing that we're looking for.
        ImagesManager % Class to controls the Behaviour, Manipulations, Additions and Acquisition  of Images
        
    end
    
    methods (Access = public)
        function obj = SegmentationAlgoClass(ImagesManager)
            %SegmentationAlgoClass Construct an instance of this class
            obj.ImagesManager = ImagesManager;
        end
        
        function [] = set(obj  , varargin)
            %set_param set the params that the user chose, and other important values.
            %                         
            % Parse Input:
            validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
            p = inputParser;
            
            addParameter(p,'AlgorithmFunction'           ,obj.Params.AlgorithmFunction );
            addParameter(p,'MatlabFunctionMethod'   ,obj.Params.MatlabFunctionMethod );
            addParameter(p,'ContractionBias'                ,obj.Params.ContractionBias           ,validScalarPosNum);
            addParameter(p,'SmoothFactor'                   ,obj.Params.SmoothFactor           ,validScalarPosNum);
            addParameter(p,'MaxNumIteration'            ,obj.Params.MaxNumIteration    ,validScalarPosNum);
            parse(p, varargin{:});
            
            % Add to struct:               
            obj.Params =struct(  ...
                'SmoothFactor' , p.Results.SmoothFactor , ...
                'ContractionBias' , p.Results.ContractionBias , ...
                'MaxNumIteration' , p.Results.MaxNumIteration , ...
                'AlgorithmFunction' , p.Results.AlgorithmFunction, ...
                'MatlabFunctionMethod' , p.Results.MatlabFunctionMethod...
                )  ;
        
        end

        function [] = start_algorithm(obj)
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
        end % start_algorithm 
        function  [] = stop_algorithm(obj)
            
        end
        
    end % methods (Access = public)
end % class

