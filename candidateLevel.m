function modelsi = candidateLevel(dets1, dets2, dets3, ind1, ind2, ind3) 
%detections for previous, current, and next frame
%indexes of those detections
    
    %indexes are important for weighting function creation, if not
    %supplied, defaults to distance of 1.
    if nargin < 6
        ind1 = 1;
        ind2 = 2;
        ind3 = 3;
    end
    dist21 = ind2 - ind1;
    dist32 = ind3 - ind2;

    %detect triplets
    model = struct('xFit', [], 'yFit', []);
    models(1:20) = model; %20 is arbitrary

    tripletCounter = 1;
    
    for j=1:size(dets2, 1) %for each detection in frame i
        centerX = dets2(j,1);
        centerY = dets2(j,2);
        frameWidth = 1280;
        frameHeight = 720;
        rad = (25 * dist21) + (25 * dist32); %25 pixels per frame of distance
        [x,y]=meshgrid(-(centerX-1):(frameWidth-centerX),-(centerY-1):(frameHeight-centerY));
        mask=((x.^2+y.^2)<=rad^2);
                
        for k=1:size(dets1,1) %for each detection in frame i-1
            if mask(round(dets1(k,2)), round(dets1(k,1))) == 1 %if detection within radius
                for p=1:size(dets3,1) %for each detection in frame i+1
                    if mask(round(dets3(p,2)), round(dets3(p,1))) == 1 %if detection within radius                       
                        
                        %frames are independent variable, position is dependent
                        models(tripletCounter).xFit = fit([ind1, ind2, ind3].',... %x dimension
                            [dets1(k,1), dets2(j,1), dets3(p,1)].','poly2');
                        models(tripletCounter).yFit = fit([ind1, ind2, ind3].',... %y dimension
                            [dets1(k,2), dets2(j,2), dets3(p,2)].','poly2');
                        
                        tripletCounter = tripletCounter + 1;                        
                    end
                end
            end     
        end
    end
    
    if tripletCounter == 1 %if no models were created
        modelsi = [];
    else
        modelsi = models(1:tripletCounter - 1); %remove extra empty models 
    end
end