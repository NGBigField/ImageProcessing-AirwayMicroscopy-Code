%%
close all;
clearvars ; clc; 
figure


Paths = PathsClass( string(pwd) , "search" );
original_image = imread( Paths.AllPictures.Coating  );


%get grey image:
gray_image = rgb2gray(original_image);
%Subtract background:
gray_image = image_substruct_background(gray_image , 10);

%histogram equalization:
gray_image = histeq(gray_image);



most_dark_grey_level = most_x_percent_darkest_level(50 , gray_image);
indices_above = gray_image<=most_dark_grey_level ;
fixed_image = zeros(size(original_image));
fixed_image(indices_above) = original_image(indices_above);


imshow(fixed_image)





%%

function without_background =  image_substruct_background(im , disk_radius)
    SE = strel('disk',   disk_radius  );
    eroded = imerode(im,SE);
    without_background = im - eroded;
end


function most_dark_grey_level = most_x_percent_darkest_level(x , gray_image)

    totalPixelNum =  size(gray_image,1)* size(gray_image,2);
    
    [counts,~] = imhist(gray_image);

    binLocationIdx = 0;
    totalCount = 0;

    while totalCount < (x/100)*totalPixelNum
        binLocationIdx = binLocationIdx + 1;
        currCount = counts(binLocationIdx);
        totalCount = totalCount + currCount;
    end

    most_dark_grey_level = binLocationIdx;
end
