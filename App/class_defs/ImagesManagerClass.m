classdef ImagesManagerClass < handle
    %IMAGESCONTROLCLASS Controls the Behaviour, Manipulations, Additions and Acquisition  of Images
    %   Detailed explanation goes here
    
    properties
        %control:
        WindowsManager % Manges and controls all open apps and windows
        %images:
        OriginalImage
        GreyImage
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
        %% Image Manipulations:
        function [] = crop(obj , roi)
            NewIm = imcrop(obj.OriginalImage , roi.Position ) ;
            obj.set_original_image(NewIm);
        end
        function [] = mask_over_image(obj , Mask  , option )
            if nargin >=3  &&  option == "FromScratch"
                obj.Image2Show = add_mask_over_image(   obj.OriginalImage  ,  Mask  ,  obj.ApearanceValues.MaskColor );
            else
                obj.Image2Show = add_mask_over_image(   obj.Image2Show    ,  Mask  ,  obj.ApearanceValues.MaskColor );
            end
            obj.show_image();
        end
        function [] = clear_masks(obj)
            obj.update_images_from_OriginalImage();
            obj.show_image();
        end
        function [] = histogram_equalization(obj)
            obj.GreyImage = insert_code_here( obj.GreyImage );
        end
        %% Windows and Visuals:
        function [] = show_image(obj)
            obj.WindowsManager.show_image(obj.Image2Show);
        end
    end % methods (Access = public)
    
    methods (Access = protected)
        function [] = update_images_from_OriginalImage(obj)
            if ndims( obj.OriginalImage )==3 % if Colored Image:
                obj.GreyImage = rgb2gray(obj.OriginalImage);
            elseif ismatrix( obj.OriginalImage )   %If gray Image:
                obj.GreyImage = obj.OriginalImage;
            else
                error("Wrong number image dimensions");
            end
            obj.Image2Show = obj.OriginalImage;
        end
    end % methods (Access = protected)
end

