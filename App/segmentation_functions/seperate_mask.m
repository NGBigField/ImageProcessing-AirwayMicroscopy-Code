function [Mask_cell] = seperate_mask(TotalMask , matrixTypeStr)
%[Mask_cell] = seperate_mask(TotalMask , matrixTypeStr)
% split the mask into seperate mask for each blob:
%
% input:
%     - TotalMask: 1 mask that covers the entire image
%     - matrixTypeStr: a string of either "full" or "sparse" to get the result in the appropriate matrix type. Default="full".
%
% output:
%     - Mask_cell. cell array of masks.

    arguments
        TotalMask (:,:,1) {mustBeNonnegative , mustBeReal , mustBeNumericOrLogical}
        matrixTypeStr string = "full"    % possible to get full or sparse
    end
    
    CC = bwconncomp(TotalMask);
    im_size = size(TotalMask);
    Mask_cell = cell(1,CC.NumObjects);
    for i=1:CC.NumObjects
        % create the current blob's mask
        temp_mask = zeros(im_size);
        temp_mask(CC.PixelIdxList{i}) = 1;
        % pass the mask as full or as sparse:
        if     lower(matrixTypeStr) == "full"
            Mask_cell{i} = temp_mask ;
        elseif lower(matrixTypeStr) == "sparse"
            Mask_cell{i} = sparse(temp_mask) ;
        else
           error("Not a possible matrix type. Got:  " + matrixTypeStr); 
        end
    end

end % function  seperate_mask