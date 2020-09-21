function [Mask_cell] = seperate_mask(TotalMask)
% split the mask into seperate mask for each blob:
    
    
    CC = bwconncomp(TotalMask);
    im_size = size(TotalMask);
    Mask_cell = cell(1,CC.NumObjects);
    for i=1:CC.NumObjects
        % create the current blob's mask
        temp_mask = zeros(im_size);
        temp_mask(CC.PixelIdxList{i}) = 1;
        Mask_cell{i} = temp_mask ;
    end

end