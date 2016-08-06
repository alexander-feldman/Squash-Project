classdef Point
    %POINT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        hasModel
        xDim
        yDim
        frame
        internalModel
        assocTracklet
    end
    
    methods
        function obj=Point(x, y, f, im)
            if nargin == 4
                obj.xDim = x;
                obj.yDim = y;
                obj.frame = f;
                obj.internalModel = im;
                obj.hasModel = true;
            elseif nargin == 3
                obj.xDim = x;
                obj.yDim = y;
                obj.frame = f;
                obj.hasModel = false;
            end
        end
        
        function dist = getDistanceFromTracklet(this, testTracklet)
           [xPoint, yPoint] = testTracklet.getPointAtFrame(this.frame);
           dist = pdist([this.xDim, this.yDim; xPoint, yPoint], 'euclidean');
        end
    end
    
end

