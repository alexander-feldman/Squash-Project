classdef Point
    %POINT Points have a location in x, y, and time and possibly an assoc
    %trcklet and internal model.
    
    properties
        hasModel        %does it have a model
        xDim            %location in x dim
        yDim            %location in y dim
        frame           %location in time dim
        internalModel   %internal model
        assocTracklet   %index of assoc tracklet
    end
    
    methods
        function obj=Point(x, y, f, im) %two constructors
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
        
        %function calls back to tracklet
        function dist = getDistanceFromTracklet(this, testTracklet)
           [xPoint, yPoint] = testTracklet.getPointAtFrame(this.frame);
           dist = pdist([this.xDim, this.yDim; xPoint, yPoint], 'euclidean');
        end
    end
    
end

