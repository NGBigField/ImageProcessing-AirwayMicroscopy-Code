function [FigH] = images_side_by_side( ImCell, TitleStrArray )

    
    if size(ImCell) ~= size(TitleStrArray)
       error("ImCell and TitleStrArray must be of same size"); 
    end
    
    FigH = figure();
    % Adjust window size:
    FigH.Position(4) = FigH.Position(4)*1.2;
    FigH.Position(2) = FigH.Position(2)*0.5;

    % sub plots:
    sbpltHandleArray = [];
    NumIm = length(ImCell);
    for i = 1 : NumIm
        
        Im       = ImCell{i};
        TitleStr = TitleStrArray(i);
        
        subPlotH = subplot(1,NumIm,i);
        imshow(Im)
        title(TitleStr)
        
        sbpltHandleArray = [sbpltHandleArray , subPlotH];

    end % for i 

    
    % axes move together:
    linkaxes(sbpltHandleArray)

    
    % enlarge the axes:
    for i = 1 : NumIm
        sbpltHandleArray(i).Position(1) = (i-1)/NumIm;
        sbpltHandleArray(i).Position(3) =   1  /NumIm;
    end
    
    drawnow
    
end