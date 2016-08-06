classdef Tracklet
    %TRACKLET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        model           %the function of the tracklet
        supports        %the array of indeces to supports for the tracklet
        numSupports     %the number of supports
        firstSupIdx     %the smallest support frame
        lastSupIdx      %the largest support frame
        meanDistance    %the mean distance between the model and the supports
        trackletID      %a unique ID to test equality
    end
    
    methods
        function this = Tracklet()
            
        end
        
        function this = updateFirstLast(this)
            %use of middle var allows retreiving just first value
            if this.numSupports == 0
                return
            end
            tempSupIdx = min(this.supports(this.supports > 0));
            this.firstSupIdx = tempSupIdx(1); 
            tempSupIdx = max(this.supports);
            this.lastSupIdx = tempSupIdx(1);
        end
        
        function [this, tracklets, points] = addSupport(this, tracklets, points, index)
            firstZero = find(this.supports == 0, 1);
            this.supports(firstZero) = index;
            this.numSupports = this.numSupports + 1;
            if ~isempty(points(index).assocTracklet) &&... %if has model
                    this.trackletID ~= tracklets(points(index).assocTracklet).trackletID %if current support isn't this
                tracklets(points(index).assocTracklet) =... %remove support from old
                    tracklets(points(index).assocTracklet).removeSupport(index, points);
            end
            points(index).assocTracklet = this.trackletID; %add this to Point
            
            this = this.updateFirstLast();
            this = this.updateModel(points);%update model
            tracklets(this.trackletID) = this;
        end
        
        %removes points from support, if isn't a support does nothing
        function this = removeSupport(this, index, points)
            if this.numSupports == 0
                return
            end
            for i=1:length(this.supports)
                if this.supports(i) == index
                    break %find index to remove
                end
                %if it wasn't found, fix num supports and return
                this.numSupports = sum(this.supports > 0);
                return
            end
            this.supports(i) = 0; %remove it
            this.numSupports = this.numSupports - 1;
            
            this = this.updateModel(points); %update model
            if this.numSupports > 0
                this = this.updateFirstLast;
            end
        end
        
        function this = updateModel(this, points)
            if this.numSupports < 3
                return
            else
                %{
                med = round(median(this.supports(this.supports > 0)));
                %test if med is a support of this, if not find one
                if ~any(this.supports == med)
                    maxSkipDistance = 5; %this should be passed!
                    for i=1:maxSkipDistance
                        if any(this.supports == med + i)
                            med = med + i;
                            break
                        elseif any(this.supports == med - 1)
                            med = med - i;
                            break
                        end
                    end
                end
                %}
                counter = 1; %keep track of how many supports have been counted
                xSups = zeros(this.numSupports, 1);
                ySups = zeros(this.numSupports, 1);
                timeSups = zeros(this.numSupports, 1);
                
                for i=1:length(this.supports)
                    if this.supports(i) > 0
                        xSups(counter) = points(this.supports(i)).xDim;
                        ySups(counter) = points(this.supports(i)).yDim;
                        timeSups(counter) = points(this.supports(i)).frame;
                        counter = counter + 1;
                    end
                end
                
                xFit = fit(timeSups,xSups,'poly2');
                yFit = fit(timeSups,ySups,'poly2');
                
                
                %{
                sup1 = [points(this.firstSupIdx).xDim, points(this.firstSupIdx).yDim];
                sup2 = [points(med).xDim, points(med).yDim];
                sup3 = [points(this.lastSupIdx).xDim, points(this.lastSupIdx).yDim];
                
                dist21 = points(med).frame - points(this.firstSupIdx).frame;
                dist32 = points(this.lastSupIdx).frame - points(med).frame;
                
                timeInterval = 1; %arbitrary                
                
                %Position: pk = p1 + ?k * v1 + ((?k)^2) / 2) * a
                %Velocity: v1 = ((p2 - p1)/?k21) - ((?k21 * a) / 2)
                %Acceleration: a  = 2 * ((?k21 * (p3 - p2) - ?k32 * (p2 - p1))
                %                   / (?k21 * ?k32 * (?k21d+ ?k32))
                
                accelNum = 2 * (((dist21/timeInterval) .* (double(sup3) - double(sup2)) - ...
                    ((dist32/timeInterval) .* (double(sup2) - double(sup1)))));
                accelDenom = (dist32/timeInterval) .* (dist21/timeInterval) .* ((dist32/timeInterval) + ...
                    (dist21/timeInterval));
                accel = accelNum ./ accelDenom;
                
                velocInit = ((sup2 - sup1) ./ dist21) - ((dist21 .* accel) ./ 2);
                
                newModel = [accel, velocInit, points(med).xDim, points(med).yDim, points(med).frame];
                %}
                
                
            end
            this.model.xFit = xFit;
            this.model.yFit = yFit;
        end
        
        function mDist = getMeanDist(this, points)
            total = 0;
            for i=1:50
                if this.supports(i) > 0
                    total = total + points(i).getDistanceFromTracklet(this);
                end
            end
            mDist = total / this.numSupports;
            
        end
        
        function [xDim, yDim] = getPointAtFrame(this, frame)
            xDim = this.model.xFit(frame);
            yDim = this.model.yFit(frame);
            
%             frameDistance = frame - this.model(7);
%             xDim = this.model(5) + (frameDistance * this.model(3)) +...
%                 ((power(frameDistance, 2) / 2) * this.model(1));
%             yDim = this.model(6) + (frameDistance * this.model(4)) +...
%                 ((power(frameDistance, 2) / 2) * this.model(2));
        end
        
        function [tracklets, points] = scoopUp(this, tracklets, points)
            threshold = 5;
            skipDistance = 5;
            %test prev
            curDistSkip = 0;
            for j=this.firstSupIdx:-1:1
                if (j < this.firstSupIdx &&... %don't test itselt
                        points(j).getDistanceFromTracklet(this) <= threshold) %is a good enough fit
                    [this, tracklets, points] = this.addSupport(tracklets, points, j); %add the point to tracklet
                    points(j).assocTracklet = this.trackletID; %add tracklet to point
                    curDistSkip = 0;                   
                elseif this.firstSupIdx == j
                    continue
                elseif curDistSkip < skipDistance
                    curDistSkip = curDistSkip + 1;
                    continue
                else
                    break %only find continuous
                end
            end
            %test next
            curDistSkip = 0;
            for j=this.lastSupIdx:length(points)
                if (j > this.lastSupIdx &&... %don't test itselt
                        points(j).getDistanceFromTracklet(this) <= threshold) %is a good enough fit
                    [this, tracklets, points] = this.addSupport(tracklets, points, j); %add the point to tracklet
                    points(j).assocTracklet = this.trackletID; %add tracklet to point
                    curDistSkip = 0;
                elseif this.lastSupIdx == j                     
                    continue
                elseif curDistSkip < skipDistance
                    curDistSkip = curDistSkip + 1;
                    continue
                else
                    break %only find continuous
                end
            end
            this.meanDistance = this.getMeanDist(points);
            tracklets(this.trackletID) = this;
        end
    end
    
end

