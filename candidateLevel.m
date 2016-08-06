function modelsi = candidateLevel(dets1, dets2, dets3, ind1, ind2, ind3) %detections for previous, current(i), and next frame (centroids)
    
    %indeces are important for weighting function creation, if not
    %supplied, defaults to distance of 1.
    if nargin < 6
        ind1 = 1;
        ind2 = 2;
        ind3 = 3;
    end
    dist21 = ind2 - ind1;
    dist32 = ind3 - ind2;

%     %format inputs
%     dets1 = uint32(dets1);
%     dets2 = uint32(dets2);
%     dets3 = uint32(dets3);

    %detect triplets
    model = struct('xFit', [], 'yFit', []);
    models(1:20) = model; %20 is arbitrary

    tripletCounter = 1;
    
    for j=1:size(dets2, 1) %for each detection in frame i
        cx = dets2(j,1);
        cy = dets2(j,2);
        ix = 1280;
        iy = 720;
        rad = (25 * dist21) + (25 * dist32); %25 pixels per frame of distance
        [x,y]=meshgrid(-(cx-1):(ix-cx),-(cy-1):(iy-cy));
        mask=((x.^2+y.^2)<=rad^2);
                
        for k=1:size(dets1,1) %for each detection in frame i-1
            if mask(round(dets1(k,2)), round(dets1(k,1))) == 1 %if detection within radius
                for p=1:size(dets3,1) %for each detection in frame i+1
                    if mask(round(dets3(p,2)), round(dets3(p,1))) == 1 %if detection within radius
                        %{                                              
                        %create a model
                        %fps = 120; %frames per second
                        timeInterval = 1; %arbitrary
            
                        
                        %Position: pk = p1 + ?k * v1 + ((?k)^2) / 2) * a
                        %Velocity: v1 = ((p2 - p1)/?k21) - ((?k21 * a) / 2)
                        %Acceleration: a  = 2 * ((?k21 * (p3 - p2) - ?k32 * (p2 - p1))
                        %                   / (?k21 * ?k32 * (?k21d+ ?k32))
                        
                        %X dimension
                        accelNumX = 2 * (((dist21/timeInterval) .* (double(dets3(p,1)) - double(dets2(j,1))) - ...
                                        ((dist32/timeInterval) .* (double(dets2(j,1)) - double(dets1(k,1))))));
                        accelDenomX = ((dist32/timeInterval) .* (dist21/timeInterval) .* ((dist32/timeInterval) + ...
                                      (dist21/timeInterval)));
                        accelX = accelNumX ./ accelDenomX;
                        
                        velocInitX = ((double(dets2(j,1)) - double(dets1(k,1))) ./dist21) - ((dist21 .* accelX) ./ 2);

                        
                        %Y dimension
                        accelNumY = 2 * (((dist21/timeInterval) .* (double(dets3(p,2)) - double(dets2(j,2))) - ...
                                        ((dist32/timeInterval) .* (double(dets2(j,2)) - double(dets1(k,2))))));
                        accelDenomY = ((dist32/timeInterval) .* (dist21/timeInterval) .* ((dist32/timeInterval) + ...
                                      (dist21/timeInterval)));
                        accelY = accelNumY ./ accelDenomY;
                        
                        velocInitY = ((double(dets2(j,2)) - double(dets1(k,2))) ./ dist21) - ((dist21 .* accelY) ./ 2);
                        
                        %frameDiff = 1; %how far ahead to predict
                        %pos = double(dets1) + (frameDiff * velocInit) + ((power(frameDiff, 2) / 2) * accel);
                        
                        model(tripletCounter, 1) = accelX;
                        model(tripletCounter, 2) = accelY;
                        model(tripletCounter, 3) = velocInitX; 
                        model(tripletCounter, 4) = velocInitY; 
                        model(tripletCounter, 5:6) = dets2(j,:); 
                        %}
                        
                        models(tripletCounter).xFit = fit([ind1, ind2, ind3].',[dets1(k,1), dets2(j,1), dets3(p,1)].','poly2');
                        models(tripletCounter).yFit = fit([ind1, ind2, ind3].',[dets1(k,2), dets2(j,2), dets3(p,2)].','poly2');
                        
                        tripletCounter = tripletCounter + 1;                        
                    end
                end
            end     
        end
    end
    
    if tripletCounter == 1
        modelsi = [];
    else
        modelsi = models(1:tripletCounter - 1);
    end
end