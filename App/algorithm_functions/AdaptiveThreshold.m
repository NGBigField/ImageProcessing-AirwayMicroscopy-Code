function [centroids, bw] = AdaptiveThreshold(IM,ws,C,tm,se)
%ADAPTIVETHRESHOLD An adaptive thresholding algorithm that seperates the
%foreground from the background with nonuniform illumination.
%  bw=adaptivethreshold(IM,ws,C) outputs a binary image bw with the local 
%   threshold mean-C or median-C to the image IM.
%  ws is the local window size.
%  tm is 0 or 1, a switch between mean and median. tm=0 mean(default); tm=1 median.
%
%  Contributed by Guanglei Xiong (xgl99@mails.tsinghua.edu.cn)
%  at Tsinghua University, Beijing, China.
%
%  For more information, please see
%  http://homepages.inf.ed.ac.uk/rbf/HIPR2/adpthrsh.htm

if (nargin<3)
    error('You must provide the image IM, the window size ws, and C.');
elseif (nargin==3)
    tm=0;
elseif (tm~=0 && tm~=1)
    error('tm must be 0 or 1.');
end
IM=mat2gray(IM);
if tm==0
    mIM=imfilter(IM,fspecial('average',ws),'replicate');
else
    mIM=medfilt2(IM,[ws ws]);
end
sIM=mIM-IM-C;
bw=im2bw(sIM,0);
bw=imcomplement(bw);

bw = imclose(bw,se);
bw = ~bw;

% find solidities and centroids of every object in the mask
stats = regionprops(bw,'Solidity', 'Centroid');
all_centroid = stats.Centroid;
Solidities = stats.Solidity;

% filter blobs by solidity
centroids = [];
L = min(length(all_centroid),length(Solidities));
for i = 1:L
    if (Solidities(i) > 0.5)
        centroids = [centroids, round(all_centroid(i))];
    end
end



end