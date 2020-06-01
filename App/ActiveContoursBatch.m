close all ; clear all; clc;

%%
Control = struct();
Control.is_plot_all = true;
Control.is_animate = true;
Control.is_record_animation = false;
Control.is_progress_bar = true;

AlgoParams = struct();
AlgoParams.MethodOptions = struct('edge' , 'edge' ,  ...
                                                                'region' , 'chan-vese');
AlgoParams.Method = AlgoParams.MethodOptions.region;
AlgoParams.SmoothFactor = 4;
AlgoParams.ContractionBias = 0.01;

Paths = Paths(pwd);


%{ =-=-=-=  load image =-=-=-=  }%
OriginalImage = imread(  Paths.AvailablePictures.NaturalImage1 );
Paths.AvailablePictures.

try
    GreyImage = rgb2gray(OriginalImage);
catch
    GreyImage = OriginalImage;
end
 %%
 % Crop Image:
 msg = 'Crop The Image';
 cropFig = figure();
 cropFig.Name = msg;
 disp(msg);
Section = imcrop(GreyImage);
%user did not choose a section:
if isempty(Section)
    Section = GreyImage;
end
delete(cropFig)

% plot stuff:
if Control.is_plot_all
    Graphics = struct();
    Graphics.fig = figure('Name' , 'Active Contour Segmentation Porccess');
    imshow(Section);
end

% Region of Interest:
msg = 'Choose Region of Interest';
disp(msg);
Graphics.fig.Name = msg;
roi = drawrectangle;
%extract the Mask from roi:
Mask = roi.createMask();    % if failed:  Mask = ones( size(Section,1) , size(Section,2)  );


%% Snakes Evolution:
% Prepare data and stuff
MaxIterationNum = 1000;
NumIterationsPerPlot = 2;
MaskIn=Mask;

rgb = [0 ,  1 , 0 ] ; %green
if Control.is_plot_all
    figure( Graphics.fig );
    maskHandle = imshow(  add_mask( Section ,MaskIn , rgb)  );
    msg = 'Snake Evolution';
    title(msg);
    Graphics.fig.Name = msg;
  
    if Control.is_animate
        %figure style:
        i = 0;
        iterationsText  =  sprintf('Iteration %04d / %d', i , MaxIterationNum) ;
        x = size(Section,1) - 300 ;
        y = size(Section,2)+40;
        Graphics.text= text( x ,y  ,iterationsText ) ;
        Graphics.text.FontSize  = 12 ;
        
        % progress bar
        if Control.is_progress_bar
            Graphics.progressbar_fig = uifigure();
            Graphics.progressbar_fig.Position(3:4) = [ 500  160 ]  ; %figure width and hight
            Graphics.progressbar_bar = uiprogressdlg(Graphics.progressbar_fig ,  'Cancelable','on'   , 'CancelText','Pause'   , 'Title','Snake Evolution',    'Message','Evolution in progress...');
        end
    end % Control.is_animate
end % Control.is_plot_all


%% Evolution Ierations:
for i = 1 : MaxIterationNum/NumIterationsPerPlot
    
    MaskOut = activecontour(Section , MaskIn , NumIterationsPerPlot , AlgoParams.Method , ...
                                                 'SmoothFactor' , AlgoParams.SmoothFactor ,...
                                                 'ContractionBias' , AlgoParams.ContractionBias);
    maskHandle.CData =  add_mask( Section ,MaskOut , rgb) ;
    MaskIn = MaskOut;
    
    %update plot:
    if Control.is_animate
        iterationsText  =  sprintf('Iteration %04d / %d', i , MaxIterationNum) ;
        Graphics.text.String = iterationsText;
        drawnow
        
        %progress bar
        if Control.is_progress_bar && Graphics.progressbar_bar.CancelRequested
            Graphics.progressbar_bar.close();
            delete(Graphics.progressbar_fig);
            break
        else
            val  =  i*NumIterationsPerPlot  / MaxIterationNum;
            Graphics.progressbar_bar.Value = val;
        end
    end

end

%%
%Subtract background:
% im = image_substruct_background(im , 4);
%histogram equalization:
% im = histeq(im);
%thresholding:


% binary_im=filter_touches_boundaries(binary_im , stats , Control);


%% sub functions:

