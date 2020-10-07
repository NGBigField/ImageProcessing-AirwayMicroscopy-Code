function [] = imiges_side_by_side_binary_with_original( Original_Im,BW_Im , ImageIndex , ImageIndex2Show , coatingTypeStruct , dayStruct , cell_coverage , Paths , Settings )

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
        

    FigH = figure();
    % Adjust window size:
    FigH.Position(4) = FigH.Position(4)*1.2;
    FigH.Position(2) = FigH.Position(2)*0.5;
    
    
    sbpltH1 = subplot(1,2,1);
    imshow(Original_Im)
    title("Original Image")
    sbpltH2 = subplot(1,2,2);    
    imshow(BW_Im)
    title("Binary Segmentation")
    
    % axes move together:
    linkaxes([sbpltH1 , sbpltH2 ])
    
    sbpltH1.Position(1) = 0;
    sbpltH2.Position(1) = (1/2)*1;
    sbpltH1.Position(3) = (1/2)*1;
    sbpltH2.Position(3) = (1/2)*1;
    
 
    
    DayAndTypeString = dayStruct.Name + " - Coating Type  " + coatingTypeStruct.Name;
    [~ , ImageString , ~ ]      = fileparts( coatingTypeStruct.Images{ImageIndex} );
    CoverageString   = "Cell Coverage = " + string(cell_coverage) + " [%]";
    
    FigH.Name   = DayAndTypeString;
    
    DetalisText = DayAndTypeString + "  - Image "+ ImageString + newline + CoverageString;
    TitleText = text( 0 , 0 , DetalisText);    
    TitleText.Units = 'normalized';
    TitleText.Position = [-1/2 , 1.2 , 0];
    TitleText.FontSize = 13;
    TitleText.Interpreter = 'none';
    

    % Save:
    if isfield(Settings , "isJustShow") && Settings.isJustShow
        % Don't save
    else
        saveFolder   = Paths.Results.Coating.OurResults.SegmentationImages.Path;
        saveFullPath = saveFolder + filesep + DayAndTypeString + ".tif";
        saveas(FigH,saveFullPath)
    end
    
    impixelinfo
    

end % imiges_side_by_side_binary_with_original
