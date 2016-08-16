function [tracklets, points, xyModels] = improveTracklets(tracklets, points)
    %in future versions also look at all detections (cents), not just points
    
    %clean up list of supports
    for i=1:length(tracklets)
        for j=1:length(tracklets(i).supports)
            curSupport = tracklets(i).supports(j);
            %if point's pointer doesn't match this
            if curSupport > 0 && ~ tracklets(points(curSupport).assocTracklet).trackletID == tracklets(i).trackletID
                [tracklets(i), points] = tracklets(i).removeSupport(curSupport, points); %remove the support
            end
        end
    end
    
    %WHILE new supports were found, or mean distance decresed
    %Didn't finish implementing this while loop. Had trouble making it all mesh
    loopCounter = 0;
    while loopCounter < 1 
        for i=1:length(tracklets) %for each tracklet
            if tracklets(i).numSupports > 0 %once a tracklet has no supports it is dead.     
                [tracklets, points] = tracklets(i).scoopUp(tracklets, points);
            end
        end
        loopCounter = loopCounter + 1;
    end
    
    %convert models from frame number vs X and frame number vs Y 
    %to X vs Y
    xyModels = struct('model', [], 'trackletID', []);
    minSupports = 4;
    xyModels(1:sum([tracklets.numSupports] > minSupports)) = struct('model', [], 'trackletID', []);
    counter = 1;
    for i=1:length(tracklets)
        if tracklets(i).numSupports > minSupports
            xDims = zeros(tracklets(i).numSupports, 1);
            yDims = zeros(tracklets(i).numSupports, 1);
            dimCounter = 1;
            for j=1:length(tracklets(i).supports)
                if tracklets(i).supports(j) > 0
                    xDims(dimCounter) = points(tracklets(i).supports(j)).xDim;
                    yDims(dimCounter) = points(tracklets(i).supports(j)).yDim;
                    dimCounter = dimCounter + 1;
                end
            end
            xyModels(counter).model = fit(xDims, yDims, 'poly2');
            xyModels(counter).trackletID = i;
            counter = counter + 1;
        end
        
    end
end