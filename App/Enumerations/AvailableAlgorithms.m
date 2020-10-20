classdef AvailableAlgorithms
    %ALGOPARAMS what can be used here
    %   enumeration and stuff
    enumeration
        MatlabBuiltIn 
        % Lankton  % not supported
        Watershed
        CannyThresholdingFusion
        
        AdaptiveThreshold
    end
    
    methods (Static)
        function cell_array = string_cell_array()
            cell_array = { 'MatlabBuiltIn' , 'Watershed' , 'CannyThresholdingFusion' , 'AdaptiveThreshold' };
        end
        
        function Methods_struct = MatlabBuiltInMethods()
            Methods_struct = struct('Edge'   , 'edge'     ,  ...
                                    'Region' , 'chan-vese');
        end %  methods (Static)
        
        function [AlgoArray] = AlgorithmsWithoutPriorROI( outputType)
            
            arguments 
               outputType string {mustBeMember(outputType,["enum" , "string"])} = "enum"               
            end
            
            switch outputType
                case "enum"
                    AlgoArray = [AvailableAlgorithms.AdaptiveThreshold , AvailableAlgorithms.CannyThresholdingFusion  ] ;
                case "string"
                    AlgoArray = [                   "AdaptiveThreshold" ,                   "CannyThresholdingFusion" ] ;
                otherwise
                    error("outputType Not Supported");
            end% switch            
        end %  AlgorithmsWithoutPriorROI( outputType)
        
    end % methods static
    
end % class


