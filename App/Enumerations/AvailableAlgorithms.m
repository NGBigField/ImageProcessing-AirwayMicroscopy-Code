classdef AvailableAlgorithms
    %ALGOPARAMS what can be used here
    %   enumeration and stuff
    enumeration
        MatlabBuiltIn 
        Lankton 
        Watershed
        
        AdaptiveThreshold
    end
    
    methods (Static)
        function cell_array = string_cell_array()
            cell_array = { 'MatlabBuiltIn' , 'Lankton' , 'Watershed'  };
        end
        
        function Methods_struct = MatlabBuiltInMethods()
            Methods_struct = struct('Edge'    , 'edge' ,  ...
                                                     'Region' , 'chan-vese');
        end
    end
    
end


