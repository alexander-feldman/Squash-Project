function connections = connectTracklets (tracklets, points, xyModels)
    %generates connections between functions (yellow lines)

    connections(1:length(xyModels)) = struct(...
        'prevModel', [], 'prevStartPoint', [], 'prevEndPoint', [],...
        'nextModel', [], 'nextStartPoint', [], 'nextEndPoint', []);
    
    for i=1:length(xyModels) - 1 %for each xy model
        %get parameters of polynomial equation
        p1 = xyModels(i).model.p1;          % x ^ 2
        p2 = xyModels(i).model.p2;          % x
        p3 = xyModels(i).model.p3;          % y intercept
        q1 = xyModels(i + 1).model.p1;      % x ^ 2
        q2 = xyModels(i + 1).model.p2;      % x
        q3 = xyModels(i + 1).model.p3;      % y intercept
        
        syms x
        prevFunc = p1 * (x ^ 2) + p2 * x + p3; %equation of first model
        nextFunc = q1 * (x ^ 2) + q2 * x + q3; %equation of second model
        solx = solve(prevFunc == nextFunc, x, 'Real', true); %solve system of equations to find possible intercepts
        
        %make endpoints actual function endpoints, not last support point
        prevFuncIntervalStart = tracklets(xyModels(i).trackletID).model.xFit(points(tracklets(xyModels(i).trackletID).lastSupIdx).frame);
        nextFuncIntervalStart = tracklets(xyModels(i + 1).trackletID).model.xFit(points(tracklets(xyModels(i + 1).trackletID).firstSupIdx).frame);
        
        intersection = [];
        distance = inf; %start at inf, relax later
        for j=1:length(solx) %find the closest solution to equation
            if distance > abs(solx(j) - prevFuncIntervalStart) + abs(solx(j) - nextFuncIntervalStart)
                distance = abs(solx(j) - prevFuncIntervalStart) + abs(solx(j) - nextFuncIntervalStart);
                intersection = double(solx(j)); %relax
            end
        end
        
        if points(tracklets(xyModels(i).trackletID).lastSupIdx).xDim >... %left to right
                points(tracklets(xyModels(i).trackletID).firstSupIdx).xDim
            if intersection > prevFuncIntervalStart %if doesn't intersect in midde of func
                if intersection > prevFuncIntervalStart %order interval from least to greatest
                    connections(i).prevModel = prevFunc;
                    connections(i).prevStartPoint = prevFuncIntervalStart;
                    connections(i).prevEndPoint = intersection;
                else
                    connections(i).prevModel = prevFunc;
                    connections(i).prevStartPoint = intersection;
                    connections(i).prevEndPoint = prevFuncIntervalStart;
                end
            end
        else %right to left
            if intersection < prevFuncIntervalStart %if doesn't intersect in midde of func
                if intersection > prevFuncIntervalStart %order interval from least to greatest
                    connections(i).prevModel = prevFunc;
                    connections(i).prevStartPoint = prevFuncIntervalStart;
                    connections(i).prevEndPoint = intersection;
                else
                    connections(i).prevModel = prevFunc;
                    connections(i).prevStartPoint = intersection;
                    connections(i).prevEndPoint = prevFuncIntervalStart;
                end
            end
        end
        
        %same for nextFunc
        if points(tracklets(xyModels(i + 1).trackletID).lastSupIdx).xDim >... %left to right
                points(tracklets(xyModels(i + 1).trackletID).firstSupIdx).xDim
            if intersection < nextFuncIntervalStart %if doesn't intersect in midde of func
                if intersection > nextFuncIntervalStart  %order interval from least to greatest 
                    connections(i).nextModel = nextFunc;
                    connections(i).nextStartPoint = nextFuncIntervalStart;
                    connections(i).nextEndPoint = intersection;
                else
                    connections(i).nextModel = nextFunc;
                    connections(i).nextStartPoint = intersection;
                    connections(i).nextEndPoint = nextFuncIntervalStart;
                end
            end
        else %right to left
            if intersection > nextFuncIntervalStart %if doesn't intersect in midde of func
                if intersection > nextFuncIntervalStart  %order interval from least to greatest 
                    connections(i).nextModel = nextFunc;
                    connections(i).nextStartPoint = nextFuncIntervalStart;
                    connections(i).nextEndPoint = intersection;
                else
                    connections(i).nextModel = nextFunc;
                    connections(i).nextStartPoint = intersection;
                    connections(i).nextEndPoint = nextFuncIntervalStart;
                end
            end
        end
        
    end
end