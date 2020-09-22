classdef ImagesManagerClass < handle
    %IMAGESCONTROLCLASS Controls the Behaviour, Manipulations, Additions and Acquisition  of Images
    %   Detailed explanation goes here
    
    properties
        %control:
        SegmentAlgo 
        WindowsManager % Manges and controls all open apps and windows
        Config = struct( "histeq_image"            ,  "off"    ,...
                         "Image2Show_color"        , "Colored" , ...  % "Colored"/"Gray"
                         "Resolution"              , 100 );
        
        
        %images:
        OriginalImage
        ColoredImage_Processed
        GreyImage_Processed        
        Image2Show  
        
        %params:
        ApearanceValues
        

    end
    
    methods (Access = public)
        %% C'tor
        function obj = ImagesManagerClass(WindowsManager , ApearanceValues)
            %IMAGESCONTROLCLASS Construct an instance of this class
            %   Input:  WindowsManager  - handle to WindowsManager object that controls all the apps\windows
            %                ApearanceValues    - struct with properties.
            obj.WindowsManager = WindowsManager;
            obj.WindowsManager.set_ImagesControl(obj); % pass 'self' to  ImagesControlClass .
            obj.ApearanceValues = ApearanceValues;
        end

        %% Get / Set:
        function [] = set_original_image( obj ,originalImage )
            %set_original_image( obj ,originalImage )
            %   First call to make sure that we're updated with user's input
            obj.OriginalImage = originalImage ;
            obj.update_images_from_OriginalImage();
            obj.show_image()
        end
        function [image2show] = get_image2show(obj)
            image2show = obj.get_image2show;
        end
        function [image2show_origin] = get_Image2Show_Origin(obj)
            if     obj.Config.Image2Show_color == "Colored"
                image2show_origin = obj.ColoredImage_Processed;
            elseif obj.Config.Image2Show_color == "Gray"
                image2show_origin = obj.GreyImage_Processed;
            else 
                error("Unknown color style for Image2Show")
            end
        end
        function [] = set( obj , kwargs )
            arguments 
                obj
                kwargs.histeq_image 
                kwargs.Image2Show_color  %OriginalImage /GrayImage
                kwargs.Resolution 
            end % arguments
            InputFields  = fields(kwargs);
            obj.Config.(InputFields{1}) = kwargs.(InputFields{1});

        end
        function [Res] = get(obj , requestStr)
            switch lower(string(requestStr))
                case lower("GrayImage")
                    Res = obj.GreyImage_Processed;
                case lower("GreyImage")
                    Res = obj.get("GrayImage");
                case lower("ColoredImage")
                    Res = obj.ColoredImage_Processed;                    
                case lower("PlottedImage")
                    Res = obj.Image2Show;
                case lower("Image2Show")
                    Res = obj.get("PlottedImage");
                case lower("Image2Show_Origin")
                    Res = obj.get_Image2Show_Origin();
                otherwise
                    error("Unknown request string for method get() ");
            end
        end
        %% Image Manipulations:
        function [] = crop(obj , roi)
            NewIm = imcrop(obj.ColoredImage2Use , roi.Position ) ;
            obj.set_original_image(NewIm);
        end
        function [] = mask_over_image(obj , Mask  , option )
            if nargin >=3  &&  option == "FromScratch"
                obj.Image2Show = add_mask_over_image(   obj.get("Image2Show_Origin") ,  Mask  ,  obj.ApearanceValues.MaskColor );
            else
                obj.Image2Show = add_mask_over_image(   obj.get("Image2Show")        ,  Mask  ,  obj.ApearanceValues.MaskColor );
            end
            obj.show_image();
        end
        function [] = clear_masks(obj)
            obj.update_images_from_OriginalImage();
            obj.show_image();
        end
        
        
        %% Windows and Visuals:
        function [] = show_image(obj)
            obj.WindowsManager.show_image(obj.Image2Show);
        end
        
%     end % methods (Access = public)
%     
%     methods (Access = protected)

        function [] = update_images_from_OriginalImage(obj)
            
            % original image ->  ColoredImage_Processed:
            if obj.Config.Resolution < 100
                Scaling =  obj.Config.Resolution/100;
                obj.ColoredImage_Processed = imresize(obj.OriginalImage , Scaling);
            elseif obj.Config.Resolution < 0 || obj.Config.Resolution  > 100
                error("Not possible");
            elseif obj.Config.Resolution ==0
                obj.ColoredImage_Processed = imresize(obj.OriginalImage , 0.001);
            elseif obj.Config.Resolution == 100
                obj.ColoredImage_Processed = obj.OriginalImage;
            else
                error("What other option do we got? ");
            end
            
            % original image ->  GrayImage :
            if ndims( obj.ColoredImage_Processed )==3 % if Colored Image:
                obj.GreyImage_Processed = rgb2gray(obj.ColoredImage_Processed);
            elseif ismatrix( obj.ColoredImage_Processed )   %If gray Image:
                obj.GreyImage_Processed = obj.ColoredImage_Processed;
            else
                error("Wrong number image dimensions");
            end
            
            % GrayImage -> GrayImage :
            if  OnOff2Logical( obj.Config.histeq_image)
                obj.GreyImage_Processed  = histeq( obj.GreyImage_Processed );
            end
            
            %  ? -> Image2Show : 
            obj.Image2Show = obj.get("Image2Show_Origin");
            
            % Add mask if exists:
            obj.SegmentAlgo.replot_all_masks();
            
        end
    end % methods (Access = protected)
end

