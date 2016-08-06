function [tracklets, points] = generateTracklets(points)
    tracklets(1:length(points)) = Tracklet();    
    counter = 0;
    
    for i=1:length(points)
        if points(i).hasModel == true %if the point has a model
            counter = counter + 1;
            %update tracklet
            tracklets(counter).trackletID = counter;                    %set ID
            tracklets(counter).model = points(i).internalModel;   %set model
            tracklets(counter).supports = zeros(50,1);            %initialize supports
            tracklets(counter).supports(1) = i;                   %set first support
            tracklets(counter).numSupports = 1;                   %set num supports
            tracklets(counter).meanDistance = 0;                  %set mean distance
            tracklets(counter).firstSupIdx = i;                   %set index
            tracklets(counter).lastSupIdx = i;                    %set index

            %update point
            points(i).assocTracklet = counter;         %set assoc tracklet
        end
    end
    
    tracklets = tracklets(1:counter);
end