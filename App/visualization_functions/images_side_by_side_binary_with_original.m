function [] = images_side_by_side_binary_with_original( Original_Im,BW_Im , ImageIndex , ImageIndex2Show , coatingTypeStruct , dayStruct , cell_coverage , Paths , Settings )

    switch Settings.howManyImages2Save
        case "All"
            % continue
        case "1 per type per day"
             if ImageIndex ~= ImageIndex2Show
                 return
             end
        case "Only first Image"
            error("Not supprted yet");
        otherwise
            error("None such option");
    end % switch    
    
    % Texts:
    DayAndTypeString = dayStruct.Name + " - Coating Type  " + coatingTypeStruct.Name;
    [~ , ImageString , ~ ]      = fileparts( coatingTypeStruct.Images{ImageIndex} );
    CoverageString   = "Cell Coverage = " + string(cell_coverage) + " [%]";
    DetailsText = DayAndTypeString + "  - Image "+ ImageString + newline + CoverageString;
    
    
    FigH = figure();
    
    isTryAgain = true;
    while isTryAgain
        
        % Our Unique LinkedMontage function:
        
        [ subPlotsH, options] = LinkedMontage( {Original_Im, BW_Im} , ["Original" , "Segmented"] , ...
                                                "Layout",       [1,nan], ...
                                                "FigureHandle", FigH );
        if any(subPlotsH(2).Position(3:4) ~= subPlotsH(1).Position(3:4))
            continue
        else
            isTryAgain = false;
        end        
        
        FigH = options.FigureHandle;
        FigH.Name   = DayAndTypeString;
        TitleH = sgtitle(options.FigureHandle, DetailsText);
        TitleH.Interpreter = 'none';
        TitleH.FontSize = 16;
        
        subPlotsH(1).Title.FontSize = 14;
        subPlotsH(2).Title.FontSize = 14;
              
    end %  while isTryAgain
    
    % Save:
    if isfield(Settings , "isJustShow") && Settings.isJustShow
        % Don't save
    else
        saveFolder   = Paths.Results.Coating.OurResults.SegmentationImages.Path;
        
        % make sure such a folder exists:
        if ~exist( saveFolder,'dir')
            [filepath,name,~] = fileparts(saveFolder);
            mkdir( filepath, name)
        end
        
        saveFullPath = saveFolder + filesep + DayAndTypeString  + ".tif";
        saveas(FigH,saveFullPath)
    end
    

    

end % imiges_side_by_side_binary_with_original
