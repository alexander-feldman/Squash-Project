function [thePoints, cent] = generatePoints(vid1, vid2)
    %candidate level
    %generate detections

    cent = cell(size(vid2,3),1); %initialize a cell to hold all detections in a frame

    %find centroids of detections
    for i=1:size(vid2,3) - 1 %one frame of buffer on end
        cent{i} = blobItUp(vid1(:,:,i), vid2(:,:,i));
    end
    
    counter = 1;
    points(1:2 * size(vid1, 3)) = Point(); %initialize, twice number of frames is arbitrary
    
    %one frame buffer on either end, points must have support on either side
    %if size of cent is 0,loop will not run. 
    for i=2:size(cent) - 1
        for j=1:size(cent{i - 1}, 1)            %for each detection in i - 1
            for k=1:size(cent{i}, 1)            %for each detection in i
                for m=1:size(cent{i + 1}, 1)    %for each detection in i + 1
                    noModel = false;            %flag to indicate if point has model
                    
                    cent1 = cent{i - 1}(j,:);
                    cent2 = cent{i}(k,:);
                    cent3 = cent{i + 1}(m,:);
                    
                    %if cents are close enough, fit a model
                    model = candidateLevel(cent1, cent2, cent3, i - 1, i, i + 1);
                    if size(model,1) == 0 %if no model was created (detections were too far apart)
                        noModel = true;
                    end
                    
                    repeatedPoint = false; %flag indicates if point is repeat
                    if ~noModel %if a model was found
                        %don't go below index of 1 for low numbers
                        for p=1:min(counter - 1, 3) %3 is arbitrary, test previous points to see if repeated point
                            if(points(counter - p).xDim == cent2(1) && points(counter - p).yDim == cent2(2)) %if already included noModel version
                                points(counter - p) = Point(cent2(1),cent2(2),i,model); %overwrite that version
                                repeatedPoint = true; %point is repeat, don't increment counter
                            end
                        end
                        if ~repeatedPoint %if point is not repeat
                            points(counter) = Point(cent2(1),cent2(2),i,model); %add point
                            counter = counter + 1; %increment counter
                        end
                    end
                    
                    if noModel %if no model was found
                        %don't go below index of 1 for low numbers
                        for p=1:min(counter - 1, 3) %3 is arbitrary, test previous points to see if repeated point
                            if(points(counter - p).xDim == cent2(1) && points(counter - p).yDim == cent2(2))
                                repeatedPoint = true; %point is repeat
                            end
                        end
                        if ~repeatedPoint %if point is not repeat
                            points(counter) = Point(cent2(1), cent2(2), i); %create a point without model
                            counter = counter + 1;
                        end
                    end
                end
            end
        end
    end
    
    thePoints = points(1:counter - 1);
end