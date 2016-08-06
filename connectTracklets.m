function [tracklets, points, xyModels] = connectTracklets (tracklets, points)
    
    slopeThreshold = 5; %degrees
    
    %connect tracks along a line
    for i=1:length(tracklets)
        if tracklets(i).numSupports > 1
            
            prevTrack = tracklets(i);
            for j=i + 1:length(tracklets)
                if tracklets(j).numSupports > 1
                    
                    nextTrack = tracklets(j);
                    
                    %calculate slope of prev track-improve this for curves?
                    prevTrackXDistance = points(prevTrack.firstSupIdx).xDim - points(prevTrack.lastSupIdx).xDim;
                    prevTrackYDistance = points(prevTrack.firstSupIdx).yDim - points(prevTrack.lastSupIdx).yDim;
                    prevTrackSlope = atand(prevTrackYDistance / prevTrackXDistance); %degrees
                    
                    %calculate slope of next track
                    nextTrackXDistance = points(nextTrack.firstSupIdx).xDim - points(nextTrack.lastSupIdx).xDim;
                    nextTrackYDistance = points(nextTrack.firstSupIdx).yDim - points(nextTrack.lastSupIdx).yDim;
                    nextTrackSlope = atand(nextTrackYDistance / nextTrackXDistance); %degrees
                    
                    shortestPathXDistance = points(nextTrack.firstSupIdx).xDim - points(prevTrack.lastSupIdx).xDim;
                    shortestPathYDistance = points(nextTrack.firstSupIdx).yDim - points(prevTrack.lastSupIdx).yDim;
                    shortestPathSlope = atand(shortestPathYDistance / shortestPathXDistance);
                    
                    %if slopes are similar, give all points in next to prev
                    if abs(prevTrackSlope - shortestPathSlope) < slopeThreshold &&... % if slopes are similar
                            abs(nextTrackSlope - shortestPathSlope) < slopeThreshold
                        
                        for k=1:length(nextTrack.supports)
                            if nextTrack.supports(k) > 0
                                toAdd = nextTrack.supports(k); %add it
                                [prevTrack, tracklets, points] = prevTrack.addSupport(tracklets, points, toAdd);
                            end
                        end
                        
                    else
                        disp('distance too far');
                    end
                    tracklets(i) = prevTrack;
                    tracklets(j) = nextTrack;
                    
                end
                
            end
            
        end
        i = i - 1;
    end
    
    %add extentions to connect all tracks
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