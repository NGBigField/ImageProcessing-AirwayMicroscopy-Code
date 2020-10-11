close all; clearvars ; clc;  
add_app_paths(pwd);
Paths = PathsClass( string(pwd) , "search" );

%% Go over all Coating:
Data = DataStruct();

[Config , Settings ] = default_CoatingCover_config("Coating");
Settings.isShowMontage = false;
Settings.howManyImages2Save = "1 per type per day" ; % "All"/"1 per type per day"/"Only first Image";


Config.EdgeDetection.isHistEqualization = false;
Config.EdgeDetection.cannyLow   = 0.05;
Config.EdgeDetection.cannyHigh  = 0.15;


% for each day:
for dayIndex = 1 : length( Paths.CoatingDirectory.subDirectories )
    dayStruct = Paths.CoatingDirectory.(Paths.CoatingDirectory.subDirectories{dayIndex});
    
    % for each coating type:
    for coatingTypeIndex = 1 : length( dayStruct.subDirectories )       
        coatingTypeStruct = dayStruct.( dayStruct.subDirectories{coatingTypeIndex} );
        % randomaly choose an image index to show later: 
        ImageIndex2ShowAndSave = randi( length(coatingTypeStruct.Images ) );

        % for each image:
        for imIndex = 1 : length(coatingTypeStruct.Images )
            
            % read Image:
            Im = imread( coatingTypeStruct.Images{imIndex} );
            % calc Cell-Coverage:
            [cell_coverage , binary_image] =  calc_image_cell_coverage(Im , Config , Settings );
            % save Data:
            Data.(dayStruct.key).(coatingTypeStruct.key) = [ Data.(dayStruct.key).(coatingTypeStruct.key)  , cell_coverage];
            % Plot images side by side if we're on the lucky number:
            images_side_by_side_binary_with_original(Im,binary_image,imIndex,ImageIndex2ShowAndSave,  coatingTypeStruct , dayStruct , cell_coverage , Paths , Settings);
            
            
        end % imIndex
    end  % coatingTypeIndex
end % dayIndex

saveFolder = Paths.Results.Coating.OurResults.Path ;
save(saveFolder+filesep+"Data" , "Data");

%% create bar Graph

saveFolder = Paths.Results.Coating.OurResults.Path ;
if ~exist("Data" , "var")
   load(saveFolder+filesep+"Data");
end

[BarHeights , BarHeightsError_Postive , BarHeightsError_Negative ]  = computeMeanValuesFromData(Data);  
FigH = figure();
BarPlotHandle   = bar(BarHeights);
pretty_plot(BarPlotHandle );
ErrorBarsHandle = errorbarOnBarPlot(BarHeights , BarHeightsError_Postive , BarHeightsError_Negative , BarPlotHandle);

% Save Bar Graph
saveFolder   = Paths.Results.Coating.OurResults.Path;
saveFullPath = saveFolder + filesep + "Bar Graph " + string(date) + ".svg";
saveas(FigH,saveFullPath)


disp("Finsih");

%% Finish




%% subs:
function res =  coating_struct()

    res = struct();
    res.C    = [];
    res.C_F  = [];
    res.FBS  = [];
    res.None = [];

end

function [BarHeights , BarHeightsError_Postive , BarHeightsError_Negative ] = computeMeanValuesFromData(Data)

    BarHeights               = zeros(4,3);
    BarHeightsError_Postive  = zeros(4,3);
    BarHeightsError_Negative = zeros(4,3);
    
    
    i=0;
    for coatingType = ["C" , "C_F" , "FBS" , "None" ]
        i = i + 1;
        j=0;
        for day = ["day_3" , "day_5" , "day_7"]
            j = j + 1;
            currentData = Data.(day).(coatingType);
            BarHeights(i,j)               = mean( currentData );
            BarHeightsError_Postive(i,j)  = std(  currentData( currentData >= mean( currentData ) ) );
            BarHeightsError_Negative(i,j) = std(  currentData( currentData <  mean( currentData ) ) );
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
    Axis.YLim = [0,120];
    
    YlineH = yline(100);
    YlineH.LineStyle = '--';
    YlineH.Annotation.LegendInformation.IconDisplayStyle = 'off';
    
    grid on
    
    
    ylabel(Axis , "Cell Cover Percentage $$ [\%] $$" , 'Interpreter' ,'latex' , 'FontSize' , 20 , 'FontWeight' ,'bold')
    
    % Error bars:

    

end % pretty_plot

function ErrorBarsHandle = errorbarOnBarPlot(BarHeights , BarHeightsError_Postive , BarHeightsError_Negative , BarPlotHandle)
    
    AxisH = BarPlotHandle.Parent;
    AxisH.XTick
    
    
    x_vec{1} = [1,2,3,4] -0.22;
    x_vec{2} = [1,2,3,4] -0;
    x_vec{3} = [1,2,3,4] +0.22;
    ErrorBarsHandle = cell(1,3);
    for i = 1 : 3
        hold on
        ErrorBarH = errorbar( x_vec{i}  , BarHeights(:,i) , BarHeightsError_Negative(:,i) , BarHeightsError_Postive(:,i)  );
        ErrorBarH.LineStyle = 'none';
        ErrorBarH.Color = 'k';
        ErrorBarH.CapSize = 10;
        ErrorBarH.LineWidth = 1;
        ErrorBarH.Annotation.LegendInformation.IconDisplayStyle = 'off';
        
        ErrorBarsHandle{i} = ErrorBarH;
    end
end

function Data = DataStruct()
    Data = struct();
    Data.day_3 = coating_struct();
    Data.day_5 = coating_struct();
    Data.day_7 = coating_struct();
end