function drawCurves (tracklets, points, xyModels, connections, emptyCourt, cent)
    %draws the plots on top of emptyCourt

    imshow(emptyCourt) %draw empty court image
 
    hold on
    
    %draw all detections in black
    for i=1:length(cent)
        for j=1:size(cent{i},1)
            plot([cent{i}(j,1), 1280], [cent{i}(j,2), 720], '*', 'MarkerSize', 4, 'MarkerEdgeColor', 'k');
        end
    end
    %draw all points in red
    for i=1:length(points)
        plot([points(i).xDim, 1280], [points(i).yDim, 720], '*', 'MarkerSize', 2, 'MarkerEdgeColor', 'r');
    end
    
    %draw all curves in blue
    dx = 5; %lower is more precise
    for i=1:length(xyModels)  
        %generate points array
        firstPoint = tracklets(xyModels(i).trackletID).model.xFit(points(tracklets(xyModels(i).trackletID).firstSupIdx).frame);
        lastPoint = tracklets(xyModels(i).trackletID).model.xFit(points(tracklets(xyModels(i).trackletID).lastSupIdx).frame);
  
        if lastPoint > firstPoint  %left to right
            xDistance = round(lastPoint - firstPoint + 1);

            %get dx to be even divider of xDistance
            numIntervals = ceil(xDistance / dx);
            dx = xDistance / numIntervals;

            predictedPoints = zeros(numIntervals, 2);
            counter = 1;
            for j=0:dx:xDistance
                predictedPoints(counter, 1) = j + firstPoint; 
                predictedPoints(counter, 2) = xyModels(i).model(j + firstPoint);
                counter = counter + 1;
            end
        else %right to left
            xDistance = round(firstPoint - lastPoint + 1);

            %get dx to be even divider of xDistance
            numIntervals = ceil(xDistance / dx);
            dx = xDistance / numIntervals;

            predictedPoints = zeros(numIntervals, 2);
            counter = 1;
            for j=0:dx:xDistance
                predictedPoints(counter, 1) = j + lastPoint; 
                predictedPoints(counter, 2) = xyModels(i).model(j + lastPoint);
                counter = counter + 1;
            end
        end
        xDims(1:length(predictedPoints),1) = 1280;
        yDims(1:length(predictedPoints),1) = 720;
        
        plot([predictedPoints(:,1), xDims], [predictedPoints(:,2), yDims], 'LineWidth', 3, 'Color', 'b'); %plot it
        xDims = [];
        yDims = [];
    end
    
    
    %draw all connections in yellow
    for i=1:length(connections)
        if ~isempty(connections(i).prevModel)
            fplot(connections(i).prevModel, [connections(i).prevStartPoint, connections(i).prevEndPoint], 'linewidth', 3, 'color', 'y');
        end
        if ~isempty(connections(i).nextModel)
            fplot(connections(i).nextModel, [connections(i).nextStartPoint, connections(i).nextEndPoint], 'linewidth', 3, 'color', 'y');
        end
    end
    
    hold off
end