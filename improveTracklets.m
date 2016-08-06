function [improvedTracklets, points] = improveTracklets(tracklets, points)
    loopCounter = 0;
    
    while loopCounter < 1 %does fancy tests (new supports, mean distance)
        for i=1:length(tracklets) %for each tracklet
            if ~ tracklets(i).numSupports == 0 %once a tracklet has no supports it is dead.    
                
                
                for j=1:length(tracklets(i).supports)
                    %clean up list of supports, 
                    %if point's pointer doesn't match this
                    curSupport = tracklets(i).supports(j);
                    if curSupport > 0 && ~ tracklets(points(curSupport).assocTracklet).trackletID == tracklets(i).trackletID
                        [tracklets(i), points] = tracklets(i).removeSupport(j); %remove the support
                    end
                end
                
                if ~ tracklets(i).numSupports == 0 %check again
                    [tracklets, points] = tracklets(i).scoopUp(tracklets, points);
                end
            end
        end
        loopCounter = loopCounter + 1;
    end
    improvedTracklets = tracklets;
end