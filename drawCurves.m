function drawCurves (tracklets, points, xyModels, emptyCourt, cent)
    minLength = 4; %min tracklet length
    imshow(emptyCourt)
 
    hold on

    for i=1:length(cent)
        for j=1:size(cent{i},1)
            plot([cent{i}(j,1), 1280], [cent{i}(j,2), 720], '*', 'MarkerSize', 4, 'MarkerEdgeColor', 'k');      
        end
    end
    for i=1:length(points)
        plot([points(i).xDim, 1280], [points(i).yDim, 720], '*', 'MarkerSize', 2, 'MarkerEdgeColor', 'r');
    end
    
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
    
    
    %draw connections from xyModels
    for i=1:length(xyModels) - 1
        p1 = xyModels(i).model.p1;
        p2 = xyModels(i).model.p2;
        p3 = xyModels(i).model.p3;
        q1 = xyModels(i + 1).model.p1;
        q2 = xyModels(i + 1).model.p2;
        q3 = xyModels(i + 1).model.p3;
        
        syms x
        prevFunc = p1 * (x ^ 2) + p2 * x + p3;
        nextFunc = q1 * (x ^ 2) + q2 * x + q3;
        solx = solve(prevFunc == nextFunc, x, 'Real', true);
        
        %make endpoints actual function endpoints, not last support point
        prevFuncIntervalStart = tracklets(xyModels(i).trackletID).model.xFit(points(tracklets(xyModels(i).trackletID).lastSupIdx).frame);
        nextFuncIntervalStart = tracklets(xyModels(i + 1).trackletID).model.xFit(points(tracklets(xyModels(i + 1).trackletID).firstSupIdx).frame);
        
        intersection = [];
        distance = inf;
        for j=1:length(solx) %find the closest solution to equation
            if distance > abs(solx(j) - prevFuncIntervalStart) + abs(solx(j) - nextFuncIntervalStart)
                distance = abs(solx(j) - prevFuncIntervalStart) + abs(solx(j) - nextFuncIntervalStart);
                intersection = double(solx(j));
            end
        end
        
        %if they don't intersect in middle of function
        if points(tracklets(xyModels(i).trackletID).lastSupIdx).xDim >... %left to right
                points(tracklets(xyModels(i).trackletID).firstSupIdx).xDim
            if intersection > prevFuncIntervalStart %if doesn't intersect in midde of func
                if intersection > prevFuncIntervalStart %order interval from least to greatest
                    fplot(prevFunc, [prevFuncIntervalStart, intersection], 'linewidth', 3, 'color', 'y'); %plot the curve in between
                else
                    fplot(prevFunc, [intersection, prevFuncIntervalStart], 'linewidth', 3, 'color', 'y'); %plot the curve in between
                end
            end
        else %right to left
            if intersection < prevFuncIntervalStart %if doesn't intersect in midde of func
                if intersection > prevFuncIntervalStart %order interval from least to greatest
                    fplot(prevFunc, [prevFuncIntervalStart, intersection], 'linewidth', 3, 'color', 'y'); %plot the curve in between
                else
                    fplot(prevFunc, [intersection, prevFuncIntervalStart], 'linewidth', 3, 'color', 'y'); %plot the curve in between
                end
            end
        end
        
        %same for nextFunc
        if points(tracklets(xyModels(i + 1).trackletID).lastSupIdx).xDim >... %left to right
                points(tracklets(xyModels(i + 1).trackletID).firstSupIdx).xDim
            if intersection < nextFuncIntervalStart %if doesn't intersect in midde of func
                if intersection > nextFuncIntervalStart  %order interval from least to greatest 
                    fplot(nextFunc, [nextFuncIntervalStart, intersection], 'linewidth', 3, 'color', 'y'); %plot the curve in between
                else
                    fplot(nextFunc, [intersection, nextFuncIntervalStart], 'linewidth', 3, 'color', 'y'); %plot the curve in between
                end
            end
        else %right to left
            if intersection > nextFuncIntervalStart %if doesn't intersect in midde of func
                if intersection > nextFuncIntervalStart  %order interval from least to greatest 
                    fplot(nextFunc, [nextFuncIntervalStart, intersection], 'linewidth', 3, 'color', 'y'); %plot the curve in between
                else
                    fplot(nextFunc, [intersection, nextFuncIntervalStart], 'linewidth', 3, 'color', 'y'); %plot the curve in between
                end
            end
        end
        
    end

    hold off
end