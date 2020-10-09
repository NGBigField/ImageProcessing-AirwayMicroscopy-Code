function [FigH , sbpltHandleArray] = LinkedMontage( ImCell, TitleStrArray , options )
    arguments
        ImCell  
        TitleStrArray  string  = string.empty(0,length(ImCell))  
    end
    
    arguments % Name Value pairs
        options.OneRow = "off";
        options.Figure = []   ;
    end

    % Check input:
    if size(ImCell) ~= size(TitleStrArray)
       error("ImCell and TitleStrArray must be of same size"); 
    end
    
    if isempty(options.Figure)
        FigH = gcf;
        % Adjust window size:
        %--------------------
        % Hight:
        FigH.Position(4) = FigH.Position(4)*1.3;
        FigH.Position(2) = 0 ;
        % Width
        FigH.Position(3) = FigH.Position(4)*2;
        FigH.Position(1) = 0 ;
    else
        FigH = options.Figure;
    end
        
    
    % focus on figure:
    figure(FigH);
    % sub plots:
    sbpltHandleArray = [];
    NumIm = length(ImCell);
    
    if      lower(options.OneRow) == "on"
         
    elseif  lower(options.OneRow) == "fff" 
        
    else
        error("No such option");
    [VerticalAmount , HorizontalAmount ] =;
    end
    
    
    for ImIndex = 1 : NumIm
        
        Im = ImCell{ImIndex};
        if ~isempty(TitleStrArray) && ~isempty(TitleStrArray(ImIndex))
            TitleStr = TitleStrArray(ImIndex);
        else
            TitleStr = "";
        end
        
        
        
        
        subPlotH = subplot(VerticalAmount,HorizontalAmount,ImIndex);
        imshow(Im)
        title(TitleStr)
        
        sbpltHandleArray = [sbpltHandleArray , subPlotH];

    end % for i 

    
    % axes move together:
    linkaxes(sbpltHandleArray)

    
    % enlarge the axes:
    for ImIndex = 1 : NumIm
        sbpltHandleArray(ImIndex).Position(1) = (ImIndex-1)/NumIm;
        sbpltHandleArray(ImIndex).Position(3) =   1  /NumIm;
    end
    
    drawnow
    
end