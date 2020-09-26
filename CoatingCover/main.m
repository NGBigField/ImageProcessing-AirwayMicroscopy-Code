%           close all; clearvars ; clc;  

Paths = PathsClass( string(pwd) , "search" );

%% one segmentation of Flask Image:
Config = default_CoatingCover_config("Flask");
Config.isPlotAllImages = true;

Config.SubstructBackgroundRadius = 0;
Config.PercentDarkest = 80;
Config.openRadius = 0;


Im = imread( Paths.ImagesForComparison.Flask );

[cell_coverage , binary_image] =  calc_image_cell_coverage(Im , Config);
disp(cell_coverage)
%% Go over all Coating:
Data = struct();
Data.day_3 = coating_struct();
Data.day_5 = coating_struct();
Data.day_7 = coating_struct();

Config = default_CoatingCover_config();
Config.isPlotAllImages = false;

% for each day:
for dayIndex = 1 : length( Paths.CoatingDirectory.subDirectories )
    dayStruct = Paths.CoatingDirectory.(Paths.CoatingDirectory.subDirectories{dayIndex});
    
    % for each coating type:
    for coatingTypeIndex = 1 : length( dayStruct.subDirectories )       
        coatingTypeStruct = dayStruct.( dayStruct.subDirectories{coatingTypeIndex} );
        % randomaly choose an image index to show later: 
        ImageIndex2Show = randi( length(coatingTypeStruct.Images ) );

        % for each image:
        for imIndex = 1 : length(coatingTypeStruct.Images )
            
            % read Image:
            Im = imread( coatingTypeStruct.Images{imIndex} );
            % calc Cell-Coverage:
            [cell_coverage , binary_image] =  calc_image_cell_coverage(Im , Config);
            % save Data:
            Data.(dayStruct.key).(coatingTypeStruct.key) = [ Data.(dayStruct.key).(coatingTypeStruct.key)  , cell_coverage];
            % Plot images side by side if we're on the lucky number:
            imiges_side_by_side_binary_with_original(Im,binary_image,imIndex,ImageIndex2Show,  coatingTypeStruct , dayStruct , cell_coverage);
            
            
        end % imIndex
    end  % coatingTypeIndex
end % dayIndex

saveFolder = string(pwd) + filesep + "Results";
save(saveFolder+filesep+"Data" , "Data");

%% create bar Graph

saveFolder = string(pwd) + filesep + "Results";
if ~exist("Data" , "var")
   load(saveFolder+filesep+"Data");
end

[BarHeights , BarHeightsError] = computeMeanValuesFromData(Data);  
FigH = figure();
BarPlotHandle   = bar(BarHeights);
pretty_plot(BarPlotHandle );
ErrorBarsHandle = errorbarOnBarPlot(BarHeights , BarHeightsError , BarPlotHandle);


%%
disp("Finsih");



%% subs:
function res =  coating_struct()

    res = struct();
    res.C    = [];
    res.C_F  = [];
    res.FBS  = [];
    res.None = [];

end

function [BarHeights , BarHeightsError ] = computeMeanValuesFromData(Data)

    BarHeights      = zeros(4,3);
    BarHeightsError = zeros(4,3);
    
    i=0;
    for coatingType = ["C" , "C_F" , "FBS" , "None" ]
        i = i + 1;
        j=0;
        for day = ["day_3" , "day_5" , "day_7"]
            j = j + 1;
            BarHeights(i,j)      = mean( Data.(day).(coatingType) );
            BarHeightsError(i,j) = std(  Data.(day).(coatingType) );
        end
    end

end % function 


function [] = pretty_plot(BarPlotHandle)

    BarPlotHandle(1).DisplayName = "Day 3";
    BarPlotHandle(2).DisplayName = "Day 5";
    BarPlotHandle(3).DisplayName = "Day 7";
    Legend = legend();
    Legend.Location = 'northwest';
    Legend.FontSize = 14;
    

    Axis = BarPlotHandle.Parent;
    Axis.XTickLabel = ["C" , "C+F" , "FBS" , "None" ];
    Axis.XAxis.FontSize = 16;
    
    
    grid on
    
    
    ylabel(Axis , "Cell Cover Percentage $$ [\%] $$" , 'Interpreter' ,'latex' , 'FontSize' , 16 , 'FontWeight' ,'bold')
    ylim(Axis , [0,100])
    
    % Error bars:

    

end % pretty_plot

function [] = imiges_side_by_side_binary_with_original(Original_Im,BW_Im ,ImageIndex,ImageIndex2Show,  coatingTypeStruct , dayStruct , cell_coverage )

    if ImageIndex ~= ImageIndex2Show
        return
    end
    
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
    savePath = string(pwd) + filesep + "Results" + filesep + "Segmentation Images" + filesep + DayAndTypeString + ".tif";
    saveas(FigH,savePath)
    

end % imiges_side_by_side_binary_with_original

function ErrorBarsHandle = errorbarOnBarPlot(BarHeights , BarHeightsError , BarPlotHandle)
    
    AxisH = BarPlotHandle.Parent;
    AxisH.XTick
    
    
    x_vec{1} = [1,2,3,4] -0.22;
    x_vec{2} = [1,2,3,4] -0;
    x_vec{3} = [1,2,3,4] +0.22;
    ErrorBarsHandle = cell(1,3);
    for i = 1 : 3
        hold on
        ErrorBarH = errorbar( x_vec{i}  , BarHeights(:,i) , BarHeightsError(:,i) );
        ErrorBarH.LineStyle = 'none';
        ErrorBarH.Color = 'k';
        ErrorBarH.CapSize = 10;
        ErrorBarH.LineWidth = 1;
        ErrorBarH.Annotation.LegendInformation.IconDisplayStyle = 'off';
        
        ErrorBarsHandle{i} = ErrorBarH;
    end
end