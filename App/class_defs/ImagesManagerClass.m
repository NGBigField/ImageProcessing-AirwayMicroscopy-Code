classdef ImagesManagerClass < handle
    %IMAGESCONTROLCLASS Controls the Behaviour, Manipulations, Additions and Acquisition  of Images
    %   Detailed explanation goes here
    
    properties
        %control:
        SegmentAlgo 
        WindowsManager % Manges and controls all open apps and windows
        Config = struct( "histeq_image"            ,  "off"    , ...
                         "Image2Show_color"        , "Colored" , ...  % "Colored"/"Gray"
                         "Resolution"              , 100       , ... 
                         "blurring"                ,  "off"    , ...
                         "blurring_options"        , struct()  ...
                       );
        
        
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
            obj.WindowsManager.set_ImagesManager(obj); % pass 'self' to  ImagesControlClass .
            obj.ApearanceValues = ApearanceValues;
        end

        %% Get / Set:
        function [] = set_original_image( obj ,originalImage )
            %set_original_image( obj ,originalImage )
            %   First call to make sure that we're updated with user's input
            
            % Save image:
            obj.OriginalImage = originalImage ;
            % Let Segment Algo know that their mask (if exists) is no longer valid:
            obj.SegmentAlgo.clear_masks();
            % Go through all the image manipulations:
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
                % Things we can set:
                kwargs.histeq_image 
                kwargs.Image2Show_color  %OriginalImage /GrayImage
                kwargs.Resolution
                kwargs.blurring
                % Extra options
                kwargs.options
            end % arguments
            InputFields  = fields(kwargs);
            InputField = string(InputFields{1});
            if InputField == "blurring" && (  length(InputFields) >= 2 )
                obj.Config.(InputField) = kwargs.(InputField);
                obj.Config.(InputField+"_options") = kwargs.options;
            else
                obj.Config.(InputField) = kwargs.(InputField);
            end
        end
        function [MaskColor] = get_MaskColor(obj)
            if obj.Config.Image2Show_color == "Colored"
                MaskColor = obj.ApearanceValues.MaskColor.ColoredImage;
            elseif obj.Config.Image2Show_color == "Gray"
                MaskColor = obj.ApearanceValues.MaskColor.GrayImage;
            else
               error("Not a legit Image2Show_color. Function got :" + string(obj.Config.Image2Show_color) ); 
            end
        end % get_MaskColor
        function [Res] = get(obj , requestStr)
            switch lower(string(requestStr))
                case lower("OriginalImage")
                    Res = obj.OriginalImage;
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
                case lower("MaskColor")
                    Res = obj.get_MaskColor();
                case lower("Image2Show_Size")
                    Res = size(obj.Image2Show);                    
                case lower("OriginalImage_Size")
                    Res = size(obj.OriginalImage);
                otherwise
                    error("Unknown request string for method get() ");
            end
        end
        %% Image Manipulations:
        function [] = crop(obj , roi)
            NewIm = imcrop(obj.get("OriginalImage") , roi.Position ) ;
            obj.set_original_image(NewIm);
        end
        function [] = mask_over_image(obj , Mask  , option )
            if nargin >=3  &&  option == "FromScratch"
                obj.Image2Show = add_mask_over_image(   obj.get("Image2Show_Origin") ,  Mask  ,  obj.get("MaskColor")  );
            else
                obj.Image2Show = add_mask_over_image(   obj.get("Image2Show")        ,  Mask  ,  obj.get("MaskColor")  );
            end            
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
                Scaling = 0.001;
                obj.ColoredImage_Processed = imresize(obj.OriginalImage , Scaling);
            elseif obj.Config.Resolution == 100
                Scaling = 1;
                obj.ColoredImage_Processed = obj.OriginalImage;
            else
                error("What other option do we got? ");
            end
            
            % original image ->  ColoredImage_Processed:
            
            
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
            if OnOff2Logical( obj.Config.blurring )
                obj.GreyImage_Processed  = ImageBlur( obj.GreyImage_Processed , obj.Config.blurring_options );
            end
            
            %  ? -> Image2Show : 
            obj.Image2Show = obj.get("Image2Show_Origin");
            
            % Add mask if exists:
            obj.mask_over_image( obj.SegmentAlgo.total_mask("CurrentResolution") , "FromScratch" );     
            
            % replot image:
            obj.show_image();
        end
    end % methods (Access = protected)
end

