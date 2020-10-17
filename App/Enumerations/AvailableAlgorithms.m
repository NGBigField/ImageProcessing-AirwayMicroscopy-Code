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
    end
    
end


