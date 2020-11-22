function bw_mask = AdaptiveThreshold(IM,ws,C,tm,se_length, lower_thresh, upper_thresh)
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

se = strel('disk',se_length);

if (nargin<3)
    error('You must provide the image IM, the window size ws, and C.');
elseif (nargin==3)
    tm=0;
elseif (tm~=0 && tm~=1)
    error('tm must be 0 or 1.');
end
IM=mat2gray(IM);
if tm==0
    % mean filter
    mIM=imfilter(IM,fspecial('average',ws),'replicate');
else
    % median filter
    mIM=medfilt2(IM,[ws ws]);
end
% C is the offset threshold:
sIM=mIM-IM-C;
% binarize around 0:
bw_mask=imbinarize(sIM,0);
bw_mask=imcomplement(bw_mask);

bw_mask = imclose(bw_mask,se);
bw_mask = ~bw_mask;

% filter the mask by solidities
bw_mask = bwpropfilt(bw_mask, 'Solidity', [lower_thresh, upper_thresh]);

end