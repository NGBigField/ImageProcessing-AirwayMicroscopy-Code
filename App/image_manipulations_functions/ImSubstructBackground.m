function without_background =  ImSubstructBackground(im , disk_radius )
    SE = strel('disk',   disk_radius  );
    eroded = imerode(im,SE);
    without_background = im - eroded;
end