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
    MontageH = montage({Original_Im, BW_Im});
    Axis = MontageH.Parent;
    
    
    DayAndTypeString = dayStruct.Name + " - Coating Type  " + coatingTypeStruct.Name;
    [~ , ImageString , ~ ]      = fileparts( coatingTypeStruct.Images{ImageIndex} );
    CoverageString   = "Cell Coverage = " + string(cell_coverage) + " [%]";
    
    FigH.Name   = DayAndTypeString;
    Axis.Title.String  = DayAndTypeString + "  - Image "+ ImageString + newline + CoverageString;
    Axis.Title.Interpreter = 'none';
    Axis.Title.FontSize = 16;
    
    
    Axis.XAxis.Visible = "on";
    XLimits = Axis.XLim;
    Axis.XTick      = [ XLimits(2)*(1/4) , XLimits(2)*(3/4)];
    Axis.XTickLabel = ["Original Image"  , "Binary Segmentation"];
    Axis.XAxis.FontSize = 18;
    
    % Adjust window size:
    FigH.Position(4) = FigH.Position(4)*1.2;
    FigH.Position(2) = FigH.Position(2)*0.5;
    
    % Save:
    if isfield(Settings , "isJustShow") && Settings.isJustShow
        % Don't save
    else
        saveFolder   = Paths.Results.Coating.OurResults.SegmentationImages.Path;
        saveFullPath = saveFolder + filesep + DayAndTypeString + ".tif";
        saveas(FigH,saveFullPath)
    end

end % imiges_side_by_side_binary_with_original
