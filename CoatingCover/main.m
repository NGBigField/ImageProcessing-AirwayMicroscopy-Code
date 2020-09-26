close all; clearvars ; clc;  


Paths = PathsClass( string(pwd) , "search" );

Data = struct();
Data.day_3 = coating_struct();
Data.day_5 = coating_struct();
Data.day_7 = coating_struct();


%%
% for each day:
for dayIndex = 1 : length( Paths.CoatingDirectory.subDirectories )
    dayStruct = Paths.CoatingDirectory.(Paths.CoatingDirectory.subDirectories{dayIndex});
    
    % for each coating type:
    for coatingTypeIndex = 1 : length( dayStruct.subDirectories )       
        coatingTypeStruct = dayStruct.( dayStruct.subDirectories{coatingTypeIndex} );
        
        % for each image:
        for imIndex = 1 : length(coatingTypeStruct.Images )
            
            % read Image:
            Im = imread( coatingTypeStruct.Images{imIndex} );
            % calc Cell-Coverage:
            [cell_coverage , binary_image] =  calc_image_cell_coverage(Im);
            % save Data:
            Data.(dayStruct.key).(coatingTypeStruct.key) = [ Data.(dayStruct.key).(coatingTypeStruct.key)  , cell_coverage];
            
            
        end % imIndex
    end  % coatingTypeIndex
end % dayIndex

save("Data" , "Data");

%% create bar Graph

if ~exist("Data" , "var")
   load("Data");
end

BarHeights = computeMeanValuesFromData(Data);  
figure()
BarPlotHandle = bar(BarHeights);
pretty_plot(BarPlotHandle);


%%
% what do we have here exactly?
disp(1);



%% subs:
function res =  coating_struct()

    res = struct();
    res.C    = [];
    res.C_F  = [];
    res.FBS  = [];
    res.None = [];

end

function BarHeights = computeMeanValuesFromData(Data)

    BarHeights = zeros(4,3);
    i=0;
    for coatingType = ["C" , "C_F" , "FBS" , "None" ]
        i = i + 1;
        j=0;
        for day = ["day_3" , "day_5" , "day_7"]
            j = j + 1;
            BarHeights(i,j) = mean( Data.(day).(coatingType) );
        end
    end

end % function 


function [] = pretty_plot(BarPlotHandle)

    Axis = BarPlotHandle.Parent;
    Axis.XTickLabel = {"C" , "C+F" , "FBS" , "None" };
    
    Legend = legend("Day 3" , "Day 5" , "Day 7");
    Legend.Location = 'northwest';
    
    
    grid on
    
    
    ylabel(Axis , "Cell Cover Percentage $$ [\%] $$" , 'Interpreter' ,'latex' , 'FontSize' , 15)
    ylim(Axis , [0,100])
    
end % pretty_plot