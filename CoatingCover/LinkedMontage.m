function [SubPlotHandleArray , options] = LinkedMontage( ImCell, TitleStrArray , options )
% LinkedMontage A tight Montage that also links the images with linkaxes()
%[SubPlotHandleArray , options] = LinkedMontage( ImCell, TitleStrArray , options )
% 
% This function plots multiple images side by side like montage(), 
% but does it using subplot that are conneced with linkaxes() function. This
% allows user to zoom into images and move around, while all images move together.
% Function also returns the handles to all the subplots, so user can change properties later.
% 
% Inputs:
%     * ImCell: Cell array of images to plot.
%     * TitleStrArray: optional. String array of names to each image. Must be of size of input ImCell.
%     * options: Name-Value Pairs, all optional. Names:
%         - FigureHandle: Figure Handle on which the montage will be plotted.
%         - LinkedAxes: "on" (default) , "off".
%         - Size: Number of rows and columns of images, specified as a 2-element vector of the 
%                 form [nrows ncols]. If you specify NaN or Inf for a particular dimension, 
%                 LinkedMontage calculates the value of the dimension to display all images 
%                 in the montage. For example, if 'Size' is [2 NaN], then the montage will have
%                 two rows and the minimum number of columns to display all images.
% 
% Output: 
%     * SubPlotHandleArray: Array of axes objects. Each corrosponds to the input image with the same index.
%     * options: The same as input options. Returns the configurations that the function used.
    

    arguments
        ImCell  
        TitleStrArray  string  = string.empty(0,length(ImCell))  
    end
    
    arguments % Name Value pairs
        options.FigureHandle {mustBeFigureHandle}  % Figure Handle
        options.LinkedAxes string {mustBeMember(options.LinkedAxes,["on","off"])}  = "on"
        options.Size {mustBeNumeric , mustBeNonnegative} = [Inf , 3]   
                                   % Number of rows and columns of images, specified as a 2-element vector of the form [nrows ncols].
                                   %{ 
                                       If you specify NaN or Inf for a particular dimension, montage calculates the value of the dimension 
                                       to display all images in the montage. For example, if 'Size' is [2 NaN], then the montage will have 
                                       two rows and the minimum number of columns to display all images.
                                       When there is a mismatch between 'Size' and number of images (frames) specified, 
                                       montage creates the tiled image based on 'Size'.
                                    %}
                                   
end % arguments

    % Check input:
    if size(ImCell) ~= size(TitleStrArray)
       error("ImCell and TitleStrArray must be of same size"); 
    end
    
    NumIm = numel(ImCell);
    % decide montage layout:    
    [NumRows , NumCols] = montage_layout(options.Size , NumIm );
              
    
    % focus on figure:
    figure(FigH);    
    % sub plots:    
    SubPlotHandleArray = gobjects(1,NumIm); % empty array of graphic objects
    
    for ImIndex = 1 : NumIm
        
        Im = ImCell{ImIndex};
        if ~isempty(TitleStrArray) && ~isempty(TitleStrArray(ImIndex)) && ( NumRows <= 1 )
            TitleStr = TitleStrArray(ImIndex);
        else
            TitleStr = "";
        end
       
        subPlotH = subplot(NumRows,NumCols,ImIndex);
        imshow(Im)
        title(TitleStr)
        
        SubPlotHandleArray(ImIndex) = subPlotH;
       
        
    end % for i 

    
    % Link the axes! Now axes move and zoom  together:
    switch options.LinkedAxes
        case "on"
            linkaxes(SubPlotHandleArray)
        case "off"
            % skip 
        otherwise
            error("Wrong LinkedAxes option. Must be ""on"" or ""of"". Got LinkedAxes="""+string(LinkedAxes)+""".");
    end

    
    % make axes fill the figure:
    for ImIndex = 1 : NumIm
        [row , col] = image_position(ImIndex , NumRows , NumCols );
        % Width sacling:
        SubPlotHandleArray(ImIndex).Position(1) = (col-1)/NumCols;
        SubPlotHandleArray(ImIndex).Position(3) =   1    /NumCols;
        % Height sacling:
        SubPlotHandleArray(ImIndex).Position(2) = 1 - row/NumRows;
        SubPlotHandleArray(ImIndex).Position(4) =   1    /NumRows;
    end    
    
end



function [nrows , ncols] = montage_layout(RequestedLayout , NumIm)
    
    nrows = RequestedLayout(1);
    ncols = RequestedLayout(2);
    
    nrowsGiven = ~( isnan(nrows) || isinf(nrows) );
    ncolsGiven = ~( isnan(ncols) || isinf(ncols) );
    
    if      nrowsGiven &&  ncolsGiven
        return        
    elseif ~nrowsGiven &&  ncolsGiven
        nrows = ceil( NumIm / ncols );
    elseif  nrowsGiven && ~ncolsGiven
        ncols = ceil( NumIm / nrows );
    elseif ~nrowsGiven && ~ncolsGiven
        erro("At least one dimension should be given");
    else
        error("BUG: No such option");
    end
end % function [nrows , ncols] = montage_layout(RequestedLayout , NumIm)


function [row , col] = image_position(ImIndex , NumRows , NumCols )

    % Column:
    col = mod(ImIndex,NumCols);
    if col == 0
       col = NumCols; 
    end
    
    % Row:
    row = ceil(ImIndex/NumCols);
    
    %check answer
    if row>NumRows || col>NumCols
       error("BUG: Error in computing row and error of image"); 
    end

end 


function  mustBeFigureHandle(A)
%MUSTBEFIGUREHANDLE Validate that value is a figure handle type object

    WhoIsInput = whos('A');
    if string(WhoIsInput.class) ~= "matlab.ui.Figure"
        error("LinkedMontage:options.FigureHandle:mustBeFigureHandle  input has to be of type matlab.ui.Figure. " + newline +...
              "Instead got input of type "+ string(WhoIsInput.class)+"." );
    end
end