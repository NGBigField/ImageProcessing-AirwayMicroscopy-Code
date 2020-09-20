function [Mask_out ,centroid ]= center_of_mask(Mask_in )
    % get center of masks as a smaller mask:
    stats = regionprops(Mask_in , 'Centroid');
    centroid = round( stats.Centroid );
      
    Radius_sqrd = 20;
    Mask_out = zeros(size(Mask_in));
    
    [row,col] = find(Mask_out==0);
    Mask_out( (col-centroid(1)).^2+(row-centroid(2)).^2  < Radius_sqrd  ) = 1;
            
end