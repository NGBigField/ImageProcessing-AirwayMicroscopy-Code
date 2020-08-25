function [ BW ] = WaterShed(GrayIm , Masks_cell , Params)
%WATERSHED Flood-Fill image

%Params:
tolerance = Params.Tolerance;

% Adjust data to span data range.
GrayIm = imadjust(GrayIm);

% Create empty mask.
BW = false(size(GrayIm,1),size(GrayIm,2));

for i = 1 : length(Masks_cell)
    Mask = Masks_cell{i};
    
    %Assert correct dimensions:
    if any( size(Mask) ~=  size(GrayIm) )
        error("Mask and Image are not of the same dimensions");
    end
    
    % Find center of mass:
    stats = regionprops(Mask , 'Centroid');
    centroid = round( stats.Centroid );
    
    % Flood fill
    addedRegion = grayconnected(GrayIm, centroid(2), centroid(1), tolerance) ;
    BW = BW | addedRegion;
end

% Create masked image.
% maskedImage = GrayIm;
% maskedImage(~BW) = 0;

%%
end
