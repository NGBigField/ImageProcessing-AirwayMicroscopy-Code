%function BWImOut = DensityWindowFilter( BWImIn , Config )
function BWImOut = DensityWindowFilter( BWImIn , Config )

if ~Config.isOn  
   BWImOut = BWImIn;
   return
end


WindowSize              = Config.DensityWindowSize;
DensityPercentThreshold = Config.DensityPercentThreshold;
BoundaryPolicy          = Config.BoundaryPolicy;

ImSize = size(BWImIn);


for i = 1 : size(BWImIn,1)
for j = 1 : size(BWImIn,2)    
    
    
    IndicesY = i-WindowSize : i+WindowSize;
    IndicesX = j-WindowSize : j+WindowSize;
    
    [IndicesX , IndicesY] = BoundaryPolicyIndices(IndicesX , IndicesY , BoundaryPolicy , ImSize);
    [X,Y] = meshgrid(IndicesX,IndicesY);
    [ImPatch]          = BoundaryPolicyValues( X         , Y       , BoundaryPolicy , BWImIn);


end % for i
end % for j



end % function BWImOut = DensityWindowFilter( BWImIn , Config )


function [ImPatch] = BoundaryPolicyValues(X , Y, BoundaryPolicy , BWImIn)

    arguments
        X (:,:) {mustBeInteger}
        Y (:,:) {mustBeInteger}
        BoundaryPolicy string {mustBeMember(BoundaryPolicy,["Symmetric","Replicate","Circular","Black","White"])}
        BWImIn   (:,:) {mustBeInteger}
    end
    
    ImSize = size(BWImIn)
    ImPatch = zeros(size(X));
    
    InBoundX = X(X>0 & X<ImSize(2)) ;
    InBoundY = Y(Y>0 & Y<ImSize(2)) ;
    OutOfBoundX = 0 
    OutOfBoundY = 0
    
    
    ImPatch( [InBoundX , InBoundY] ) = BWImIn([InBoundX , InBoundY]);
    
    
    
    switch lower(BoundaryPolicy)
        
        case {lower("White") , lower("Replicate") }
            
        case {lower("Replicate")}
            
        otherwise
            error("EdgePolicy="""+BoundaryPolicy+""", Not supported ");
    end % switch
           



end %  [IndicesX , IndicesY] = EdgePolicyIndices(IndicesX , IndicesY)

function [IndicesX , IndicesY] = BoundaryPolicyIndices(IndicesX , IndicesY , BoundaryPolicy , ImSize)

    arguments
        IndicesX (:,1) {mustBeInteger}
        IndicesY (:,1) {mustBeInteger}
        BoundaryPolicy string {mustBeMember(BoundaryPolicy,["Symmetric","Replicate","Circular","Black","White"])}
        ImSize   (1,:) {mustBeInteger}
    end
    

    
    switch lower(BoundaryPolicy)
        
        case {lower("White") , lower("Replicate") }
            
        case {lower("Replicate")}
            
        otherwise
            error("EdgePolicy="""+BoundaryPolicy+""", Not supported ");
    end % switch
           



end %  [IndicesX , IndicesY] = EdgePolicyIndices(IndicesX , IndicesY)