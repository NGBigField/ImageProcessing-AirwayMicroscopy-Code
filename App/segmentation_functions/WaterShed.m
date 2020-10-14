function [ NewTotallMask ] = WaterShed(GrayIm , Masks_cell , Params)
%WATERSHED Flood-Fill image
% Our Watershed Function
%
% By: Nir Gutman and Tomer Arama

%Params:
tolerance = Params.Tolerance;

% Adjust data to span data range.
GrayIm = imadjust(GrayIm);

% Create empty mask.
NewTotallMask = false(size(GrayIm,1),size(GrayIm,2));

for i = 1 : length(Masks_cell)
    Mask = Masks_cell{i};
    
    %Assert correct dimensions:
    if any( size(Mask) ~=  size(GrayIm) )
        error("Mask and Image are not of the same dimensions");
    end

    
    % Find center of mass:
    [~ ,centroid ] = center_of_mask( Mask );
    
    
    % Flood fill
    addedRegion = grayconnected(GrayIm, centroid(2), centroid(1), tolerance) ;
    NewTotallMask = NewTotallMask | addedRegion;
end

% Create masked image.
% maskedImage = GrayIm;
% maskedImage(~BW) = 0;

%%
end

