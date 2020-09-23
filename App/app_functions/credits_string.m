function [CreditString] = credits_string()
  
    clear all; clc;
    Text = importdata('Credit.txt');
    Text = Text.textdata;

    TotalString = "";
    for i = 1 : size(Text,1)
        for j = 1 : size(Text,2)
            
            crntString = string(Text{i,j});
            if  isempty( crntString )
                % insert space
                TotalString = TotalString + " ";
            else
                TotalString = TotalString + crntString;
                % insert space
                TotalString = TotalString + " ";
            end
            
            
            
        end % for j   
        
        % insert newline:
        TotalString = TotalString + newline;
        
    end % for i
    
    
    CreditString = TotalString;

end % credits_string