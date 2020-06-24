classdef ImagesManagerClass < handle
    %IMAGESCONTROLCLASS Controls the Behaviour, Manipulations, Additions and Acquisition  of Images
    %   Detailed explanation goes here
    
    properties
        %control:
        WindowsManager
        %images:
        OriginalImage
        GreyImage
        Image2Show  
        %params:
        is_display_
    end
    
    methods (Access = public)
        %% C'tor
        function obj = ImagesManagerClass(WindowsManager)
            %IMAGESCONTROLCLASS Construct an instance of this class
            %   Input:  handle to WindowsManager object that controls all the apps\windows
            obj.WindowsManager = WindowsManager;
            obj.WindowsManager.set_ImagesControl(obj);
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
        function [] = add_mask(obj ,Mask , ApearanceValues )
            obj.Image2Show = add_mask(   obj.OriginalImage  ,  Mask  ,  ApearanceValues.MaskColor );
            obj.show_image();
        end
        
        %% Windows and Visuals:
        function [] = show_image(obj)
            obj.WindowsManager.show_image(obj.Image2Show);
        end
    end % methods (Access = public)
    
    methods (Access = protected)
        function [] = update_images_from_OriginalImage(obj)
            obj.GreyImage = rgb2gray(obj.OriginalImage);
            obj.Image2Show = obj.OriginalImage;
        end
    end % methods (Access = protected)
end

