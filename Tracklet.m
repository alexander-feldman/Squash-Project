classdef Tracklet
    %TRACKLET contains a model and set of points which fit that model
    
    %At its core, a tracklet is function and set of support points. This
    %tracklet also has functionality to work within an array of tracklets.
    %there is a one to many relationship between tracklets and points.
    
    properties
        model           %the function of the tracklet
        supports        %the array of indeces to supports for the tracklet
        numSupports     %the number of supports
        firstSupIdx     %the smallest support frame
        lastSupIdx      %the largest support frame
        meanDistance    %the mean distance between the model and the supports (goodness of fit)
        trackletID      %a unique ID to test equality
    end
    
    methods
        function this = Tracklet()
%       an empty constructor
%           model           = [];
%           supports        = [];
%           numSupports     = [];
%           firstSupIdx     = [];
%           lastSupIdx      = [];
%           meanDistance    = [];
%           trackletID      = [];
        end
        
        %finds the first and last support point of a tracklet
        function this = updateFirstLast(this)
            if this.numSupports == 0
                return
            end
            %MATLAB doesn't allow indexing into temp variables. Use
            %tempSupIDX instead.
            tempSupIdx = min(this.supports(this.supports > 0));
            this.firstSupIdx = tempSupIdx(1); 
            tempSupIdx = max(this.supports);
            this.lastSupIdx = tempSupIdx(1);
        end
        
        %adds a point into the supports of a tracklet
        %updates model, first/last, old point's tracklet
        function [this, tracklets, points] = addSupport(this, tracklets, points, index)
            %add to list of supports
            firstZero = find(this.supports == 0, 1);
            this.supports(firstZero) = index;
            
            this.numSupports = this.numSupports + 1; %increment num supports
            
            if ~isempty(points(index).assocTracklet) &&... %if has Tracklet
                    this.trackletID ~= tracklets(points(index).assocTracklet).trackletID %if current support isn't this
                tracklets(points(index).assocTracklet) =... %remove support from old
                    tracklets(points(index).assocTracklet).removeSupport(index, points);
            end
            points(index).assocTracklet = this.trackletID; %add this to Point
            
            this = this.updateFirstLast();
            this = this.updateModel(points); %update model
            tracklets(this.trackletID) = this; %return
        end
        
        %removes points from support, if isn't a support does nothing
        function this = removeSupport(this, index, points)
            if this.numSupports == 0
                return
            end
            
            %find the support to remove in list
            toRemove = find(this.supports == index, 1);            
            if isempty(toRemove)
                return
            end
            this.supports(toRemove) = 0; %remove it
            this.numSupports = this.numSupports - 1; %decrement
            
            if this.numSupports > 0
                this = this.updateModel(points); %update model            
                this = this.updateFirstLast; %update first/last
            end
        end
        
        %fits a new model based on current supports
        function this = updateModel(this, points)
            %need a minimum of three points for a model fit
            if this.numSupports < 3
                return
            else

                counter = 1; %keep track of how many supports have been counted
                
                %model has xDim/frames and yDim/frames
                xSups = zeros(this.numSupports, 1);     %xDim
                ySups = zeros(this.numSupports, 1);     %yDim
                timeSups = zeros(this.numSupports, 1);  %frames
                
                %fill in arrays
                for i=1:length(this.supports)
                    if this.supports(i) > 0
                        xSups(counter) = points(this.supports(i)).xDim;
                        ySups(counter) = points(this.supports(i)).yDim;
                        timeSups(counter) = points(this.supports(i)).frame;
                        counter = counter + 1;
                    end
                end
                
                %fit using built in MATLAB fit
                xFit = fit(timeSups,xSups,'poly2', 'Normalize', 'on');
                yFit = fit(timeSups,ySups,'poly2', 'Normalize', 'on');
               
            end
            %return
            this.model.xFit = xFit;
            this.model.yFit = yFit;
        end
        
        function mDist = getMeanDist(this, points)
            accumulator = 0;           
            %for each support
            for i=1:size(this.supports,1)
                if this.supports(i) > 0
                    %add distance to accumulator
                    accumulator = accumulator + points(i).getDistanceFromTracklet(this);
                end
            end     
            %divide and return
            mDist = accumulator / this.numSupports;           
        end
        
        function [xDim, yDim] = getPointAtFrame(this, frame)
            %predict a point from a model and frame number
            xDim = this.model.xFit(frame);
            yDim = this.model.yFit(frame);
        end
        
        %tracklets look at nearby points and use them as supports if fit model
        function [tracklets, points] = scoopUp(this, tracklets, points, threshold)
            if nargin < 4
                threshold = 5; %maximum distance between prediction and detection
            end
            skipDistance = 3; %max num frames to check in either direction
            
            %test prev
            for j=this.firstSupIdx-1:-1:1
                if (getDistanceFromPredicted(this, points(j)) <= threshold) &&...%is a good enough fit
                        points(j).frame + skipDistance >= points(this.firstSupIdx).frame %is point close enough to support
                    
                    [this, tracklets, points] = this.addSupport(tracklets, points, j); %add the point to tracklet
                    points(j).assocTracklet = this.trackletID; %add tracklet to point
                elseif ~points(j).frame + skipDistance >= points(this.firstSupIdx).frame
                    break %if too far from prediction and outside skipdistance, break
                end
            end
            
            %test next
            for j=this.lastSupIdx + 1:length(points)
                if (getDistanceFromPredicted(this, points(j)) <= threshold) &&... %is a good enough fit
                        points(j).frame - skipDistance <= points(this.lastSupIdx).frame %is point close enough to support                    
                    
                    [this, tracklets, points] = this.addSupport(tracklets, points, j); %add the point to tracklet
                    points(j).assocTracklet = this.trackletID; %add tracklet to point              
                elseif points(j).frame - skipDistance <= points(this.lastSupIdx).frame
                    break %if too far from prediction and outside skipdistance, break
                end
            end
            this.meanDistance = this.getMeanDist(points);
            tracklets(this.trackletID) = this;
        end
        
        function distance = getDistanceFromPredicted(tracklet, point)
            %make predictions
            [predictedX, predictedY] = tracklet.getPointAtFrame(point.frame);
            
            %find distance
            distance = pdist([predictedX, predictedY; point.xDim, point.yDim], 'euclidean');            
        end
        
    end
    
end

