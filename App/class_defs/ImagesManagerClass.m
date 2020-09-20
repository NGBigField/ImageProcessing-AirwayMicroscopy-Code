classdef ImagesManagerClass < handle
    %IMAGESCONTROLCLASS Controls the Behaviour, Manipulations, Additions and Acquisition  of Images
    %   Detailed explanation goes here
    
    properties
        %control:
        WindowsManager % Manges and controls all open apps and windows
        %images:
        OriginalImage
        ColoredImage2Use
        GreyImage
        Image2Show  
        %params:
        ApearanceValues
        Config = struct("histeq_image"            ,  "off"   ,...
                                 "Image2Show_origin" , "OriginalImage" , ...
                                 "Resolution"                 , 100 );
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
        function [] = set( obj , kwargs)
            arguments 
                obj
                kwargs.histeq_image 
                kwargs.Image2Show_origin  %OriginalImage /GrayImage
                kwargs.Resolution 
            end % arguments
            InputFields  = fields(kwargs);
            
            obj.Config.(InputFields{1}) = kwargs.(InputFields{1});

            % act according to config:
            obj.update_images_from_OriginalImage();
            obj.show_image()            
        end
        %% Image Manipulations:
        function [] = crop(obj , roi)
            NewIm = imcrop(obj.ColoredImage2Use , roi.Position ) ;
            obj.set_original_image(NewIm);
        end
        function [] = mask_over_image(obj , Mask  , option )
            if nargin >=3  &&  option == "FromScratch"
                obj.Image2Show = add_mask_over_image(   obj.ColoredImage2Use  ,  Mask  ,  obj.ApearanceValues.MaskColor );
            else
                obj.Image2Show = add_mask_over_image(   obj.Image2Show              ,  Mask  ,  obj.ApearanceValues.MaskColor );
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
    end % methods (Access = public)
    
    methods (Access = protected)
        function [] = update_images_from_OriginalImage(obj)
            
            % original image ->  original image:
            if obj.Config.Resolution < 100
                Scaling =  obj.Config.Resolution/100;
                obj.ColoredImage2Use = imresize(obj.OriginalImage , Scaling);
            elseif obj.Config.Resolution < 0 || obj.Config.Resolution  > 100
                error("Not possible");
            elseif obj.Config.Resolution ==0
                obj.ColoredImage2Use = imresize(obj.OriginalImage , 0.001);
            else
                obj.ColoredImage2Use = obj.OriginalImage;
            end
            
            % original image ->  GrayImage :
            if ndims( obj.ColoredImage2Use )==3 % if Colored Image:
                obj.GreyImage = rgb2gray(obj.ColoredImage2Use);
            elseif ismatrix( obj.ColoredImage2Use )   %If gray Image:
                obj.GreyImage = obj.ColoredImage2Use;
            else
                error("Wrong number image dimensions");
            end
            
            % GrayImage -> GrayImage :
            if  OnOff2Logical( obj.Config.histeq_image)
                obj.GreyImage  = histeq( obj.GreyImage );
            end
            
            %  ? -> Image2Show : 
            switch obj.Config.Image2Show_origin
                case "OriginalImage"
                    obj.Image2Show = obj.ColoredImage2Use;
                case "GrayImage"
                    obj.Image2Show = obj.GreyImage;
                otherwise
                    error("Illegit input Argument");
            end
            
        end
    end % methods (Access = protected)
end

